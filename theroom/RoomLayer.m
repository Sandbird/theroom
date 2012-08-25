//
//  RoomLayer.m
//  theroom
//
//  Created by Ingimar Gudmundsson on 25/08/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RoomLayer.h"

#import "Character.h"
#import "Pathfinder.h"
#import "UtilityFunctions.h"
#import "Waypoint.h"


@implementation RoomLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	RoomLayer *layer = [RoomLayer node];
	
	// add layer as a child to scene
	[scene addChild:layer];
	
	// return the scene
	return scene;
}

- (id)init
{
	self = [super init];
	if (self != nil)
	{
		// Setup the 
		NSString *path = [[NSBundle mainBundle] pathForResource:@"herb" ofType:@"png"];
		_background = [CCSprite spriteWithFile:path];
		NSSize winSize = [[CCDirector sharedDirector] winSize];
		_background.position = ccp( winSize.width / 2, winSize.height / 2);
		[self addChild:_background];
		
		_johnny = [[Character alloc] init];
		
		Waypoint *entrancePoint = [[Pathfinder sharedPathfinder] waypoint:@"Entrance"];
		_johnny.position = entrancePoint.location;
		[self addChild:_johnny];
		
		self.isMouseEnabled = YES;
	}
	
	return self;
}

- (BOOL)ccMouseUp:(NSEvent *)event
{
	// Take the event and send johnny to the location
	CGPoint mouseLocation = event.locationInWindow;
	NSLog(@"Closest Location : %@", [[Pathfinder sharedPathfinder] closestLocationTo:mouseLocation]);
	
	return YES;
}

@end
