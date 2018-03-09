//
//  UploadMediaProgressView.h
//  STeBook
//
//  Created by scjy on 2017/8/15.
//  Copyright © 2017年 rain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UploadMediaProgressView : UIView
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) BOOL succ;
+ (UploadMediaProgressView *)ShowUploadMediaProgressViewWithTerminalBlock:(void(^)())TerminalBlock reuploadBlock:(void(^)())reuploadBlock;
@end
