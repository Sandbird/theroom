//
//  Character.h
//  theroom
//
//  Created by Ingimar Gudmundsson on 25/08/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// Forward Declarations
@class FiniteStateMachine;
@class Furniture;

@interface Character : CCNode
{
	CCSprite *_appearanceFront;
	CCSprite *_appearanceBack;
	NSString *_currentWaypointName;
	
	// State Machine Variables
	BOOL _finishedActions;
	Furniture *_targetFurniture;
	NSString *_wayPointDestinationName;
	FiniteStateMachine *_behaviour;
}

@property (nonatomic, readwrite, retain) NSString *currentWaypointName;
@property (nonatomic, readonly) BOOL finishedActions;

- (void)update:(ccTime)delta;
- (void)moveTo:(Furniture *)target;
- (void)moveToWaypointWithName:(NSString *)waypointName;
- (void)itemSelected;
- (void)itemSelectionCancelled;

@end
