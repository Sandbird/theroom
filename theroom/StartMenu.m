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
		CCLabelTTF *playLabel = [CCLabelTTF labelWithString:@"ENTER" fontName:@"Arial" fontSize:24];
		CCMenuItem *playMenuItem = [CCMenuItemLabel itemWithLabel:playLabel block:^(id sender)
									{
										[[CCDirector sharedDirector] pushScene:[RoomLayer scene]];
										[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
									}];
		
		CCLabelTTF *quitLabel = [CCLabelTTF labelWithString:@"EXIT" fontName:@"Arial" fontSize:24];
		CCMenuItem *quitMenuItem = [CCMenuItemLabel itemWithLabel:quitLabel block:^(id sender)
									{
										[[NSApplication sharedApplication] terminate:self];
									}];
		quitMenuItem.position = ccp(500, 0);
		
		CCMenu *menu = [CCMenu menuWithItems:playMenuItem, quitMenuItem, nil];
		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
		menu.position = ccp(225, 242);
		[self addChild:menu];
		
		CCLabelTTF *noteLabel = [CCLabelTTF labelWithString:@"AUDIO IS IMPORTANT" fontName:@"Arial" fontSize:14];
        noteLabel.anchorPoint = ccp(1, 0);
		noteLabel.position = ccp(956, 4);
		[self addChild:noteLabel];
		
		CCLabelTTF *creditsLabel = [CCLabelTTF labelWithString:@"© 2012, Qboid" fontName:@"Arial" fontSize:14];
        creditsLabel.anchorPoint = ccp(0, 0);
		creditsLabel.position = ccp(4, 4);
		[self addChild:creditsLabel];
		
		_titleLabel = [CCLabelTTF labelWithString:@"THE ROOM" fontName:@"Arial" fontSize:74];
		_titleLabel.position = ccp (size.width / 2, size.height / 2);
        _titleLabel.opacity = 0;
		[self addChild:_titleLabel];
		
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"home again.mp3"];
	}
	return self;
}

- (void)onEnter
{
    [super onEnter];
    
    [_titleLabel runAction:[CCFadeIn actionWithDuration:2.0f]];
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