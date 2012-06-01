//
//  BPRegion.h
//  BorderPatrol
//
//  Created by Jim Puls on 5/30/12.
//  Copyright (c) 2012 Square, Inc. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@class BPPolygon;

@interface BPRegion : CLRegion

+ (BPRegion *)regionWithContentsOfURL:(NSURL *)url;
+ (BPRegion *)regionWithPolygons:(NSSet *)polygons identifier:(NSString *)identifier;

@property (nonatomic, readonly, strong) NSSet *polygons;

- (id)initWithPolygons:(NSSet *)polygons identifier:(NSString *)identifier;

@end
