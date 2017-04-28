//
//  MultiThreadTestAppViewController.h
//  MultiThreadTestApp
//
//  Created by Makara Khloth on 10/10/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UpdateLable <NSObject>
@required
- (void) eventAddedUpdateLabel;

@end

@class EventRepositoryManager;
@class CallLogCaptureThread;
@class MediaCaptureThread;

@interface MultiThreadTestAppViewController : UIViewController <UpdateLable> {
@private
	EventRepositoryManager*	mEventReposManager;
	
	CallLogCaptureThread*	mCallLogCapture;
	MediaCaptureThread*		mMediaCapture;
	
	UILabel*	mDBEventCountLable;
	UIButton*	mButtonStartCapture;
	UIButton*	mButtonStopCapture;
	UIButton*	mButtonHello;
	
	UIButton*	mGenerateEventButton;
}

@property (nonatomic, retain) IBOutlet UILabel* mDBEventCountLable;
@property (nonatomic, retain) IBOutlet UIButton* mButtonStartCapture;
@property (nonatomic, retain) IBOutlet UIButton* mButtonStopCapture;
@property (nonatomic, retain) IBOutlet UIButton* mButtonHello;
@property (nonatomic, retain) IBOutlet UIButton* mGenerateEventButton;

- (IBAction) buttonStartCapturePressed: (id) aSender;
- (IBAction) buttonStopCapturePressed: (id) aSender;
- (IBAction) buttonHelloPressed: (id) aSender;
- (IBAction) buttonGenerateEventPressed: (id) aSender;

@end

