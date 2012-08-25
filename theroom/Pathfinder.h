//
//  Pathfinder.h
//  theroom
//
//  Created by Ingimar Gudmundsson on 25/08/2012.
//
//

#import <Foundation/Foundation.h>

// Forward Declarations
@class Waypoint;

@interface Pathfinder : NSObject
{
	NSMutableDictionary *_waypoints;
}

+ (id)sharedPathfinder;

- (Waypoint *)waypoint:(NSString *)waypointName;
- (NSString *)closestLocationTo:(CGPoint)point;
- (NSArray*)findPathBetween:(NSString *)location andDestination:(NSString *)destination;

@end
