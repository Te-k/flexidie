//
//  RemoteCmdSignatureUtils.m
//  RCM
//
//  Created by Makara Khloth on 10/19/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RemoteCmdSignatureUtils.h"
#import "RemoteCmdData.h"
#import "RemoteCmdExceptionCode.h"

@implementation RemoteCmdSignatureUtils

+ (BOOL) verifyRemoteCmdDataSignature: (RemoteCmdData *) aRemoteCmdData
				numberOfCompulsoryTag: (NSInteger) aNumberOfTag {
	BOOL tick = NO;
	if ([[aRemoteCmdData mArguments] count] == aNumberOfTag) {
		tick = YES;
	} else {
		if ([aRemoteCmdData mIsSMSReplyRequired]) {
			NSInteger tags = aNumberOfTag + 1;
			if ([[aRemoteCmdData mArguments] count] == tags) {
				tick = YES;
			}
		}
	}
	return (tick);
}

+ (void) throwInvalidCmdWithName: (NSString *) aName
						  reason: (NSString *) aReason {
	DLog (@"RemoteCmdSignatureUtils--->throwInvalidCmdWithName:reason:")
	FxException* exception = [FxException exceptionWithName:aName andReason:aReason];
	[exception setErrorCode:kCmdExceptionErrorInvalidCmdFormat];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}

@end
