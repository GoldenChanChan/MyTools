//
//  NSString+Size.h
//
//
//  Created by Conner Wu.
//  Copyright © 2016年 Beyondsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Size)

- (CGFloat)getHeightOfFont:(UIFont *)textFont width:(CGFloat)textWidth;
- (CGFloat)getWidthOfFont:(UIFont *)textFont height:(CGFloat)textHeight;

- (CGFloat)getHeightOfFont: (UIFont *) textFont
                     width: (CGFloat)  textWidth
               lineSpacing: (CGFloat)  lineSpacing;

- (CGFloat)getWidthOfFont: (UIFont *) textFont
                   height: (CGFloat)  textHeight
          withLineSpacing: (CGFloat)  lineSpacing;
@end
