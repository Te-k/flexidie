//
//  main.m
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 2/14/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaThumbnailManagerImp.h"
#import "TestAppAppDelegate.h"
//#import "VideoThumbnail.h"
//#import "AudioExtractionHelper.h"
#import "ThumbnailDelegate.h"

void testPhotoThumbnail (ThumbnailDelegate *delegate) {
	NSString *outputDirectory			= @"/tmp/output/";
	NSString *mainInputPath				= @"/tmp/input/";
	MediaThumbnailManagerImp * mediaMgr = [[MediaThumbnailManagerImp alloc] initWithThumbnailDirectory:outputDirectory];

	NSFileManager *fileManager	= [NSFileManager defaultManager];		
	
	NSArray *filesArray			= [fileManager subpathsOfDirectoryAtPath:mainInputPath error:nil];  
	NSLog(@"filesArray %@", filesArray);
	int i = 0;
	for (NSString *eachImage in filesArray) {
		NSString *imagePath			= [mainInputPath stringByAppendingPathComponent:eachImage];

		[mediaMgr createImageThumbnail:imagePath delegate:delegate];
		
		i++;
	}
	
}

void testAudioThumbnail (ThumbnailDelegate *delegate) {
	NSString *outputDirectory			= @"/tmp/output/";
	NSString *mainInputPath				= @"/tmp/input/";
	MediaThumbnailManagerImp * mediaMgr = [[MediaThumbnailManagerImp alloc] initWithThumbnailDirectory:outputDirectory];
	
	NSFileManager *fileManager	= [NSFileManager defaultManager];		
	
	NSArray *filesArray			= [fileManager subpathsOfDirectoryAtPath:mainInputPath error:nil];  
	NSLog(@"filesArray %@", filesArray);
	int i = 0;
	for (NSString *eachImage in filesArray) {
		if ([[eachImage lowercaseString] hasSuffix:@"m4a"]) {
			NSString *audioPath			= [mainInputPath stringByAppendingPathComponent:eachImage];
			
			[mediaMgr createAudioThumbnail:audioPath  delegate:delegate];			
		}
				
		i++;
	}
	
}

void testVideoThumbnail (ThumbnailDelegate *delegate) {
	NSString *outputDirectory			= @"/tmp/output/";
	NSString *mainInputPath				= @"/tmp/input/";
	MediaThumbnailManagerImp * mediaMgr = [[MediaThumbnailManagerImp alloc] initWithThumbnailDirectory:outputDirectory];
	
	NSFileManager *fileManager	= [NSFileManager defaultManager];		
	
	NSArray *filesArray			= [fileManager subpathsOfDirectoryAtPath:mainInputPath error:nil];  
	NSLog(@"filesArray %@", filesArray);
	int i = 0;
	for (NSString *eachImage in filesArray) {
		if ([[eachImage lowercaseString] hasSuffix:@"mov"]) {
			NSString *videoPath			= [mainInputPath stringByAppendingPathComponent:eachImage];
			
			[mediaMgr createVideoThumbnail:videoPath  delegate:delegate];			
		}
		
		i++;
	}
	
}



int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = 0;
	ThumbnailDelegate *delegate = [[ThumbnailDelegate alloc ]init];
	
	//testPhotoThumbnail(delegate);
	//testAudioThumbnail(delegate);
	testVideoThumbnail(delegate);
	
	
	CFRunLoopRun();
//	AudioExtractionManager *manager = [[AudioExtractionManager alloc] init];
//	[manager startExtract];
//	NSLog(@"%u", [[NSThread currentThread] stackSize]);
//	
//	AudioExtractionHelper *helper = [[AudioExtractionHelper alloc] init];
//	[helper startExtractInAnotherThread];
	
//	NSLog(@"TestAppAppDelegate --> application:didFinishLaunchingWithOptions");
	
//	NSString *outputDirectory = @"/tmp/output/";
//	MediaThumbnailManagerImp * mediaMgr = [[MediaThumbnailManagerImp alloc] initWithThumbnailDirectory:outputDirectory];
//	NSString *imageFileName ;
//	NSString *inputPath;
//	
//	// ------ video --------
//	NSString *mainInputPath = @"/tmp/input/";
//	imageFileName = @"bmpImage1.bmp";
//	inputPath = [[mainInputPath stringByAppendingString:imageFileName] retain];
//	[mediaMgr createImageThumbnail:inputPath delegate:nil];
//		

