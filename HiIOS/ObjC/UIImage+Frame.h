//
//  UIImage+Frame.h
//  HiIOS
//
//  Created by liaoya on 2022/7/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GradientDirection) {
    GradientDirectionTopToBottom = 0,   // 从上到下
    GradientDirectionLeftToRight = 1,   // 从左到右
};

@interface UIImage (Frame)
- (UIImage *)getGradientImageFromColors:(NSArray *)colors gradientDirection:(GradientDirection)gradientDirection imgSize:(CGSize)imgSize;

@end

NS_ASSUME_NONNULL_END
