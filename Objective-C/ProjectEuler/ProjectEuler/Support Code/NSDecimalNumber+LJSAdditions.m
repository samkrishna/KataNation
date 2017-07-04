// Copyright 2012 Little Joy Software. All rights reserved.
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in
//       the documentation and/or other materials provided with the
//       distribution.
//     * Neither the name of the Little Joy Software nor the names of its
//       contributors may be used to endorse or promote products derived
//       from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY LITTLE JOY SOFTWARE ''AS IS'' AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
// PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL LITTLE JOY SOFTWARE BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
// OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
// IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#if !__has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import <objc/runtime.h>
#import "NSDecimalNumber+LJSAdditions.h"

@interface LjsInterval ()
@property (nonatomic, readwrite, strong) NSDecimalNumber *min;
@property (nonatomic, readwrite, strong) NSDecimalNumber *max;
@end

@implementation LjsInterval

+ (LjsInterval *)intervalWithMin:(NSDecimalNumber *)min max:(NSDecimalNumber *)max
{
    return [[LjsInterval alloc] initWithMin:min max:max];
}

+ (LjsInterval *)intervalWithMidpoint:(NSDecimalNumber *)midpoint delta:(CGFloat)delta
{
    NSCParameterAssert(delta > 0.0);
    NSDecimalNumber *deltaDN = [LjsDn dnWithFloat:delta];
    return [self intervalWithMidpoint:midpoint deltaDN:deltaDN];
}

+ (LjsInterval *)intervalWithMidpoint:(NSDecimalNumber *)midpoint deltaDN:(NSDecimalNumber *)deltaDN
{
    return [self intervalWithMin:[midpoint dnBySubtracting:deltaDN] max:[midpoint dnByAdding:deltaDN]];
}

+ (LjsInterval *)intervalWithNumber:(NSDecimalNumber *)number minusMinOffset:(NSDecimalNumber *)minOffset plusMaxOffset:(NSDecimalNumber *)maxOffset
{
    return [self intervalWithMin:[number dnBySubtracting:minOffset] max:[number dnByAdding:maxOffset]];
}

- (id)initWithMin:(NSDecimalNumber *)aMin max:(NSDecimalNumber *)aMax
{
    if (!(self = [super init])) return nil;

    NSCParameterAssert([aMin lte:aMax]);
    
    _min = aMin;
    _max = aMax;
    
    return self;
}

- (NSDecimalNumber *)length
{
    return [self.max dnBySubtracting:self.min];
}

- (NSDecimalNumber *)firstQuartile
{
    NSUInteger scale = [self _roundingScale];
    return [LjsDn midpointBetweenFirstDN:self.min andSecondDN:self.mid roundingScale:scale delta:NULL];
}

- (NSDecimalNumber *)thirdQuartile
{
    NSUInteger scale = [self _roundingScale];
    return [LjsDn midpointBetweenFirstDN:self.mid andSecondDN:self.max roundingScale:scale delta:NULL];
}

- (NSUInteger)_roundingScale
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(\\.\\d+)" options:0 error:&error];
    NSString *minString = [self.min description];
    NSRange stringRange = NSMakeRange(0, [minString length]);
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:minString options:0 range:stringRange];
    NSUInteger scale = 1;
    
    if (numberOfMatches) {
        NSRange matchRange = [regex rangeOfFirstMatchInString:minString options:0 range:stringRange];
        NSString *substring = [minString substringWithRange:matchRange];
        scale = [substring length];
    }

    return scale;
}

- (NSDecimalNumber *)mid
{
    NSUInteger scale = [self _roundingScale];
    return [LjsDn midpointBetweenFirstDN:self.min andSecondDN:self.max roundingScale:scale delta:NULL];
}

- (BOOL)isEqual:(id)object
{
    LjsInterval *target = object;
    return ([self.min e:target.min] && [self.max e:target.max]);
}

- (BOOL)intervalContains:(NSDecimalNumber *)aNumber
{
    NSCParameterAssert(aNumber);
    return [LjsDn dn:aNumber isOnMin:self.min max:self.max];
}

