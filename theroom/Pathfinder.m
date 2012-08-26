//
//  Pathfinder.m
//  theroom
//
//  Created by Ingimar Gudmundsson on 25/08/2012.
//
//

#import "Pathfinder.h"
#import "cocos2d.h"
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
			 [_waypoints setObject:waypoint forKey:key];
		 }];
	}
	
	return self;
}

- (Waypoint *)waypoint:(NSString *)waypointName
{
	return [_waypoints objectForKey:waypointName];
}

- (NSString *)closestLocationTo:(CGPoint)point
{
	// Search through the waypoints for the closest waypoint to the click
	__block Waypoint *closestWaypoint = nil;
	__block float minDistanceSquared = FLT_MAX;
	
	[_waypoints enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
	 {
		 Waypoint *waypoint = (Waypoint *)obj;
		 float distanceSquared = ccpDistanceSQ(point, waypoint.location);
		 if (closestWaypoint == nil || distanceSquared <= minDistanceSquared)
		 {
			 closestWaypoint = waypoint;
			 minDistanceSquared = distanceSquared;
		 }
	 }];
	
	if (closestWaypoint != nil)
	{
		return closestWaypoint.name;
	}
	
	return nil;
}

- (NSArray*)findPathBetween:(NSString *)location andDestination:(NSString *)destination
{
	Waypoint *locationWaypoint = [_waypoints objectForKey:location];
	NSArray *waypointPath = [locationWaypoint.paths objectForKey:destination];
	if (waypointPath != nil)
	{
		NSMutableArray *waypoints = [NSMutableArray arrayWithCapacity:[waypointPath count]];
		for (NSString *nextDestination in waypointPath)
		{
			[waypoints addObject:[_waypoints objectForKey:nextDestination]];
		}
		
		return waypoints;
	}
	
	NSLog(@"ERROR: No paths to destination %@ from %@", destination, location);
	
	return nil;
}


@end
