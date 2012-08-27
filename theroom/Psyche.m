//
//  Psyche.m
//  theroom
//
//  Created by Ingimar Gudmundsson on 27/08/2012.
//
//

#import "Psyche.h"

@implementation Psyche

@synthesize numberOfDays = _numberOfDays;

- (id)init
{
    self = [super init];
    if (self) {
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
