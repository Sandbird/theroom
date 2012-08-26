//
//  RoomLayer.h
//  theroom
//
//  Created by Ingimar Gudmundsson on 25/08/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// Forward declarations
@class Character;
@class FiniteStateMachine;
@class Furniture;

@interface RoomLayer : CCLayer
{
	CCSprite *_background;
	Furniture *_bed;
	Furniture *_tv;
	Furniture *_fridge;
	Furniture *_couch;
	Furniture *_phone;
	Character *_johnny;
	
	FiniteStateMachine *_room;
}

// returns a CCScene that contains the RoomLayer as the only child
+(CCScene *) scene;

- (void)update:(ccTime)delta;

@end