- (NSString *)description
{
    NSString *desc;

    if ([self.min e:[LjsDn min]] && [self.max e:[LjsDn max]]) {
        desc = [NSString stringWithFormat:@"[ MIN, MAX ]"];
    }
    else if ([self.min e:[LjsDn min]] && [self.max dne:[LjsDn max]]) {
        desc = [NSString stringWithFormat:@"[ MIN, %@ ]", self.max];
    }
    else if ([self.min dne:[LjsDn min]] && [self.max e:[LjsDn max]]) {
        desc = [NSString stringWithFormat:@"[ %@, MAX ]", self.min];
    }
    else {
        desc = [NSString stringWithFormat:@"[ %@, %@ ]", self.min, self.max];
    }
    
    return desc;
}

- (NSString *)descriptionWithMidpoint
{
    NSString *desc;
    
    if ([self.min e:[LjsDn min]] && [self.max e:[LjsDn max]]) {
        desc = [NSString stringWithFormat:@"[ MIN, %@, MAX ]", self.mid];
    }
    else if ([self.min e:[LjsDn min]] && [self.max dne:[LjsDn max]]) {
        desc = [NSString stringWithFormat:@"[ MIN, %@, %@ ]", self.mid, self.max];
    }
    else if ([self.min dne:[LjsDn min]] && [self.max e:[LjsDn max]]) {
        desc = [NSString stringWithFormat:@"[ %@, %@, MAX ]", self.min, self.mid];
    }
    else {
        desc = [NSString stringWithFormat:@"[ %@, %@, %@ ]", self.min, self.mid, self.max];
    }
    
    return desc;
}

- (NSDecimalNumber *)numberClosestToTarget:(NSDecimalNumber *)target
{
    NSDecimalNumber *minDistance = [[self.min dnBySubtracting:target] abs];
    NSDecimalNumber *maxDistance = [[self.max dnBySubtracting:target] abs];
    NSDecimalNumber *midDistance = [[self.mid dnBySubtracting:target] abs];
    NSArray *distances = @[ minDistance, midDistance, maxDistance ];
    NSArray *sortedDistances = [distances sortedArrayUsingSelector:@selector(compare:)];
    
    if (sortedDistances[0] == minDistance) {
        return self.min;
    }
    else if (sortedDistances[0] == midDistance) {
        return self.mid;
    }
    
    return self.max;
}

- (NSDecimalNumber *)edgeNumberClosestToTarget:(NSDecimalNumber *)target
{
    NSDecimalNumber *minDistance = [[self.min dnBySubtracting:target] abs];
    NSDecimalNumber *maxDistance = [[self.max dnBySubtracting:target] abs];
    NSArray *distances = @[ minDistance, maxDistance ];
    NSArray *sortedDistances = [distances sortedArrayUsingSelector:@selector(compare:)];
    
    if (sortedDistances[0] == minDistance) {
        return self.min;
    }
    
    return self.max;
}

- (NSDecimalNumber *)numberFarthestFromTarget:(NSDecimalNumber *)target
{
    NSDecimalNumber *minDistance = [[self.min dnBySubtracting:target] abs];
    NSDecimalNumber *maxDistance = [[self.max dnBySubtracting:target] abs];
    NSDecimalNumber *midDistance = [[self.mid dnBySubtracting:target] abs];
    NSArray *distances = @[ minDistance, midDistance, maxDistance ];
    NSArray *sortedDistances = [distances sortedArrayUsingSelector:@selector(compare:)];
    return sortedDistances[2];
}

- (BOOL)isEqualToInterval:(LjsInterval *)interval
{
    return ([self.max e:interval.max] && [self.min e:interval.min]);
}

@end

/**
 NSDecimalNumber is a powerful tool for handling currency, statistics, and other
 floating point data.  The class name and the methods are, in my opinion, overly
 verbose and tend to clutter code at the worse times - when you are doing
 sensitive currency calculations or implementing a complex confusing statistical
 algorithm.  And who can remember how to compare two NSDecimalNumbers?
 
 Enter LjsDn - which provides methods for creating NSDecimalNumbers
 from various numeric values, logical comparisons and rounding.
 
 */
