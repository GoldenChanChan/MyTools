//
//  ImageWithBottomTitleButton.h
//  STeBook
//
//  Created by scjy on 2017/8/14.
//  Copyright © 2017年 rain. All rights reserved.
//带下标题的图片视图

#import <UIKit/UIKit.h>

@interface ImageWithBottomTitleButton : UIButton

/**
 改初始化方法必须传入title内容才可正常使用

 @param size 图片区域大小
 @param title 标题内容
 @param font 标题字体大小
 @return ImageWithBottomTitleButton对象
 */
-(id)initWithImageViewSize:(CGSize)size title:(NSString *)title font:(UIFont *)font;
- (void)setImage:(UIImage *)image;
@end
