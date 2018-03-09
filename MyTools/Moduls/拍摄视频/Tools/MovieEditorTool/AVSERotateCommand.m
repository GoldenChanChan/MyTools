/*
     File: AVSERotateCommand.m
 Abstract: A subclass of AVSECommand which uses AVMutableVideoComposition to achieve a rotate effect. This tool rotates the composition by 90 degrees. This is achieved by applying a CGAffineTransformRotate along with CGAffineTransformMakeTranslation to move the rotated composition into view.
  Version: 1.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 */


#import "AVSERotateCommand.h"

#define degreesToRadians( degrees ) ( ( degrees ) / 180.0 * M_PI )

@implementation AVSERotateCommand

- (void)rotateWithAsset:(AVAsset*)asset radians:(CGFloat)degrees
{
	AVMutableVideoCompositionInstruction *instruction = nil;
	AVMutableVideoCompositionLayerInstruction *layerInstruction = nil;
	CGAffineTransform t1;
	CGAffineTransform t2;
	
	AVAssetTrack *assetVideoTrack = nil;
	AVAssetTrack *assetAudioTrack = nil;
	// Check if the asset contains video and audio tracks
	if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
		assetVideoTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
	}
	if ([[asset tracksWithMediaType:AVMediaTypeAudio] count] != 0) {
		assetAudioTrack = [asset tracksWithMediaType:AVMediaTypeAudio][0];
	}
	
	CMTime insertionPoint = kCMTimeZero;
	NSError *error = nil;
	
	
	// Step 1
	// Create a composition with the given asset and insert audio and video tracks into it from the asset
	if (!self.mutableComposition) {
		
		// Check whether a composition has already been created, i.e, some other tool has already been applied
		// Create a new composition
		self.mutableComposition = [AVMutableComposition composition];
		
		// Insert the video and audio tracks from AVAsset
		if (assetVideoTrack != nil) {
			AVMutableCompositionTrack *compositionVideoTrack = [self.mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
			[compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration]) ofTrack:assetVideoTrack atTime:insertionPoint error:&error];
		}
		if (assetAudioTrack != nil) {
			AVMutableCompositionTrack *compositionAudioTrack = [self.mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
			[compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration]) ofTrack:assetAudioTrack atTime:insertionPoint error:&error];
		}
		
	}
	
	
	// Step 2
	// Translate the composition to compensate the movement caused by rotation (since rotation would cause it to move out of frame)
    CGSize renderSize = CGSizeZero;
    if (degrees==180.0) {
        //顺时针旋转180°
        NSLog(@"视频旋转180度，home按键在上");
        t1 = CGAffineTransformMakeTranslation(assetVideoTrack.naturalSize.width, assetVideoTrack.naturalSize.height);
        t2 = CGAffineTransformRotate(t1,degreesToRadians(degrees));
        renderSize = CGSizeMake(assetVideoTrack.naturalSize.width,assetVideoTrack.naturalSize.height);
//水印        waterMarkVideoComposition.renderSize = CGSizeMake(assetVideoTrack.naturalSize.width,assetVideoTrack.naturalSize.height);
    }else if (degrees==270.0) {
        //顺时针旋转270°
        NSLog(@"视频旋转270度，home按键在右");
        t1 = CGAffineTransformMakeTranslation(0.0, assetVideoTrack.naturalSize.width);
        t2 = CGAffineTransformRotate(t1,degreesToRadians(degrees));
        renderSize = CGSizeMake(assetVideoTrack.naturalSize.height,assetVideoTrack.naturalSize.width);
//        waterMarkVideoComposition.renderSize = CGSizeMake(assetVideoTrack.naturalSize.height,assetVideoTrack.naturalSize.width);
    }else if (degrees==90.0) {
        //顺时针旋转90°
        NSLog(@"视频旋转90度，home按键在左");
        t1 = CGAffineTransformMakeTranslation(assetVideoTrack.naturalSize.height, 0.0);
        // Rotate transformation
        t2 = CGAffineTransformRotate(t1, degreesToRadians(90.0));
        renderSize = CGSizeMake(assetVideoTrack.naturalSize.height,assetVideoTrack.naturalSize.width);
    } else {
        NSLog(@"进支持以上三种角度旋转~~~~");
    }
	

	// Step 3
	// Set the appropriate render sizes and rotational transforms
	if (!self.mutableVideoComposition) {
		
		// Create a new video composition
		self.mutableVideoComposition = [AVMutableVideoComposition videoComposition];
		self.mutableVideoComposition.renderSize = renderSize;
		self.mutableVideoComposition.frameDuration = CMTimeMake(1, 30);
		
		// The rotate transform is set on a layer instruction
		instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
		instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [self.mutableComposition duration]);
		layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:(self.mutableComposition.tracks)[0]];
		[layerInstruction setTransform:t2 atTime:kCMTimeZero];
	}
	
	
	// Step 4
	// Add the transform instructions to the video composition
	instruction.layerInstructions = @[layerInstruction];
	self.mutableVideoComposition.instructions = @[instruction];
	// Step 5
	// Notify AVSEViewController about rotation operation completion
}

@end
