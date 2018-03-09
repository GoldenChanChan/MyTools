//
//  RecordVideoViewController.m
//  STeBook
//
//  Created by scjy on 2017/8/13.
//  Copyright © 2017年 rain. All rights reserved.
//

#import "RecordVideoViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreMotion/CoreMotion.h>
#import <Photos/Photos.h>
#import "WCLRecordEngine.h"
#import "RecordTimeCountView.h"
#import "ImageWithBottomTitleButton.h"
#import "TitleWithBottomPointButton.h"
#import "UIColor+Method.h"
#import "AppDefines.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "MediaEditorHelper.h"
#import "EXTScope.h"

//#import "PublishRecordViewController.h"
//#import "MediaEditorHelper.h"
//#import "LoadingManager.h"
//#import "AppDelegate+Publish.h"


#define TypeMovie    @"public.movie"
#define TypeImage    @"public.image"

#define MAINSTYLECOLOR [UIColor colorWithRed:56.0f/255.0f green:55.0f/255.0f blue:61.0f/255.0f alpha:1]

@interface RecordVideoViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    int limitTimerInterval;
    CGFloat _currentRecordTime;
}
@property (nonatomic, strong) RecordTimeCountView *topView;
@property (nonatomic, strong) UIButton *closeBtn;//关闭按钮
@property (nonatomic, strong) UIButton *startBtn;//录制视频按钮
@property (nonatomic, strong) UIButton *switchBtn;//前后摄像头切换按钮
@property (nonatomic, strong) UIButton *lightBtn;//闪光灯按钮
@property (nonatomic, strong) UIButton *recreateBtn;//重拍
@property (nonatomic, strong) UIButton *nextBtn;//重拍
@property (nonatomic, strong) ImageWithBottomTitleButton *selectLocalVideoButton;//导入视频
@property (nonatomic, strong) UIImagePickerController *imagePicker;

@property (nonatomic, strong) TitleWithBottomPointButton *videoBottomOption;//拍摄视频


@property (nonatomic, strong) WCLRecordEngine         *recordEngine;
@property (nonatomic, strong) NSTimer *limitTimer;
@property (nonatomic, strong) MPMoviePlayerViewController *playerVC;//播放器
@property (nonatomic, strong) UIImage *videoCoverImage;//视频截图
@property (nonatomic, copy) NSString *videoPath;
@property (nonatomic, strong) CMMotionManager * motionManager;//通过陀螺仪定时检查屏幕方向
@property (nonatomic, assign) UIDeviceOrientation orientation;//当前屏幕的实际方向(只用于旋转视图)

@end

