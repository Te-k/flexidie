//
//  WipeOtherAccountsOP.h
//  WipeDataManager
//
//  Created by Makara Khloth on 6/12/15.
//
//

#import <Foundation/Foundation.h>


@interface WipeOtherAccountsOP : NSOperation {
@private
    id				mDelegate;				// not own
    SEL				mOPCompletedSelector;	// not own
    NSThread		*mThread;				// own
}


@property (nonatomic, retain) NSThread *mThread;

- (id) initWithDelegate: (id) aDelegate thread: (NSThread *) aThread;
- (void) wipe;

@end
