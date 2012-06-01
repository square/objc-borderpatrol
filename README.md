# BorderPatrol

BorderPatrol allows you import a KML file and then check if points are inside or outside the polygons the file defines. It extends the types you're already using in CoreLocation, and it presents an API that should be immediately familiar.

The KML file may have multiple polygons defined; Google Maps is a good source.

## Examples

An example KML file can be found here:
http://maps.google.com/maps/ms?ie=UTF8&hl=en&msa=0&ll=38.814031,-103.743896&spn=9.600749,16.248779&z=7&msid=110523771099674876521.00049301d20252132a92c&output=kml

To test if a coordinate is in the region you can use the `BPRegion class`, a subclass of `CLRegion` that supports disjoint polygon regions. Use the standard `CLLocationCoordinate2D` struct to represent your coordinates.

    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"colorado-test" withExtension:@"kml"];
    BPRegion *region = [BPRegion regionWithContentsOfURL:url];
    CLLocationCoordinate2D denver = CLLocationCoordinate2DMake(39.75, -105);
	[region containsCoordinate:denver]; // true
    CLLocationCoordinate2D  sanFrancisco = CLLocationCoordinate2DMake(37.75, -122.5);
	[region containsCoordinate:sanFrancisco]; // false

## Performance
It's no dedicated GIS system, but it's about 200 times faster than the Ruby version. There's a test in the test suite that checks 10,000 random points for whether or not they're in a region.

                        user     system     total       real
         Colorado   0.003013   0.000004   0.003017 (0.003014)
    Multi Polygon   0.008146   0.000001   0.008147 (0.008152)


## Pro Tip

You can make KML files easily on Google Maps by clicking "My Maps", drawing shapes and saving the map.  Just copy the share link and add "&output=kml" to download the file.

## Dependencies

* iOS 4 or Mac OS X 10.7
* CoreLocation

## Known Issues

Polygons across the International Date Line don't work.

## Acknowledgments

This library is a nearly direct port of [our Ruby implementation of the same](https://github.com/square/border_patrol). See that library for more acknowledgments.