@implementation RecordVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    limitTimerInterval = 30;
    self.orientation = UIDeviceOrientationPortrait;//默认竖屏(当前按钮初始化的方向)
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    [self.recordEngine previewLayer].frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    [self.view.layer insertSublayer:[self.recordEngine previewLayer] atIndex:0];
//    [self.recordEngine startUp];
    
    [self.view addSubview:self.topView];
    
    //此处开始添加子视图的顺序不能变
    [self.view addSubview:self.videoBottomOption];
    [self.view addSubview:self.startBtn];
    [self.view addSubview:self.selectLocalVideoButton];
    [self.view addSubview:self.switchBtn];
    [self.view addSubview:self.lightBtn];
    [self.view addSubview:self.closeBtn];
    
    [self.view addSubview:self.recreateBtn];
    [self.view addSubview:self.nextBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc {
    NSLog(@"dealloc %@",self.class);
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [UIApplication sharedApplication].statusBarHidden = YES;
    [self startMotionManager];
    [self.recordEngine startUp];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self.navigationController setNavigationBarHidden:NO];
    [self stopMotionManager];
    [self.recordEngine shutdown];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

//MARK: - 系统通知
- (void)appResignActive {//进入后台则结束录制
    if (self.recordEngine.isCapturing) {
        [self.recordEngine stopRecordWhileAppDidInBackGround];
        
        if (_limitTimer) {//结束计时
            [_limitTimer invalidate];
            _limitTimer = nil;
        }
    }
}
- (void)appBecomeActive {//进入前台时，按需切换到下一步
    if (self.recordEngine.isPaused||self.recordEngine.isCapturing) {
        [self startBtnClicked:self.startBtn];
    }
}

#pragma mark - btn click
//返回
- (void)closeBtnClicked:(UIButton *)btn {
    [self stopPlayMovie];
    [self.recordEngine shutdown];
    if (self.navigationController) {
        if ([self.navigationController respondsToSelector:@selector(popViewControllerAnimated:)]) {
            [self.navigationController popViewControllerAnimated:YES];
        } else if ([self.navigationController respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    }
}
//开始和结束
- (void)startBtnClicked:(UIButton *)btn {
    if (btn.selected) {
        //停止录制 并跳转到下一步界面
        [self endRecordMovie];
    } else {
        
        //开始录制
        [self startRecordMovie];
    }
    btn.selected = !btn.selected;
}
//摄像头切换
- (void)switchBtnClicked:(UIButton *)btn {
    btn.selected = !btn.selected;
    if (btn.selected) {//前置摄像头
        //前置摄像头
        self.lightBtn.selected = NO;
        self.lightBtn.enabled = NO;
        [self.recordEngine closeFlashLight];
        [self.recordEngine changeCameraInputDeviceisFront:YES];
    } else {//后置摄像头
        self.lightBtn.selected = NO;
        self.lightBtn.enabled = YES;
        [self.recordEngine changeCameraInputDeviceisFront:NO];
    }
}
//闪光灯开关
- (void)lightBtnClicked:(UIButton *)btn {
    btn.selected = !btn.selected;
    if (btn.selected) {
        [self.recordEngine openFlashLight];
    } else {
        [self.recordEngine closeFlashLight];
    }
}

//导入视频
- (void)selectLocalVideoButtonClicked:(UIButton *)btn {
    if ([MediaEditorHelper canUserPickVideosFromPhotoLibrary]){
        self.imagePicker.mediaTypes =  [[NSArray alloc] initWithObjects:TypeMovie, nil];
        [self.imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    }
    //        weakSelf.imagePicker.allowsEditing = YES;
    
}
//重拍
- (void)recreateBtnClicked:(UIButton *)btn {
    //隐藏切换按钮，闪光灯按钮，导入本地视频按钮，拍摄按钮，底部选项卡视图
    self.switchBtn.hidden = NO;
    self.lightBtn.hidden = NO;
    self.startBtn.hidden = NO;
    self.selectLocalVideoButton.hidden = NO;
    self.videoBottomOption.hidden = NO;
    //隐藏重拍按钮，下一步按钮
    self.recreateBtn.hidden = YES;
    self.nextBtn.hidden = YES;
    [self stopPlayMovie];
}
//下一步
- (void)nextBtnClicked:(UIButton *)btn {
    //跳转到下一步界面
//    [self pushToPublishControllerWithVideoPath:self.recordEngine.videoPath coverImage:self.videoCoverImage imagePickerInfo:nil];
}

- (void)pushToPublishControllerWithVideoPath:(NSString *)videoPath coverImage:(UIImage *)coverImage imagePickerInfo:(NSDictionary *)pickerInfo{
    //隐藏重拍按钮，下一步按钮
    self.recreateBtn.hidden = YES;
    self.nextBtn.hidden = YES;
    
    [self stopPlayMovie];
    [self.recordEngine shutdown];
    
//    PublishRecordViewController *controller = [[PublishRecordViewController alloc] init];
//    controller.videoLocalPath = videoPath;
//    controller.coverImage = coverImage;
//    controller.duration = _currentRecordTime;
//    controller.tempBookId = self.tempBookId;
//    controller.model = nil;
//    [self.navigationController pushViewController:controller animated:YES];
    
}
#pragma mark - timer action
- (void)timerAction {
    if (limitTimerInterval==0) {
        [self startBtnClicked:self.startBtn];
    } else {
        limitTimerInterval--;
        //更新计时视图
        [self.topView setContent:[NSString stringWithFormat:@"00:%02i",limitTimerInterval]];
    }
}

//开始录制
- (void)startRecordMovie{
    limitTimerInterval = 30;
    _limitTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_limitTimer forMode:NSDefaultRunLoopMode];
    self.selectLocalVideoButton.hidden = YES;
    self.videoBottomOption.hidden = YES;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.topView.frame = CGRectMake(0, 0, CGRectGetWidth(self.topView.frame), CGRectGetHeight(self.topView.frame));
        self.closeBtn.frame = CGRectMake(CGRectGetMinX(self.closeBtn.frame), -CGRectGetHeight(self.closeBtn.frame), CGRectGetWidth(self.closeBtn.frame), CGRectGetHeight(self.closeBtn.frame));
    }];
    //设置录制方向并开始捕捉画面
    self.recordEngine.startCaptureDeviceOrientation = self.orientation;
    [self.recordEngine startCapture];
}

//结束录制
- (void)endRecordMovie {
    if (_limitTimer) {//结束计时
        [_limitTimer invalidate];
        _limitTimer = nil;
    }
    //暂停捕捉画面
//    [self.recordEngine pauseCapture];
    
    void (^dealFailureMethod)() = ^(){
        [SVProgressHUD showErrorWithStatus:@"视频录制失败，请重拍！"];
        if (self.lightBtn.selected) {//关闭闪光灯
            [self lightBtnClicked:self.lightBtn];
        }
        [UIView animateWithDuration:0.2 animations:^{
            self.topView.frame = CGRectMake(0, -CGRectGetHeight(self.topView.frame), CGRectGetWidth(self.topView.frame), CGRectGetHeight(self.topView.frame));
            self.closeBtn.frame = CGRectMake(CGRectGetMinX(self.closeBtn.frame), 0, CGRectGetWidth(self.closeBtn.frame), CGRectGetHeight(self.closeBtn.frame));
        }];
        self.selectLocalVideoButton.hidden = NO;
        self.videoBottomOption.hidden = NO;
    };
    
    if (self.recordEngine.videoPath.length > 0) {//显示预览界面
        [SVProgressHUD showWithStatus:@"视频处理中..."];
        @weakify(self);
        [self.recordEngine stopCaptureHandler:^(UIImage *movieImage) {
            _currentRecordTime = self.recordEngine.currentRecordTime;
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
            
            @strongify(self);
            
            if (movieImage) {
                self.videoCoverImage = movieImage;
                self.videoPath = self.recordEngine.videoPath;
                [self showPreView];
            } else {
                dealFailureMethod();
            }
        }];
    }else {
        dealFailureMethod();
    }
}
//停止播放
- (void)stopPlayMovie {
    if (self.playerVC) {
        [self.playerVC.moviePlayer stop];
        [self.playerVC.view.layer removeFromSuperlayer];
        [self.playerVC removeFromParentViewController];
        self.playerVC = nil;
    }
}
//进入预览界面
- (void)showPreView {
    if (self.lightBtn.selected) {//关闭闪光灯
        [self lightBtnClicked:self.lightBtn];
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.topView.frame = CGRectMake(0, -CGRectGetHeight(self.topView.frame), CGRectGetWidth(self.topView.frame), CGRectGetHeight(self.topView.frame));
        self.closeBtn.frame = CGRectMake(CGRectGetMinX(self.closeBtn.frame), 0, CGRectGetWidth(self.closeBtn.frame), CGRectGetHeight(self.closeBtn.frame));
    }];
    //隐藏切换按钮，闪光灯按钮，导入本地视频按钮，拍摄按钮，底部选项卡视图
    self.switchBtn.hidden = YES;
    self.lightBtn.hidden = YES;
    self.startBtn.hidden = YES;
    self.selectLocalVideoButton.hidden = YES;
    self.videoBottomOption.hidden = YES;
    //显示重拍按钮，下一步按钮
    self.recreateBtn.hidden = NO;
    self.nextBtn.hidden = NO;
    //开始自动播放
    self.playerVC =  [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:self.videoPath]];
    NSLog(@"url=%@",self.videoPath);
    self.playerVC.moviePlayer.controlStyle = MPMovieControlStyleNone;
    self.playerVC.moviePlayer.repeatMode = MPMovieRepeatModeOne;
    [self addChildViewController:self.playerVC];
    self.playerVC.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    [self.view.layer insertSublayer:self.playerVC.view.layer above:[self.recordEngine previewLayer]];
    [[self.playerVC moviePlayer] prepareToPlay];
    
}
//启动屏幕方向监控
- (void)startMotionManager{
    if (_motionManager == nil) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    _motionManager.deviceMotionUpdateInterval = 1/15.0;
    if (_motionManager.deviceMotionAvailable) {
        NSLog(@"Device Motion Available");
        [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
                                            withHandler: ^(CMDeviceMotion *motion, NSError *error){
                                                [self performSelectorOnMainThread:@selector(handleDeviceMotion:) withObject:motion waitUntilDone:YES];
                                                
                                            }];
    } else {
        NSLog(@"No device motion on device.");
        [self setMotionManager:nil];
    }
}
//停止屏幕方向监控
- (void)stopMotionManager {
    [_motionManager stopDeviceMotionUpdates];
}

