//
//  FiniteState.h
//  Void Star
//
//  Created by Ingimar Gudmundsson on 15/04/2012.
//  Copyright (c) 2012 Cuboid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// Use this Macro to locally declare a SELF that avoids
// creating a retain cycle when member variables of the
// FiniteState containing class are accessed within the block
#define DEFINE_BLOCK_SELF __block typeof(self) SELF = self;

// Block Definitions to build States and Edges from
typedef void (^StateEnter) (void);
typedef void (^StateLeave) (void);
typedef void (^StateUpdate) (ccTime delta);

// StateEdge blocks should return the subsequent state if the
// edge evaluates to true, otherwise they should return nil
typedef NSString * (^StateEdge) (ccTime delta);


@interface FiniteState : NSObject
{
	NSString *name;
	
	NSMutableArray *edges;
	StateEnter stateEnter;
	StateUpdate stateUpdate;
	StateLeave stateLeave;
	
	NSString *subsequentState;
}

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readwrite, copy) StateEnter stateEnter;
@property (nonatomic, readwrite, copy) StateUpdate stateUpdate;
@property (nonatomic, readwrite, copy) StateLeave stateLeave;
@property (nonatomic, readonly) NSString *subsequentState;

+ (id)stateWithName:(NSString *)aName;
- (id)initStateWithName:(NSString *)aName;

- (void)enter;
- (void)updateWithDelta:(ccTime)aDelta;
- (void)leave;

- (BOOL)finishedWithDelta:(ccTime)aDelta;

- (void)addEdge:(StateEdge)edge;

@end
