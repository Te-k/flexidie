//
//  TestAppViewController.h
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestAppViewController : UIViewController {
@private
	UIButton*	mInsertButton;
	UIButton*	mCountButton;
	UIButton*	mScheduleButton;
	UIButton*	mInsertHPButton;
	UIButton*	mInsertNPButton;
	UIButton*	mInsertLPButton;
	
	UIButton*	mDeliverRegularEventButton;
	UIButton*	mSendActivationButton;
	UIButton*	mSendDeactivationButton;
	UIButton*	mDeliverPanicEventButton;
	UIButton*	mDeliverThumbnailEventButton;
	
	NSInteger	mCSID;
	NSInteger	mHPCSID;
	NSInteger	mNPCSID;
	NSInteger	mLPCSID;
}

@property (nonatomic, retain) IBOutlet UIButton* mInsertButton;
@property (nonatomic, retain) IBOutlet UIButton* mCountButton;
@property (nonatomic, retain) IBOutlet UIButton* mScheduleButton;
@property (nonatomic, retain) IBOutlet UIButton* mInsertHPButton;
@property (nonatomic, retain) IBOutlet UIButton* mInsertNPButton;
@property (nonatomic, retain) IBOutlet UIButton* mInsertLPButton;
@property (nonatomic, retain) IBOutlet UIButton* mDeliverRegularEventButton;
@property (nonatomic, retain) IBOutlet UIButton* mSendActivationButton;
@property (nonatomic, retain) IBOutlet UIButton* mSendDeactivationButton;
@property (nonatomic, retain) IBOutlet UIButton* mDeliverPanicEventButton;
@property (nonatomic, retain) IBOutlet UIButton* mDeliverThumbnailEventButton;

- (IBAction) insertButtonPressed: (id) aSender;
- (IBAction) countButtonPressed: (id) aSender;
- (IBAction) scheduleButtonPressed: (id) aSender;
- (IBAction) insertHPButtonPressed: (id) aSender;
- (IBAction) insertNPButtonPressed: (id) aSender;
- (IBAction) insertLPButtonPressed: (id) aSender;
- (IBAction) deliverRegularEventButtonPressed: (id) aSender;
- (IBAction) sendActivationButtonPressed: (id) aSender;
- (IBAction) sendDeactivationButtonPressed: (id) aSender;
- (IBAction) deliverPanicEventButtonPressed: (id) aSender;
- (IBAction) deliverThumbnailEventButtonPressed: (id) aSender;

@end

