//
//  ImageWithBottomTitleButton.m
//  STeBook
//
//  Created by scjy on 2017/8/14.
//  Copyright © 2017年 rain. All rights reserved.
//

#import "ImageWithBottomTitleButton.h"
#import "NSString+Size.h"
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#define space_h 6
@interface ImageWithBottomTitleButton()
{
    UIImageView *_imageView;
    UILabel *_tipsLabel;
}

@end

@implementation ImageWithBottomTitleButton

-(id)initWithImageViewSize:(CGSize)size title:(NSString *)title font:(UIFont *)font{
    self = [super init];
    if (self) {
        CGFloat content_w = [title getWidthOfFont:font height:20];
        CGFloat content_h = [title getHeightOfFont:font width:1000];
        self.frame = CGRectMake(0, 0, size.width>content_w?size.width:content_w, size.height+content_h+space_h*2);
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor lightGrayColor];
        _imageView.contentMode = UIViewContentModeCenter;
        _imageView.image = [UIImage imageNamed:@"icon_video_import"];
        _imageView.layer.masksToBounds = YES;
        [self addSubview:_imageView];
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@0);
            make.centerX.equalTo(self);
            make.size.mas_equalTo(size);
        }];
        
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.font = font;
        _tipsLabel.textColor = [UIColor whiteColor];
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.text = title;
        [self addSubview:_tipsLabel];
        [_tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.equalTo(_imageView.mas_bottom).offset(space_h);
            make.height.equalTo(@(content_h));
        }];
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.image = image;
}
@end
