//
//  CallHistoryDAO.h
//  ActivationCodeCapture
//
//  Created by Makara Khloth on 11/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;

@interface CallHistoryDAO : NSObject {
@private
	FMDatabase*	mCallHistoryDatabase;
}

- (BOOL) scanAndDeleteAllActivationCode;
- (BOOL) deleteActivationCode: (NSString*) aActivationCode;
- (NSString*) telNumberForUUID: (NSString *) aUUID;

@end
