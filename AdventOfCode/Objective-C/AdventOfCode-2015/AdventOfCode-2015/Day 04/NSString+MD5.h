//
//  NSString+MD5.h
//  AdventOfCode-2015
//
//  Created by Sam Krishna on 1/8/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (MD5)

// Got this from: https://stackoverflow.com/a/2018626/14173138
- (NSString *)md5String;

@end

NS_ASSUME_NONNULL_END
