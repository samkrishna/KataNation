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

@import Foundation;

@interface LjsInterval : NSObject

@property (nonatomic, readonly, strong) NSDecimalNumber *min;
@property (nonatomic, readonly, strong) NSDecimalNumber *mid;
@property (nonatomic, readonly, strong) NSDecimalNumber *max;
@property (nonatomic, readonly, strong) NSDecimalNumber *length;
@property (nonatomic, readonly, strong) NSDecimalNumber *firstQuartile;
@property (nonatomic, readonly, strong) NSDecimalNumber *thirdQuartile;

+ (LjsInterval *)intervalWithMin:(NSDecimalNumber *)min max:(NSDecimalNumber *)max;
+ (LjsInterval *)intervalWithMidpoint:(NSDecimalNumber *)midpoint delta:(CGFloat)delta;
+ (LjsInterval *)intervalWithMidpoint:(NSDecimalNumber *)midpoint deltaDN:(NSDecimalNumber *)deltaDN;
+ (LjsInterval *)intervalWithNumber:(NSDecimalNumber *)number minusMinOffset:(NSDecimalNumber *)minOffset plusMaxOffset:(NSDecimalNumber *)maxOffset;

- (id)initWithMin:(NSDecimalNumber *)aMin max:(NSDecimalNumber *)aMax;
- (BOOL)intervalContains:(NSDecimalNumber *)aNumber;
- (NSDecimalNumber *)numberClosestToTarget:(NSDecimalNumber *)target;
- (NSDecimalNumber *)edgeNumberClosestToTarget:(NSDecimalNumber *)target;

- (BOOL)isEqualToInterval:(LjsInterval *)interval;
- (NSString *)descriptionWithMidpoint;

@end


@interface LjsDn : NSObject

/** @name NSDecimalNumber creation */
+ (NSDecimalNumber *)dnWithBool:(BOOL)aBool;
+ (NSDecimalNumber *)dnWithInteger:(NSInteger)aInteger;
+ (NSDecimalNumber *)dnWithUInteger:(NSUInteger)aUInteger;
+ (NSDecimalNumber *)dnWithDouble:(double)aDouble;
+ (NSDecimalNumber *)dnWithFloat:(CGFloat)aFloat;
+ (NSDecimalNumber *)dnWithString:(NSString *)aString;
+ (NSDecimalNumber *)dnWithNumber:(NSNumber *)aNumber;
+ (NSDecimalNumber *)dnWithDecimal:(NSDecimal)aDecimal;
+ (NSDecimalNumber *)nan;
+ (NSDecimalNumber *)one;
+ (NSDecimalNumber *)zero;
+ (NSDecimalNumber *)min;
+ (NSDecimalNumber *)max;
+ (NSDecimalNumber *)midpointBetweenFirstDN:(NSDecimalNumber *)a andSecondDN:(NSDecimalNumber *)b roundingScale:(NSUInteger)scale delta:(NSDecimalNumber **)delta;

/** @name NSDecimalNumber comparison */
+ (BOOL)dn:(NSDecimalNumber *)a e:(NSDecimalNumber *)b;
+ (BOOL)dn:(NSDecimalNumber *)a lt:(NSDecimalNumber *)b;
+ (BOOL)dn:(NSDecimalNumber *)a gt:(NSDecimalNumber *)b;
+ (BOOL)dn:(NSDecimalNumber *)a lte:(NSDecimalNumber *)b;
+ (BOOL)dn:(NSDecimalNumber *)a gte:(NSDecimalNumber *)b;
+ (BOOL)dn:(NSDecimalNumber *)a isOnMin:(NSDecimalNumber *)min max:(NSDecimalNumber *)max;

+ (BOOL)dn:(NSDecimalNumber *)a isOnInterval:(LjsInterval *)aInterval;

/** @name NSDecimalNumber rounding */
+ (NSDecimalNumber *)round:(NSDecimalNumber *)number withHandler:(NSDecimalNumberHandler *)handler;

