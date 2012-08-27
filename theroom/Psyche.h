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

@interface MentalFactor : NSObject
{
	NSString *_name;
	NSInteger _score;
}

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readwrite) NSInteger score;

+ (id)mentalFactorWithName:(NSString *)name initialScore:(NSInteger)score;

@end

@interface Psyche : NSObject
{
	NSMutableDictionary *_mentalFactors;
	NSUInteger _numberOfDays;
}

@property (nonatomic, readonly) NSUInteger numberOfDays;

- (BOOL)isMentallyStable;
- (void)updateWithSelection:(ItemSelection *)selection;

@end
