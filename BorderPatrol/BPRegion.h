//
//  BPRegion.h
//  BorderPatrol
//
//  Created by Jim Puls on 5/30/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import <CoreLocation/CoreLocation.h>

@class BPPolygon;

@interface BPRegion : CLRegion

+ (BPRegion *)regionWithContentsOfURL:(NSURL *)url;
+ (BPRegion *)regionWithPolygons:(NSSet *)polygons identifier:(NSString *)identifier;

@property (nonatomic, readonly, strong) NSSet *polygons;

- (id)initWithPolygons:(NSSet *)polygons identifier:(NSString *)identifier;

@end