@implementation LjsDn

+ (NSDecimalNumber *)nan
{
    return [NSDecimalNumber notANumber];
}

+ (NSDecimalNumber *)one
{
    @autoreleasepool {
        return [NSDecimalNumber one];
    }
}

+ (NSDecimalNumber *)zero
{
    @autoreleasepool {
        return [NSDecimalNumber zero];
    }
}

+ (NSDecimalNumber *)min
{
    return [NSDecimalNumber minimumDecimalNumber];
}

+ (NSDecimalNumber *)max
{
    return [NSDecimalNumber maximumDecimalNumber];
}

/**
 @return a decimal number with the BOOL value
 @param aBool a BOOL value
 */
+ (NSDecimalNumber *)dnWithBool:(BOOL)aBool
{
    NSCParameterAssert(aBool == YES || aBool == NO);
    
    @autoreleasepool {
        NSString *numberString = [NSString stringWithFormat:@"%d", aBool];
        return [LjsDn dnWithString:numberString];
    }
}

/**
 @return a decimal number with the NSInteger value
 @param aInteger an integer
 */
+ (NSDecimalNumber *)dnWithInteger:(NSInteger)aInteger
{
    @autoreleasepool {
        NSString *numberString = [NSString stringWithFormat:@"%ld", aInteger];
        return [LjsDn dnWithString:numberString];
    }
}

/**
 @return a decimal number with the NSUInteger value
 @param aUInteger a uinteger
 */
+ (NSDecimalNumber *)dnWithUInteger:(NSUInteger)aUInteger
{
    @autoreleasepool {
        NSString *numberString = [NSString stringWithFormat:@"%lu", aUInteger];
        return [LjsDn dnWithString:numberString];
    }
}

/**
 @return a decimal number with the double value
 @param aDouble a double
 */
+ (NSDecimalNumber *)dnWithDouble:(double)aDouble
{
    @autoreleasepool {
        return [LjsDn dnWithNumber:@(aDouble)];
    }
}

/**
 @return a decimal number with the CGFloat value
 @param aFloat a CGFloat
 */
+ (NSDecimalNumber *)dnWithFloat:(CGFloat)aFloat
{
    @autoreleasepool {
        return [LjsDn dnWithNumber:@(aFloat)];
    }
}

/**
 @return a decimal number with the string value
 @param aString a string
 */
+ (NSDecimalNumber *)dnWithString:(NSString *)aString
{
    if (!aString) return nil;
    NSDecimal result;
    @autoreleasepool {
        NSScanner *theScanner = [[NSScanner alloc] initWithString:aString];
        [theScanner scanDecimal:&result];
        return [NSDecimalNumber decimalNumberWithDecimal:result];
    }
}

/**
 @return a decimal number from aNumber
 @param aNumber a number
 */
+ (NSDecimalNumber *)dnWithNumber:(NSNumber *)aNumber
{
    if (object_getClass(aNumber) == [NSDecimalNumber class]) {
        return (NSDecimalNumber *)aNumber;
    }
    
    @autoreleasepool {
        return [NSDecimalNumber decimalNumberWithDecimal:[aNumber decimalValue]];
    }
}

/**
 @return a decimal number from aDecimal
 @param aDecimal an NSDecimal struct
 */
+ (NSDecimalNumber *)dnWithDecimal:(NSDecimal)aDecimal
{
    @autoreleasepool {
        return [NSDecimalNumber decimalNumberWithDecimal:aDecimal];
    }
}

/**
 @return true iff a = b
 @param a left hand side
 @param b right hand side
 */
+ (BOOL)dn:(NSDecimalNumber *)a e:(NSDecimalNumber *)b
{
    NSDecimal aDec = [a decimalValue];
    NSDecimal bDec = [b decimalValue];
    return (NSDecimalCompare(&aDec, &bDec) == NSOrderedSame);
}

