//
//  AppDefines.h
//
//
//  Created by cc.
//  Copyright © 2016年 cc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kApiBaseURL;

// 判断系统版本
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
//颜色值设置
#define RGB(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.00]
#define kScreenWidth CGRectGetWidth([UIScreen mainScreen].bounds)
#define kScreenHeight CGRectGetHeight([UIScreen mainScreen].bounds)


//nslog宏 用于调试
#ifdef DEBUG
#define NAILog(fmt, lvl, ...) NSLog((@"[%@] [Line%4d]%s" fmt @"\n\n"), lvl, __LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__)
#define NALog(fmt, ...) NSLog((@"[Line%4d]%s" fmt @"\n\n"), __LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__)
#else
#define NAILog(fmt, lvl, ...)
#define NALog(fmt, ...)
#endif


