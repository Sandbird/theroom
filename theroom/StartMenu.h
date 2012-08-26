//
//  StartMenu.h
//  theroom
//
//  Created by Ingimar Gudmundsson on 25/08/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// StartMenu
@interface StartMenu : CCLayer
{
    CCLabelTTF *_titleLabel;
}

// returns a CCScene that contains the StartMenu  as the only child
+(CCScene *) scene;

@end