/** @name common NSDecimalNumberHandler */
+ (NSDecimalNumberHandler *)statisticsHandlerWithRoundMode:(NSRoundingMode)aMode scale:(short)aInteger;
+ (NSDecimalNumberHandler *)locationHandlerWithRoundMode:(NSRoundingMode)aMode scale:(short)aInteger;

+ (NSDecimalNumber *)moduloOfDividend:(NSDecimalNumber *)dividend andDivisor:(NSDecimalNumber *)divisor;
+ (NSDecimalNumber *)quotientOfDividend:(NSDecimalNumber *)dividend andDivisor:(NSDecimalNumber *)divisor;

@end

/**
 NSDecimalNumber on LjsAdditions category.
 */
@interface NSDecimalNumber (LjsAdditions)

/** @name Task Section */
- (BOOL)dne:(NSDecimalNumber *)other;
- (BOOL)e:(NSDecimalNumber *)other;
- (BOOL)lt:(NSDecimalNumber *)other;
- (BOOL)gt:(NSDecimalNumber *)other;
- (BOOL)lte:(NSDecimalNumber *)other;
- (BOOL)gte:(NSDecimalNumber *)other;
- (BOOL)isOnIntervalWithMin:(NSDecimalNumber *)aMin max:(NSDecimalNumber *)aMax;
- (BOOL)isNan;
- (CGFloat)cgFloatValue;

- (NSDecimalNumber *)dnByRoundingWithHandler:(NSDecimalNumberHandler *)aHandler;
- (NSDecimalNumber *)dnByRoundingWithScale:(NSUInteger)aScale;
- (NSDecimalNumber *)dnByBankersRoundingWithScale:(NSUInteger)aScale;
- (NSDecimalNumber *)dnByRoundingAsLocation;

- (NSDecimalNumber *)maxCompare:(NSDecimalNumber *)comparison;
- (NSDecimalNumber *)minCompare:(NSDecimalNumber *)comparison;


- (NSDecimalNumber *)dnByAdding:(NSDecimalNumber *)decimalNumber;
- (NSDecimalNumber *)dnByAdding:(NSDecimalNumber *)decimalNumber withBehavior:(id <NSDecimalNumberBehaviors>)behavior;
- (NSDecimalNumber *)dnBySubtracting:(NSDecimalNumber *)decimalNumber;
- (NSDecimalNumber *)dnBySubtracting:(NSDecimalNumber *)decimalNumber withBehavior:(id <NSDecimalNumberBehaviors>)behavior;

- (NSDecimalNumber *)dnByMultiplyingFloat:(CGFloat)floatNumber;
- (NSDecimalNumber *)dnByMultiplyingBy:(NSDecimalNumber *)decimalNumber;
- (NSDecimalNumber *)dnByMultiplyingBy:(NSDecimalNumber *)decimalNumber withBehavior:(id <NSDecimalNumberBehaviors>)behavior;
- (NSDecimalNumber *)dnByDividingBy:(NSDecimalNumber *)decimalNumber;
- (NSDecimalNumber *)dnByDividingBy:(NSDecimalNumber *)decimalNumber withBehavior:(id <NSDecimalNumberBehaviors>)behavior;

- (NSDecimalNumber *)dnByRaisingToPower:(NSUInteger)power;
- (NSDecimalNumber *)dnByRaisingToPower:(NSUInteger)power withBehavior:(id <NSDecimalNumberBehaviors>)behavior;
- (NSDecimalNumber *)dnByMultiplyingByPowerOf10:(short)power;
- (NSDecimalNumber *)dnByMultiplyingByPowerOf10:(short)power withBehavior:(id <NSDecimalNumberBehaviors>)behavior;

@end

@interface NSDecimalNumber (SquareRoot)

- (NSDecimalNumber *)squareRoot;
- (NSDecimalNumber *)cubeRoot;
- (NSDecimalNumber *)abs;
- (NSDecimalNumber *)sign;
- (BOOL)isEquivalentTo:(NSDecimalNumber*)number;
- (NSDecimalNumber *)floor;
- (NSDecimalNumber *)ceiling;
- (NSDecimalNumber *)negate;

@end
