//
//  PublishRecordVideoBottomOptionView.m
//  STeBook
//
//  Created by scjy on 2017/8/14.
//  Copyright © 2017年 rain. All rights reserved.
//

#import "PublishRecordVideoBottomOptionView.h"
#import "UIColor+Method.h"
#import "NSString+Size.h"
#import <Masonry/Masonry.h>

@implementation PublishRecordVideoBottomOptionView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.titleInputField = [[UITextField alloc] init];
        self.titleInputField.textColor = [UIColor whiteColor];
        self.titleInputField.placeholder = @"请简述视频内容";
        
        NSAttributedString *attr = [[NSAttributedString alloc] initWithString:self.titleInputField.placeholder attributes:@{NSForegroundColorAttributeName:[UIColor getColor:@"#7a7a7a"], NSFontAttributeName:[UIFont systemFontOfSize:14.0]}];
        self.titleInputField.attributedPlaceholder = attr;
        self.titleInputField.userInteractionEnabled = NO;
        self.titleInputField.font = [UIFont systemFontOfSize:14];
        self.titleInputField.backgroundColor = [UIColor getColor:@"#292929"];
        self.titleInputField.layer.cornerRadius = 4;
        self.titleInputField.returnKeyType = UIReturnKeyDone;
        [self addSubview:self.titleInputField];
        [self.titleInputField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@13);
            make.left.equalTo(@16);
            make.right.equalTo(self.mas_right).offset(-16);
            make.height.equalTo(@40);
        }];
        
        UIButton *inputZoneBtn = [[UIButton alloc] init];
        [inputZoneBtn addTarget:self action:@selector(inputZoneClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:inputZoneBtn];
        self.inputZoneBtn = inputZoneBtn;
        [inputZoneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.titleInputField);
        }];
        //设置边距
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
        view.userInteractionEnabled = NO;
        self.titleInputField.leftView = view;
        self.titleInputField.leftViewMode = UITextFieldViewModeAlways;
        
        self.bgMusicBtn = [[UIButton alloc] init];
        [self.bgMusicBtn addTarget:self action:@selector(bgMusicBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.bgMusicBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.bgMusicBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.bgMusicBtn setImage:[UIImage imageNamed:@"icon_publishVideo_music_normal"] forState:UIControlStateNormal];
        [self.bgMusicBtn setImage:[UIImage imageNamed:@"icon_publishVideo_music_selected"] forState:UIControlStateSelected];
        [self addSubview:self.bgMusicBtn];
        [self.bgMusicBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleInputField);
            make.bottom.equalTo(self.mas_bottom).offset(-8);
            make.size.mas_equalTo(CGSizeMake(36, 36));
        }];
        
        UIButton *publishBtn = [[UIButton alloc] init];
        [publishBtn addTarget:self action:@selector(publishClicked:) forControlEvents:UIControlEventTouchUpInside];
        publishBtn.layer.cornerRadius = 4;
        publishBtn.backgroundColor = [UIColor getColor:@"#ff5b52"];
        [publishBtn setTitle:@"发布" forState:UIControlStateNormal];
        [publishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        publishBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:publishBtn];
        [publishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bgMusicBtn);
            make.right.equalTo(self.titleInputField);
            make.width.equalTo(@70);
            make.height.equalTo(self.bgMusicBtn);
        }];
    }
    return self;
}

- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)inputZoneClicked:(UIButton *)btn {
    if (self.BeginInput) {
        self.BeginInput();
    }
}

- (void)setMusicName:(NSString *)musicName {
    if (musicName.length>0) {
        _musicName = musicName;
        NSString *name = [NSString stringWithFormat:@" %@",musicName];
        CGFloat name_w = [name getWidthOfFont:_bgMusicBtn.titleLabel.font height:20];
        [self.bgMusicBtn setTitle:name forState:UIControlStateSelected];
        [self.bgMusicBtn setTitle:name forState:UIControlStateNormal];
        self.bgMusicBtn.selected = YES;
        [self.bgMusicBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_offset(CGSizeMake(36+name_w+10, 36));
        }];
    }
}

- (void)publishClicked:(UIButton *)btn {
    if (self.PublishBtnClicked) {
        self.PublishBtnClicked();
    }
}

- (void)bgMusicBtnClicked:(UIButton *)btn {
    if (self.MusicBtnClicked) {
        self.MusicBtnClicked();
    }
}
@end
