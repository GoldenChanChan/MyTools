//
//  PublishRecordInputView.m
//  STeBook
//
//  Created by scjy on 2017/8/15.
//  Copyright © 2017年 rain. All rights reserved.
//
#define top_margin 5
#import "PublishRecordInputView.h"
#import "UIColor+Method.h"
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "EXTScope.h"
#import "AppDefines.h"

@interface PublishRecordInputView()
{
//    UITextView *_textView;
    CGRect _frame;//初始化时的frame
    BOOL _isInitialized;
}

@end

@implementation PublishRecordInputView

- (id)initWithFrame:(CGRect)frame content:(NSString *)content {
    self = [super initWithFrame:frame];
    if (self) {
        _isInitialized = YES;
        _frame = frame;
        self.backgroundColor = [UIColor blackColor];
        _textView = [[UITextView alloc] init];
        _textView.font = [UIFont systemFontOfSize:14];
        _textView.textColor = [UIColor whiteColor];
        _textView.backgroundColor = [UIColor getColor:@"#292929"];
        _textView.layer.cornerRadius = 4;
        _textView.text = content;
        [self addSubview:_textView];
        [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(top_margin));
            make.left.equalTo(@10);
            make.bottom.equalTo(self.mas_bottom).offset(-top_margin);
            make.right.equalTo(self.mas_right).offset(-60);
        }];
        
        _doneBtn = [[UIButton alloc] init];
        [_doneBtn addTarget:self action:@selector(finishBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_doneBtn setTitleColor:[UIColor getColor:@"#ff5b52"] forState:UIControlStateNormal];
        [_doneBtn setTitle:@"完成" forState:UIControlStateNormal];
        _doneBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [self addSubview:_doneBtn];
        [_doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).offset(0);
            make.size.mas_equalTo(CGSizeMake(60, 44));
            make.centerY.equalTo(self);
        }];
        
        @weakify(self);
        [RACObserve(self.textView, contentSize) subscribeNext:^(id x) {
            @strongify(self);
            if (self.textView.contentSize.height>CGRectGetHeight(self->_frame)-top_margin*2) {
                CGFloat new_h = self->_textView.contentSize.height+top_margin*2>90?90:self.textView.contentSize.height+top_margin*2;
                if (_isInitialized) {
                    _isInitialized = NO;
                    self.frame = CGRectMake(0, CGRectGetMinY(self.frame), CGRectGetWidth(self.frame), new_h);
                } else {
                    self.frame = CGRectMake(0, CGRectGetMaxY(self.frame)-new_h, CGRectGetWidth(self.frame), new_h);
                }
                
            }
            if (self.textView.contentSize.height<=CGRectGetHeight(self->_frame)-top_margin*2) {
                self.frame = CGRectMake(0, CGRectGetMaxY(self.frame)-CGRectGetHeight(self->_frame), CGRectGetWidth(self.frame), CGRectGetHeight(self->_frame));
            }
        }];
        
        //键盘高度变化通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)beginInput {
    if ([_textView canBecomeFirstResponder]) {
        [_textView becomeFirstResponder];
    }
    
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - 监听方法
/**
 * 键盘的frame发生改变时调用（显示、隐藏等）
 */
- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    // 键盘的frame
    CGRect keyboardF = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (_textView.isFirstResponder) {
        self.frame = CGRectMake(CGRectGetMinX(self.frame), keyboardF.origin.y-CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    } else {
        [UIView animateWithDuration:0.2 animations:^{
           self.frame = CGRectMake(CGRectGetMinX(self.frame), kScreenHeight, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(CGRectGetMinX(self.frame), kScreenHeight, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    }];
}
- (void)finishBtnClicked:(UIButton *)btn {
    if (_textView.isFirstResponder) {
        [_textView resignFirstResponder];
    }
    
    if (self.DoneBlock) {
        self.DoneBlock(_textView.text);
    }
}

@end
