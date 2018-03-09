//
//  MediaEditorHelper.h
//  MyTools
//
//  Created by 圣才电子书10号 on 2018/3/9.
//  Copyright © 2018年 goldenchan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface MediaEditorHelper : NSObject
/**
 压缩图片
  @return void
 */
+ (void)normalizedImage:(UIImage *)orignImage
               complete:(void(^)(NSData *data,CGSize size))completeBlock;

/**
 判断是否允许访问视频
 
 @return bool
 */
+ (BOOL) canUserPickVideosFromPhotoLibrary;

/**
 判断是否允许访问相册
 
 @return bool
 */
+ (BOOL) canUserPickPhotosFromPhotoLibrary;

/**
 判断设备是否有摄像头
 
 @return bool
 */
+ (BOOL) isCameraAvailable;

/**
 前面的摄像头是否可用
 
 @return bool
 */
+ (BOOL) isFrontCameraAvailable;

/**
 后面的摄像头是否可用
 
 @return bool
 */
+ (BOOL) isRearCameraAvailable;

/**
 检查摄像头是否支持录像
 
 @return bool
 */
+ (BOOL) doesCameraSupportShootingVideos;

/**
 检查摄像头是否支持拍照
 
 @return bool
 */
+ (BOOL) doesCameraSupportTakingPhotos;

//把获取视频封面图的逻辑抽取出来
/**
 *  获取视频的缩略图方法
 *  @param filePath 视频的本地路径
 *  @return 视频截图
 */
+ (void)getScreenShotImageFromVideoPath:(NSString *)filePath result:(void(^)(BOOL succ,NSString *posterImagePath))result;
/**
 预处理已选择的视频
 改为 NSURL *mediaURL
 @param dict 视频信息
 @param result 处理后的回调
 */
+(void)dealLocalVideo:(NSURL *)mediaURL
               result:(void(^)(BOOL succ,
                               NSString *videoPath,
                               NSInteger duration))result;

+ (void)requestImageForAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *, NSDictionary *))completion;
@end
