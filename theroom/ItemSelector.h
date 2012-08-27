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
	NSString *_itemName;
	NSUInteger _itemNumber;
}

@property (nonatomic, readonly) NSString *itemName;
@property (nonatomic, readonly) NSUInteger itemNumber;

+ (id)itemSelectionWithName:(NSString *)itemName itemNumber:(NSUInteger)itemNumber;

@end

@interface ItemSelector : CCNode <CCMouseEventDelegate>
{
    NSMutableArray *_items;
	NSString *_tag;
	NSString *_furnitureName;
	
	BOOL _clicked;
}

- (id)initWithTag:(NSString *)tag furnitureName:(NSString *)furnitureName;

@end
