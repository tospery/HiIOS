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

//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wdeprecated-declarations"
//- (CGFloat)statusBarHeight {
//    return StatusBarHeight;
//}
//
//- (CGFloat)statusBarHeightConstant {
//    return StatusBarHeightConstant;
//}
//
//- (CGFloat)navigationBarHeight {
//    return NavigationBarHeight;
//}
//
//- (CGFloat)navigationContentTop {
//    return NavigationContentTop;
//}
//
//- (CGFloat)navigationContentTopConstant {
//    return NavigationContentTopConstant;
//}
//
//- (CGFloat)tabBarHeight {
//    return TabBarHeight;
//}
//
//- (CGFloat)toolBarHeight {
//    return ToolBarHeight;
//}
//#pragma clang diagnostic pop

+ (instancetype)sharedInstance {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

@end
