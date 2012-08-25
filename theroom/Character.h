//
//  Character.h
//  theroom
//
//  Created by Ingimar Gudmundsson on 25/08/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Character : CCNode
{
	CCSprite *_appearance;
}

@property (nonatomic, readwrite, retain) NSString *waypointName;

@end
