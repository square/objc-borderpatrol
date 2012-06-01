//
//  BPPolygon.h
//  BorderPatrol
//
//  Created by Jim Puls on 5/30/12.
//  Copyright (c) 2012 Square, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface BPPolygon : NSObject

+ (BPPolygon *)polygonWithCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count;

@property (nonatomic, readonly) CLLocationCoordinate2D *coordinates;
@property (nonatomic, readonly) NSUInteger coordinateCount;

- (id)initWithCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count;
- (BOOL)containsCoordinate:(CLLocationCoordinate2D)coordinate;

@end
