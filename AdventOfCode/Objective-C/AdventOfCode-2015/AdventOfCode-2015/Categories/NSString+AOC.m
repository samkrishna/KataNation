//
//  NSString+AOC.m
//  AdventOfCode-2015
//
//  Created by Sam Krishna on 1/15/22.
//

#import <CommonCrypto/CommonDigest.h>
#import "NSString+AOC.h"

@implementation NSString (AOC)

- (NSString *)md5String {
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );

    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
        result[0], result[1], result[2], result[3],
        result[4], result[5], result[6], result[7],
        result[8], result[9], result[10], result[11],
        result[12], result[13], result[14], result[15]
    ];
}

- (NSArray *)characterArray {
    NSMutableArray *chars = [NSMutableArray array];

    for (NSUInteger i = 0; i < self.length; i++) {
        NSString *c = [NSString stringWithFormat:@"%c", [self characterAtIndex:i]];
        [chars addObject:c];
    }

    return [chars copy];
}

@end
