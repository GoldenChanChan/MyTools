//
//  TitleWithBottomPointButton.h
//  STeBook
//
//  Created by scjy on 2017/8/14.
//  Copyright © 2017年 rain. All rights reserved.
//带选中小圆点的标题视图

#import <UIKit/UIKit.h>

@interface TitleWithBottomPointButton : UIButton
@property (nonatomic, assign) BOOL isSelected;
- (id)initWithTitle:(NSString *)content isSelected:(BOOL)isSelected font:(UIFont *)font;
@end
