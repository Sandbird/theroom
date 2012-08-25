//
//  Pathfinder.m
//  theroom
//
//  Created by Ingimar Gudmundsson on 25/08/2012.
//
//

#import "Pathfinder.h"
#import "Waypoint.h"

@implementation Pathfinder

static Pathfinder *sharedPathfinder = nil;

+ (Pathfinder *)sharedPathfinder
{
	@synchronized([Pathfinder class])
	{
		if (sharedPathfinder == nil)
		{
			NSString *pathToWaypoints = [[NSBundle mainBundle] pathForResource:@"floorPlan" ofType:@"plist"];
			NSDictionary *waypointData = [NSDictionary dictionaryWithContentsOfFile:pathToWaypoints];
			
			sharedPathfinder = [[Pathfinder alloc] initWithWaypoints:waypointData];
		}
		return sharedPathfinder;
	}
	
	return nil;
}


- (id)initWithWaypoints:(NSDictionary *)waypoints
{
	self = [super init];
	if (self != nil)
	{
		_waypoints = [[NSMutableDictionary alloc] initWithCapacity:[waypoints count]];
		[waypoints enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
		 {
			 Waypoint *waypoint = [Waypoint waypointWithWaypointData:obj];
			 _waypoints[key] = waypoint;
		 }];
	}
	
	return self;
}

- (Waypoint *)waypoint:(NSString *)waypointName
{
	return _waypoints[waypointName];
}

- (NSString *)closestLocationTo:(CGPoint)point
{
	return nil;
}

- (NSArray*)findPathBetween:(NSString *)location andDestination:(NSString *)destination
{
	return nil;
}


@end