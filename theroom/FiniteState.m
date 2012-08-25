//
//  FiniteState.m
//  Void Star
//
//  Created by Ingimar Gudmundsson on 15/04/2012.
//  Copyright (c) 2012 Cuboid. All rights reserved.
//

#import "FiniteState.h"

@implementation FiniteState

@synthesize name;
@synthesize stateEnter;
@synthesize stateUpdate;
@synthesize stateLeave;
@synthesize subsequentState;

+ (id)stateWithName:(NSString *)aName
{
	return [[[FiniteState alloc] initStateWithName:aName] autorelease];
}

-(id)initStateWithName:(NSString *)aName
{
	self = [super init];
	
	if (self != nil)
	{
		name = [aName retain];
		edges = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (NSString *)name
{
	return name;
}

- (void)enter
{
	if (stateEnter != nil)
	{
		stateEnter();
	}
	
	subsequentState = nil;
}

- (void)updateWithDelta:(ccTime)aDelta
{
	if (stateUpdate != nil)
	{
		stateUpdate(aDelta);
	}
}

- (void)leave
{
	if (stateLeave)
	{
		stateLeave();		
	}
	[subsequentState release];
	subsequentState = nil;
}

- (BOOL)finishedWithDelta:(ccTime)aDelta
{
	for (StateEdge edge in edges)
	{
		subsequentState = edge(aDelta);
		if (subsequentState != nil)
		{
			[subsequentState retain];
			return YES;
		}
	}
	return NO;
}

- (void)addEdge:(StateEdge)edge
{
	StateEdge addedEdge = [edge copy];
	[edges addObject:addedEdge];
	[addedEdge release];
}

- (void)dealloc
{
	[name release];
	[edges release];
	
	[stateEnter release];
	[stateUpdate release];
	[stateLeave release];
	
	[super dealloc];
}

@end
