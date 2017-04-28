//
//  TestAppAudioPlayerViewController.m
//  TestAppAudioPlayer
//
//  Created by Benjawan Tanarattanakorn on 8/20/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "TestAppAudioPlayerViewController.h"
#import "AudioPlayer.h"

@implementation TestAppAudioPlayerViewController


- (IBAction) startButtonPressed: (id) aSender {
	NSLog(@"--> play");
	if (!mAudioPlayer) {
		mAudioPlayer = [[AudioPlayer alloc] init];
		NSBundle *bundle = [NSBundle mainBundle];
		NSString *alertSoundPath = [bundle pathForResource:@"alertSound.mp3" ofType:nil];
		if (!alertSoundPath) {
			NSLog(@"file not found");
		} else {
			[mAudioPlayer setMFilePath:alertSoundPath];
			[mAudioPlayer setMRepeat:YES];
		}				
	}

	
	[mAudioPlayer play];
}

- (IBAction) stopButtonPressed: (id) aSender {
	NSLog(@"--> stop");
	[mAudioPlayer stop];
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
