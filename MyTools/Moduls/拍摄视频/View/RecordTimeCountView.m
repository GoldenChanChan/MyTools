//
//  RecordTimeCountView.m
//  STeBook
//
//  Created by scjy on 2017/8/14.
//  Copyright © 2017年 rain. All rights reserved.
//

#import "RecordTimeCountView.h"
#import "NSString+Size.h"
#import "UIColor+Method.h"

@interface RecordTimeCountView()
{
    UILabel *_timeLabel;
    UIView *_circlePointView;
}

@end

@implementation RecordTimeCountView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:61/255 green:61/255 blue:61/255 alpha:0.5];
        _circlePointView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
        _circlePointView.layer.cornerRadius = 5.0/2.0;
        _circlePointView.backgroundColor = [UIColor getColor:@"#ff3e3e"];
        [self addSubview:_circlePointView];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, CGRectGetHeight(frame))];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = [UIFont systemFontOfSize:18.2];
        [self addSubview:_timeLabel];
        
        [self setContent:@"00:30"];
    }
    return self;
}

- (void)setContent:(NSString *)content {
    _timeLabel.text = content;
    CGFloat content_w = [content getWidthOfFont:_timeLabel.font height:20];
    _circlePointView.frame = CGRectMake(
                                        CGRectGetWidth(self.frame)/2-(content_w+CGRectGetWidth(_circlePointView.frame)+8)/2,
                                        CGRectGetHeight(self.frame)/2-CGRectGetHeight(_circlePointView.frame)/2,
                                        CGRectGetWidth(_circlePointView.frame),
                                        CGRectGetHeight(_circlePointView.frame));
    _timeLabel.frame = CGRectMake(CGRectGetMaxX(_circlePointView.frame)+8, 0, content_w, CGRectGetHeight(self.frame));
}

@end
