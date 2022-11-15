//
//  UITextView+Frame.h
//  HiIOS
//
//  Created by liaoya on 2022/7/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextView (Frame)
@property (nonatomic, readonly) UITextView *placeholderTextView NS_SWIFT_NAME(placeholderTextView);

@property (nonatomic, strong, nullable) IBInspectable NSString *placeholder;
@property (nonatomic, strong, nullable) NSAttributedString *attributedPlaceholder;
@property (nonatomic, strong, nullable) IBInspectable UIColor *placeholderColor;

+ (UIColor *)defaultPlaceholderColor;

@end

NS_ASSUME_NONNULL_END
