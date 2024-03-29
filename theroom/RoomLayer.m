//
//  RoomLayer.m
//  theroom
//
//  Created by Ingimar Gudmundsson on 25/08/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RoomLayer.h"

#import "Character.h"
#import "FiniteState.h"
#import "FiniteStateMachine.h"
#import "Furniture.h"
#import "ItemSelector.h"
#import "NotificationConstants.h"
#import "Pathfinder.h"
#import "Psyche.h"
#import "UtilityFunctions.h"
#import "Waypoint.h"
#import "SimpleAudioEngine.h"


@implementation RoomLayer

static NSString *kRoomEnteringRoomState = @"enteringRoomState";
static NSString *kRoomIdleState = @"idleState";
static NSString *kRoomSleepState = @"sleepState";
static NSString *kRoomInteractWithFurnitureState = @"interactWithFurnitureState";
static NSString *kRoomMoveCharacterState = @"moveCharacterState";
static NSString *kRoomDeathState = @"roomDeathState";
static NSString *kRoomHolidayState = @"roomHolidayState";

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
		// Setup the Room
		NSBundle *mainBundle = [NSBundle mainBundle];
		NSString *path = [mainBundle pathForResource:@"theroom" ofType:@"png"];
		_background = [CCSprite spriteWithFile:path];
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		_background.position = ccp( winSize.width / 2, winSize.height / 2);
		[self addChild:_background];
		
		// Game specific data
		NSString *pathToGameData = [mainBundle pathForResource:@"gameData" ofType:@"plist"];
		NSDictionary *gameData = [NSDictionary dictionaryWithContentsOfFile:pathToGameData];
		
		// Setup the Furniture
		_bed = [Furniture furnitureWithData:[gameData objectForKey:@"Bed"]];
		[self addChild:_bed];
		
		_tv = [Furniture furnitureWithData:[gameData objectForKey:@"TV"]];
		[self addChild:_tv];
		
		_fridge = [Furniture furnitureWithData:[gameData objectForKey:@"Fridge"]];
		[self addChild:_fridge];

		// Setup the Character Johnny
		_johnny = [[Character alloc] init];
		[self addChild:_johnny];
				
		_phone = [Furniture furnitureWithData:[gameData objectForKey:@"Phone"]];
		[self addChild:_phone];
		
		_nightLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 50, 255)];
		_nightLayer.opacity = 0;
		[self addChild:_nightLayer];
		
		_dayLabel = [CCLabelTTF labelWithString:@"DAY 1" fontName:@"Arial" fontSize:48];
		_dayLabel.position = ccp(480, 256);
		_dayLabel.opacity = 0;
		[_nightLayer addChild:_dayLabel];
		
		self.isMouseEnabled = YES;
		
		_backgroundNoise = [[SimpleAudioEngine sharedEngine] soundSourceForFile:@"room_tone_bg_loop.wav"];
		_backgroundNoise.looping = YES;
//		[backgroundNoise play];
		
		_itemSelectionCancelled = NO;
		[self setupStateMachine];
		
		[self scheduleUpdate];
		
		// Register for game notifications
		[self setupObservations];
		
		// Cache all the furniture separately in an arry for easy enumeration
		_allFurniture = [[NSMutableArray alloc] initWithObjects:_bed, _tv, _fridge, _phone, nil];
	}
	
	return self;
}

- (void)onEnter
{
	[super onEnter];
	[_room start];
	
	[SimpleAudioEngine sharedEngine].backgroundMusicVolume = 0.3f;
	[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"riders of chord.mp3" loop:YES];
}

- (void)update:(ccTime)delta
{
	[_room update:delta];
	[_johnny update:delta];
}

- (void)onExit
{
	[_room stop];
	[super onExit];
}

- (BOOL)ccMouseUp:(NSEvent *)event
{
	if (_isInteractive == YES && _targetWaypoint == nil)
	{
		NSLog(@"RoomLayer mouse up");
		// Take the event and send johnny to the location
		CGPoint mouseLocation = ccp(event.locationInWindow.x, event.locationInWindow.y);
		_targetWaypoint = [[[Pathfinder sharedPathfinder] closestLocationTo:mouseLocation] retain];
		
//		return YES;
	}
	
	return NO;
}

#pragma mark - Private 

