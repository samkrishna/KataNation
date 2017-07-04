//
//  pe0002Test.m
//  ObjCProjectEulerTests
//
//  Created by Sam Krishna on 7/4/17.
//  Copyright © 2017 Sam Krishna. All rights reserved.
//

#import "EulerSolution.h"
#import <XCTest/XCTest.h>

@interface pe0002 : NSObject <EulerSolution>
@end

@implementation pe0002

+ (NSDecimalNumber *)PEResult
{
    NSMutableArray *fibs = [NSMutableArray array];
    NSUInteger seqNumber = 1;
    NSDecimalNumber *fibValue = [self fibValueForSequenceNumber:seqNumber];
    NSUInteger total = 0;
    
    do {
        [fibs addObject:fibValue];
        fibValue = [self fibValueForSequenceNumber:seqNumber++];
    } while ([fibValue unsignedIntegerValue] < 4000000);
    
    [fibs removeObjectsInRange:NSMakeRange(0, 2)];
    for (NSDecimalNumber *fib in fibs) {
        NSUInteger UFibValue = [fib unsignedIntegerValue];
        total += (UFibValue % 2 == 0) ? UFibValue : 0;
    }
    
    return [LjsDn dnWithUInteger:total];
}

+ (NSDecimalNumber *)fibValueForSequenceNumber:(NSUInteger)sequenceNumber
{
    NSUInteger n = sequenceNumber;
    NSDecimalNumber *sqRootOf5 = [[LjsDn dnWithUInteger:5] squareRoot];
    NSDecimalNumber *one = [LjsDn one];
    NSDecimalNumber *two = [LjsDn dnWithUInteger:2];
    NSDecimalNumber *a = [[one dnByAdding:sqRootOf5] dnByDividingBy:two];
    NSDecimalNumber *b = [[one dnBySubtracting:sqRootOf5] dnByDividingBy:two];
    NSDecimalNumber *aToN = [a dnByRaisingToPower:n];
    NSDecimalNumber *bToN = [b dnByRaisingToPower:n];
    NSDecimalNumber *fibonacciValue = [[[aToN dnBySubtracting:bToN] dnByDividingBy:sqRootOf5] dnByRoundingWithScale:0];
    return fibonacciValue;
}

@end

@interface pe0002Test : XCTestCase
@end

@implementation pe0002Test

- (void)testResult {
    NSDecimalNumber *result = [pe0002 PEResult];
    NSNumber *check = @(4613732);
    XCTAssert([result isEqualToNumber:check], @"This should be %@ (%@)", check, result);
}

@end