- (void)handleDeviceMotion:(CMDeviceMotion *)deviceMotion{
    double x = deviceMotion.gravity.x;
    double y = deviceMotion.gravity.y;
    if (x >= 0.75) {//home button left
//        orientationNew = UIDeviceOrientationLandscapeRight;
        if (self.orientation != UIDeviceOrientationLandscapeRight) {
            [self transformFromOrientation:self.orientation toOrientation:UIDeviceOrientationLandscapeRight];
            self.orientation=UIDeviceOrientationLandscapeRight;
            NSLog(@"屏幕向右");
        }
    }
    else if (x <= -0.75) {//home button right
//        orientationNew = UIDeviceOrientationLandscapeLeft;
        if (self.orientation != UIDeviceOrientationLandscapeLeft) {
            [self transformFromOrientation:self.orientation toOrientation:UIDeviceOrientationLandscapeLeft];
            self.orientation=UIDeviceOrientationLandscapeLeft;
            NSLog(@"屏幕向左");
        }
    }
    else if (y <= -0.75) {
//        orientationNew = UIDeviceOrientationPortrait;
        if (self.orientation != UIDeviceOrientationPortrait) {
            [self transformFromOrientation:self.orientation toOrientation:UIDeviceOrientationPortrait];
            self.orientation=UIDeviceOrientationPortrait;
            NSLog(@"屏幕向上");
        }
    }
    else if (y >= 0.75) {
//        orientationNew = UIDeviceOrientationPortraitUpsideDown;
        if (self.orientation != UIDeviceOrientationPortraitUpsideDown) {
            [self transformFromOrientation:self.orientation toOrientation:UIDeviceOrientationPortraitUpsideDown];
            self.orientation=UIDeviceOrientationPortraitUpsideDown;
            NSLog(@"屏幕向下");
        }
    }
    else {
        // Consider same as last time
        return;
    }
}

