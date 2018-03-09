//
//  NSString+Size.m
//
//
//  Created by Conner Wu.
//  Copyright © 2016年 Beyondsoft. All rights reserved.
//

#import "NSString+Size.h"

@implementation NSString (Size)

- (CGFloat)getHeightOfFont:(UIFont *)textFont width:(CGFloat)textWidth {
    
    return [self getHeightOfFont:textFont width:textWidth lineSpacing:0];
}

- (CGFloat)getHeightOfFont:(UIFont *)textFont
                     width:(CGFloat)textWidth
               lineSpacing:(CGFloat) lineSpacing
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [paragraphStyle setLineSpacing:lineSpacing];
    
    NSDictionary *attributes = @{NSFontAttributeName:textFont, NSParagraphStyleAttributeName:paragraphStyle};
    
    CGRect rect = [self boundingRectWithSize:CGSizeMake(textWidth, CGFLOAT_MAX)
                                     options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                  attributes:attributes
                                     context:nil];
    CGSize requiredSize = rect.size;
    
    return ceilf(requiredSize.height);
}

- (CGFloat)getWidthOfFont:(UIFont *)textFont height:(CGFloat)textHeight {
    
    return [self getWidthOfFont:textFont height:textHeight withLineSpacing:0];
}

- (CGFloat)getWidthOfFont:(UIFont *)textFont
                   height:(CGFloat)textHeight
          withLineSpacing: (CGFloat)lineSpacing {
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [paragraphStyle setLineSpacing:lineSpacing];
    
    NSDictionary *attributes = @{NSFontAttributeName:textFont, NSParagraphStyleAttributeName:paragraphStyle};
    
    CGRect rect = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, textHeight)
                                     options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                  attributes:attributes
                                     context:nil];
    CGSize requiredSize = rect.size;
    
    return ceilf(requiredSize.width);
}

@end
