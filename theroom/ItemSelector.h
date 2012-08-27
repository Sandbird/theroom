//
//  ItemSelector.h
//  theroom
//
//  Created by Marco Bancale on 8/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface ItemSelection : NSObject
{
	NSString *_selectedTag;
	NSUInteger _itemNumber;
}

@property (nonatomic, readonly) NSString *selectedTag;
@property (nonatomic, readonly) NSUInteger itemNumber;

+ (id)itemSelectionWithTag:(NSString *)selectedTag itemNumber:(NSUInteger)itemNumber;

@end

@interface ItemSelector : CCNode <CCMouseEventDelegate>
{
    NSMutableArray *_items;
	NSString *_tag;
}

- (id)initWithTag:(NSString *)tag;

@end
