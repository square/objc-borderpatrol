//
//  BPRegion.m
//  BorderPatrol
//
//  Created by Jim Puls on 5/30/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import "BPRegion.h"
#import "BPPolygon.h"

@interface BPRegion () <NSXMLParserDelegate>

@property (nonatomic, strong) NSString *overriddenIdentifier;

// Parsing state
@property (nonatomic, strong) NSMutableString *currentPolygonData;
@property (nonatomic, strong, readwrite) NSMutableSet *currentPolygons;
@property (nonatomic) BOOL parsingPolygon;

@end

@implementation BPRegion

@synthesize polygons = _polygons;
@synthesize overriddenIdentifier = _overriddenIdentifier;
@synthesize currentPolygonData = _currentPolygonData;
@synthesize currentPolygons = _currentPolygons;
@synthesize parsingPolygon = _parsingPolygon;

+ (BPRegion *)regionWithContentsOfURL:(NSURL *)url;
{
    NSAssert(url, @"Need a URL to create region");
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    BPRegion *region = [[self alloc] initWithPolygons:nil identifier:nil];
    parser.delegate = region;
    [parser parse];
    
    return region;
}

+ (BPRegion *)regionWithPolygons:(NSSet *)polygons identifier:(NSString *)identifier;
{
    return [[self alloc] initWithPolygons:polygons identifier:identifier];
}

- (id)initWithPolygons:(NSSet *)polygons identifier:(NSString *)identifier;
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _polygons = polygons;
    _overriddenIdentifier = identifier;
    
    return self;
}

- (NSString *)identifier;
{
    return self.overriddenIdentifier;
}

- (BOOL)containsCoordinate:(CLLocationCoordinate2D)coordinate;
{
    for (BPPolygon *polygon in self.polygons) {
        if ([polygon containsCoordinate:coordinate]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser;
{
    NSAssert(!_polygons, @"Started parsing after polygons had been set");
    self.currentPolygons = [NSMutableSet set];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    if ([elementName isEqualToString:@"Polygon"]) {
        self.parsingPolygon = YES;
    }
    if ([elementName isEqualToString:@"coordinates"] && self.parsingPolygon) {
        self.currentPolygonData = [NSMutableString string];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;
{
    [self.currentPolygonData appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    if ([elementName isEqualToString:@"Polygon"]) {
        self.parsingPolygon = NO;
    }
    if ([elementName isEqualToString:@"coordinates"]) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([-0-9.]+),([-0-9.]+)(,[-0-9.]+)\\s*" options:0 error:NULL];
        NSArray *matches = [regex matchesInString:self.currentPolygonData options:0 range:NSMakeRange(0, self.currentPolygonData.length)];
        
        CLLocationCoordinate2D coordinates[matches.count];
        NSUInteger index = 0;
        
        for (NSTextCheckingResult *result in matches) {
            CLLocationDegrees latitude = [[self.currentPolygonData substringWithRange:[result rangeAtIndex:2]] doubleValue];
            CLLocationDegrees longitude = [[self.currentPolygonData substringWithRange:[result rangeAtIndex:1]] doubleValue];
            coordinates[index++] = CLLocationCoordinate2DMake(latitude, longitude);
        }
        self.currentPolygonData = nil;
        
        BPPolygon *newPolygon = [BPPolygon polygonWithCoordinates:coordinates count:index];
        [self.currentPolygons addObject:newPolygon];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser;
{
    _polygons = [NSSet setWithSet:self.currentPolygons];
    self.currentPolygons = nil;
}

@end