//旋转子视图(所有旋转都是相对初始化时的位置旋转的)
- (void)transformFromOrientation:(UIDeviceOrientation)fromOrientation
                   toOrientation:(UIDeviceOrientation)toOrientation {
    CGFloat radian = 0;//正数为顺时针旋转，负数为逆时针旋转,0表示回到初始位置

    if (toOrientation==UIDeviceOrientationPortrait) {
        radian = 0;
    }
    if (toOrientation==UIDeviceOrientationLandscapeLeft) {
        radian = 90.0;
    }
    if (toOrientation==UIDeviceOrientationLandscapeRight) {
        radian = -90.0;
    }
    if (toOrientation==UIDeviceOrientationPortraitUpsideDown) {
        radian = 180.0;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        self.switchBtn.transform = CGAffineTransformMakeRotation(radian*M_PI/180);
        self.lightBtn.transform = CGAffineTransformMakeRotation(radian*M_PI/180);
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - UIImagePickerControllerDelegate 代理方法
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{

    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self dismissViewControllerAnimated:YES completion:^{
        NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        //         NSLog(@"info:%@",info);
        if([mediaType isEqualToString:TypeMovie]) {
            NSLog(@"已选择视频");
//            [MediaEditorHelper dealLocalVideo:info result:^(BOOL succ, NSString *videoPath, NSInteger duration) {
//                _currentRecordTime = duration;
//            }];
             NSURL* mediaURL = [info objectForKey:UIImagePickerControllerMediaURL];
            self.videoPath = mediaURL.path;
            [self showPreView];
        }
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo
{
    
}
#pragma mark - init property
- (RecordTimeCountView *)topView {
    if (!_topView) {
        _topView = [[RecordTimeCountView alloc] initWithFrame:CGRectMake(0, -40, kScreenWidth, 40)];
    }
    return _topView;
}
- (WCLRecordEngine *)recordEngine {
    if (_recordEngine == nil) {
        _recordEngine = [[WCLRecordEngine alloc] init];
//        _recordEngine.delegate = self;
    }
    return _recordEngine;
}

//懒加载imagePicker
- (UIImagePickerController *)imagePicker{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        [_imagePicker.navigationBar setBarTintColor: MAINSTYLECOLOR];
        [_imagePicker.navigationBar setTranslucent:NO];
        [_imagePicker.navigationBar setTintColor:[UIColor whiteColor]];
        [_imagePicker.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:18.0]}];
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}

#define CameraBtn_W 40
#define StartBtn_W 65
- (UIButton *)startBtn {
    if (!_startBtn) {
        _startBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth/2-StartBtn_W/2, kScreenHeight-StartBtn_W-CGRectGetHeight(self.videoBottomOption.frame)-14, StartBtn_W, StartBtn_W)];
        [_startBtn setImage:[UIImage imageNamed:@"icon_publish_recoredVideo_startBtn_normal"] forState:UIControlStateNormal];
        [_startBtn setImage:[UIImage imageNamed:@"icon_publish_recoredVideo_startBtn_selected"] forState:UIControlStateSelected];
        [_startBtn addTarget:self action:@selector(startBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _startBtn.layer.masksToBounds = YES;
        _startBtn.layer.cornerRadius = StartBtn_W/2;
        _startBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        _startBtn.layer.borderWidth = 5;
    }
    return _startBtn;
}

- (UIButton *)switchBtn {
    if (!_switchBtn) {
        _switchBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth/2-20-CameraBtn_W, CGRectGetMinY(self.startBtn.frame)-CameraBtn_W-16, CameraBtn_W, CameraBtn_W)];
        [_switchBtn setImage:[UIImage imageNamed:@"icon_camera_switchBtn"] forState:UIControlStateNormal];//后置摄像
        [_switchBtn setImage:[UIImage imageNamed:@"icon_camera_switchBtn"] forState:UIControlStateSelected];//前置摄像
        [_switchBtn addTarget:self action:@selector(switchBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//        _switchBtn.backgroundColor = [UIColor colorWithRed:59/255 green:59/255 blue:59/255 alpha:0.8];
//        _switchBtn.layer.cornerRadius = 36/2;
    }
    return _switchBtn;
}

- (UIButton *)lightBtn {
    if (!_lightBtn) {
        _lightBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth/2+20, CGRectGetMinY(self.startBtn.frame)-CameraBtn_W-16, CameraBtn_W, CameraBtn_W)];
        [_lightBtn setImage:[UIImage imageNamed:@"icon_camera_light_normal"] forState:UIControlStateNormal];//未开启闪光灯
        [_lightBtn setImage:[UIImage imageNamed:@"icon_camera_light_selected"] forState:UIControlStateSelected];//开启闪光灯
        [_lightBtn setImage:[UIImage imageNamed:@"icon_camera_light_disabled"] forState:UIControlStateDisabled];//闪光灯不可用
        [_lightBtn addTarget:self action:@selector(lightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//        _lightBtn.backgroundColor = [UIColor colorWithRed:59/255 green:59/255 blue:59/255 alpha:0.8];
//        _lightBtn.layer.cornerRadius = 36/2;
    }
    return _lightBtn;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-44, 0, 44, 44)];
        [_closeBtn setImage:[UIImage imageNamed:@"icon_publish_recoredVideo_close"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

#define PreViewBtn_w 60
- (UIButton *)recreateBtn {
    if (!_recreateBtn) {
        _recreateBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, kScreenHeight-45-PreViewBtn_w, PreViewBtn_w, PreViewBtn_w)];
        _recreateBtn.hidden = YES;
        _recreateBtn.backgroundColor = [UIColor getColor:@"#a5a5a5"];
        _recreateBtn.layer.cornerRadius = PreViewBtn_w/2;
        [_recreateBtn setTitle:@"重拍" forState:UIControlStateNormal];
        _recreateBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [_recreateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_recreateBtn addTarget:self action:@selector(recreateBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _recreateBtn;
}

- (UIButton *)nextBtn {
    if (!_nextBtn) {
        _nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-50-PreViewBtn_w, kScreenHeight-45-PreViewBtn_w, PreViewBtn_w, PreViewBtn_w)];
        _nextBtn.hidden = YES;
        _nextBtn.backgroundColor = [UIColor getColor:@"#f35651"];
        _nextBtn.layer.cornerRadius = PreViewBtn_w/2;
        [_nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
        _nextBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [_nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_nextBtn addTarget:self action:@selector(nextBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextBtn;
}

- (ImageWithBottomTitleButton *)selectLocalVideoButton {
    if (!_selectLocalVideoButton) {
        CGSize imageSize = CGSizeMake(40, 40);
        _selectLocalVideoButton = [[ImageWithBottomTitleButton alloc] initWithImageViewSize:imageSize title:@"导入视频" font:[UIFont systemFontOfSize:12]];
        CGFloat y= self.startBtn.center.y-imageSize.height/2;
        _selectLocalVideoButton.frame = CGRectMake(40, y, CGRectGetWidth(_selectLocalVideoButton.frame), CGRectGetHeight(_selectLocalVideoButton.frame));
        [_selectLocalVideoButton addTarget:self action:@selector(selectLocalVideoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        //获取第一个视频对象
        PHAsset *video = nil;
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        //ascending 为YES时，按照照片的创建时间升序排列;为NO时，则降序排列
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:option];
        if (result.count>0) {
            video = result[0];
        }
        //获取视频截图
        [MediaEditorHelper requestImageForAsset:video size:CGSizeMake(imageSize.width*2.5, imageSize.height*2.5) resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image, NSDictionary *info) {
            [_selectLocalVideoButton setImage:image];
        }];
    }
    return _selectLocalVideoButton;
}

- (TitleWithBottomPointButton *)videoBottomOption {
    if (!_videoBottomOption) {
        _videoBottomOption = [[TitleWithBottomPointButton alloc] initWithTitle:@"拍摄视频" isSelected:YES font:[UIFont systemFontOfSize:12]];
        _videoBottomOption.frame = CGRectMake(kScreenWidth/2-CGRectGetWidth(_videoBottomOption.frame)/2, kScreenHeight-CGRectGetHeight(_videoBottomOption.frame), CGRectGetWidth(_videoBottomOption.frame), CGRectGetHeight(_videoBottomOption.frame));
    }
    return _videoBottomOption;
}
@end
