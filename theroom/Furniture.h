//
//  Bed.h
//  theroom
//
//  Created by Ingimar Gudmundsson on 25/08/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Furniture : CCNode <CCMouseEventDelegate>
{
	CCSprite *_front;
	CCSprite *_active;
	NSString *_name;
	NSString *_closestWaypointName;
	CGPoint _positionInRoom;
	
	BOOL _activeState;
}

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *closestWaypointName;
@property (nonatomic, readonly) CGPoint positionInRoom;

+ (id)furnitureWithData:(NSDictionary *)data;

- (id)initWithData:(NSDictionary *)data;
- (void)showInactive;
- (void)showActive;

@end
