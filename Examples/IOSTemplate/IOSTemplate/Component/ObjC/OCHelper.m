//
//  OCHelper.m
//  IOSTemplate
//
//  Created by 杨建祥 on 2020/11/28.
//

#import "OCHelper.h"

@interface OCHelper ()

@end

@implementation OCHelper

#pragma mark - 类方法
+ (instancetype)sharedInstance {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

@end
