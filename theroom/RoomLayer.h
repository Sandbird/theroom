//
//  RoomLayer.h
//  theroom
//
//  Created by Ingimar Gudmundsson on 25/08/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface RoomLayer : CCLayer
{
	CCSprite *_background;
}

// returns a CCScene that contains the RoomLayer as the only child
+(CCScene *) scene;

@end