/**
 @return scaled absolute value of midpoint between a = b
 @param a left hand side
 @param b right hand side
 @param scale rounding scale
 */
+ (NSDecimalNumber *)midpointBetweenFirstDN:(NSDecimalNumber *)a andSecondDN:(NSDecimalNumber *)b roundingScale:(NSUInteger)scale delta:(NSDecimalNumber **)delta
{
    NSParameterAssert(a);
    NSParameterAssert(b);
    
    NSDecimal deltaSub;
    NSDecimal midpoint;
    NSDecimal aMinusB;
    NSDecimal aDecimal = [a decimalValue];
    NSDecimal bDecimal = [b decimalValue];
    NSDecimal resultDecimal;
    NSDecimal two = [@2 decimalValue];

    NSDecimalSubtract(&aMinusB, &aDecimal, &bDecimal, NSRoundPlain);
    NSDecimalDivide(&resultDecimal, &aMinusB, &two, NSRoundPlain);
    
    if ([a gt:b]) {
        NSDecimal absResult = [[[LjsDn dnWithDecimal:resultDecimal] abs] decimalValue];
        NSDecimalSubtract(&midpoint, &aDecimal, &absResult, NSRoundPlain);
        NSDecimalSubtract(&deltaSub, &aDecimal, &midpoint, NSRoundPlain);
    }
    else {
        NSDecimal absResult = [[[LjsDn dnWithDecimal:resultDecimal] abs] decimalValue];
        NSDecimalSubtract(&midpoint, &bDecimal, &absResult, NSRoundPlain);
        NSDecimalSubtract(&deltaSub, &bDecimal, &midpoint, NSRoundPlain);
    }
    
    if (delta != NULL) {
        *delta = [LjsDn dnWithDecimal:deltaSub];
    }

    NSDecimal midpointResult;
    NSDecimalRound(&midpointResult, &midpoint, (NSInteger)scale, NSRoundPlain);
    return [LjsDn dnWithDecimal:midpointResult];
}

/***
 @return true iff a lt b
 @param a left hand side
 @param b right hand side
 */
+ (BOOL)dn:(NSDecimalNumber *)a lt:(NSDecimalNumber *)b
{
    NSDecimal aDec = [a decimalValue];
    NSDecimal bDec = [b decimalValue];
    return (NSDecimalCompare(&aDec, &bDec) == NSOrderedAscending);
}

/**
 @return true iff a gt b
 @param a left hand side
 @param b right hand side
 */
+ (BOOL)dn:(NSDecimalNumber *)a gt:(NSDecimalNumber *)b
{
    NSDecimal aDec = [a decimalValue];
    NSDecimal bDec = [b decimalValue];
    return (NSDecimalCompare(&aDec, &bDec) == NSOrderedDescending);
}

/**
 @return true iff a lte b
 @param a left hand side
 @param b right hand side
 */
+ (BOOL)dn:(NSDecimalNumber *)a lte:(NSDecimalNumber *)b
{
    NSDecimal aDec = [a decimalValue];
    NSDecimal bDec = [b decimalValue];
    return (NSDecimalCompare(&aDec, &bDec) != NSOrderedDescending);
}

/**
 @return true iff a gte b
 @param a left hand side
 @param b right hand side
 */
+ (BOOL)dn:(NSDecimalNumber *)a gte:(NSDecimalNumber *)b
{
    NSDecimal aDec = [a decimalValue];
    NSDecimal bDec = [b decimalValue];
    return (NSDecimalCompare(&aDec, &bDec) != NSOrderedAscending);
}

/**
 @return return true iff a is on (min, max)
 @param a number to test
 @param min lower bound of range
 @param max upper bound or range
 */
+ (BOOL)dn:(NSDecimalNumber *)a isOnMin:(NSDecimalNumber *)min max:(NSDecimalNumber *)max
{
    return [LjsDn dn:a gte:min] && [LjsDn dn:a lte:max];
}

