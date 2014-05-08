//
//  BPPolygonTests.m
//  BorderPatrol
//
//  Created by Jim Puls on 5/30/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import "BPPolygonTests.h"
#import "BPPolygon.h"

@implementation BPPolygonTests {
    BPPolygon *testPolygon;
    BPPolygon *testPolygon2;
}

- (void)setUp;
{
    CLLocationCoordinate2D coordinates[3] = {
        CLLocationCoordinate2DMake(-10, 0),
        CLLocationCoordinate2DMake(10, 0),
        CLLocationCoordinate2DMake(0, 10)
    };
    
    NSArray *locations = @[[[CLLocation alloc] initWithLatitude:-10 longitude:0],
                           [[CLLocation alloc] initWithLatitude:10 longitude:0],
                           [[CLLocation alloc] initWithLatitude:0 longitude:10]];
    
    testPolygon = [BPPolygon polygonWithCoordinates:coordinates count:3];
    testPolygon2 = [BPPolygon polygonWithLocations:locations];
    
}

- (void)testContainsCoordinateInPolygon;
{
    STAssertTrue([testPolygon containsCoordinate:CLLocationCoordinate2DMake(0.5, 0.5)], @"Should contain coordinate");
    STAssertTrue([testPolygon containsCoordinate:CLLocationCoordinate2DMake(0, 5)], @"Should contain coordinate");
    STAssertTrue([testPolygon containsCoordinate:CLLocationCoordinate2DMake(-1, 3)], @"Should contain coordinate");
    
    
    STAssertTrue([testPolygon2 containsCoordinate:CLLocationCoordinate2DMake(0.5, 0.5)], @"Should contain coordinate");
    STAssertTrue([testPolygon2 containsCoordinate:CLLocationCoordinate2DMake(0, 5)], @"Should contain coordinate");
    STAssertTrue([testPolygon2 containsCoordinate:CLLocationCoordinate2DMake(-1, 3)], @"Should contain coordinate");
}

- (void)testContainsCoordinateOnSlopes;
{
    STAssertTrue([testPolygon containsCoordinate:CLLocationCoordinate2DMake(5, 5)], @"Should contain coordinate");
    STAssertTrue([testPolygon containsCoordinate:CLLocationCoordinate2DMake(4.999999, 4.999999)], @"Should contain coordinate");
    STAssertFalse([testPolygon containsCoordinate:CLLocationCoordinate2DMake(5.000001, 5.000001)], @"Should not contain coordinate");
    STAssertTrue([testPolygon containsCoordinate:CLLocationCoordinate2DMake(0, 0)], @"Should contain coordinate");
    STAssertTrue([testPolygon containsCoordinate:CLLocationCoordinate2DMake(0.000001, 0.000001)], @"Should contain coordinate");
    STAssertFalse([testPolygon containsCoordinate:CLLocationCoordinate2DMake(-0.000001, -0.000001)], @"Should not contain coordinate");
    
    STAssertTrue([testPolygon2 containsCoordinate:CLLocationCoordinate2DMake(5, 5)], @"Should contain coordinate");
    STAssertTrue([testPolygon2 containsCoordinate:CLLocationCoordinate2DMake(4.999999, 4.999999)], @"Should contain coordinate");
    STAssertFalse([testPolygon2 containsCoordinate:CLLocationCoordinate2DMake(5.000001, 5.000001)], @"Should not contain coordinate");
    STAssertTrue([testPolygon2 containsCoordinate:CLLocationCoordinate2DMake(0, 0)], @"Should contain coordinate");
    STAssertTrue([testPolygon2 containsCoordinate:CLLocationCoordinate2DMake(0.000001, 0.000001)], @"Should contain coordinate");
    STAssertFalse([testPolygon2 containsCoordinate:CLLocationCoordinate2DMake(-0.000001, -0.000001)], @"Should not contain coordinate");
}

