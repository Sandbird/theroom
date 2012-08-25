//
//  Waypoint.h
//  theroom
//
//  Created by Ingimar Gudmundsson on 25/08/2012.
//
//

#import <Foundation/Foundation.h>

@interface Waypoint : NSObject

@property (nonatomic, readonly) CGPoint location;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSDictionary *paths;

+ (id)waypointWithWaypointData:(NSDictionary *)waypointData;
- (id)initWithWaypointData:(NSDictionary *)waypointData;

@end