- (void)setupStateMachine
{
	DEFINE_BLOCK_SELF
	// Entering Room State
	FiniteState *enteringRoom = [FiniteState stateWithName:kRoomEnteringRoomState];
	enteringRoom.stateEnter = ^(void)
	{
		SELF->_isInteractive = NO;
		[SELF->_johnny moveToWaypointWithName:@"Entrance"];
		[SELF->_allFurniture enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
		 {
			 Furniture *furniture = (Furniture *)obj;
			 [furniture prepareForNewDay];
		 }];
	};
	[enteringRoom addEdge:^NSString *(ccTime delta)
	 {
		 if (SELF->_johnny.finishedActions == YES)
		 {
			 return kRoomIdleState;
		 }
		 return nil;
	 }];
	
	// Going To Sleep State
	FiniteState *sleepState = [FiniteState stateWithName:kRoomSleepState];
	sleepState.stateLeave = ^(void)
	{
		SELF->_isInteractive = YES;
	};
	[sleepState addEdge:^NSString *(ccTime delta)
	 {
		 if (SELF->_johnny.psyche.mentalState == kMentalStateInsane)
		 {
			 return kRoomDeathState;
		 }
		 else if (SELF->_johnny.psyche.mentalState == kMentalStateContent)
		 {
			 return kRoomHolidayState;
		 }
		 if (SELF->_dayCycling == NO)
		 {
			 return kRoomEnteringRoomState;
		 }
		 
		 return nil;
	 }];
	
	// HolidayState
	FiniteState *holidayState = [FiniteState stateWithName:kRoomHolidayState];
	holidayState.stateEnter = ^(void)
	{
		NSString *pathToHoliday = [[NSBundle mainBundle] pathForResource:@"endGood" ofType:@"png"];
		CCSprite *endScene = [CCSprite spriteWithFile:pathToHoliday];
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		endScene.position = ccp( winSize.width / 2, winSize.height / 2);
		[SELF addChild:endScene];
		
		CCLabelTTF *quitLabel = [CCLabelTTF labelWithString:@"Great, you feel content with your choices, time for a holiday" fontName:@"Arial" fontSize:24];
		CCMenuItem *quitMenuItem = [CCMenuItemLabel itemWithLabel:quitLabel block:^(id sender)
									{
										[[NSApplication sharedApplication] terminate:self];
									}];
		quitMenuItem.position = ccp(winSize.width / 2, winSize.height / 2 + 100);
		[SELF addChild:quitMenuItem];
	};
	
	// Death State
	FiniteState *deathState = [FiniteState stateWithName:kRoomDeathState];
	deathState.stateEnter = ^(void)
	{
		NSString *pathToDeath = [[NSBundle mainBundle] pathForResource:@"endBad" ofType:@"png"];
		CCSprite *endScene = [CCSprite spriteWithFile:pathToDeath];
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		endScene.position = ccp( winSize.width / 2, winSize.height / 2);
		[SELF addChild:endScene];
		
		CCLabelTTF *quitLabel = [CCLabelTTF labelWithString:@"You didn't manage to adapt to your environment, try again" fontName:@"Arial" fontSize:24];
		CCMenuItem *quitMenuItem = [CCMenuItemLabel itemWithLabel:quitLabel block:^(id sender)
									{
										[[NSApplication sharedApplication] terminate:self];
									}];
		quitMenuItem.position = ccp(winSize.width / 2, winSize.height / 2 - 200);
		[SELF addChild:quitMenuItem];
	};
	
	// Idle State
	FiniteState *idleState = [FiniteState stateWithName:kRoomIdleState];
	idleState.stateEnter = ^(void)
	{
		SELF->_isInteractive = YES;
	};
	[idleState addEdge:^NSString *(ccTime delta)
	 {
		 if (SELF->_targetFurniture != nil)
		 {
			 return kRoomInteractWithFurnitureState;
		 }
		 else if (SELF->_targetWaypoint != nil)
		 {
			 return kRoomMoveCharacterState;
		 }
		 else if (SELF->_dayCycling == YES)
		 {
			 return kRoomSleepState;
		 }
		 
		 return nil;
	 }];
	
	// Move Character State
	FiniteState *moveCharacterState = [FiniteState stateWithName:kRoomMoveCharacterState];
	moveCharacterState.stateEnter = ^(void)
	{
		[SELF->_johnny moveToWaypointWithName:_targetWaypoint];
	};
	moveCharacterState.stateLeave = ^(void)
	{
		[SELF->_targetWaypoint release];
		SELF->_targetWaypoint = nil;
	};
	[moveCharacterState addEdge:^NSString *(ccTime delta)
	 {
		 if (SELF->_johnny.finishedActions == YES)
		 {
			 return kRoomIdleState;
		 }
		 return nil;
	 }];
	
	// Interacting With Furniture State
	FiniteState *interactingWithFurnitureState = [FiniteState stateWithName:kRoomInteractWithFurnitureState];
	interactingWithFurnitureState.stateEnter = ^(void)
	{
		[SELF->_johnny moveTo:_targetFurniture];
		SELF->_isInteractive = NO;
	};
	interactingWithFurnitureState.stateUpdate = ^(ccTime delta)
	{
		if (SELF->_selectedItem != nil)
		{
			NSLog(@"Handle selection");
			[SELF->_selectedItem release];
			SELF->_selectedItem = nil;
			
			[SELF->_johnny itemSelected];
		}
		else if (SELF->_itemSelectionCancelled)
		{
			[SELF->_johnny itemSelectionCancelled];
		}
	};
	interactingWithFurnitureState.stateLeave = ^(void)
	{
		[SELF->_targetFurniture showInactive];
		[SELF->_targetFurniture release];
		SELF->_targetFurniture = nil;
		SELF->_itemSelectionCancelled = NO;	
	};
	[interactingWithFurnitureState addEdge:^NSString *(ccTime delta)
	{
		if (SELF->_johnny.finishedActions == YES && SELF->_selectedItem == nil)
		{
			return kRoomIdleState;
		}
		
		return nil;
	}];
	
	_room = [[FiniteStateMachine alloc] initWithInitialState:enteringRoom];
	[_room addStates:sleepState, idleState, moveCharacterState, interactingWithFurnitureState, holidayState, deathState, nil];
}

