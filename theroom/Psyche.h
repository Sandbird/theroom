//
//  Psyche.h
//  theroom
//
//  Created by Ingimar Gudmundsson on 27/08/2012.
//
//

#import <Foundation/Foundation.h>

// Forward Declarations
@class ItemSelection;
@class CDSoundSource;

@interface MentalFactor : NSObject
{
	NSString *_name;
	NSUInteger _desire;
	NSInteger _score;
}

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSUInteger desire;
@property (nonatomic, readwrite) NSInteger score;

+ (id)mentalFactorWithName:(NSString *)name initialScore:(NSInteger)score;

@end

typedef enum
{
	kMentalStateInsane = 0,
	kMentalStateStable = 1,
	kMentalStateContent = 2
} MentalState;

@interface Psyche : NSObject
{
	NSMutableDictionary *_mentalFactors;
	NSMutableArray *_events;
	NSUInteger _numberOfDays;
	MentalState _mentalState;
	
	CDSoundSource *_goodFeedback;
	CDSoundSource *_badFeedback;
}

@property (nonatomic, readonly) NSUInteger numberOfDays;
@property (nonatomic, readonly) MentalState mentalState;

- (void)updateWithSelection:(ItemSelection *)selection;
- (void)contemplateDayEvents;

@end
