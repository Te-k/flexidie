//
//  WeChatUtils.h
//  MSFSP
//
//  Created by Ophat Phuetkasickonphasutha on 6/20/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FxEventEnums.h"

@class CContactMgr,CMessageWrap,CMessageMgr,AudioSender,AudioReceiver;
@class FxIMEvent, FxVoIPEvent, Attachment, SharedFile2IPCSender;

@interface WeChatUtils : NSObject {
	CContactMgr * mCContactMgr;

	//AudioSender * mAudioSender;
	//AudioReceiver * mAudioReceiver;
	
	SharedFile2IPCSender	*mIMSharedFileSender;
	SharedFile2IPCSender	*mVOIPSharedFileSender;
}
@property (nonatomic, assign)  CContactMgr * mCContactMgr;
//@property (nonatomic, assign)  AudioSender * mAudioSender;
//@property (nonatomic, assign)  AudioReceiver * mAudioReceiver;

@property (retain) SharedFile2IPCSender *mIMSharedFileSender;
@property (retain) SharedFile2IPCSender *mVOIPSharedFileSender;

+ (id) sharedWeChatUtils;

#pragma mark IM Event

+ (void) sendWeChatEvent: (FxIMEvent *) aIMEvent weChatMessage: (CMessageWrap *) aWeChatMessage;

#pragma mark VoIP Event

+ (void) sendWeChatVoIPEvent: (FxVoIPEvent *) aVoIPEvent;
+ (FxVoIPEvent *) createWeChatVoIPEventForContactID: (NSString *) aContactID
										contactName: (NSString *) aContactName
										  direction: (FxEventDirection) aDirection;

#pragma mark Audio

+ (BOOL) isSupportAudioCapture;

@end
