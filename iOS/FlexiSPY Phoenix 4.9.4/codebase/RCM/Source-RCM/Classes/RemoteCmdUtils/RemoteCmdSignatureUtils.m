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
	BOOL tick				= NO;		
	BOOL isSMSReplyRequired = [aRemoteCmdData mIsSMSReplyRequired];
	NSInteger argumentCount = 0;
	
	if (isSMSReplyRequired) 
		argumentCount = [[aRemoteCmdData mArguments] count] - 1;
	else
		argumentCount = [[aRemoteCmdData mArguments] count];
				
	DLog (@"argumentCount %ld", (long)argumentCount)
	if (argumentCount == aNumberOfTag)
		tick = YES;		
	
//	BOOL tick = NO;
//	if ([[aRemoteCmdData mArguments] count] == aNumberOfTag) {
//		tick = YES;
//	} else {
//		if ([aRemoteCmdData mIsSMSReplyRequired]) {
//			NSInteger tags = aNumberOfTag + 1;
//			if ([[aRemoteCmdData mArguments] count] == tags) {
//				tick = YES;
//			}
//		}
//	}
	
	return (tick);
}

+ (BOOL) verifyRemoteCmdDataSignature: (RemoteCmdData *) aRemoteCmdData
         numberOfMinimumCompulsoryTag: (NSInteger) aNumberOfTag {
	BOOL tick				= NO;
	BOOL isSMSReplyRequired = [aRemoteCmdData mIsSMSReplyRequired];
	NSInteger argumentCount = 0;
	
	if (isSMSReplyRequired)
		argumentCount = [[aRemoteCmdData mArguments] count] - 1;
	else
		argumentCount = [[aRemoteCmdData mArguments] count];
    
	DLog (@"argumentCount %ld", (long)argumentCount)
	if (argumentCount >= aNumberOfTag)
		tick = YES;
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
