//
//  Day05.m
//  AdventOfCode-2015
//
//  Created by Sam Krishna on 1/15/22.
//

#import "RegexKitX.h"
#import "Day05.h"

@implementation Day05

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
