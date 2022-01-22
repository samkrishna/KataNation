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

- (void)testDay03 {
    NSString *inputString = [self inputStringForClassName:@"Day03"];
    Day03 *d = [Day03 new];

    // Part a
    [d fillGiftCountMatrixForString:inputString];

    NSUInteger giftedHousesCount = 0;

    for (NSUInteger x = 0; x < 1000; x++) {
        for (NSUInteger y = 0; y < 1000; y++) {
            if ([d countForX:x Y:y] > 0) {
                giftedHousesCount++;
            }
        }
    }

    NSLog(@"Santa alone: gifted houses count = %lu", giftedHousesCount);

    // Reset everything for part b
    d = [Day03 new];
    [d fillGiftCountMatrixWithRobotHelperForString:inputString];
    giftedHousesCount = 0;

    for (NSUInteger x = 0; x < 1000; x++) {
        for (NSUInteger y = 0; y < 1000; y++) {
            if ([d countForX:x Y:y] > 0) {
                giftedHousesCount++;
            }
        }
    }

    NSLog(@"With Robot helper: gifted houses count = %lu", giftedHousesCount);
}

- (void)testDay04 {
    NSString *input = @"iwrupvqb";
    NSString *hook;

    // Part a
    for (NSUInteger i = 0; i < NSNotFound; i++) {
        NSString *test = [NSString stringWithFormat:@"%@%lu", input, i];
        NSString *hash = [test md5String];

        NSString *catch = [hash substringWithRange:NSMakeRange(0, 6)];
        if ([catch isEqualToString:@"00000"]) {
            hook = [NSString stringWithFormat:@"%lu", i];
            break;
        }
    }

    NSLog(@"Part a: hook is %@", hook);

    for (NSUInteger i = 1000000; i < NSNotFound; i++) {
        NSString *test = [NSString stringWithFormat:@"%@%lu", input, i];
        NSString *hash = [test md5String];

        NSString *catch = [hash substringWithRange:NSMakeRange(0, 6)];
        if ([catch isEqualToString:@"000000"]) {
            hook = [NSString stringWithFormat:@"%lu", i];
            break;
        }
    }

    NSLog(@"Part b: hook is %@", hook);
}

- (void)testDay05Sampler {
    NSString *sampler = @"ugknbfddgicrmopn";
    NSArray *vowels = [sampler arrayOfCaptureSubstringsMatchedByRegex:@"a|e|i|o|u" options:RKXCaseless];
    XCTAssert(vowels.count >= 3);

    __block BOOL doubleNice = NO;
    NSArray *testArray = sampler.characterArray;
    [sampler.characterArray enumerateObjectsUsingBlock:^(NSString * _Nonnull c, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx > 0) {
            if (idx > 0 && [c isEqualToString:testArray[idx - 1]]) {
                *stop = YES;
                doubleNice = YES;
            }
        }
    }];

    XCTAssert(doubleNice);

    XCTAssertFalse([sampler isMatchedByRegex:@"ab|cd|pq|xy" options:RKXCaseless]);
}

- (void)testDay05PartA {
    NSString *input = [self inputStringForClassName:@"Day05"];
    __block NSUInteger niceCount = 0;

    [input enumerateLinesUsingBlock:^(NSString * _Nonnull line, BOOL * _Nonnull stop) {
        NSArray *vowels = [line arrayOfCaptureSubstringsMatchedByRegex:@"a|e|i|o|u" options:RKXCaseless];
        if (vowels.count < 3) { return; }

        __block BOOL doubleNice = NO;
        NSArray *testArray = line.characterArray;
        [line.characterArray enumerateObjectsUsingBlock:^(NSString * _Nonnull c, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx > 0) {
                if (idx > 0 && [c isEqualToString:testArray[idx - 1]]) {
                    *stop = YES;
                    doubleNice = YES;
                }
            }
        }];

        if (!doubleNice) { return; }

        if (![line isMatchedByRegex:@"ab|cd|pq|xy" options:RKXCaseless]) {
            niceCount++;
        }
    }];

    NSLog(@"Nice Count: %lu", niceCount);
}

- (void)testDay05PartB {
    NSArray *input = @[
        @"qjhvhtzxzqqjkmpb",
        @"xxyxx",
        @"uurcxstgmygtbstg",
        @"ieodomkazucvgmuy"
    ];

    XCTAssert([Day05 partBisNiceForString:input[0]]);
    XCTAssert([Day05 partBisNiceForString:input[1]]);
    XCTAssertFalse([Day05 partBisNiceForString:input[2]]);
    XCTAssertFalse([Day05 partBisNiceForString:input[3]]);

    NSString *lines = [self inputStringForClassName:@"Day05"];
    __block NSUInteger niceCount = 0;

    [lines enumerateLinesUsingBlock:^(NSString * _Nonnull line, BOOL * _Nonnull stop) {
        niceCount += [Day05 partBisNiceForString:line] ? 1 : 0;
    }];

    NSLog(@"Part B: niceCount = %lu", niceCount);
}

@end