+ (BOOL)dn:(NSDecimalNumber *)a isOnInterval:(LjsInterval *)aInterval
{
    return [aInterval intervalContains:a];
}

/**
 @return rounded decimal number with handler
 @param number the number to round
 @param handler the handler to use
 */
+ (NSDecimalNumber *)round:(NSDecimalNumber *)number withHandler:(NSDecimalNumberHandler *)handler
{
    @autoreleasepool {
        return [number decimalNumberByMultiplyingBy:[NSDecimalNumber one] withBehavior:handler];
    }
}


/**
 NB: typically you will want to use NSRoundPlain for statistics
 
 @return a handler with mode and scale
 @param aMode a rounding mode
 @param aInteger a scale (precision)
 */
+ (NSDecimalNumberHandler *)statisticsHandlerWithRoundMode:(NSRoundingMode)aMode scale:(short)aInteger
{
    @autoreleasepool {
        return [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:aMode scale:aInteger raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES];
    }
}

/**
 NB: typically you will want to use NSRoundPlain for location
 
 @return a handler with mode and scale
 @param aMode a rounding mode
 @param aInteger a scale (precision)
 */
+ (NSDecimalNumberHandler *)locationHandlerWithRoundMode:(NSRoundingMode)aMode scale:(short)aInteger
{
    @autoreleasepool {
        return [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:aMode scale:aInteger raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES];
    }
}

+ (NSDecimalNumber *)moduloOfDividend:(NSDecimalNumber *)dividend andDivisor:(NSDecimalNumber *)divisor
{
    NSRoundingMode roundingMode = ((dividend.floatValue < 0) ^ (divisor.floatValue < 0)) ? NSRoundUp : NSRoundDown;
    
    NSDecimal dividendDecimal = [dividend decimalValue];
    NSDecimal divisorDecimal = [divisor decimalValue];
    NSDecimal quotientDecimal;
    
    NSDecimalDivide(&quotientDecimal, &dividendDecimal, &divisorDecimal, roundingMode);
    NSDecimal finalQuotient;
    NSDecimalRound(&finalQuotient, &quotientDecimal, 0, roundingMode);
    
    NSDecimal subtractAmountDecimal;
    NSDecimalMultiply(&subtractAmountDecimal, &finalQuotient, &divisorDecimal, roundingMode);
    
    NSDecimal remainderDecimal;
    NSDecimalSubtract(&remainderDecimal, &dividendDecimal, &subtractAmountDecimal, roundingMode);

    return [LjsDn dnWithDecimal:remainderDecimal];
}

+ (NSDecimalNumber *)quotientOfDividend:(NSDecimalNumber *)dividend andDivisor:(NSDecimalNumber *)divisor
{
    @autoreleasepool {
        NSRoundingMode roundingMode = ((dividend.floatValue < 0) ^ (divisor.floatValue < 0)) ? NSRoundUp : NSRoundDown;
        NSDecimalNumberHandler *roundingHandler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:roundingMode scale:0 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES];
        NSDecimalNumber *quotient = [dividend decimalNumberByDividingBy:divisor withBehavior:roundingHandler];
        return quotient;
    }
}


@end

@implementation NSDecimalNumber (LjsAdditions)

/** @name Task Section */
- (BOOL)dne:(NSDecimalNumber *)other
{
    return ![LjsDn dn:self e:other];
}

- (BOOL)e:(NSDecimalNumber *)other
{
    return [LjsDn dn:self e:other];
}

- (BOOL)lt:(NSDecimalNumber *)other
{
    return [LjsDn dn:self lt:other];
}

- (BOOL)gt:(NSDecimalNumber *)other
{
    return [LjsDn dn:self gt:other];
}

- (BOOL)lte:(NSDecimalNumber *)other
{
    return [LjsDn dn:self lte:other];
}

- (BOOL)gte:(NSDecimalNumber *)other
{
    return [LjsDn dn:self gte:other];
}

- (BOOL)isOnIntervalWithMin:(NSDecimalNumber *)aMin max:(NSDecimalNumber *)aMax
{
    return [LjsDn dn:self isOnMin:aMin max:aMax];
}

