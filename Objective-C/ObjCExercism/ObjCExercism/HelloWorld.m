//
//  HelloWorld.m
//  ObjCExercism
//
//  Created by Sam Krishna on 7/5/17.
//  Copyright © 2017 Sam Krishna. All rights reserved.
//

#import "HelloWorld.h"

@implementation HelloWorld

- (NSString *)hello:(NSString *)input
{
    if (!input) {
        return @"Hello, World!";
    }
    
    return [NSString stringWithFormat:@"Hello, %@!", input];
}

@end
