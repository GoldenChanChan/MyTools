//
//  MediaEditorHelper.m
//  MyTools
//
//  Created by 圣才电子书10号 on 2018/3/9.
//  Copyright © 2018年 goldenchan. All rights reserved.
//

#import "MediaEditorHelper.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "AppDefines.h"

#define TypeMovie    @"public.movie"
#define TypeImage    @"public.image"

@implementation MediaEditorHelper
+ (void)normalizedImage:(UIImage *)orignImage complete:(void(^)(NSData *data,CGSize size))completeBlock{
    UIImage *normalizedImage = orignImage;
    if (orignImage.imageOrientation != UIImageOrientationUp)//修正图片方向
    {
        UIGraphicsBeginImageContextWithOptions(orignImage.size, NO, orignImage.scale);
        [orignImage drawInRect:(CGRect){0, 0, orignImage.size}];
        normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    NSData *imageData = UIImageJPEGRepresentation(normalizedImage,1.0);
    NSData *result = nil;
    CGSize size = normalizedImage.size;
    float length = [imageData length]/1000;
    if (length > 160) {
        //此处要加判断，小于160k不做处理
        size = orignImage.size;
        float width = (kScreenWidth-32)*3;
        if (size.width > width) {
            size.width = width;
            size.height = width*normalizedImage.size.height/normalizedImage.size.width;
        }
        // 创建一个bitmap的context
        // 并把它设置成为当前正在使用的context
        UIGraphicsBeginImageContext(size);
        // 绘制改变大小的图片
        [normalizedImage drawInRect:CGRectMake(0,0, size.width, size.height)];
        // 从当前context中创建一个改变大小后的图片
        UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
        // 使当前的context出堆栈
        UIGraphicsEndImageContext();
        //返回新的改变大小后的图片
        result = UIImageJPEGRepresentation(scaledImage, 0.5);
    } else {
        result = imageData;;
    }
    if (completeBlock) {
        completeBlock(result,size);
    }
}

// 是否可以在相册中选择视频
+ (BOOL) canUserPickVideosFromPhotoLibrary{
    return [MediaEditorHelper cameraSupportsMedia:TypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

// 是否可以在相册中选择图片
+ (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [MediaEditorHelper cameraSupportsMedia:TypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

// 判断设备是否有摄像头
+ (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}
// 前面的摄像头是否可用
+ (BOOL) isFrontCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}
// 后面的摄像头是否可用
+ (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

// 检查摄像头是否支持录像
+ (BOOL) doesCameraSupportShootingVideos{
    return [MediaEditorHelper cameraSupportsMedia:TypeMovie sourceType:UIImagePickerControllerSourceTypeCamera];
}

// 检查摄像头是否支持拍照
+ (BOOL) doesCameraSupportTakingPhotos{
    return [MediaEditorHelper cameraSupportsMedia:TypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

// 判断是否支持某种多媒体类型：拍照，视频
+ (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0){
        NSLog(@"Media type is empty.");
        return NO;
    }
    NSArray *availableMediaTypes =[UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL*stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
        
    }];
    return result;
}

//把获取视频封面图的逻辑抽取出来
/**
 *  获取视频的缩略图方法
 *  @param filePath 视频的本地路径
 *  @return 视频截图
 */
+ (void)getScreenShotImageFromVideoPath:(NSString *)filePath result:(void(^)(BOOL succ,NSString *posterImagePath))result{
    
    UIImage *shotImage;
    //视频路径URL
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:fileURL options:nil];
    long long second = asset.duration.value / asset.duration.timescale; // 获取视频总时长,单位秒
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    gen.appliesPreferredTrackTransform = YES;
    
    CMTime time = CMTimeMakeWithSeconds(second/2, 60);
    
    NSError *error = nil;
    
    CMTime actualTime;
    
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    
    shotImage = [[UIImage alloc] initWithCGImage:image];
    
    CGImageRelease(image);
    
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyyMMddHHmmss"];
    NSString *dateStr = [formater stringFromDate:[NSDate date]];
    result(YES,nil);
    //压缩封面图片
//    [MediaEditorHelper normalizedImage:shotImage complete:^(NSData *data, CGSize size) {
//        NSString *posterImagePath = [NSString stringWithFormat:@"%@/htmlEditor/media/%@.png",[SGSaveFile getPublicPath],dateStr];
//        [data writeToFile:posterImagePath atomically:YES];
//
//    }];
}



//预处理已选择的视频
+(void)dealLocalVideo:(NSURL *)mediaURL result:(void(^)(BOOL succ,NSString *videoPath,NSInteger duration))result{
    //    NSLog(@"dealLocalVideo:%@",dict);
    //        [Unity addLoadingView:nil WithTag:1111 withText:@"正在处理视频，请稍候…" interactionEnabled:YES];
    //    NSURL* mediaURL = [dict objectForKey:UIImagePickerControllerMediaURL];
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:mediaURL options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    //NSLog(@"compatiblePresets:%@",compatiblePresets);
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:AVAssetExportPresetMediumQuality];
        NSDateFormatter* formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyyMMddHHmmss"];
        NSString *dateStr = [formater stringFromDate:[NSDate date]];
        NSString *videoPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/output%@.mp4", dateStr];
        
        exportSession.outputURL = [NSURL fileURLWithPath: videoPath];
        exportSession.shouldOptimizeForNetworkUse = NO;
        exportSession.outputFileType = AVFileTypeMPEG4;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            NSLog(@"testByte/1024/1024:%lld",[[[NSFileManager defaultManager] attributesOfItemAtPath:videoPath error:nil] fileSize]);
            /* AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:avAsset];
             gen.appliesPreferredTrackTransform = YES;
             CMTime time = CMTimeMakeWithSeconds(30, 60);
             NSError *error = nil;
             CMTime actualTime;
             CGImageRef imageRef = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
             UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
             CGImageRelease(imageRef);
             */
            NSURL    *movieURL = [NSURL fileURLWithPath:videoPath];
            NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
            AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:movieURL options:opts];  // 初始化视频媒体文件
            NSInteger second = urlAsset.duration.value / urlAsset.duration.timescale; // 获取视频总时长,单位秒
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result) {
                    result(YES,videoPath,second);
                }
            });
            //            [Unity removeLoadingView:nil WithTag:1111];
        }];
    } else{
        //        [Unity removeLoadingView:nil WithTag:1111];
        if (result) {
            result(NO,nil,0);
        }
    }
}

