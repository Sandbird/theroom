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
		NSString *pathToAppearance = [[NSBundle mainBundle] pathForResource:@"Johnny" ofType:@"png"];
		_appearance = [CCSprite spriteWithFile:pathToAppearance];
		[self addChild:_appearance];
	}
	
	return self;
}

@end
