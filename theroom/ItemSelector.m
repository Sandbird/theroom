//
//  ItemSelector.m
//  theroom
//
//  Created by Marco Bancale on 8/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ItemSelector.h"

#define MENU_WIDTH 150.0f
#define ITEM_WIDTH 50.0f
#define ITEM_HEIGHT 42.0f

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
		// Register for mouse events
		CCDirector *director = [CCDirector sharedDirector];
		[[director eventDispatcher] addMouseDelegate:self priority:0];
		
		self.contentSize = CGSizeMake(MENU_WIDTH, ITEM_HEIGHT);
		self.anchorPoint = ccp(0.5f, 0.5f);
	}
	
	return self;
}

- (void)onEnter
{
	[super onEnter];
	
	
}

- (BOOL)ccMouseUp:(NSEvent *)event
{
	CGPoint locationInWindow = ccp(event.locationInWindow.x, event.locationInWindow.y);
	CGPoint eventLocation = [self convertToNodeSpace:locationInWindow];
	CGPoint finalPoint = ccpSub(eventLocation, ccp(MENU_WIDTH / 2, ITEM_HEIGHT / 2));
	
	if (finalPoint.y >= 0 && finalPoint.y <= ITEM_HEIGHT && finalPoint.x >= 0 && finalPoint.x <= MENU_WIDTH)
	{
		NSLog(@"Mouse Up Inside Menu, swallowing event");
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
