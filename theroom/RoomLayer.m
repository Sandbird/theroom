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
		
		Waypoint *entrancePoint = [[Pathfinder sharedPathfinder] waypoint:@"Entrance"];
		_johnny.position = entrancePoint.location;
		[self addChild:_johnny];
		
		_phone = [Furniture furnitureWithData:[gameData objectForKey:@"Phone"]];
		[self addChild:_phone];
		
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
	if (_isInteractive == YES)
	{
		NSLog(@"RoomLayer mouse up");
		// Take the event and send johnny to the location
		CGPoint mouseLocation = ccp(event.locationInWindow.x, event.locationInWindow.y);
		NSString *mouseWaypointName = [[Pathfinder sharedPathfinder] closestLocationTo:mouseLocation];
		
		if (_johnny.waypointName != mouseWaypointName)
		{
			NSArray *waypointsToDestination = [[Pathfinder sharedPathfinder] findPathBetween:_johnny.waypointName andDestination:mouseWaypointName];
			NSMutableArray *allActionsToDestination = [NSMutableArray arrayWithCapacity:[waypointsToDestination count]];
			
			for (Waypoint *waypoint in waypointsToDestination)
			{
				CCAction *moveAction = [CCMoveTo actionWithDuration:2.0f position:waypoint.location];
				[allActionsToDestination addObject:moveAction];
			}
			id waypointSequence = [CCSequence actionWithArray:allActionsToDestination];
			
			
			[_johnny runAction:waypointSequence];
		}		
	}
	
	return YES;
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
		[SELF->_johnny moveFrom:@"Offscreen" to:@"Entrance"];
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
	FiniteState *idle = [FiniteState stateWithName:kRoomIdleState];
	[idle addEdge:^NSString *(ccTime delta)
	 {
		 if (SELF->_targetFurniture != nil)
		 {
			 return kRoomInteractWithFurnitureState;
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
	[interactingWithFurnitureState addEdge:^NSString *(ccTime delta)
	{
		if (SELF->_johnny.finishedActions == YES)
		{
			return kRoomIdleState;
		}
		
		return nil;
	}];
	
	_room = [[FiniteStateMachine alloc] initWithInitialState:enteringRoom];
	[_room addStates:sleepState, idle, interactingWithFurnitureState, nil];
}

- (void)setupObservations
{
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
}

#pragma mark -

- (void)dealloc
{
	[_room release];
	
	[super dealloc];
}

@end
