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

@interface Character : CCNode
{
	CCSprite *_appearanceFront;
	CCSprite *_appearanceBack;
	NSString *_wayPointName;
	
	BOOL _finishedActions;
	FiniteStateMachine *_behaviour;
}

@property (nonatomic, readwrite, retain) NSString *waypointName;
@property (nonatomic, readonly) BOOL finishedActions;

- (void)update:(ccTime)delta;
- (void)moveFrom:(NSString *)locationName to:(NSString *)destinationName;

@end
