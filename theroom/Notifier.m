//
//  Notifier.m
//  Void Star
//
//  Created by Marco Bancale on 6/29/12.
//  Copyright (c) 2012 Cuboid. All rights reserved.
//

#import "Notifier.h"

@implementation Notifier

- (id)initWithProtocol:(Protocol *)aProtocol;
{
	self = [super init];
	if (self != nil)
	{
		protocol = aProtocol;
		receivers = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (BOOL)addReceiver:(id)aReceiver
{
	if ([receivers containsObject:aReceiver] == NO && [aReceiver conformsToProtocol:protocol] == YES)
	{
		[receivers addObject:aReceiver];
		
		return YES;
	}
	
	return NO;
}

- (void)removeReceiver:(id)aReceiver
{
	[receivers removeObject:aReceiver];
}

- (void)notifyWithBlock:(NotificationBlock)notificationBlock
{
	for (id receiver in receivers)
	{
		notificationBlock(receiver);
	}
}

- (void)dealloc
{
	[receivers release];

	[super dealloc];
}

@end
