#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "WebViewJavascriptBridgeBase.h"
#import "WebViewJavascriptBridge_JS.h"
#import "WKWebViewJavascriptBridge.h"
#import "HiHelper.h"
#import "SwiftyLoad.h"
#import "UIImage+Frame.h"
#import "UITextView+Frame.h"

FOUNDATION_EXPORT double HiIOSVersionNumber;
FOUNDATION_EXPORT const unsigned char HiIOSVersionString[];

