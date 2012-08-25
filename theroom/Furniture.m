//
//  Bed.m
//  theroom
//
//  Created by Ingimar Gudmundsson on 25/08/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Furniture.h"
#import "UtilityFunctions.h"

@implementation Furniture

+ (id)furnitureWithData:(NSDictionary *)data
{
	return [[[Furniture alloc] initWithData:data] autorelease];
}

- (id)initWithData:(NSDictionary *)data
{
	self = [super init];
	if (self != nil)
	{
		NSString *pathToImage = [[NSBundle mainBundle] pathForResource:data[@"Image"] ofType:@"png"];
		_front = [CCSprite spriteWithFile:pathToImage];
		[self addChild:_front];
		_name = [data[@"Name"] retain];
		_positionInRoom = CGPointFromDictionary(data[@"PositionInRoom"]);
		self.position = _positionInRoom;
		self.contentSize = _front.contentSize;
		
		
		// Register for mouse events
		CCDirector *director = [CCDirector sharedDirector];
		[[director eventDispatcher] addMouseDelegate:self priority:0];

	}
	
	return self;
}

- (BOOL)ccMouseUp:(NSEvent *)event
{
	CGPoint eventLocation = ccpSub(event.locationInWindow,_positionInRoom);
	CGPoint halfSize = ccpMult( ccp(_front.contentSize.width, _front.contentSize.height), 0.5f);

	if (ABS(eventLocation.x) <= halfSize.x && ABS(eventLocation.y) <= halfSize.y)
	{
		NSLog(@"Mouse Up Inside Furniture, swallowing event");
		return YES;
	}

	return NO;
}

- (void)dealloc
{
	[[[CCDirector sharedDirector] eventDispatcher] removeMouseDelegate:self];
	[_name release];
	[super dealloc];
}

@end