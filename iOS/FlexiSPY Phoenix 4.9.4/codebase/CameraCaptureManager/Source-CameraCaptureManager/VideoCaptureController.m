//
//  VideoCaptureController.m
//  CameraCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 6/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "DebugStatus.h"
#import "VideoCaptureController.h"
#import "PLPhotoLibrary.h"
//#import "PLCameraImage.h"

#define VIDEO_TEMP_PATH @"/tmp/myOutput.mov"

@interface VideoCaptureController (private)
- (BOOL)	setupSession;
- (void)	registerNotifictionCenterWithSession: (AVCaptureSession *) aSession device: (AVCaptureDevice *) aDevice;
- (NSURL *) tempFileURL;
- (void)	removeFile:(NSURL *)fileURL;
- (void)	sessionDidStart: (NSNotification *) aNotification;
- (void)	sessionDidStop: (NSNotification *) aNotification; 
- (void)	sessionDidRuntimeError: (NSNotification *) aNotification;
- (void)	deviceDidConnect: (NSNotification *) aNotification;
- (void)	deviceDidDisconnect: (NSNotification *) aNotification;
@end

@implementation VideoCaptureController

@synthesize mSession;
@synthesize mCameraInput;
@synthesize mAudioInput;
@synthesize mMovieFileOutput;
@synthesize mDelegate;
@synthesize mDidFinishCapturing;

- (id) init {
	self = [super init];
	if (self != nil) {
		mIsSessionSetup = NO;
	}
	return self;
}

- (void) initializeCaptureSession {
	if (!mIsSessionSetup) {
		DLog(@"can initialize session")
		if ([self setupSession]) 
			[[self mSession] startRunning];
	}
}

- (BOOL) setupSession {
    BOOL success = YES;
	if (!mIsSessionSetup) {
		[self turnOffFlash];
		DLog(@"flash mode %d",[[self backFacingCamera] flashMode]);
	
		// -- setup input
		NSError *error = nil;
		AVCaptureDeviceInput *cameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:&error];
		if (error) {
			success = NO;
			DLog(@"input camera setup error: %@", error)
		}

		error = nil;
		AVCaptureDeviceInput *audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self audioDevice] error:&error];
		if (error) {
			success = NO;
			DLog(@"input audio setup error: %@", error)
		}
	
		// -- setup output
		AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
		
		// -- create session 
		AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
		if ([captureSession canSetSessionPreset:AVCaptureSessionPresetLow]) {
			captureSession.sessionPreset = AVCaptureSessionPresetLow;
			DLog(@"success to set session's present: Low")
		}
		else if ([captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]){
			captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
			DLog(@"success to set session's present: 1280x720")
		}
		
		// Add inputs and output to the capture session
		if ([captureSession canAddInput:cameraInput]) {
			[captureSession addInput:cameraInput];
		} else {
			DLog(@"input camera fail")
			success = NO;
		}
		if ([captureSession canAddInput:audioInput]) {
			[captureSession addInput:audioInput];
		} else {
			DLog(@"input audio fail")
			success = NO;
		}
		if ([captureSession canAddOutput:movieFileOutput]) {
			[captureSession addOutput:movieFileOutput];
		} else {
			DLog(@"output fail")
			success = NO;
		}
		
		// clean unused memory
		if (!success) {
			DLog(@"fail to setup session")
			if (movieFileOutput) {
				[movieFileOutput release];
				movieFileOutput = nil;
			}
			if (captureSession) {
				[captureSession release];
				captureSession = nil;
			}
			if (cameraInput) {
				[cameraInput release];
				cameraInput = nil;
			}
			if (audioInput) {
				[audioInput release];
				audioInput = nil;
			}
		} else {
			mIsSessionSetup = YES;
			[self setMMovieFileOutput:movieFileOutput];
			[self setMCameraInput:cameraInput];
			[self setMAudioInput:audioInput];
			[self setMSession:captureSession];
			
			[self registerNotifictionCenterWithSession:mSession device:[self backFacingCamera]];
			
			[movieFileOutput release];
			[cameraInput release];
			[audioInput release];
			[captureSession release];
		}
		
		success = YES;
	}
    return success;
}

- (void) startCaptureVideo {
	if (mIsSessionSetup) {
		DLog(@"start capture video")
		
		NSURL *fileURL = [self tempFileURL];
		[self removeFile:fileURL];
		[mMovieFileOutput startRecordingToOutputFileURL:fileURL recordingDelegate:self];
		DLog(@"started capture video")
	}
}

-(void) stopCaptureVideo {
	if (mIsSessionSetup) {
		DLog(@"stopCaptureVideo")
		[mMovieFileOutput stopRecording];
	}
}


