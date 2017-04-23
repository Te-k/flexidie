//
//  ViewController.h
//  TestAppMac
//
//  Created by Makara Khloth on 3/23/15.
//
//

#import <Cocoa/Cocoa.h>

#import "EventDelegate.h"

@class AppAgentManagerForMac;

@interface ViewController : NSViewController <EventDelegate> {
    AppAgentManagerForMac *mAppAgentManager;
}
-(IBAction)crash:(id)sender;
@end

