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
#import "UtilityFunctions.h"
#import "Waypoint.h"
#import "SimpleAudioEngine.h"


@implementation RoomLayer

static NSString *kRoomEnteringRoomState = @"enteringRoomState";
static NSString *kRoomIdleState = @"idleState";
static NSString *kRoomGoingToSleepState = @"goingToSleepState";
static NSString *kRoomInteractWithFurnitureState = @"interactWithFurnitureState";
static NSString *kRoomMoveCharacterState = @"moveCharacterState";

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
		
		_phone = [Furniture furnitureWithData:[gameData objectForKey:@"Phone"]];
		[self addChild:_phone];
		
		// Setup the Character Johnny
		_johnny = [[Character alloc] init];
		[self addChild:_johnny];
		
		self.isMouseEnabled = YES;
		
		backgroundNoise = [[SimpleAudioEngine sharedEngine] soundSourceForFile:@"room_tone_bg_loop.wav"];
		backgroundNoise.looping = YES;
//		[backgroundNoise play];
		
		[self setupStateMachine];
		
		[self scheduleUpdate];
		
		// Register for game notifications
		[self setupObservations];
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
	};
	enteringRoom.stateLeave = ^(void)
	{
		SELF->_isInteractive = YES;
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
	FiniteState *sleepState = [FiniteState stateWithName:kRoomGoingToSleepState];
	
	// Idle State
	FiniteState *idleState = [FiniteState stateWithName:kRoomIdleState];
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
	};
	interactingWithFurnitureState.stateLeave = ^(void)
	{
		[SELF->_targetFurniture showInactive];
		[SELF->_targetFurniture release];
		SELF->_targetFurniture = nil;
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
	[_room addStates:sleepState, idleState, moveCharacterState, interactingWithFurnitureState, nil];
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
			 _targetFurniture = (Furniture *) note.object;
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
		 }
	 }];
}

#pragma mark -

- (void)dealloc
{
	[_room release];
	
	[super dealloc];
}

@end
