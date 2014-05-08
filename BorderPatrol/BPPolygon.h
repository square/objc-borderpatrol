//
//  BPPolygon.h
//  BorderPatrol
//
//  Created by Jim Puls on 5/30/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface BPPolygon : NSObject

+ (BPPolygon *)polygonWithCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count;
+ (BPPolygon *)polygonWithLocations:(NSArray *)locations;

@property (nonatomic, readonly) CLLocationCoordinate2D *coordinates;
@property (nonatomic, readonly) NSUInteger coordinateCount;

- (id)initWithCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count;
- (BOOL)containsCoordinate:(CLLocationCoordinate2D)coordinate;

@end