- (BOOL)isNan
{
    NSDecimal decimal = [self decimalValue];
    NSDecimal nanDecimal = [[LjsDn nan] decimalValue];
    return (NSDecimalCompare(&decimal, &nanDecimal) == NSOrderedSame);
}

- (NSDecimalNumber *)dnByRoundingWithHandler:(NSDecimalNumberHandler *)aHandler
{
    return [LjsDn round:self withHandler:aHandler];
}

- (NSDecimalNumber *)dnByRoundingWithScale:(NSUInteger)aScale
{
    NSDecimal decimal = [self decimalValue];
    NSDecimal result;
    NSDecimalRound(&result, &decimal, (NSInteger)aScale, NSRoundPlain);
    @autoreleasepool {
        return [NSDecimalNumber decimalNumberWithDecimal:result];
    }
}

- (NSDecimalNumber *)dnByBankersRoundingWithScale:(NSUInteger)aScale
{
    NSDecimal decimal = [self decimalValue];
    NSDecimal result;
    NSDecimalRound(&result, &decimal, (NSInteger)aScale, NSRoundBankers);
    @autoreleasepool {
        return [NSDecimalNumber decimalNumberWithDecimal:result];
    }
}

- (NSDecimalNumber *)dnByRoundingAsLocation
{
    return [self dnByRoundingWithScale:8];
}

- (NSDecimalNumber *)maxCompare:(NSDecimalNumber *)comparison
{
    return ([self gte:comparison]) ? self : comparison;
}

- (NSDecimalNumber *)minCompare:(NSDecimalNumber *)comparison
{
    return ([self lte:comparison]) ? self : comparison;
}

- (CGFloat)cgFloatValue
{
    return [self doubleValue];
}

- (NSDecimalNumber *)dnByAdding:(NSDecimalNumber *)decimalNumber
{
    NSDecimal selfDec = [self decimalValue];
    NSDecimal dnDecimal = [decimalNumber decimalValue];
    NSDecimal result;
    NSDecimalAdd(&result, &selfDec, &dnDecimal, NSRoundPlain);
    return [LjsDn dnWithDecimal:result];
}

- (NSDecimalNumber *)dnByAdding:(NSDecimalNumber *)decimalNumber withBehavior:(id <NSDecimalNumberBehaviors>)behavior
{
    NSCParameterAssert(decimalNumber);
    NSCParameterAssert(behavior);
    @autoreleasepool {
        return [self decimalNumberByAdding:decimalNumber withBehavior:behavior];
    }
}

- (NSDecimalNumber *)dnBySubtracting:(NSDecimalNumber *)decimalNumber
{
    NSDecimal selfDec = [self decimalValue];
    NSDecimal dnDecimal = [decimalNumber decimalValue];
    NSDecimal result;
    NSDecimalSubtract(&result, &selfDec, &dnDecimal, NSRoundPlain);
    return [LjsDn dnWithDecimal:result];
}

- (NSDecimalNumber *)dnBySubtracting:(NSDecimalNumber *)decimalNumber withBehavior:(id <NSDecimalNumberBehaviors>)behavior
{
    NSCParameterAssert(decimalNumber);
    NSCParameterAssert(behavior);
    @autoreleasepool {
        return [self decimalNumberBySubtracting:decimalNumber withBehavior:behavior];
    }
}

- (NSDecimalNumber *)dnByMultiplyingFloat:(CGFloat)floatNumber
{
    return [self dnByMultiplyingBy:[LjsDn dnWithFloat:floatNumber]];
}

- (NSDecimalNumber *)dnByMultiplyingBy:(NSDecimalNumber *)decimalNumber
{
    NSDecimal selfDec = [self decimalValue];
    NSDecimal dnDecimal = [decimalNumber decimalValue];
    NSDecimal result;
    NSDecimalMultiply(&result, &selfDec, &dnDecimal, NSRoundPlain);
    return [LjsDn dnWithDecimal:result];
}

