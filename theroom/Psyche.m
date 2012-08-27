//
//  Psyche.m
//  theroom
//
//  Created by Ingimar Gudmundsson on 27/08/2012.
//
//

#import "Psyche.h"
#import "ItemSelector.h"

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

static NSInteger minStableScore = 6;
static NSInteger minContentScore = 12;

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
        _numberOfDays = 1;
		_mentalState = kMentalStateStable;
    }
    return self;
}

- (void)updateWithSelection:(ItemSelection *)selection
{
	++_numberOfDays;
	
	MentalFactor *mentalFactor = [_mentalFactors objectForKey:selection.itemName];
	if (mentalFactor.desire == selection.itemNumber)
	{
		mentalFactor.score += 1;
	}
	else
	{
		mentalFactor.score -= 2;
	}

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
	
	NSLog(@"Psyche Update: Current State %d, Current Score : %ld", _mentalState, overallScore);
}

@end
