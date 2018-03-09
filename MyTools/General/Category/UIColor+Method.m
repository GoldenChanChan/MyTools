//
//  UIColor+Method.m
//  MyTools
//
//  Created by 圣才电子书10号 on 2018/3/9.
//  Copyright © 2018年 goldenchan. All rights reserved.
//

#import "UIColor+Method.h"

@implementation UIColor (Method)
+(UIColor *)getColor:(NSString *) stringToConvert
{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    
    if ([cString length] < 6) return [UIColor blackColor];
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6) return [UIColor blackColor];
    
    // Separate into r, g, b substrings
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    //    unsigned int r, g, b;
    //    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    //    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    //    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    NSInteger red = strtoul([rString UTF8String], 0, 16);
    NSInteger green = strtoul([gString UTF8String], 0, 16);
    NSInteger blue = strtoul([bString UTF8String], 0, 16);
    
    return [UIColor colorWithRed:((float) red / 255.0f)
                           green:((float) green / 255.0f)
                            blue:((float) blue / 255.0f)
                           alpha:1.0f];
}
@end