#pragma mark - 获取asset对应的图片
+ (void)requestImageForAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *, NSDictionary *))completion
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    /**
     resizeMode：对请求的图像怎样缩放。有三种选择：None，默认加载方式；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸。
     deliveryMode：图像质量。有三种值：Opportunistic，在速度与质量中均衡；HighQualityFormat，不管花费多长时间，提供高质量图像；FastFormat，以最快速度提供好的质量。
     这个属性只有在 synchronous 为 true 时有效。
     */
    
    option.resizeMode = resizeMode;//控制照片尺寸
    //    option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;//控制照片质量
    option.networkAccessAllowed = YES;
    
    /*
     info字典提供请求状态信息:
     PHImageResultIsInCloudKey：图像是否必须从iCloud请求
     PHImageResultIsDegradedKey：当前UIImage是否是低质量的，这个可以实现给用户先显示一个预览图
     PHImageResultRequestIDKey和PHImageCancelledKey：请求ID以及请求是否已经被取消
     PHImageErrorKey：如果没有图像，字典内的错误信息
     */
    
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey];
        //不要该判断，即如果该图片在iCloud上时候，会先显示一张模糊的预览图，待加载完毕后会显示高清图
        // && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]
        if (downloadFinined && completion) {
            completion(image, info);
        }
    }];
}
@end
