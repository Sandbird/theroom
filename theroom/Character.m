//
//  Character.m
//  theroom
//
//  Created by Ingimar Gudmundsson on 25/08/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Character.h"

#import "Furniture.h"
#import "FiniteState.h"
#import "FiniteStateMachine.h"
#import "Pathfinder.h"
#import "Psyche.h"
#import "Waypoint.h"

@implementation Character

static NSString *kCharacterIdleState = @"characterIdleState";
static NSString *kCharacterMovementState = @"characterMovementState";
static NSString *kCharacterInteractWithFurnitureState = @"characterInteractWithFurnitureState";

@synthesize currentWaypointName = _currentWaypointName;
@synthesize finishedActions = _finishedActions;
@synthesize psyche = _psyche;

- (id)init
{
	self = [super init];
	if	(self != nil)
	{
		NSString *pathToAppearanceFront = [[NSBundle mainBundle] pathForResource:@"johnnyFront" ofType:@"png"];
		_appearanceFront = [CCSprite spriteWithFile:pathToAppearanceFront];
		_appearanceFront.position = ccp( 0, _appearanceFront.contentSize.height / 2);
		[self addChild:_appearanceFront];
		
		NSString *pathToAppearanceBack = [[NSBundle mainBundle] pathForResource:@"johnnyBack" ofType:@"png"];
		_appearanceBack = [CCSprite spriteWithFile:pathToAppearanceBack];
		_appearanceBack.position = ccp( 0, _appearanceBack.contentSize.height / 2);
		[self addChild:_appearanceBack];
		_appearanceBack.visible = NO;
		
		_currentWaypointName = @"Outside";
		self.position = [[Pathfinder sharedPathfinder] waypoint:_currentWaypointName].location;
		initialPosition = self.position;
		
		_psyche = [[Psyche alloc] init];
		
		_finishedMovement = NO;
		_finishedActions = NO;
		_targetFurniture = nil;
		
		[self setupStateMachine];
	}
	
	return self;
}

- (void)onEnter
{
	[super onEnter];
	[_behaviour start];
}

- (void)update:(ccTime)delta
{
	[_behaviour update:delta];
}

- (void)onExit
{
	[_behaviour stop];
	[super onExit];
}

- (void)moveTo:(Furniture *)target
{
	if (_targetFurniture == nil)
	{
		_targetFurniture = [target retain];
		_finishedActions = NO;
	}
}

- (void)moveToWaypointWithName:(NSString *)waypointName
{
	if (_wayPointDestinationName == nil && [waypointName isEqualToString:_currentWaypointName] == NO)
	{
		_wayPointDestinationName = [waypointName retain];
	}
}

- (void)teleportToInitialPosition
{
	self.position = initialPosition;
	_currentWaypointName = @"Outside";
}

- (void)itemSelected
{
	_finishedActions = YES;
}

- (void)itemSelectionCancelled
{
	_finishedActions = YES;
}

#pragma mark - Private

- (void)setupStateMachine
{
	DEFINE_BLOCK_SELF
	// Idle State
	FiniteState *idleState = [FiniteState stateWithName:kCharacterIdleState];
	idleState.stateEnter = ^(void)
	{
		SELF->_finishedActions = YES;
	};
	[idleState addEdge:^NSString *(ccTime delta)
	 {
		 if (SELF->_targetFurniture != nil)
		 {
			 if([SELF->_targetFurniture.closestWaypointName isEqualToString:SELF->_currentWaypointName] == YES)
			 {
				 return kCharacterInteractWithFurnitureState;
			 }
			 else
			 {
				 return kCharacterMovementState;
			 }
		 }
		 
		 if (SELF->_wayPointDestinationName != nil)
		 {
			 return kCharacterMovementState;
		 }
		 
		 return nil;
		 
	 }];
	
	// Interacting with furniture State
	FiniteState *interactWithFurnitureState = [FiniteState stateWithName:kCharacterInteractWithFurnitureState];
	interactWithFurnitureState.stateEnter = ^(void)
	{
		SELF->_finishedActions = NO;
		[SELF->_targetFurniture showActive];
		SELF->_appearanceBack.visible = NO;
		SELF->_appearanceFront.visible = NO;
	};
	interactWithFurnitureState.stateLeave = ^(void)
	{
		SELF->_appearanceFront.visible = YES;
		[SELF->_targetFurniture release];
		SELF->_targetFurniture = nil;
	};
	[interactWithFurnitureState addEdge:^NSString *(ccTime delta) {
		if (SELF->_finishedActions == YES)
		{
			return kCharacterIdleState;
		}
		
		return nil;
	}];
	
	// Movement State
	FiniteState *movementState = [FiniteState stateWithName:kCharacterMovementState];
	movementState.stateEnter = ^(void)
	{
		SELF->_finishedMovement = NO;
		if (SELF->_targetFurniture != nil && SELF->_wayPointDestinationName == nil)
		{
			SELF->_wayPointDestinationName = [SELF->_targetFurniture.closestWaypointName  retain];
		}
		
		// Figure out path and create actions
		NSArray *waypointsToDestination = [[Pathfinder sharedPathfinder] findPathBetween:SELF->_currentWaypointName andDestination:_wayPointDestinationName];
		NSMutableArray *allActionsToDestination = [NSMutableArray arrayWithCapacity:[waypointsToDestination count]];
			
		for (Waypoint *waypoint in waypointsToDestination)
		{
			CCAction *moveAction = [CCMoveTo actionWithDuration:2.0f position:waypoint.location];
			[allActionsToDestination addObject:moveAction];
		}
		[allActionsToDestination addObject:[CCCallBlock actionWithBlock:^{
			SELF->_finishedMovement = YES;
		}]];
		id waypointSequence = [CCSequence actionWithArray:allActionsToDestination];
		
		
		[SELF runAction:waypointSequence];
	};
	movementState.stateLeave = ^(void)
	{
		_currentWaypointName = [_wayPointDestinationName retain];
		
		[_wayPointDestinationName release];
		_wayPointDestinationName = nil;
		
		SELF->_finishedActions = YES;
		SELF->_finishedMovement = YES;
	};
	[movementState addEdge:^NSString *(ccTime delta)
	 {
		 if (SELF->_finishedMovement == YES)
		 {
			 if (SELF->_targetFurniture != nil)
			 {
				 return kCharacterInteractWithFurnitureState;
			 }
			 
			 return kCharacterIdleState;
		 }
		 
		return nil;
	}];
	
	
	// The actual state machine
	_behaviour = [[FiniteStateMachine alloc] initWithInitialState:idleState];
	[_behaviour addStates:interactWithFurnitureState, movementState, nil];
}

#pragma mark -

- (void)dealloc
{
	[_psyche dealloc];
	[_behaviour release];
	
	[super dealloc];
}

@end
