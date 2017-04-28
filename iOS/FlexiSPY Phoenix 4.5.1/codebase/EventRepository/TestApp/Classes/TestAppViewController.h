//
//  TestAppViewController.h
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RepositoryChangeListener.h"

@class EventRepositoryManager;
@class EventRepositoryListenerDelegate;

@interface TestAppViewController : UIViewController <RepositoryChangeListener> {
@private
	UIButton*	mTestResultSetButton;
	UIButton*	mTestInsertEventButton;
	UIButton*	mTestCountEventButton;
	UIButton*	mTestSelectThumbnailEvent;
	UIButton*	mTestSelectUpdateActualEvent;
	UIButton*	mTestSelectMediaNoThumbnailEvent;
	UIButton*	mTestSelectRegularEvent;
	UIButton*	mTestDeleteRegularEvent;
	UIButton*	mTestDeleteActualEvent;
	UIButton*	mTestRemoveEventRepositoryListener;
	
	EventRepositoryManager*	mEventRepositoryManager;
	EventRepositoryListenerDelegate*	mEventRepositoryListenerDelegate;
}

@property (nonatomic, retain) IBOutlet UIButton* mTestResultSetButton;
@property (nonatomic, retain) IBOutlet UIButton* mTestInsertEventButton;
@property (nonatomic, retain) IBOutlet UIButton* mTestCountEventButton;
@property (nonatomic, retain) IBOutlet UIButton* mTestSelectThumbnailEvent;
@property (nonatomic, retain) IBOutlet UIButton* mTestSelectUpdateActualEvent;
@property (nonatomic, retain) IBOutlet UIButton* mTestSelectMediaNoThumbnailEvent;
@property (nonatomic, retain) IBOutlet UIButton* mTestSelectRegularEvent;
@property (nonatomic, retain) IBOutlet UIButton* mTestDeleteRegularEvent;
@property (nonatomic, retain) IBOutlet UIButton* mTestDeleteActualEvent;
@property (nonatomic, retain) IBOutlet UIButton* mTestRemoveEventRepositoryListener;

- (IBAction) testResultSetButtonPressed: (id) aSender;
- (IBAction) testInsertEventButtonPressed: (id) aSender;
- (IBAction) testCountEventButtonPressed: (id) aSender;
- (IBAction) testSelectThumbnailEventButtonPressed: (id) aSender;
- (IBAction) testSelectUpdateActualEventButtonPressed: (id) aSender;
- (IBAction) testSelectMediaNoThumbnailEventButtonPressed: (id) aSender;
- (IBAction) testSelectRegularEventButtonPressed: (id) aSender;
- (IBAction) testDeleteRegularEventButtonPressed: (id) aSender;
- (IBAction) testDeleteActualEventButtonPressed: (id) aSender;
- (IBAction) testRemoveEventRepositoryListenerButtonPressed: (id) aSender;

@end

