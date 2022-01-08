//
//  Day03.h
//  AdventOfCode-2015
//
//  Created by Sam Krishna on 1/8/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Day03 : NSObject
{
    NSUInteger _grid[1000][1000];
}

- (void)fillGiftCountMatrixForString:(NSString *)directionString;
- (void)fillGiftCountMatrixWithRobotHelperForString:(NSString *)directionString;
- (NSUInteger)countForX:(NSUInteger)x Y:(NSUInteger)y;

@end

NS_ASSUME_NONNULL_END
