//
//  Psyche.m
//  theroom
//
//  Created by Ingimar Gudmundsson on 27/08/2012.
//
//

#import "Psyche.h"

@implementation MentalFactor

@synthesize name = _name;
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
		_score = score;
	}
	
	return self;
}

@end

@implementation Psyche

@synthesize numberOfDays = _numberOfDays;

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
    }
    return self;
}

- (BOOL)isMentallyStable
{
	return YES;
}

- (void)updateWithSelection:(ItemSelection *)selection
{
	++_numberOfDays;
}

@end