- (void)testContainsCoordinateOnVertices;
{
    STAssertTrue([testPolygon containsCoordinate:CLLocationCoordinate2DMake(-10, 0)], @"Should contain coordinate");
    STAssertTrue([testPolygon containsCoordinate:CLLocationCoordinate2DMake(0, 10)], @"Should contain coordinate");
    STAssertTrue([testPolygon containsCoordinate:CLLocationCoordinate2DMake(10, 0)], @"Should contain coordinate");
    
    STAssertTrue([testPolygon2 containsCoordinate:CLLocationCoordinate2DMake(-10, 0)], @"Should contain coordinate");
    STAssertTrue([testPolygon2 containsCoordinate:CLLocationCoordinate2DMake(0, 10)], @"Should contain coordinate");
    STAssertTrue([testPolygon2 containsCoordinate:CLLocationCoordinate2DMake(10, 0)], @"Should contain coordinate");
}

- (void)testExcludesCoordinateOutsidePolygon;
{
    STAssertFalse([testPolygon containsCoordinate:CLLocationCoordinate2DMake(9, 5)], @"Should not contain coordinate");
    STAssertFalse([testPolygon containsCoordinate:CLLocationCoordinate2DMake(-5, 8)], @"Should not contain coordinate");
    STAssertFalse([testPolygon containsCoordinate:CLLocationCoordinate2DMake(-10, -1)], @"Should not contain coordinate");
    STAssertFalse([testPolygon containsCoordinate:CLLocationCoordinate2DMake(-20, -20)], @"Should not contain coordinate");
    
    STAssertFalse([testPolygon2 containsCoordinate:CLLocationCoordinate2DMake(9, 5)], @"Should not contain coordinate");
    STAssertFalse([testPolygon2 containsCoordinate:CLLocationCoordinate2DMake(-5, 8)], @"Should not contain coordinate");
    STAssertFalse([testPolygon2 containsCoordinate:CLLocationCoordinate2DMake(-10, -1)], @"Should not contain coordinate");
    STAssertFalse([testPolygon2 containsCoordinate:CLLocationCoordinate2DMake(-20, -20)], @"Should not contain coordinate");
}

- (void)testCoordinatesOnFunkyShapes;
{
    CLLocationCoordinate2D coordinates[8] = {
        CLLocationCoordinate2DMake(0, -15),
        CLLocationCoordinate2DMake(10, -15),
        CLLocationCoordinate2DMake(10, -5),
        CLLocationCoordinate2DMake(20, -5),
        CLLocationCoordinate2DMake(20, 5),
        CLLocationCoordinate2DMake(10, 5),
        CLLocationCoordinate2DMake(10, 15),
        CLLocationCoordinate2DMake(0, 15)
    };
    BPPolygon *otherTestPolygon = [BPPolygon polygonWithCoordinates:coordinates count:8];
    
    NSMutableArray *locations = [[NSMutableArray alloc] initWithCapacity:8];
    for (int i = 0; i < 8; i++) {
        CLLocationCoordinate2D coordinate = coordinates[i];
        [locations addObject:[[CLLocation alloc] initWithCoordinate:coordinate
                                                           altitude:0
                                                 horizontalAccuracy:0
                                                   verticalAccuracy:0
                                                             course:0
                                                              speed:0
                                                          timestamp:0]];
    }
    
    BPPolygon *otherTestPolygon2 = [BPPolygon polygonWithLocations:locations];
    
    STAssertTrue([otherTestPolygon containsCoordinate:CLLocationCoordinate2DMake(5, 5)], @"Should contain coordinate");
    STAssertFalse([otherTestPolygon containsCoordinate:CLLocationCoordinate2DMake(15, -10)], @"Should not contain coordinate");
    STAssertFalse([otherTestPolygon containsCoordinate:CLLocationCoordinate2DMake(5, -20)], @"Should not contain coordinate");
    STAssertFalse([otherTestPolygon containsCoordinate:CLLocationCoordinate2DMake(20, -15)], @"Should not contain coordinate");
    
    STAssertTrue([otherTestPolygon2 containsCoordinate:CLLocationCoordinate2DMake(5, 5)], @"Should contain coordinate");
    STAssertFalse([otherTestPolygon2 containsCoordinate:CLLocationCoordinate2DMake(15, -10)], @"Should not contain coordinate");
    STAssertFalse([otherTestPolygon2 containsCoordinate:CLLocationCoordinate2DMake(5, -20)], @"Should not contain coordinate");
    STAssertFalse([otherTestPolygon2 containsCoordinate:CLLocationCoordinate2DMake(20, -15)], @"Should not contain coordinate");
}

@end
