//
//  UploadMediaProgressView.m
//  STeBook
//
//  Created by scjy on 2017/8/15.
//  Copyright © 2017年 rain. All rights reserved.
//

#import "UploadMediaProgressView.h"
#import <Masonry/Masonry.h>
#import "UIColor+Method.h"
#import "AppDefines.h"

#define Bg_H 194
#define Bg_W 240
#define Bottom_H 35

#define CircleColor_normal @"#22ac38"
#define CircleColor_failure @"#ff5b52"
#define kLineWidth 3.0
@interface VideoProgressView : UIView
{
    UILabel *_progressLabel;
    
    CAShapeLayer *_outLayer;
    CAShapeLayer *_normalLayer;
    CAShapeLayer *_failureLayer;
}

@end

@implementation VideoProgressView
- (id)init {
    self = [super init];
    if (self) {
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.textColor =  [UIColor getColor:CircleColor_normal];
        _progressLabel.font = [UIFont systemFontOfSize:14];
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_progressLabel];
        [_progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.height.equalTo(@20);
            make.centerY.equalTo(self);
        }];
        
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    self.layer.cornerRadius = 70/2;
//    self.layer.borderWidth = 2;
//    self.layer.borderColor = [Unity getColor:@"#f1f1f1"].CGColor;
    
    self.transform = CGAffineTransformMakeRotation(-M_PI_2);//逆时针旋转90度
    _progressLabel.transform = CGAffineTransformMakeRotation(M_PI_2);//顺时针旋转90度
    CGRect rect = {kLineWidth / 2, kLineWidth / 2,
        CGRectGetWidth(self.frame) - kLineWidth, CGRectGetHeight(self.frame) - kLineWidth};
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    
    if (!_outLayer) {
        _outLayer = [CAShapeLayer layer];
        _outLayer.strokeColor = [UIColor getColor:@"#f1f1f1"].CGColor;
        _outLayer.lineWidth = kLineWidth;
        _outLayer.fillColor =  [UIColor clearColor].CGColor;
        _outLayer.lineCap = kCALineCapRound;
        _outLayer.path = path.CGPath;
        [self.layer addSublayer:_outLayer];
    }
    if (!_normalLayer.superlayer) {
        _normalLayer = [CAShapeLayer layer];
        _normalLayer.fillColor = [UIColor clearColor].CGColor;
        _normalLayer.strokeColor = [UIColor getColor:CircleColor_normal].CGColor;
        _normalLayer.lineWidth = kLineWidth;
        _normalLayer.lineCap = kCALineCapRound;
        _normalLayer.path = path.CGPath;
        _normalLayer.strokeEnd =  0;
        [self.layer addSublayer:_normalLayer];
    }
    if (!_failureLayer) {
        _failureLayer = [CAShapeLayer layer];
        _failureLayer.fillColor = [UIColor clearColor].CGColor;
        _failureLayer.strokeColor = [UIColor getColor:CircleColor_failure].CGColor;
        _failureLayer.lineWidth = kLineWidth;
        _failureLayer.lineCap = kCALineCapRound;
        _failureLayer.path = path.CGPath;
        _failureLayer.hidden = YES;
        _failureLayer.strokeEnd = 0;
        [self.layer addSublayer:_failureLayer];
    }
}

- (void)updateProgressWithProgress:(CGFloat)progress {
    _progressLabel.text = [NSString stringWithFormat:@"%.f%%",progress*100];
//    [CATransaction begin];
//    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
//    [CATransaction setAnimationDuration:0.0];
    _normalLayer.strokeEnd =  progress;
    _failureLayer.strokeEnd = progress;
//    [CATransaction commit];
}

- (void)setFailure {
    _normalLayer.hidden = YES;
    _failureLayer.hidden = NO;
    _progressLabel.textColor = [UIColor getColor:CircleColor_failure];
}
- (void)setStart {
    _normalLayer.hidden = NO;
    _failureLayer.hidden = YES;
    _progressLabel.textColor = [UIColor getColor:CircleColor_normal];
    [self updateProgressWithProgress:0];
}
@end
@interface UploadMediaProgressView()
{
    UIView *_bgView;
    UIView *_bottomView;
    
}

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *terminalUploadBtn;//中断上传
@property (nonatomic, strong) UIButton *dismissBtn;//关闭视图
@property (nonatomic, strong) UIButton *reuploadBtn;//重新发布
@property (nonatomic, strong) VideoProgressView *progressView;
@property (nonatomic, strong) void(^TerminalBlock)();
@property (nonatomic, strong) void(^ReuploadBlock)();
@end

