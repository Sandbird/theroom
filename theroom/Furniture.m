//
//  Bed.m
//  theroom
//
//  Created by Ingimar Gudmundsson on 25/08/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Furniture.h"
#import "NotificationConstants.h"
#import "UtilityFunctions.h"
#import "SimpleAudioEngine.h"
#import "ItemSelector.h"

@implementation Furniture

@synthesize name = _name;
@synthesize closestWaypointName = _closestWaypointName;
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
		_closestWaypointName = [[data objectForKey:@"ClosestWayPoint"] retain];
		_positionInRoom = CGPointFromDictionary([data objectForKey:@"PositionInRoom"]);
		self.position = _positionInRoom;
		
		_itemSelector = [[ItemSelector alloc] initWithTag:[data objectForKey:@"Image"]];
		_itemSelector.position = CGPointFromDictionary([data objectForKey:@"MenuPosition"]);
        _itemSelector.visible = NO;
		[self addChild:_itemSelector];
		
		if ([data objectForKey:@"Sound"] != nil)
		{
			_sound = [[[SimpleAudioEngine sharedEngine] soundSourceForFile:[data objectForKey:@"Sound"]] retain];
			_sound.looping = YES;
		}
		
		[self showInactive];
		
		// Register for mouse events
		CCDirector *director = [CCDirector sharedDirector];
		[[director eventDispatcher] addMouseDelegate:self priority:1];
	}
	
	return self;
}

- (void)showInactive
{
	_active.visible = NO;
	_front.visible = YES;
	[_sound stop];

    _itemSelector.visible = NO;
    
	_activeState = NO;
}

- (void)showActive
{
	_active.visible = YES;
	_front.visible = NO;
	[_sound play];
	
    _itemSelector.visible = YES;
    
	_activeState = YES;
}

- (BOOL)ccMouseUp:(NSEvent *)event
{
	CGPoint locationInWindow = ccp(event.locationInWindow.x, event.locationInWindow.y);
	CGPoint eventLocation = [self convertToNodeSpace:locationInWindow];
	CGPoint halfSize = ccpMult( ccp(_front.contentSize.width, _front.contentSize.height), 0.5f);

	if (ABS(eventLocation.x) <= halfSize.x && ABS(eventLocation.y) <= halfSize.y)
	{
		if (_activeState == YES)
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:kFurnitureNotActive object:self];
		}
		else
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:kFurnitureActive object:self];
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
	[_closestWaypointName release];
	[_itemSelector release];
	
	[super dealloc];
}

@end