- (NSDecimalNumber *)dnByMultiplyingBy:(NSDecimalNumber *)decimalNumber withBehavior:(id <NSDecimalNumberBehaviors>)behavior
{
    NSCParameterAssert(decimalNumber);
    NSCParameterAssert(behavior);
    @autoreleasepool {
        return [self decimalNumberByMultiplyingBy:decimalNumber withBehavior:behavior];
    }
}

- (NSDecimalNumber *)dnByDividingBy:(NSDecimalNumber *)decimalNumber
{
    NSDecimal selfDec = [self decimalValue];
    NSDecimal dnDecimal = [decimalNumber decimalValue];
    NSDecimal result;
    NSDecimalDivide(&result, &selfDec, &dnDecimal, NSRoundPlain);
    return [LjsDn dnWithDecimal:result];
}

- (NSDecimalNumber *)dnByDividingBy:(NSDecimalNumber *)decimalNumber withBehavior:(id <NSDecimalNumberBehaviors>)behavior
{
    NSCParameterAssert(decimalNumber);
    NSCParameterAssert(behavior);
    @autoreleasepool {
        return [self decimalNumberByDividingBy:decimalNumber withBehavior:behavior];
    }
}

- (NSDecimalNumber *)dnByRaisingToPower:(NSUInteger)power
{
    NSDecimal selfDec = [self decimalValue];
    NSDecimal result;
    NSDecimalPower(&result, &selfDec, power, NSRoundPlain);
    return [LjsDn dnWithDecimal:result];
}

- (NSDecimalNumber *)dnByRaisingToPower:(NSUInteger)power withBehavior:(id <NSDecimalNumberBehaviors>)behavior
{
    NSCParameterAssert(behavior);
    @autoreleasepool {
        return [self decimalNumberByRaisingToPower:power withBehavior:behavior];
    }
}

- (NSDecimalNumber *)dnByMultiplyingByPowerOf10:(short)power
{
    NSDecimal selfDec = [self decimalValue];
    NSDecimal result;
    NSDecimalMultiplyByPowerOf10(&result, &selfDec, power, NSRoundPlain);
    return [LjsDn dnWithDecimal:result];
}

- (NSDecimalNumber *)dnByMultiplyingByPowerOf10:(short)power withBehavior:(id <NSDecimalNumberBehaviors>)behavior
{
    NSCParameterAssert(behavior);
    @autoreleasepool {
        return [self decimalNumberByMultiplyingByPowerOf10:power withBehavior:behavior];
    }
}

@end

static NSString * Tolerance = @"0.0000000000000001";
static NSDecimalNumber *MinusOne;

@implementation NSDecimalNumber (SquareRoot)

- (NSDecimalNumber *)squareRoot
{
    NSComparisonResult comparison = [self compare:[NSDecimalNumber zero]];
    if (comparison == NSOrderedAscending)
        return [NSDecimalNumber notANumber];
    else if (comparison == NSOrderedSame)
        return [NSDecimalNumber zero];
    
    // TODO: Convert this to use NSDecimal when PRC is operational in the future.
    NSDecimalNumber *half = [[NSDecimalNumber one] decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithDecimal:[@2 decimalValue]]];
    NSDecimalNumber *guess = [[self decimalNumberByAdding:[NSDecimalNumber one]] decimalNumberByMultiplyingBy:half];
    NSDecimalNumber * next_guess;
    
    @try {
        while (TRUE) {
            next_guess = [[[self decimalNumberByDividingBy:guess] decimalNumberByAdding:guess] decimalNumberByMultiplyingBy:half];
            
            if ([next_guess isEquivalentTo:guess]) {
                // We are close enough
                break;
            }
            
            guess = next_guess;
        }
    }
    @catch (NSException *exception) {
        // deliberately ignore exception and assume the last guess is good enough
    }
    
    NSDecimalNumber *int_value = [LjsDn dnWithInteger:[guess integerValue]];
    if ([guess isEquivalentTo:int_value]) {
        return int_value;
    }
    else {
        return guess;
    }
}

