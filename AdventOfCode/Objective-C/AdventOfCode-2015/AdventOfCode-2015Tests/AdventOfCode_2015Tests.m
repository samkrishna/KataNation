//
//  AdventOfCode_2015Tests.m
//  AdventOfCode-2015Tests
//
//  Created by Sam Krishna on 1/3/22.
//

@import XCTest;

#import <AdventOfCode_2015/AdventOfCode_2015.h>

@interface AdventOfCode_2015Tests : XCTestCase

@end

@implementation AdventOfCode_2015Tests

- (NSString *)inputStringForClassName:(NSString *)className {
    NSString *inputPath = [[NSBundle bundleForClass:NSClassFromString(className)] pathForResource:className ofType:@"txt"];
    NSString *inputString = [NSString stringWithContentsOfFile:inputPath encoding:NSUTF8StringEncoding error:NULL];
    return inputString;
}

- (void)testDay01 {
    NSString *inputString = [self inputStringForClassName:@"Day01"];
    Day01 *d = [Day01 new];
    NSInteger floorLevel = [d processInput:inputString];
    NSLog(@"For Day 01: floor level = %ld", floorLevel);

    NSUInteger basementPos = [d findBasement:inputString];
    NSLog(@"Basement Position: %lu", basementPos);
}

- (void)testDay02 {
    NSString *inputString = [self inputStringForClassName:@"Day02"];
    Day02 *d = [Day02 new];
    NSUInteger footage = [d totalSquareFeetForInput:inputString];
    NSLog(@"For Day 02: wrapping footage = %lu", footage);
    NSUInteger ribbonFootage = [d totalFeetOfRibbonForInput:inputString];
    NSLog(@"For Day 02: ribbon footage = %lu", ribbonFootage);
}

@end
