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
}

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) CGPoint positionInRoom;

+ (id)furnitureWithData:(NSDictionary *)data;

- (id)initWithData:(NSDictionary *)data;

@end
