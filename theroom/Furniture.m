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

@synthesize name = _name;
@synthesize positionInRoom = _positionInRoom;

+ (id)furnitureWithData:(NSDictionary *)data
{
	return [[[Furniture alloc] initWithData:data] autorelease];
}

- (id)initWithData:(NSDictionary *)data
{
	self = [super init];
	if (self != nil)
	{
		NSString *pathToImage = [[NSBundle mainBundle] pathForResource:[data objectForKey:@"Image"] ofType:@"png"];
		_front = [CCSprite spriteWithFile:pathToImage];
		[self addChild:_front];
		
		pathToImage = [[NSBundle mainBundle] pathForResource:[data objectForKey:@"ActiveImage"] ofType:@"png"];
		_active = [CCSprite spriteWithFile:pathToImage];
		[self addChild:_active];
		
		_name = [[data objectForKey:@"Name"] retain];
		_positionInRoom = CGPointFromDictionary([data objectForKey:@"PositionInRoom"]);
		self.position = _positionInRoom;
		self.contentSize = _front.contentSize;
		
		[self showInactive];
		
		// Register for mouse events
		CCDirector *director = [CCDirector sharedDirector];
		[[director eventDispatcher] addMouseDelegate:self priority:0];
	}
	
	return self;
}

- (void)showInactive
{
	_active.visible = NO;
	_front.visible = YES;

	_activeState = NO;
}

- (void)showActive
{
	_active.visible = YES;
	_front.visible = NO;
	
	_activeState = YES;
}

- (BOOL)ccMouseUp:(NSEvent *)event
{
	CGPoint locationInWindow = ccp(event.locationInWindow.x, event.locationInWindow.y);
	CGPoint eventLocation = ccpSub(locationInWindow, _positionInRoom);
	CGPoint halfSize = ccpMult( ccp(_front.contentSize.width, _front.contentSize.height), 0.5f);

	if (ABS(eventLocation.x) <= halfSize.x && ABS(eventLocation.y) <= halfSize.y)
	{
		if (_activeState == YES)
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:@"kFurnitureNotActive" object:self];
		}
		else
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:@"kFurnitureActive" object:self];
		}
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
