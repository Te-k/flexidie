//
//  TestAppAppDelegate.m
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 2/14/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "TestAppAppDelegate.h"
#import "TestAppViewController.h"
#import "MediaThumbnailManagerImp.h"
#import "MediaInfo.h"


@interface TestAppAppDelegate (private)

- (void) timer;

@end


@implementation TestAppAppDelegate

@synthesize window;
@synthesize viewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
//	NSLog(@"TestAppAppDelegate --> application:didFinishLaunchingWithOptions");
//	
//	NSString *outputDirectory = @"/tmp/output/";
//	MediaThumbnailManagerImp * mediaMgr = [[MediaThumbnailManagerImp alloc] initWithThumbnailDirectory:outputDirectory];
//	NSString *imageFileName ;
//	NSString *inputPath;
//	// ------ video --------
//	NSString *mainInputPath = @"/tmp/input_video/";
	
	// ------------------------------------
	// File not found
	
//	imageFileName = @"m4afsfdsf.MOV";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createVideoThumbnail:inputPath delegate:self];
//	
//	// ------------------------------------
//	// Valid format 
//	
//	imageFileName = @"universal2.MOV";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createVideoThumbnail:inputPath delegate:self];
//	
//	imageFileName = @"universal2.M4V";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createVideoThumbnail:inputPath delegate:self];
//	
//	imageFileName = @"universal2.MP4";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createVideoThumbnail:inputPath delegate:self];
//	
//	imageFileName = @"universal2.3GP";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createVideoThumbnail:inputPath delegate:self];
//	
//	
//	imageFileName = @"IMG_0275.MOV";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createVideoThumbnail:inputPath delegate:self];
//	
//	
//	// ------------------------------------
//	// Invalid format 
//	
//	imageFileName = @"pdf.pdf";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createVideoThumbnail:inputPath delegate:self];
//	
//	imageFileName = @"ods.ods";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createVideoThumbnail:inputPath delegate:self];
//	
//	imageFileName = @"txt.txt";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createVideoThumbnail:inputPath delegate:self];
//	
//	imageFileName = @"rtf.rtf";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createVideoThumbnail:inputPath delegate:self];
//
//	// ------------------------------------
//	// Unsupport format
//
//	imageFileName = @"avi.avi";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createVideoThumbnail:inputPath delegate:self];
//	
//	
//	imageFileName = @"wmv.wmv";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createVideoThumbnail:inputPath delegate:self];
//	
//	
//	imageFileName = @"universal2.FLC";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createVideoThumbnail:inputPath delegate:self];
//	
	
//	// ------ image --------
//	mainInputPath = @"/tmp/input_image/";
//	
//	// ------------------------------------
//	// File not found	
//	imageFileName = @"bmpImagefsdsfsd1.bmp";
//	inputPath = [[mainInputPath stringByAppendingString:imageFileName] retain];
//	[mediaMgr createImageThumbnail:inputPath delegate:self];
//	
//	// ------------------------------------
//	// Valid format 
//	
//	imageFileName = @"bmpImage1.bmp";
//	inputPath = [[mainInputPath stringByAppendingString:imageFileName] retain];
//	[mediaMgr createImageThumbnail:inputPath delegate:self];
//	
//	imageFileName = @"curImage1.cur";
//	inputPath = [[mainInputPath stringByAppendingString:imageFileName] retain];
//	[mediaMgr createImageThumbnail:inputPath delegate:self];
//	
//	imageFileName = @"gifImage1.gif";
//	inputPath = [[mainInputPath stringByAppendingString:imageFileName] retain];
//	[mediaMgr createImageThumbnail:inputPath delegate:self];
//	
//	imageFileName = @"icoImage1.ico";
//	inputPath = [[mainInputPath stringByAppendingString:imageFileName] retain];
//	[mediaMgr createImageThumbnail:inputPath delegate:self];
//	
//	
//	imageFileName = @"IMG_0001.JPG";
//	inputPath = [[mainInputPath stringByAppendingString:imageFileName] retain];
//	[mediaMgr createImageThumbnail:inputPath delegate:self];
//	
//	imageFileName = @"jpgImage6.jpeg";
//	inputPath = [[mainInputPath stringByAppendingString:imageFileName] retain];
//	[mediaMgr createImageThumbnail:inputPath delegate:self];
//	
//	
//	imageFileName = @"pngImage1.png";
//	inputPath = [[mainInputPath stringByAppendingString:imageFileName] retain];
//	[mediaMgr createImageThumbnail:inputPath delegate:self];
//	
//	
//	imageFileName = @"tiffImage1.tiff";
//	inputPath = [[mainInputPath stringByAppendingString:imageFileName] retain];
//	[mediaMgr createImageThumbnail:inputPath delegate:self];
//	
//	imageFileName = @"tiffImage3.tif";
//	inputPath = [[mainInputPath stringByAppendingString:imageFileName] retain];
//	[mediaMgr createImageThumbnail:inputPath delegate:self];
//	
//	imageFileName = @"xbmImage2.xbm";
//	inputPath = [[mainInputPath stringByAppendingString:imageFileName] retain];
//	[mediaMgr createImageThumbnail:inputPath delegate:self];
	
	// ------------------------------------
	// Invalid format
	
