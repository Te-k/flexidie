//
//  AddressBarValueNotifier.h
//  PageVisitedCaptureManager
//
//  Created by Makara Khloth on 11/22/16.
//
//

#import <Foundation/Foundation.h>

@protocol PageVisitedDelegate;

// *** Applicable for Chrome & Safari only

@interface AddressBarValueNotifier : NSObject {
    id <PageVisitedDelegate> mDelegate;
    
    AXUIElementRef mBrowserProcess;
    AXUIElementRef mAddressBar;
    AXObserverRef mBrowserObserver;
    AXObserverRef mAddressBarObserver;
    
    pid_t mCurrentPID;
    NSString *mCurrentBundleID;
}

@property (nonatomic, assign) id <PageVisitedDelegate> mDelegate;

@property (nonatomic, assign) pid_t mCurrentPID;
@property (nonatomic, copy) NSString *mCurrentBundleID;

- (instancetype) initWithDelegate: (id <PageVisitedDelegate>) aDelegate;

- (void) startNotify;
- (void) stopNotify;

@end