@implementation UploadMediaProgressView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame)/2-Bg_W/2, CGRectGetHeight(frame)/2-Bg_H/2, Bg_W, Bg_H)];
        _bgView.alpha = 0;
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.masksToBounds = YES;
        _bgView.layer.cornerRadius = 4.0f;
        [self addSubview:_bgView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = [UIColor getColor:@"#777777"];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = @"视频发布中";
        [_bgView addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@26);
            make.left.right.equalTo(_bgView);
            make.height.equalTo(@20);
        }];
        
        _progressView = [[VideoProgressView alloc] init];
        [_bgView addSubview:_progressView];
        [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_titleLabel.mas_bottom).offset(20);
            make.size.mas_equalTo(CGSizeMake(70, 70));
            make.centerX.equalTo(_bgView);
        }];
        
        _bottomView = [[UIView alloc] init];
        [_bgView addSubview:_bottomView];
        [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(_bgView);
            make.height.equalTo(@(Bottom_H));
        }];
        
        _dismissBtn = [[UIButton alloc] init];
        [_dismissBtn addTarget:self action:@selector(dismissBtnClicked:)forControlEvents:UIControlEventTouchUpInside];
        [_dismissBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_dismissBtn setTitleColor:[UIColor getColor:@"#333333"] forState:UIControlStateNormal];
        _dismissBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_bottomView addSubview:_dismissBtn];
        [_dismissBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.equalTo(_bottomView);
            make.right.equalTo(_bottomView.mas_centerX);
        }];
        
        _reuploadBtn = [[UIButton alloc] init];
        [_reuploadBtn addTarget:self action:@selector(reuploadBtnClicked:)forControlEvents:UIControlEventTouchUpInside];
        [_reuploadBtn setTitle:@"重新发布" forState:UIControlStateNormal];
        [_reuploadBtn setTitleColor:[UIColor getColor:@"#ff3e3e"] forState:UIControlStateNormal];
        _reuploadBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_bottomView addSubview:_reuploadBtn];
        [_reuploadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.bottom.equalTo(_bottomView);
            make.left.equalTo(_bottomView.mas_centerX);
        }];
        
        UIView *verLine = [[UIView alloc] init];
        verLine.backgroundColor = [UIColor getColor:@"#e4e4e4"];
        [_bottomView addSubview:verLine];
        [verLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.centerX.equalTo(_bottomView);
            make.width.equalTo(@0.5);
        }];
        
        _terminalUploadBtn = [[UIButton alloc] init];
        _terminalUploadBtn.backgroundColor = _bgView.backgroundColor;
        [_terminalUploadBtn addTarget:self action:@selector(terminalUploadBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_terminalUploadBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_terminalUploadBtn setTitleColor:[UIColor getColor:@"#333333"] forState:UIControlStateNormal];
        _terminalUploadBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_bottomView addSubview:_terminalUploadBtn];
        [_terminalUploadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_bottomView);
        }];
        
        UIView *horLine = [[UIView alloc] init];
        horLine.backgroundColor = verLine.backgroundColor;
        [_bottomView addSubview:horLine];
        [horLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(_bottomView);
            make.height.equalTo(@0.5);
        }];
        
        
        _bgView.alpha = 1.0f;
        CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        popAnimation.duration = 0.4;
        popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                                [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                                [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)],
                                [NSValue valueWithCATransform3D:CATransform3DIdentity]];
        popAnimation.keyTimes = @[@0.2f, @0.5f, @0.75f, @1.0f];
        popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                         [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                         [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [_bgView.layer addAnimation:popAnimation forKey:nil];
        
    }
    return self;
}
//更新进度UI
- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [_progressView updateProgressWithProgress:progress];
}
//设置成功UI
- (void)setSucc:(BOOL)succ {
    _succ = succ;
    if (!succ) {
        self.terminalUploadBtn.hidden = YES;
        self.titleLabel.text = @"视频发布失败";
        [_progressView setFailure];
    }
}

//中断上传
- (void)terminalUploadBtnClicked:(UIButton *)btn {
    [self removeFromSuperview];
    if (self.TerminalBlock) {
        self.TerminalBlock();
    }
}
//重新上传
- (void)reuploadBtnClicked:(UIButton *)btn {
    self.terminalUploadBtn.hidden = NO;
    [_progressView setStart];
    if (self.ReuploadBlock) {
        self.ReuploadBlock();
    }
}
//关闭视图
- (void)dismissBtnClicked:(UIButton *)btn {
    [self removeFromSuperview];
}
+ (UploadMediaProgressView *)ShowUploadMediaProgressViewWithTerminalBlock:(void(^)())TerminalBlock reuploadBlock:(void(^)())reuploadBlock {
    UIView *keyView=[UIApplication sharedApplication].keyWindow;
    UploadMediaProgressView *uploadView = [[UploadMediaProgressView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    [keyView addSubview:uploadView];
    uploadView.TerminalBlock = ^{
        if (TerminalBlock) {
            TerminalBlock();
        }
    };
    uploadView.ReuploadBlock = ^{
        if (reuploadBlock) {
            reuploadBlock();
        }
    };
    return uploadView;
}

@end
