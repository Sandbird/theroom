//
//  UtilityFunctions.h
//  theroom
//
//  Created by Ingimar Gudmundsson on 25/08/2012.
//
//

#ifndef theroom_UtilityFunctions_h
#define theroom_UtilityFunctions_h

static inline CGPoint CGPointFromDictionary(NSDictionary *dictionary)
{
	if([dictionary objectForKey:@"X"] != nil && [dictionary objectForKey:@"Y"] != nil)
	{
		return CGPointMake([[dictionary objectForKey:@"X"] floatValue], [[dictionary objectForKey:@"Y"] floatValue]);
	}
	else
	{
		NSLog(@"WARNING: Trying to create CGPoint from dictionary that doesn't contain X and Y as keys");
		return CGPointZero;
	}
}

#endif