- (void)setupObservations
{
	// Observe notifications from furniture items
	[[NSNotificationCenter defaultCenter] addObserverForName:kFurnitureNotActive object:nil queue:nil usingBlock:^(NSNotification *note)
	 {
		 NSLog(@"WARNING: No response implemented for handling making furniture inactive");
	 }];
	[[NSNotificationCenter defaultCenter] addObserverForName:kFurnitureActive object:nil queue:nil usingBlock:^(NSNotification *note)
	 {
		 if (_targetFurniture == nil)
		 {
			 _targetFurniture = (Furniture *) [note.object retain];
		 }
		 else
		 {
			 NSLog(@"WARNING: trying to set %@ as active furniture but %@ is already active",
				   ((Furniture *)note.object).name,
				   _targetFurniture.name);
		 }
	 }];
	
	
	// Observe notifications from menu items
	[[NSNotificationCenter defaultCenter] addObserverForName:kMenuItemSelected object:nil queue:nil usingBlock:^(NSNotification *note)
	 {
		 if (_selectedItem == nil)
		 {
			 _selectedItem = (ItemSelection *)[note.object retain];
			 [self updatePsyche];
		 }
	 }];

	[[NSNotificationCenter defaultCenter] addObserverForName:kMenuItemCancelled object:nil queue:nil usingBlock:^(NSNotification *note)
	 {
		 _itemSelectionCancelled = YES;
	 }];
}

- (void)updatePsyche
{
	[_johnny.psyche updateWithSelection:_selectedItem];
		
	if ([_selectedItem.itemName isEqualToString:@"Bed"] == YES)
	{
		[_johnny.psyche contemplateDayEvents];
		[self cycleDay];
	}
}

- (void)cycleDay
{
	// INGIMAR: use this variable in the state machine to discard all input while the cycling is animated
	_dayCycling = YES;
	
	_dayLabel.string = [NSString stringWithFormat:@"DAY %lu", _johnny.psyche.numberOfDays];
	
	_nightLayer.opacity = 0;
	_dayLabel.opacity = 0;
	
	[_nightLayer runAction:[CCSequence actions:[CCFadeTo actionWithDuration:2.0f opacity:190], [CCDelayTime actionWithDuration:1.0f], [CCFadeTo actionWithDuration:2.0f opacity:0], nil]];
	[_dayLabel runAction:[CCSequence actions:[CCFadeIn actionWithDuration:2.0f], [CCDelayTime actionWithDuration:1.0f], [CCFadeOut actionWithDuration:2.0f],
						  [CCCallBlock actionWithBlock:^
	{
		_dayCycling = NO;
	}], nil]];
	
	[_johnny teleportToInitialPosition];
}

#pragma mark -

- (void)dealloc
{
	[_room release];
	[_allFurniture release];
	
	[super dealloc];
}

@end
