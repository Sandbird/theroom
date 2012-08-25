//
//  Character.m
//  theroom
//
//  Created by Ingimar Gudmundsson on 25/08/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Character.h"

@implementation Character

- (id)init
{
	self = [super init];
	if	(self != nil)
	{
		NSString *pathToAppearanceFront = [[NSBundle mainBundle] pathForResource:@"JohnnyFront" ofType:@"png"];
		_appearanceFront = [CCSprite spriteWithFile:pathToAppearanceFront];
		[self addChild:_appearanceFront];
		
		NSString *pathToAppearanceBack = [[NSBundle mainBundle] pathForResource:@"JohnnyBack" ofType:@"png"];
		_appearanceBack = [CCSprite spriteWithFile:pathToAppearanceBack];
		[self addChild:_appearanceBack];
		_appearanceBack.visible = NO;
		
		
		_waypointName = @"Entrance";
	}
	
	return self;
}

@end
