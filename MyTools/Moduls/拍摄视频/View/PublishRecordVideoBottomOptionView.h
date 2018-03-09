//
//  PublishRecordVideoBottomOptionView.h
//  STeBook
//
//  Created by scjy on 2017/8/14.
//  Copyright © 2017年 rain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PublishRecordVideoBottomOptionView : UIView
@property (nonatomic, strong) UITextField *titleInputField;
@property (nonatomic, strong) UIButton *bgMusicBtn;
@property (nonatomic, strong) NSString *musicName;
@property (nonatomic, strong) UIButton *inputZoneBtn;
@property (nonatomic, strong) void(^PublishBtnClicked)();
@property (nonatomic, strong) void(^MusicBtnClicked)();
@property (nonatomic, strong) void(^BeginInput)();
@end
