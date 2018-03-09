//
//  TitleWithBottomPointButton.m
//  STeBook
//
//  Created by scjy on 2017/8/14.
//  Copyright © 2017年 rain. All rights reserved.
//

#import "TitleWithBottomPointButton.h"
#import "NSString+Size.h"
#import "UIColor+Method.h"
#import <Masonry/Masonry.h>
#define space_h 6
#define circle_d 6 //圆点直径
@interface TitleWithBottomPointButton()
{
    UILabel *_tipsLabel;
    UIView *_pointView;
}

@end

@implementation TitleWithBottomPointButton

- (id)initWithTitle:(NSString *)content isSelected:(BOOL)isSelected font:(UIFont *)font{
    self = [super init];
    if (self) {
        CGFloat content_w = [content getWidthOfFont:font height:20];
        CGFloat content_h = [content getHeightOfFont:font width:1000];
        self.frame = CGRectMake(0, 0, content_w, content_h+space_h*2+circle_d);
        _isSelected = isSelected;
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.text = content;
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.textColor = isSelected?[UIColor getColor:@"#f69754"]:[UIColor whiteColor];
        _tipsLabel.font = font?font:[UIFont systemFontOfSize:14];
        [self addSubview:_tipsLabel];
        [_tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.height.equalTo(@(content_h));
        }];
        
        _pointView = [[UIView alloc] init];
        _pointView.backgroundColor = [UIColor getColor:@"#f69051"];
        _pointView.layer.cornerRadius = circle_d/2;
        [self addSubview:_pointView];
        [_pointView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_tipsLabel.mas_bottom).offset(space_h);
            make.centerX.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(circle_d, circle_d));
        }];
        _pointView.hidden = isSelected?NO:YES;
    }
    return self;
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    _pointView.hidden = isSelected?NO:YES;
    _tipsLabel.textColor = isSelected?[UIColor getColor:@"#f69754"]:[UIColor whiteColor];
}

@end
