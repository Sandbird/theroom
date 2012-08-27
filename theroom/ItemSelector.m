//
//  ItemSelector.m
//  theroom
//
//  Created by Marco Bancale on 8/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ItemSelector.h"

#import "NotificationConstants.h"

#define MENU_WIDTH 150.0f
#define ITEM_WIDTH 50.0f
#define ITEM_HEIGHT 42.0f

@implementation ItemSelection

@synthesize selectedTag = _selectedTag;
@synthesize itemNumber = _itemNumber;

+ (id)itemSelectionWithTag:(NSString *)selectedTag itemNumber:(NSUInteger)itemNumber
{
	return [[[ItemSelection alloc] initWithSelectionTag:selectedTag itemNumber:itemNumber] autorelease];
}

- (id)initWithSelectionTag:(NSString *)selectedTag itemNumber:(NSUInteger)itemNumber
{
	self = [super init];
	if (self != nil)
	{
		_selectedTag = [selectedTag retain];
		_itemNumber = itemNumber;
	}
	
	return self;
}

-(void)dealloc
{
	[_selectedTag release];
	[super dealloc];
}

@end

@implementation ItemSelector

- (id)initWithTag:(NSString *)tag
{
	self = [super init];
	if (self != nil)
	{
		_items = [[NSMutableArray alloc] initWithCapacity:3];
		_tag = [tag retain];
		
		for (NSUInteger i = 0; i < 3; ++i)
		{
			NSMutableDictionary *itemStates = [NSMutableDictionary dictionary];
			
			NSString *pathToImage = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@%lu", tag, i] ofType:@"png"];
			CCSprite *sprite = [CCSprite spriteWithFile:pathToImage];
			sprite.position = ccp(i * ITEM_WIDTH, 0);
			sprite.anchorPoint = CGPointZero;
			[self addChild:sprite];
			itemStates[@"normal"] = sprite;
			
			pathToImage = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@%luhover", tag, i] ofType:@"png"];
			sprite = [CCSprite spriteWithFile:pathToImage];
			sprite.position = ccp(i * ITEM_WIDTH, 0);
			sprite.anchorPoint = CGPointZero;
			sprite.visible = NO;
			[self addChild:sprite];
			itemStates[@"hover"] = sprite;
			
			pathToImage = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@%ludeactive", tag, i] ofType:@"png"];
			sprite = [CCSprite spriteWithFile:pathToImage];
			sprite.position = ccp(i * ITEM_WIDTH, 0);
			sprite.anchorPoint = CGPointZero;
			sprite.visible = NO;
			[self addChild:sprite];
			itemStates[@"deactive"] = sprite;
			
			[_items addObject:itemStates];
		}
/*
		if ([data objectForKey:@"Sound"] != nil)
		{
			_sound = [[[SimpleAudioEngine sharedEngine] soundSourceForFile:[data objectForKey:@"Sound"]] retain];
			_sound.looping = YES;
		}
*/
		
		_clicked = NO;
		
		// Register for mouse events
		CCDirector *director = [CCDirector sharedDirector];
		[[director eventDispatcher] addMouseDelegate:self priority:0];
		
		self.contentSize = CGSizeMake(MENU_WIDTH, ITEM_HEIGHT);
		self.anchorPoint = ccp(0.5f, 0.5f);
	}
	
	return self;
}

