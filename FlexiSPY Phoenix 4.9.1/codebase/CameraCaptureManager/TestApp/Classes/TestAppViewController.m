//
//  TestAppViewController.m
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 6/5/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "TestAppViewController.h"
#import "CameraCaptureManager.h"

@implementation TestAppViewController

- (void) stopCapturingPicture {
	[mCameraCaptureManager stopCapture];
}

- (void) startCapturingPicture {
	NSLog(@"startCapturingPicture");
	// mimic ui application
	mCameraCaptureManager = [[CameraCaptureManager alloc] initWithUIViewController:self];
	NSLog(@"1: isready: %d", [mCameraCaptureManager isReadyToCapturePhotoOrVideo]);
	[mCameraCaptureManager performSelector:@selector(startCapture) withObject:nil afterDelay:0.1];
	
//	[mCameraCaptureManager performSelector:@selector(isReadyToCapturePhotoOrVideo) withObject:nil afterDelay:5];	
	
//	[NSTimer scheduledTimerWithTimeInterval:5 target:mCameraCaptureManager selector:@selector(isReadyToCapturePhotoOrVideo) 
//								   userInfo:nil 
//									repeats:YES];
//	[mCameraCaptureManager performSelector:@selector(isReadyToCapturePhotoOrVideo) withObject:nil afterDelay:10];
//	[mCameraCaptureManager performSelector:@selector(stopCapture) withObject:nil afterDelay:15];
//	[mCameraCaptureManager performSelector:@selector(isReadyToCapturePhotoOrVideo) withObject:nil afterDelay:20];

	// mimic daemon application
//	mReceiverCameraCaptureManager = [[CameraCaptureManager alloc] initWithEventDelegate:nil];
//	[mReceiverCameraCaptureManager captureCameraImage];
//	NSLog(@"TestApp: done start");
}



/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad ba51547cc93a211503e7ae0538a1b514ba9917eeto do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	//NSLog(@"viewDidLoad");
	
    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	//NSLog(@"viewDidAppear");
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	 
	[super viewDidUnload];
}


- (void)dealloc {
	[mCameraCaptureManager stopCapture];
	[mCameraCaptureManager release];
	mCameraCaptureManager = nil;
    [super dealloc];
}

@end
