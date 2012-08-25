//
//  FiniteStateMachine.h
//  Void Star
//
//  Created by Ingimar Gudmundsson on 10/04/2012.
//  Copyright (c) 2012 Cuboid. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"
#import "FiniteState.h"


// The way to use the FiniteStateMachine is 
// to add it as a component to the class you want
// to make a state machine object and add states 
// to it with edges being block functions passed 
// to the states
@interface FiniteStateMachine : NSObject
{
	NSMutableDictionary *states;
	NSString *initialStateKey;
	FiniteState *currentState;
}

@property (nonatomic, readonly) NSString *currentStateName;

- (id)initWithInitialState:(FiniteState *)initialState;
- (void)addState:(FiniteState *)state;
- (void)addStates:(FiniteState *)firstState,... NS_REQUIRES_NIL_TERMINATION;
	
- (void)start;
- (void)update:(ccTime)delta;
- (void)stop;

@end
