//
//  Psyche.m
//  theroom
//
//  Created by Ingimar Gudmundsson on 27/08/2012.
//
//

#import "Psyche.h"
#import "ItemSelector.h"
#import "SimpleAudioEngine.h"

@implementation MentalFactor

@synthesize name = _name;
@synthesize desire = _desire;
@synthesize score = _score;

+ (id)mentalFactorWithName:(NSString *)name initialScore:(NSInteger)score
{
	return [[[MentalFactor alloc] initWithName:name initialScore:score] autorelease];
}

- (id)initWithName:(NSString *)name initialScore:(NSInteger)score
{
	self = [super init];
	if (self != nil)
	{
		_name = [name retain];
		_desire = arc4random() % 3;
		_score = score;
	}
	
	return self;
}

@end

@implementation Psyche

@synthesize numberOfDays = _numberOfDays;
@synthesize mentalState = _mentalState;

static NSInteger minStableScore = 10;
static NSInteger minContentScore = 25;

- (id)init
{
    self = [super init];
    if (self)
	{
		NSString *pathToGameData = [[NSBundle mainBundle] pathForResource:@"gameData" ofType:@"plist"];
		NSDictionary *gameData = [NSDictionary dictionaryWithContentsOfFile:pathToGameData];
		_mentalFactors = [[NSMutableDictionary alloc] initWithCapacity:[gameData count]];
		[gameData enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
		 {
			 MentalFactor *mentalFactor = [MentalFactor mentalFactorWithName:key initialScore:5];
			 [_mentalFactors setObject:mentalFactor forKey:key];
		 }];
		_events = [[NSMutableArray alloc] initWithCapacity:[gameData count]];
        _numberOfDays = 1;
		_mentalState = kMentalStateStable;
		
		

		_goodFeedback = [[[SimpleAudioEngine sharedEngine] soundSourceForFile:@"yes2.wav"] retain];
		_goodFeedback.looping = NO;
		
		_badFeedback = [[[SimpleAudioEngine sharedEngine] soundSourceForFile:@"no2.wav"] retain];
		_badFeedback.looping = NO;
    }
    return self;
}

- (void)updateWithSelection:(ItemSelection *)selection
{

	MentalFactor *mentalFactor = [_mentalFactors objectForKey:selection.itemName];
	if (mentalFactor.desire == selection.itemNumber)
	{
		mentalFactor.score += 1;
		NSLog(@"Correct choice %@ increased by one, now %ld", selection.itemName, mentalFactor.score);
		[_goodFeedback play];
	}
	else
	{
		mentalFactor.score -= 2;
		NSLog(@"Wrong choice %@ decreased by two, now : %ld", selection.itemName, mentalFactor.score);
		
		[_badFeedback play];
	}
	
	[_events addObject:selection];
}

- (void)contemplateDayEvents
{
	++_numberOfDays;
	
	__block NSInteger overallScore = 0;
	[_mentalFactors enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
	 {
		 MentalFactor *mentalFactor = (MentalFactor *) obj;
		 overallScore += mentalFactor.score;
	 }];
	
	if (overallScore < minStableScore)
	{
		_mentalState = kMentalStateInsane;
	}
	else if (overallScore > minStableScore && overallScore < minContentScore)
	{
		_mentalState = kMentalStateStable;
	}
	else if (overallScore >= minContentScore)
	{
		_mentalState = kMentalStateContent;
	}
	
	// If the user gets it right make the person content
	if ([_events count] == [_mentalFactors count])
	{
		__block BOOL everythingCorrect = YES;
		[_events enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
		 {
			 ItemSelection *event = (ItemSelection *)obj;
			 MentalFactor *mentalFactor = [_mentalFactors objectForKey:event.itemName];
			 if (event.itemNumber != mentalFactor.desire)
			 {
				 everythingCorrect = NO;
				 *stop = YES;
			 }
		 }];
		
		if (everythingCorrect == YES)
		{
			_mentalState = kMentalStateContent;
		}
		
	}
	[_events removeAllObjects];
}



@end
