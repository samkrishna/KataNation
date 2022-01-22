//
//  NSString+AOC.h
//  AdventOfCode-2015
//
//  Created by Sam Krishna on 1/15/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (AOC)

// Got this from: https://stackoverflow.com/a/2018626/14173138
- (NSString *)md5String;

- (NSArray<NSString *> *)characterArray;

@end

NS_ASSUME_NONNULL_END
