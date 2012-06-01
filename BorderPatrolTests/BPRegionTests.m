//
//  BPRegionTests.m
//  BorderPatrol
//
//  Created by Jim Puls on 5/30/12.
//  Copyright (c) 2012 Square, Inc. All rights reserved.
//

#import "BPRegionTests.h"
#import "BPRegion.h"
#import "BPPolygon.h"

#include <sys/resource.h>
#include <sys/time.h>

@implementation BPRegionTests

- (void)testRegionWithContentsOfColorado;
{
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"colorado-test" withExtension:@"kml"];
    STAssertNotNil(url, @"Failed to find colorado KML file");
    
    BPRegion *region = [BPRegion regionWithContentsOfURL:url];
    STAssertNotNil(region, @"Failed to create a region from a KML file");
    
    STAssertEquals(region.polygons.count, 1U, @"Should be one polygon in Colorado");
    STAssertEqualObjects([[region.polygons anyObject] class], [BPPolygon class], @"Polygons in regions should be of type BPPolygon");
    
    STAssertTrue([region containsCoordinate:CLLocationCoordinate2DMake(40, -105)], @"Coordinate should be in Colorado");
}

- (void)testRegionWithContentsOfSeveralContinents;
{
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"multi-polygon-test" withExtension:@"kml"];
    STAssertNotNil(url, @"Failed to find multi polygons KML file");
    
    BPRegion *region = [BPRegion regionWithContentsOfURL:url];
    STAssertNotNil(region, @"Failed to create a region from a KML file");
    
    STAssertEquals(region.polygons.count, 3U, @"Should be three polygons in the test file");
    STAssertEqualObjects([[region.polygons anyObject] class], [BPPolygon class], @"Polygons in regions should be of type BPPolygon");
}

- (BPPolygon *)polygonWithOffset:(CLLocationDegrees)start;
{
    CLLocationCoordinate2D coordinates[4] = {
        CLLocationCoordinate2DMake(start, start),
        CLLocationCoordinate2DMake(start + 10, start),
        CLLocationCoordinate2DMake(start + 10, start + 10),
        CLLocationCoordinate2DMake(start, start + 10)
    };
    return [BPPolygon polygonWithCoordinates:coordinates count:4];
}

- (void)testContainsCoordinate;
{
    NSSet *polygons = [NSSet setWithObjects:[self polygonWithOffset:0], [self polygonWithOffset:30], nil];
    BPRegion *region = [BPRegion regionWithPolygons:polygons identifier:nil];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(1, 2);
    STAssertTrue([region containsCoordinate:coordinate], @"Region that contains a coordinate should return true");

    coordinate = CLLocationCoordinate2DMake(-1, -2);
    STAssertFalse([region containsCoordinate:coordinate], @"Region that doesn't contain a coordinate should return false");

    coordinate = CLLocationCoordinate2DMake(35, 35);
    STAssertTrue([region containsCoordinate:coordinate], @"Region that contains a coordinate in another polygon should return true");
}

- (void)testBenchmarks;
{
    BPRegion *colorado = [BPRegion regionWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"colorado-test" withExtension:@"kml"]];
    BPRegion *multiPolygon = [BPRegion regionWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"multi-polygon-test" withExtension:@"kml"]];
    
    void (^benchmark)(NSString *, void (^)()) = ^(NSString *label, void (^code)()) {
        struct rusage usage, usageAfter;
        CFAbsoluteTime absoluteTime, absoluteTimeAfter;

        getrusage(RUSAGE_SELF, &usage);
        absoluteTime = CFAbsoluteTimeGetCurrent();

        code();
        
        getrusage(RUSAGE_SELF, &usageAfter);
        absoluteTimeAfter = CFAbsoluteTimeGetCurrent();
        
        long userSec = usageAfter.ru_utime.tv_sec - usage.ru_utime.tv_sec;
        long userUsec = usageAfter.ru_utime.tv_usec - usage.ru_utime.tv_usec;
        long sysSec = usageAfter.ru_stime.tv_sec - usage.ru_stime.tv_sec;
        long sysUsec = usageAfter.ru_stime.tv_usec - usage.ru_stime.tv_usec;
        long totalSec = userSec + sysSec;
        long totalUsec = userUsec + sysUsec;
        
        if (totalUsec > 1000000) {
            totalUsec -= 1000000;
            totalSec += 1;
        }
        
        CFAbsoluteTime real = absoluteTimeAfter - absoluteTime;
        
        NSLog(@"%@ %3ld.%06ld %3ld.%06ld %3ld.%06ld (%3.06f)", label, userSec, userUsec, sysSec, sysUsec, totalSec, totalUsec, real);
    };
    
    NSLog(@"                    user     system     total       real");
    benchmark(@"     Colorado", ^{
        for (int index = 0; index < 10000; index++) {
            CLLocationCoordinate2D randomPoint = CLLocationCoordinate2DMake(random() % 180 - 90, random() % 360 - 180);
            (void)[colorado containsCoordinate:randomPoint];
        }
    });
    benchmark(@"Multi Polygon", ^{
        for (int index = 0; index < 10000; index++) {
            CLLocationCoordinate2D randomPoint = CLLocationCoordinate2DMake(random() % 180 - 90, random() % 360 - 180);
            (void)[multiPolygon containsCoordinate:randomPoint];
        }
    });
}

@end
