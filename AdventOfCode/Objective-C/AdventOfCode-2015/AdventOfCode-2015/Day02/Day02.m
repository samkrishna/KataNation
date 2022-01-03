//
//  Day02.m
//  AdventOfCode-2015
//
//  Created by Sam Krishna on 1/3/22.
//

#import "Day02.h"

@implementation Day02

- (NSUInteger)totalSquareFeetForInput:(NSString *)inputString {
    __block NSUInteger totalFootage = 0;

    [inputString enumerateLinesUsingBlock:^(NSString * _Nonnull line, BOOL * _Nonnull stop) {
        NSArray<NSString *> *dimStrings = [line componentsSeparatedByString:@"x"];

        NSInteger l = dimStrings[0].integerValue;
        NSInteger w = dimStrings[1].integerValue;
        NSInteger h = dimStrings[2].integerValue;
        NSInteger side1 = 2 * l * w;
        NSInteger side2 = 2 * w * h;
        NSInteger side3 = 2 * h * l;

        NSArray *dims = @[ @(l), @(w), @(h) ];
        NSArray<NSNumber *> *sortedDims = [dims sortedArrayUsingSelector:@selector(compare:)];
        NSInteger slack = sortedDims[0].integerValue * sortedDims[1].integerValue;
        NSUInteger packageFootage = side1 + side2 + side3 + slack;
        totalFootage += packageFootage;
    }];

    return totalFootage;
}

- (NSUInteger)totalFeetOfRibbonForInput:(NSString *)inputString {
    __block NSUInteger totalFootage = 0;

    [inputString enumerateLinesUsingBlock:^(NSString * _Nonnull line, BOOL * _Nonnull stop) {
        NSArray<NSString *> *dimStrings = [line componentsSeparatedByString:@"x"];
        NSInteger l = dimStrings[0].integerValue;
        NSInteger w = dimStrings[1].integerValue;
        NSInteger h = dimStrings[2].integerValue;

        NSArray *dims = @[ @(l), @(w), @(h) ];
        NSArray<NSNumber *> *sortedDims = [dims sortedArrayUsingSelector:@selector(compare:)];
        NSInteger s1 = sortedDims[0].integerValue;
        NSInteger s2 = sortedDims[1].integerValue;
        NSInteger s3 = sortedDims[2].integerValue;

        NSUInteger presentLength = s1 + s1 + s2 + s2;
        NSUInteger bowLength = s1 * s2 * s3;
        totalFootage += (presentLength + bowLength);
    }];

    return totalFootage;
}

@end
