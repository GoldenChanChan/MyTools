//
//  PublishRecordInputView.h
//  STeBook
//
//  Created by scjy on 2017/8/15.
//  Copyright © 2017年 rain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PublishRecordInputView : UIView

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton   *doneBtn;

@property (nonatomic, strong) void(^DoneBlock)(NSString *content);
- (id)initWithFrame:(CGRect)frame content:(NSString *)content;
- (void)beginInput;
@end
