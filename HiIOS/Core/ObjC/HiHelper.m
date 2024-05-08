//
//  HiHelper.m
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/18.
//

#import "HiHelper.h"

@interface HiHelper ()

@end

@implementation HiHelper

+ (instancetype)sharedInstance {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

@end
