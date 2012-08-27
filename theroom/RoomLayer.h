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
@class CDSoundSource;
@class Character;
@class FiniteStateMachine;
@class Furniture;
@class ItemSelection;


@interface RoomLayer : CCLayer
{
	// Elements Of The Game World
	CCSprite *_background;
	Furniture *_bed;
	Furniture *_tv;
	Furniture *_fridge;
	Furniture *_phone;
	Character *_johnny;
	
	CDSoundSource *_backgroundNoise;
	
	// State Variables For Input
	Furniture *_targetFurniture;
	NSString *_targetWaypoint;
	ItemSelection *_selectedItem;
	BOOL _itemSelectionCancelled;
	BOOL _isInteractive;
	
	CCLayerColor *_nightLayer;
	CCLabelTTF *_dayLabel;
	BOOL _dayCycling;
	
	// Game Loop State Machine
	FiniteStateMachine *_room;
}

// returns a CCScene that contains the RoomLayer as the only child
+(CCScene *) scene;

- (void)update:(ccTime)delta;

@end