- (NSDecimalNumber *)cubeRoot
{
    NSComparisonResult comparison = [self compare:[NSDecimalNumber zero]];
    if (comparison == NSOrderedSame) {
        return [NSDecimalNumber zero];
    }
    
    BOOL negative = NO;
    NSDecimalNumber * value = [self abs];
    NSDecimalNumber * guess, * next_guess, * two, * three;
    
    if ([self compare:[NSDecimalNumber zero]] == NSOrderedAscending) {
        negative = YES;
        value = [self abs];
    }
    
    guess = [self sign];
    two = [NSDecimalNumber decimalNumberWithString:@"2"];
    three = [NSDecimalNumber decimalNumberWithString:@"3"];
    
    @try {
        while (TRUE) {
            // (x/y^2 + 2y)/3
            next_guess = [[[self decimalNumberByDividingBy:[guess decimalNumberByMultiplyingBy:guess]] decimalNumberByAdding:[two decimalNumberByMultiplyingBy:guess]] decimalNumberByDividingBy:three];
            
            if ([next_guess isEquivalentTo:guess]) {
                // We are close enough
                break;
            }
            
            guess = next_guess;
        }
    }
    @catch (NSException *exception) {
        // deliberately ignore exception and assume the last guess is good enough
    }
    
    NSDecimalNumber *int_value = [LjsDn dnWithInteger:[guess integerValue]];
    if ([guess isEquivalentTo:int_value]) {
        return int_value;
    }
    else {
        return guess;
    }
}

// Absolute value
- (NSDecimalNumber *)abs
{
    NSDecimal zero = [[LjsDn zero] decimalValue];
    NSDecimal one  = [[LjsDn one] decimalValue];
    NSDecimal negativeOne;

    if (!MinusOne) {
        NSDecimalSubtract(&negativeOne, &zero, &one, NSRoundPlain);
        @autoreleasepool {
            MinusOne = [LjsDn dnWithDecimal:negativeOne];
        }
    }
    
    NSDecimal selfDecimal = [self decimalValue];
    

    if (NSDecimalCompare(&selfDecimal, &zero) == NSOrderedAscending) {
        NSDecimal result;
        negativeOne = [MinusOne decimalValue];
        NSDecimalDivide(&result, &selfDecimal, &negativeOne, NSRoundPlain);
        @autoreleasepool {
            return [LjsDn dnWithDecimal:result];
        }
    }
    else {
        return self;
    }
}

// Sign returns either 1.0 or -1.0 depending on the sign of the value
- (NSDecimalNumber *)sign
{
    // TODO: Convert when working with PRC in the future.
    
    if (!MinusOne) {
        @autoreleasepool {
            MinusOne = [LjsDn dnWithInteger:-1];
        }
    }
    
    if ([self compare:[NSDecimalNumber zero]] == NSOrderedAscending) {
        return MinusOne;
    }
    else {
        return [LjsDn one];
    }
}

// Equivalence test
- (BOOL)isEquivalentTo:(NSDecimalNumber*)number
{
    static NSDecimalNumber * tolerance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!tolerance) {
            tolerance = [NSDecimalNumber decimalNumberWithString:Tolerance];
        }
    });

    NSDecimalNumber *difference;
    @autoreleasepool {
        difference = [[self decimalNumberBySubtracting:number] abs];
    }

    return [difference compare:tolerance] == NSOrderedAscending;
}

- (NSDecimalNumber *)floor
{
    NSDecimalNumberHandler *roundingHandler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:0 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES];
    return [self decimalNumberByRoundingAccordingToBehavior:roundingHandler];
}

- (NSDecimalNumber *)ceiling
{
    NSDecimalNumberHandler *roundingHandler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundUp scale:0 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES];
    return [self decimalNumberByRoundingAccordingToBehavior:roundingHandler];
}

- (NSDecimalNumber *)negate
{
    NSDecimalNumber *negOne = [LjsDn dnWithInteger:-1];
    return [self dnByMultiplyingBy:negOne];
}

@end
