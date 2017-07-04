//
//  p0001Test.m
//  ProjectEulerTests
//
//  Created by Sam Krishna on 7/4/17.
//  Copyright © 2017 Sam Krishna. All rights reserved.
//

#import "EulerSolution.h"
#import <XCTest/XCTest.h>

@interface p0001 : NSObject <EulerSolution>
@end

@implementation p0001

+ (NSDecimalNumber *)PEResult
{
    NSUInteger total = 0;
    
    for (NSUInteger i = 1; i < 1000; i++) {
        if (i % 3 == 0 || i % 5 == 0) {
            total += i;
        }
    }
    
    return [LjsDn dnWithUInteger:total];
}

@end

@interface p0001Test : XCTestCase
@end

@implementation p0001Test

- (void)testResult {
    NSDecimalNumber *result = [p0001 PEResult];
    NSNumber *check = @(233168);
    XCTAssert([result isEqualToNumber:check], @"This should be %@ (%@)", check, result);
}

@end
