//
//  AppProcessKilledNotifier.h
//  SystemUtils
//
//  Created by Makara Khloth on 1/28/16.
//
//

#import <Foundation/Foundation.h>

@interface AppProcessKilledNotifier : NSObject {
    NSString *mAppProcessName;
    id mDelegate;
    SEL mSelector;
    
    CFFileDescriptorRef mNoteExitKQueueRef;
}

@property (nonatomic, copy) NSString *mAppProcessName;
@property (nonatomic, assign) id mDelegate;
@property (nonatomic, assign) SEL mSelector;

- (void) registerAppProcess;
- (void) unregisterAppProcess;

@end