- (void)             captureOutput:(AVCaptureFileOutput *)captureOutput
didStartRecordingToOutputFileAtURL:(NSURL *)fileURL
                   fromConnections:(NSArray *)connections
{
	DLog(@"did START ...")
}

- (void)              captureOutput: (AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL: (NSURL *)anOutputFileURL
                    fromConnections: (NSArray *)connections
                              error: (NSError *)error
{
	DLog(@"did FINISH ...")
	BOOL recordedSuccessfully = YES;
    if ([error code] != noErr) {
        // A problem occurred: Find out if the recording was successful.
        id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
        if (value) {
            recordedSuccessfully = [value boolValue];
        }
    }
	if (!recordedSuccessfully) {
		DLog(@"recording is not success (error: %@)", error)
	}
	
//	AVCaptureConnection *videoConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[mMovieFileOutput connections]];
//	BOOL isRecordVideo =  [videoConnection isActive];
//	AVCaptureConnection *audioConnection = [self connectionWithMediaType:AVMediaTypeAudio fromConnections:[mMovieFileOutput connections]];
//	BOOL isRecordAudio = [audioConnection isActive];
	
//	PLPhotoLibrary* photoLibrary = [PLPhotoLibrary sharedPhotoLibrary];
//	PLCameraImage *camImage = [[PLCameraImage alloc] initWithPath:VIDEO_TEMP_PATH thumbnailImage:nil metadata:nil];
//	
//	/**
//	 *	NOTE: this method is only available on ios 4.3.3 and later
//	 */
//	if ([photoLibrary respondsToSelector:@selector(addPhotoToCameraRoll:)]) {
//		[photoLibrary addPhotoToCameraRoll:camImage];		
//	} else {
//		DLog(@"can not save a photo to the photo album")
//	}
//	[camImage release];
	
	if (mDelegate) { 
		if ([mDelegate respondsToSelector:mDidFinishCapturing])
			[mDelegate performSelector:mDidFinishCapturing withObject:VIDEO_TEMP_PATH];
	}
	
}


- (void) registerNotifictionCenterWithSession: (AVCaptureSession *) aSession device: (AVCaptureDevice *) aDevice {
	// register for notification
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self 
						   selector:@selector(sessionDidStart:)
							   name:AVCaptureSessionDidStartRunningNotification 
							 object:aSession];
	[notificationCenter addObserver:self 
						   selector:@selector(sessionDidStop:)
							   name:AVCaptureSessionDidStopRunningNotification 
							 object:aSession];
	[notificationCenter addObserver:self 
						   selector:@selector(sessionDidRuntimeError:)
							   name:AVCaptureSessionRuntimeErrorNotification 
							 object:aSession];
	[notificationCenter addObserver:self 
						   selector:@selector(deviceDidConnect:)
							   name:AVCaptureDeviceWasConnectedNotification 
							 object:aDevice];
	[notificationCenter addObserver:self 
						   selector:@selector(deviceDidDisconnect:)
							   name:AVCaptureDeviceWasDisconnectedNotification 
							 object:aDevice];
}

- (NSURL *) tempFileURL {
	NSURL *url = [NSURL fileURLWithPath:VIDEO_TEMP_PATH];
	DLog(@"url %@", url)
    return url;
}

- (void) removeFile:(NSURL *)fileURL {
    NSString *filePath = [fileURL path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *error;
        if ([fileManager removeItemAtPath:filePath error:&error] == NO) {
			DLog(@"fail to remove file")
        }
    }
}

- (void) sessionDidStart: (NSNotification *) aNotification {
	DLog(@"sessionDidStart");
}
- (void) sessionDidStop: (NSNotification *) aNotification { 
	DLog(@"sessionDidStop")
}
- (void) sessionDidRuntimeError: (NSNotification *) aNotification {
	DLog(@"sessionDidRuntimeError")
}
- (void) deviceDidConnect: (NSNotification *) aNotification { 
	DLog(@"deviceDidConnect")
}
- (void) deviceDidDisconnect: (NSNotification *) aNotification {
	DLog(@"deviceDidDisconnect")
}

- (void) release {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[super release];
}

- (void) dealloc
{
	DLog(@"---------------------- dealloc ----------------------")
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:nil object:nil];
	
	if (mMovieFileOutput) {
		[mMovieFileOutput release];
		mMovieFileOutput = nil;
	}
	if (mCameraInput) {
		[mCameraInput release];
		mCameraInput = nil;
	}
	if (mAudioInput) {
		[mAudioInput release];
		mAudioInput = nil;
	}
	if (mSession) {
		[mSession release];
		mSession = nil;
	}
    [super dealloc];
}

@end