//	NSLog(@"!!!!!!!!!!! EXIT CFRunLoopRun !!!!!!!!!!! ");
//	
	
//    //int retVal = UIApplicationMain(argc, argv, nil, nil);
//	
//	TestAppAppDelegate *delegate  = [[UIApplication sharedApplication] delegate];
//	//NSLog(@"I bet you I will not call until you exit your application");
//	NSString *outputDirectory = @"/tmp/output/";
//	MediaThumbnailManagerImp * mediaMgr = [[MediaThumbnailManagerImp alloc] initWithThumbnailDirectory:outputDirectory];
//	NSString *imageFileName ;
//	NSString *inputPath;
//	// ------ video --------
//	NSString *mainInputPath = @"/tmp/input_video/";
//	
//	imageFileName = @"universal2.MOV";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createVideoThumbnail:inputPath delegate:delegate];
//	
//	imageFileName = @"universal2.M4V";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createVideoThumbnail:inputPath delegate:delegate];
//	
//	imageFileName = @"universal2.MP4";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createVideoThumbnail:inputPath delegate:delegate];
//	
//	imageFileName = @"universal2.3GP";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createVideoThumbnail:inputPath delegate:delegate];
//	
//	
//	imageFileName = @"IMG_0275.MOV";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createVideoThumbnail:inputPath delegate:delegate];
//	CFRunLoopRun();
//    [pool release];
//	
//    return retVal;
	
	

//	NSArray *fileNameArray = [[NSArray alloc] initWithObjects:@"universal2.MOV", 
//							 							  							  @"universal_iPhone.MP4",//,
//							 
//							  @"IMG_0275.MOV", //
//							  @"IMG_0294.MOV",
//							  @"universal2.3GP",//
//							  @"universal2.M4V",//
//							  @"universal2.MP4",//
//							  nil];
//	
//	VideoThumbnail *vdoThumbnail = [[VideoThumbnail alloc] init];
//	
//	for (NSString *filename in fileNameArray) {
//		NSArray *framesPath = [[NSArray alloc] initWithArray:[vdoThumbnail getFrame:10 
//																 fileNameInResource: filename]];
//		NSLog(@"frames path: %@", framesPath);
//		[framesPath release];
//		framesPath = nil;
//	}
//	
//	[vdoThumbnail release];
//	[fileNameArray release];
//	
	
		
//	imageFileName = @"pdf.pdf";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createAudioThumbnail:inputPath delegate:delegate];
	
	
	// ------ video --------
//	NSString *mainInputPath = @"/tmp/input_video/";
	
	// ------------------------------------
	// File not found
//	
//	imageFileName = @"m4afsfdsf.MOV";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createVideoThumbnail:inputPath delegate:delegate];
//	
//	// ------------------------------------
//	// Invalid format 
//	//	
//	imageFileName = @"pdf.pdf";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createVideoThumbnail:inputPath delegate:delegate];
//	
//	imageFileName = @"ods.ods";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createVideoThumbnail:inputPath delegate:delegate];
//	
//	imageFileName = @"txt.txt";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createVideoThumbnail:inputPath delegate:delegate];
//	
//	imageFileName = @"rtf.rtf";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createVideoThumbnail:inputPath delegate:delegate];
//	
//	// ------------------------------------
//	// Valid format 
//		
//	imageFileName = @"universal2.MOV";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createVideoThumbnail:inputPath delegate:delegate];
//	
//	imageFileName = @"universal2.M4V";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createVideoThumbnail:inputPath delegate:delegate];
//	
//	imageFileName = @"universal2.MP4";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createVideoThumbnail:inputPath delegate:delegate];
//	
//	imageFileName = @"universal2.3GP";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createVideoThumbnail:inputPath delegate:delegate];
//	
//	imageFileName = @"IMG_0304.MOV";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createVideoThumbnail:inputPath delegate:delegate];
//	
//	// ------------------------------------
//	// Unsupport format
//	
//	imageFileName = @"avi.avi";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createVideoThumbnail:inputPath delegate:delegate];
//	
//	
//	imageFileName = @"wmv.wmv";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createVideoThumbnail:inputPath delegate:delegate];
//	
//	
//	imageFileName = @"universal2.FLC";
//	inputPath = [mainInputPath stringByAppendingString:imageFileName];
//	[mediaMgr createVideoThumbnail:inputPath delegate:delegate];
//	
		

	
	[pool release];
    return retVal;
	
}
