//
//  Day05.m
//  AdventOfCode-2015
//
//  Created by Sam Krishna on 1/15/22.
//

#import "RegexKitX.h"
#import "NSString+AOC.h"
#import "Day05.h"

@implementation Day05

+ (BOOL)partAisNiceForString:(NSString *)line {
    NSArray *vowels = [line arrayOfCaptureSubstringsMatchedByRegex:@"a|e|i|o|u" options:RKXCaseless];
    if (vowels.count < 3) { return NO; }

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

    if (!doubleNice) { return NO; }

    if (![line isMatchedByRegex:@"ab|cd|pq|xy" options:RKXCaseless]) {
        return YES;
    }

    return NO;
}

+ (BOOL)partBisNiceForString:(NSString *)line {
    BOOL repeatWithExactlyOneLetterBetweenTest = NO;

    for (NSUInteger i = 0; i < (line.length - 2); i++) {
        NSString *testChar1 = [line substringWithRange:NSMakeRange(i, 1)];
        NSString *testChar2 = [line substringWithRange:NSMakeRange(i + 2, 1)];
        repeatWithExactlyOneLetterBetweenTest = [testChar1 isEqualToString:testChar2];

        if (repeatWithExactlyOneLetterBetweenTest) {
            break;
        }
    }

    BOOL pairAppearsTwiceTest = YES;
    for (NSUInteger i = 0; i < (line.length - 2); i++) {
        for (NSUInteger j = i; j < (line.length - 2); j++) {
            NSString *testPair = [line substringWithRange:NSMakeRange(j, 2)];
            NSArray *ranges = [line rangesOfRegex:testPair];

            pairAppearsTwiceTest = (ranges.count >= 2);

            if (pairAppearsTwiceTest) { break; }
        }

        if (pairAppearsTwiceTest) { break; }
    }

    return (repeatWithExactlyOneLetterBetweenTest && pairAppearsTwiceTest);
}

@end