- (BOOL)ccMouseUp:(NSEvent *)event
{
    if (self.visible == NO || _clicked == YES)
    {
        return NO;
    }
    
	CGPoint locationInWindow = ccp(event.locationInWindow.x, event.locationInWindow.y);
	CGPoint eventLocation = [self convertToNodeSpace:locationInWindow];
	
	if (eventLocation.y >= 0 && eventLocation.y <= ITEM_HEIGHT && eventLocation.x >= 0 && eventLocation.x <= MENU_WIDTH)
	{
		NSUInteger index = (NSUInteger)(eventLocation.x / ITEM_WIDTH);

		for (NSUInteger i = 0; i < 3; ++i)
		{
			NSDictionary *itemStates = [_items objectAtIndex:i];
			
			CCSprite *normalSprite = itemStates[@"normal"];
			CCSprite *hoverSprite = itemStates[@"hover"];
			CCSprite *deactiveSprite = itemStates[@"deactive"];
			
			normalSprite.visible = (i == index);
			hoverSprite.visible = NO;
			deactiveSprite.visible = (i != index);
		}
		
		_clicked = YES;
		
		[self runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:0.5f] two:[CCCallBlock actionWithBlock:^
		{
			for (NSUInteger i = 0; i < 3; ++i)
			{
				NSDictionary *itemStates = [_items objectAtIndex:i];
				
				CCSprite *normalSprite = itemStates[@"normal"];
				CCSprite *deactiveSprite = itemStates[@"deactive"];
				
				[normalSprite runAction:[CCFadeOut actionWithDuration:0.5f]];
				[deactiveSprite runAction:[CCFadeOut actionWithDuration:0.5f]];
			}
		}]]];
		
		[self runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:1.0f] two:[CCCallBlock actionWithBlock:^
		{
			self.visible = NO;
			_clicked = NO;
			
			[[NSNotificationCenter defaultCenter] postNotificationName:kMenuItemSelected object:[ItemSelection itemSelectionWithTag:_tag itemNumber:index]];
			
			for (NSUInteger i = 0; i < 3; ++i)
			{
				NSDictionary *itemStates = [_items objectAtIndex:i];
				
				CCSprite *normalSprite = [itemStates objectForKey:@"normal"];
				CCSprite *hoverSprite = [itemStates objectForKey:@"hover"];
				CCSprite *deactiveSprite = [itemStates objectForKey:@"deactive"];
				
				normalSprite.opacity = 0xFF;
				normalSprite.visible = YES;
				hoverSprite.opacity = 0xFF;
				hoverSprite.visible = YES;
				deactiveSprite.opacity = 0xFF;
				deactiveSprite.visible = YES;
			}
		}]]];
		
		NSLog(@"Mouse Up Inside Menu, swallowing event");
		return YES;
	}
	else
	{
		self.visible = NO;
		_clicked = NO;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kMenuItemCancelled object:nil];
		
		return YES;
	}
	
	return NO;
}

- (BOOL)ccMouseMoved:(NSEvent *)event
{
    if (self.visible == NO || _clicked == YES)
    {
        return NO;
    }
    
	CGPoint locationInWindow = ccp(event.locationInWindow.x, event.locationInWindow.y);
	CGPoint eventLocation = [self convertToNodeSpace:locationInWindow];
	
	if (eventLocation.y >= 0 && eventLocation.y <= ITEM_HEIGHT && eventLocation.x >= 0 && eventLocation.x <= MENU_WIDTH)
	{
		NSUInteger index = (NSUInteger)(eventLocation.x / ITEM_WIDTH);

		for (NSUInteger i = 0; i < 3; ++i)
		{
			NSDictionary *itemStates = [_items objectAtIndex:i];
			
			CCSprite *normalSprite = itemStates[@"normal"];
			CCSprite *hoverSprite = itemStates[@"hover"];
			
			normalSprite.visible = YES;
			hoverSprite.visible = (i == index);			
		}
		
		return YES;
	}
	else
	{
		for (NSUInteger i = 0; i < 3; ++i)
		{
			NSDictionary *itemStates = [_items objectAtIndex:i];
			
			CCSprite *normalSprite = itemStates[@"normal"];
			CCSprite *hoverSprite = itemStates[@"hover"];
			
			normalSprite.visible = YES;
			normalSprite.opacity = 0xFF;
			hoverSprite.visible = NO;
			hoverSprite.opacity = 0xFF;
		}
		
		return YES;
	}
	
	return NO;
}

- (void)dealloc
{
	[_items release];
	
	[super dealloc];
}

@end
