//
//  OpenPanelAppearMointor.h
//  blbld
//
//  Created by Makara Khloth on 10/19/16.
//
//

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

@class NSEvent;

@interface OpenPanelAppearMointor : NSObject {
@private
    AXUIElementRef mFirefoxProcess;
    AXObserverRef mFirefoxObserver;
    
    EventHandlerRef mCarbonEventsRef;
    
    NSTimeInterval mPanelDisappearAt;
    
    NSEvent *mDraggedEventMonitor;
    NSUInteger mPBCountOfRecentChange;
    
    id mDelegate;
    SEL mSelector;
}

@property (assign) NSTimeInterval mPanelDisappearAt;
@property (retain) NSEvent *mDraggedEventMonitor;
@property (assign) NSUInteger mPBCountOfRecentChange;

@property (nonatomic, assign) id mDelegate;
@property (nonatomic, assign) SEL mSelector;

- (void) startMonitor;
- (void) stopMonitor;

@end
