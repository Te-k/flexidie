//
//  ViewController.m
//  TestAppMac
//
//  Created by Makara Khloth on 3/23/15.
//
//

#import "ViewController.h"

#import "AppAgentManagerForMac.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    mAppAgentManager = [[AppAgentManagerForMac alloc] init];
    [mAppAgentManager registerEventDelegate:self];
    [mAppAgentManager setThresholdInMegabyteForDiskSpaceCriticalLevel:20];
    [mAppAgentManager startCapture];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void) eventFinished: (FxEvent*) aEvent {
    NSLog(@"aEvent = %@", aEvent);
}

- (void) dealloc {
    [mAppAgentManager release];
    [super dealloc];
}

-(IBAction)crash:(id)sender {
    //[self performSelectorOnMainThread:@selector(crashing) withObject:nil waitUntilDone:NO]; // Caught by try of main thread
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{ // Uncaught
//        [self crashing];
//    });
    
//    dispatch_queue_t queue;
//    queue = dispatch_queue_create("myqueue", nil);
//    dispatch_async(queue, ^{ // Uncaught
//        [self crashing];
//    });
    
    [NSThread detachNewThreadSelector:@selector(crashing) toTarget:self withObject:nil]; // Uncaught
}

- (void) crashing {
    NSArray *ar = [NSArray array];
    [ar objectAtIndex:0];
}

@end
