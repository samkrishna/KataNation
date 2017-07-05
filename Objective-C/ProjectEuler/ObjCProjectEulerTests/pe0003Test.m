//
//  pe0003Test.m
//  ObjCProjectEulerTests
//
//  Created by Sam Krishna on 7/4/17.
//  Copyright © 2017 Sam Krishna. All rights reserved.
//

#import "EulerSolution.h"
#import <XCTest/XCTest.h>

@interface pe0003 : NSObject <EulerSolution>
@end

@implementation pe0003

+ (NSDecimalNumber *)PEResult
{
    NSUInteger target = 600851475143;
    while (YES) {
        NSUInteger p = [self smallestFactorForNumber:target];
        if (p < target) {
            target /= p;
        }
        else {
            break;
        }
    }
    
    return [LjsDn dnWithUInteger:target];
}

+ (NSUInteger)smallestFactorForNumber:(NSUInteger)number
{
    NSCParameterAssert(number > 1);
    CGFloat target = (CGFloat)number;
    CGFloat sqrtOfTarget = sqrt(target);
    
    for (NSUInteger i = 2; i <= sqrtOfTarget; i++) {
        if (number % i == 0) {
            return i;
        }
    }
    
    return number;
}

@end

@interface pe0003Test : XCTestCase
@end

@implementation pe0003Test

- (void)testResult {
    NSDecimalNumber *result = [pe0003 PEResult];
    NSNumber *check = @(6857);
    XCTAssert([result isEqualToNumber:check], @"This should be %@ (%@)", check, result);
}

@end

