//
//  Day01.m
//  AdventOfCode-2015
//
//  Created by Sam Krishna on 1/3/22.
//

#import "Day01.h"

@implementation Day01

- (NSInteger)processInput:(NSString *)inputString {
    NSCountedSet *set = [[NSCountedSet alloc] init];
    NSUInteger basementPos = 0;

    for (NSUInteger i = 0; i < inputString.length; i++) {
        [set addObject:[NSString stringWithFormat:@"%c", [inputString characterAtIndex:i]]];
        NSUInteger upCount = [set countForObject:@"("];
        NSUInteger downCount = [set countForObject:@")"];

        if ((upCount - downCount) == -1 && basementPos == 0) {
            basementPos = i + 1;
            NSLog(@"Basement entered at position %lu", basementPos);
        }
    }

    NSUInteger upCount = [set countForObject:@"("];
    NSUInteger downCount = [set countForObject:@")"];
    return upCount - downCount;
}

- (NSUInteger)findBasement:(NSString *)inputString {
    NSCountedSet *set = [[NSCountedSet alloc] init];
    NSUInteger basementPos = 0;

    for (NSUInteger i = 0; i < inputString.length; i++) {
        [set addObject:[NSString stringWithFormat:@"%c", [inputString characterAtIndex:i]]];
        NSUInteger upCount = [set countForObject:@"("];
        NSUInteger downCount = [set countForObject:@")"];

        if ((upCount - downCount) == -1) {
            basementPos = i + 1;
            return basementPos;
        }
    }

    return NSNotFound;
}

@end
