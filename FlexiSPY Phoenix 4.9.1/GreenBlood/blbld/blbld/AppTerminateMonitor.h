//
//  AppTerminateMonitor.h
//  blbld
//
//  Created by Makara Khloth on 2/17/15.
//
//

#import <Foundation/Foundation.h>

@interface AppTerminateMonitor : NSObject {
    id mDelegate;
    SEL mSelector;
    
    CFFileDescriptorRef mNoteExitKQueueRef;
    
    NSString *mProcessName;
}

@property (nonatomic, assign) id mDelegate;
@property (nonatomic, assign) SEL mSelector;

@property (nonatomic, copy) NSString *mProcessName;

- (void) start;
- (void) stop;

@end
