//
//  ItemSelector.h
//  theroom
//
//  Created by Marco Bancale on 8/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface ItemSelector : CCNode <CCMouseEventDelegate>
{
    NSMutableArray *_items;
	NSString *_tag;
}

- (id)initWithTag:(NSString *)tag;

@end