//	imageFileName = @"pdf.pdf";
//	inputPath = [[mainInputPath stringByAppendingString:imageFileName] retain];
//	[mediaMgr createImageThumbnail:inputPath delegate:self];
//	
//	imageFileName = @"odf.odf";
//	inputPath = [[mainInputPath stringByAppendingString:imageFileName] retain];
//	[mediaMgr createImageThumbnail:inputPath delegate:self];
//	
//	imageFileName = @"txt.txt";
//	inputPath = [[mainInputPath stringByAppendingString:imageFileName] retain];
//	[mediaMgr createImageThumbnail:inputPath delegate:self];
//	
//	imageFileName = @"rtf.rtf";
//	inputPath = [[mainInputPath stringByAppendingString:imageFileName] retain];
//	[mediaMgr createImageThumbnail:inputPath delegate:self];
	
	// ------------------------------------
	// Unsupport format
	
//	imageFileName = @"aniImage1.ant";
//	inputPath = [[mainInputPath stringByAppendingString:imageFileName] retain];
//	[mediaMgr createImageThumbnail:inputPath delegate:self];
	
	
//	// ------ audio --------
//	mainInputPath = @"/tmp/input_audio/";
//	
//	// ------------------------------------
//	// File not found
//	
//	imageFileName = @"m4afsfdsf.m4a";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createAudioThumbnail:inputPath delegate:self];
	
//	// ------------------------------------
//	// Valid format 
//	
//	imageFileName = @"m4a.m4a";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createAudioThumbnail:inputPath delegate:self];
//	imageFileName = @"makara_m4a.m4a";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createAudioThumbnail:inputPath delegate:self];
	
//	imageFileName = @"wav.wav";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createAudioThumbnail:inputPath delegate:self];
//	
//	imageFileName = @"mp3.mp3";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createAudioThumbnail:inputPath delegate:self];
//	
//	imageFileName = @"m4r.m4r";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createAudioThumbnail:inputPath delegate:self];
//	// ------------------------------------
//	// Invalid format 
//	
//	imageFileName = @"pdf.pdf";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createAudioThumbnail:inputPath delegate:self];
//	
//	imageFileName = @"ods.ods";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createAudioThumbnail:inputPath delegate:self];
//	
//	imageFileName = @"txt.txt";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createAudioThumbnail:inputPath delegate:self];
//	
//	imageFileName = @"rtf.rtf";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createAudioThumbnail:inputPath delegate:self];
//
//	// ------------------------------------
//	// Unsupport format
//	
//	imageFileName = @"aif.aif";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createAudioThumbnail:inputPath delegate:self];
	
	// Add the view controller's view to the window and display.
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];

    return YES;
}


// conform to protocol MediaThumbnailDelegate
- (void) thumbnailCreationDidFinished: (NSError *) aError
							mediaInfo: (MediaInfo *) aMedia
						thumbnailPath: (id) aPaths {
	
	NSLog(@"TestAppAppDelegate --> thumbnailCreationDidFinished:mediaInfo:thumbnailPath: Main Thread or not: %d", [NSThread isMainThread]);

	if ([aMedia mMediaInputType] == kMediaInputTypeVideo) {
		NSLog(@"--------------- VIDEO MEDIA TYPE -------------------");
	} else if ([aMedia mMediaInputType] == kMediaInputTypeImage) {
		NSLog(@"--------------- IMAGE MEDIA TYPE -------------------");
	} else if ([aMedia mMediaInputType] == kMediaInputTypeAudio) {
		NSLog(@"--------------- AUDIO MEDIA TYPE -------------------");
	} else if ([aMedia mMediaInputType] == kMediaInputTypeUndefined) {
		NSLog(@"--------------- UNDEFINED MEDIA TYPE -------------------");
	}
	NSLog(@"error: %@", aError);
	NSLog(@"error: %d", [aError code]);
	NSLog(@"mediaInfo: %@",[aMedia description]);
	NSLog(@"paths: %@", aPaths);	
	// This timer is used to make sure that the callback is called in the main thread
	//[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(timer) userInfo:nil repeats:YES];
	
}

- (void) timer {
	NSLog(@"TIMERRRRR");
	//CFRunLoopStop([[NSRunLoop mainRunLoop] getCFRunLoop]);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void) dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
