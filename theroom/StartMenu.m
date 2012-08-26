//
//  StartMenu.m
//  theroom
//
//  Created by Ingimar Gudmundsson on 25/08/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "StartMenu.h"
#import "RoomLayer.h"
#import "SimpleAudioEngine.h"


// Import the interfaces
#import "StartMenu.h"

// HelloWorldLayer implementation
@implementation StartMenu

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	StartMenu *layer = [StartMenu node];
	
	// add layer as a child to scene
	[scene addChild:layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init]) )
	{
		// create and initialize The game starting labels
		CCLabelTTF *playLabel = [CCLabelTTF labelWithString:@"Enter" fontName:@"Arial" fontSize:32];
		CCMenuItem *playMenuItem = [CCMenuItemLabel itemWithLabel:playLabel block:^(id sender)
									{
										NSLog(@"Play");
										[[CCDirector sharedDirector] pushScene:[RoomLayer scene]];
										[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
									}];
		
		CCLabelTTF *quitLabel = [CCLabelTTF labelWithString:@"Quit" fontName:@"Arial" fontSize:32];
		CCMenuItem *quitMenuItem = [CCMenuItemLabel itemWithLabel:quitLabel block:^(id sender)
									{
										[[NSApplication sharedApplication] terminate:self];
									}];
		quitMenuItem.position = ccp( 0, -100);
		
		CCMenu *menu = [CCMenu menuWithItems:playMenuItem, quitMenuItem, nil];
		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
		menu.position = ccp( size.width / 2, size.height / 2);
		[self addChild:menu];
		
		CCLabelTTF *noteLabel = [CCLabelTTF labelWithString:@"(You'll need a headset!)" fontName:@"Arial" fontSize:16];
		noteLabel.position = ccp (size.width / 2, (size.height / 2) - 24);
		[self addChild:noteLabel];
		
		CCLabelTTF *titleLabel = [CCLabelTTF labelWithString:@"THE ROOM" fontName:@"Arial" fontSize:74];
		titleLabel.position = ccp (size.width / 2, size.height - (size.height / 4));
		[self addChild:titleLabel];
		
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"home again.mp3"];
	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end