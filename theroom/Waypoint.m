//
//  Waypoint.m
//  theroom
//
//  Created by Ingimar Gudmundsson on 25/08/2012.
//
//

#import "Waypoint.h"

#import "UtilityFunctions.h"

@implementation Waypoint

@synthesize name = _name;
@synthesize location = _location;
@synthesize paths = _paths;

+ (id)waypointWithWaypointData:(NSDictionary *)waypointData
{
	return [[[Waypoint alloc] initWithWaypointData:waypointData] autorelease];
}

- (id)initWithWaypointData:(NSDictionary *)waypointData
{
	self = [super init];
	if (self !=nil)
	{
		_name = [[waypointData objectForKey:@"Name"] retain];
		_location = CGPointFromDictionary([waypointData objectForKey:@"Position"]);
		_paths = [[waypointData objectForKey:@"Paths"] retain];
	}
	
	return self;
}

- (void)dealloc
{
	[_name release];
	[_paths release];
	
	[super dealloc];
}

@end
