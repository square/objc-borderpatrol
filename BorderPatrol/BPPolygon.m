//
//  BPPolygon.m
//  BorderPatrol
//
//  Created by Jim Puls on 5/30/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import "BPPolygon.h"

@implementation BPPolygon {
    CLLocationCoordinate2D *_coordinates;
}

@synthesize coordinateCount = _coordinateCount;

+ (BPPolygon *)polygonWithCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count;
{
    return [[self alloc] initWithCoordinates:coordinates count:count];
}

+ (BPPolygon *)polygonWithLocations:(NSArray *)locations
{
    NSUInteger count = [locations count];
    CLLocationCoordinate2D cArray[count];
    for (int i = 0; i < count; i++){
        cArray[i] = [[locations objectAtIndex:i] coordinate];
    }
    
    return [[self alloc] initWithCoordinates:cArray count:count];
}

- (id)initWithCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count;
{
    NSAssert(count > 2, @"Need more than two coordinates to make a polygon");
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _coordinates = malloc(count * sizeof(CLLocationCoordinate2D));
    memcpy(_coordinates, coordinates, count * sizeof(CLLocationCoordinate2D));
    
    _coordinateCount = count;
    
    return self;
}

- (void)dealloc;
{
    free(_coordinates);
}

- (CLLocationCoordinate2D *)coordinates;
{
    return _coordinates;
}

- (BOOL)containsCoordinate:(CLLocationCoordinate2D)coordinate;
{
    // Step 1: test bounding box and vertex equality
    CLLocationDegrees minLatitude = INFINITY, minLongitude = INFINITY, maxLatitude = -INFINITY, maxLongitude = -INFINITY;
    for (int index = 0; index < _coordinateCount; index++) {
        if (_coordinates[index].longitude == coordinate.longitude && _coordinates[index].latitude == coordinate.latitude) {
            return YES;
        }
        
        if (_coordinates[index].latitude < minLatitude) {
            minLatitude = _coordinates[index].latitude;
        }
        if (_coordinates[index].longitude < minLongitude) {
            minLongitude = _coordinates[index].longitude;
        }
        if (_coordinates[index].latitude > maxLatitude) {
            maxLatitude = _coordinates[index].latitude;
        }
        if (_coordinates[index].longitude > maxLongitude) {
            maxLongitude = _coordinates[index].longitude;
        }
    }
    if (coordinate.latitude < minLatitude || coordinate.latitude > maxLatitude || coordinate.longitude < minLongitude || coordinate.longitude > maxLongitude) {
        return NO;
    }
    
    // Step 2: cast two rays in "random" directions
    // For a ray going straight to the right, loop through each side;
    // the coordinate lat must be between the points on the side
    // and the coordinate long must be less than where the ray intersection would be
    // If we pass through a different number of sides (mod 2) in different directions, we're starting on an edge. That's inside.
    NSInteger sidesCrossedMovingRight = 0;
    NSInteger sidesCrossedMovingLeft = 0;
    NSInteger previousIndex = _coordinateCount - 1;
    for (int index = 0; index < _coordinateCount; index++) {
        CLLocationCoordinate2D firstCoordinate = _coordinates[previousIndex];
        CLLocationCoordinate2D secondCoordinate = _coordinates[index];
        
        if ((firstCoordinate.latitude <= coordinate.latitude && coordinate.latitude < secondCoordinate.latitude) ||
            (secondCoordinate.latitude <= coordinate.latitude && coordinate.latitude < firstCoordinate.latitude)) {
            if (coordinate.longitude <= (secondCoordinate.longitude - firstCoordinate.longitude) * (coordinate.latitude - firstCoordinate.latitude) / (secondCoordinate.latitude - firstCoordinate.latitude) + firstCoordinate.longitude) {
                sidesCrossedMovingRight++;
            }
            if (coordinate.longitude >= (secondCoordinate.longitude - firstCoordinate.longitude) * (coordinate.latitude - firstCoordinate.latitude) / (secondCoordinate.latitude - firstCoordinate.latitude) + firstCoordinate.longitude) {
                sidesCrossedMovingLeft++;
            }
        }
        previousIndex = index;
    }
    return sidesCrossedMovingLeft % 2 == 1 || sidesCrossedMovingLeft % 2 != sidesCrossedMovingRight % 2;
}

@end
