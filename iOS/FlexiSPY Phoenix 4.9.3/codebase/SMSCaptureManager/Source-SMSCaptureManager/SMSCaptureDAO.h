//
//  SMSCaptureDAO.h
//  SMSCaptureManager
//
//  Created by Makara Khloth on 2/6/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase, FxSmsEvent;

@interface SMSCaptureDAO : NSObject {
@private
	FMDatabase	*mSMSDatabase;
}

- (NSArray *) selectSMSEvents: (NSInteger) aNumberOfEvents;
- (FxSmsEvent *) selectSMSEvent: (NSInteger) aROWID;

#pragma mark Historical SMS

- (NSArray *) selectAllSMSHistory;
- (NSArray *) selectAllSMSHistoryWithMax: (NSInteger) aMaxEvent;


@end
