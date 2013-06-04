#import "MapPin.h"

@implementation MapPin

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:placeName description:description {
    self = [super init];
    if (self != nil) {
        coordinate = location;
        title = placeName;
        [title retain];
        subtitle = description;
        [subtitle retain];
    }
    return self;
}

- (void)dealloc {
    [title release];
    [subtitle release];
    [super dealloc];
}


@end