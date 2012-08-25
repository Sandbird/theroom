//
//  FiniteStateMachine.m
//  Void Star
//
//  Created by Ingimar Gudmundsson on 10/04/2012.
//  Copyright (c) 2012 Cuboid. All rights reserved.
//

#import "FiniteStateMachine.h"

@implementation FiniteStateMachine

@dynamic currentStateName;

- (id)initWithInitialState:(FiniteState *)initialState
{
	self = [super init];
	if (self != nil)
	{
		initialStateKey = [[initialState name] retain];
		states = [[NSMutableDictionary alloc] initWithObjectsAndKeys:initialState, [initialState name], nil];
		
		currentState = nil;
	}
	
	return self;
}

- (void)addState:(FiniteState *)state
{
	[states setObject:state forKey:state.name];
}

- (void)addStates:(FiniteState *)firstState, ...
{
	va_list args;
	va_start(args, firstState);
    for (FiniteState *arg = firstState; arg != nil; arg = va_arg(args, FiniteState*))
    {
        [states setObject:arg forKey:arg.name];
    }
    va_end(args);
}

- (void)start
{
	currentState = [states objectForKey:initialStateKey];
	[currentState enter];
}

- (void)update:(ccTime)delta
{
	if (currentState != nil)
	{
		BOOL stateInFlux = YES;
		while (stateInFlux == YES)
		{
			[currentState updateWithDelta:delta];
			if ([currentState finishedWithDelta:delta] == YES)
			{
				stateInFlux = YES;
				NSString *nextStateKey = [currentState.subsequentState retain];
				[currentState leave];
				
				// Transititon to the next state
				currentState = [states objectForKey:nextStateKey];
				[currentState enter];
				[nextStateKey release];
			}
			else
			{
				stateInFlux = NO;
			}
		}
 	}
}

- (void)stop
{
	// halt state updates and clean up the
	// state machine, so that it is in the
	// same condition as when it first started
	currentState = nil;	
}

- (NSString *)currentStateName
{
	return currentState.name;
}

- (void)dealloc
{
	[initialStateKey release];
	[states release];
	
	[super dealloc];
}

@end
