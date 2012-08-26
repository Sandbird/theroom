//
//  Notifier.h
//  Void Star
//
//  Created by Marco Bancale on 6/29/12.
//  Copyright (c) 2012 Cuboid. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^NotificationBlock) (id receiver);

@interface Notifier : NSObject
{
	Protocol *protocol;
	NSMutableArray *receivers;
}

- (id)initWithProtocol:(Protocol *)aProtocol;

- (BOOL)addReceiver:(id)aReceiver;
- (void)removeReceiver:(id)aReceiver;

- (void)notifyWithBlock:(NotificationBlock)notificationBlock;

@end
