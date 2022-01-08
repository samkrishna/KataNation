//
//  Day03.m
//  AdventOfCode-2015
//
//  Created by Sam Krishna on 1/8/22.
//

#import "Day03.h"

@implementation Day03

- (instancetype)init {
    if (!(self = [super init])) { return nil; }

    for (NSUInteger i = 0; i < 1000; i++) {
        for (NSUInteger j = 0; j < 1000; j++) {
            _grid[i][j] = 0;
        }
    }

    _grid[500][500] = 1;

    return self;
}

- (NSDictionary *)idxDict {
    static NSDictionary *idxDict;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        idxDict = @{
            @"^" : @[ @0, @1],
            @"v" : @[@0, @-1],
            @">" : @[@1, @0],
            @"<" : @[@-1, @0]
        };
    });

    return idxDict;
}

- (void)fillGiftCountMatrixForString:(NSString *)directionString {
    NSMutableArray *directionTokens = [NSMutableArray arrayWithCapacity:directionString.length];
    for (NSUInteger i = 0; i < directionString.length; i++) {
        [directionTokens addObject:[NSString stringWithFormat:@"%c", [directionString characterAtIndex:i]]];
    }

    NSUInteger x = 500;
    NSUInteger y = 500;

    for (NSString *token in directionTokens) {
        NSArray<NSNumber *> *tuple = self.idxDict[token];
        x += tuple[0].unsignedIntegerValue;
        y += tuple[1].unsignedIntegerValue;
        _grid[x][y] += 1;
    }
}

- (void)fillGiftCountMatrixWithRobotHelperForString:(NSString *)directionString {
    NSMutableArray *directionTokens = [NSMutableArray arrayWithCapacity:directionString.length];
    for (NSUInteger i = 0; i < directionString.length; i++) {
        [directionTokens addObject:[NSString stringWithFormat:@"%c", [directionString characterAtIndex:i]]];
    }

    // Santa position
    NSUInteger sx = 500;
    NSUInteger sy = 500;
    // Robot Position
    NSUInteger rx = 500;
    NSUInteger ry = 500;

    for (NSUInteger i = 0; i < directionTokens.count; i++) {
        NSString *token = directionTokens[i];
        NSArray<NSNumber *> *tuple = self.idxDict[token];

        if (i % 2 == 0) {
            sx += tuple[0].unsignedIntegerValue;
            sy += tuple[1].unsignedIntegerValue;
            _grid[sx][sy] += 1;
        }
        else {
            rx += tuple[0].unsignedIntegerValue;
            ry += tuple[1].unsignedIntegerValue;
            _grid[rx][ry] += 1;
        }
    }
}

- (NSUInteger)countForX:(NSUInteger)x Y:(NSUInteger)y {
    return _grid[x][y];
}

@end
