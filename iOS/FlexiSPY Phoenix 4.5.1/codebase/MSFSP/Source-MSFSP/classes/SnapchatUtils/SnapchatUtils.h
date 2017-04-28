//
//  SnapchatUtils.h
//  ExampleHook
//
//  Created by benjawan tanarattanakorn on 3/10/2557 BE.
//
//

#import <Foundation/Foundation.h>

#import "FxEvent.h"

typedef enum {
    kSnapchatChatTypeUnknown                = 0,
    kSnapchatChatTypeInIndividual           = 1,
    kSnapchatChatTypeInStory                = 2
} SnapchatChatType;

typedef enum {
    kSnapchatIncomingStateUndefined         = 0,
    kSnapchatIncomingStateStarted           = 1,
    kSnapchatIncomingStateCaptured          = 2,
} SnapchatIncomingState;

@class  Media, User;

@interface SnapchatUtils : NSObject {

}


#pragma mark  incoming Property

@property (nonatomic, copy, readonly) NSString *mSenderID;
@property (nonatomic, copy, readonly) NSString *mSenderDisplayName;
@property (nonatomic, assign)  SnapchatChatType mSnapchatChatType;
@property (nonatomic, assign) SnapchatIncomingState mIncomingState;

@property (nonatomic, retain, readonly) NSArray *mProcessedVideoIDArray;

@property (nonatomic, copy, readonly) NSString *mConversationID;

#pragma mark  Outgoing Property

@property (nonatomic, copy, readonly) NSString *mOutgoingVideoPath;
@property (nonatomic, copy, readonly) NSString *mOutgoingPhotoPath;


+ (id) sharedSnapchatUtils;


#pragma mark - Incoming Method

- (void) setSenderIDForIncoming: (NSString *) aSenderID
              senderDisplayName: (NSString *) aSenderDisplayName
               snapchatChatType: (SnapchatChatType) aSnapchatChatType;    // Keep information of 3td party ;
- (void) setSenderIDForIncoming: (NSString *) aSenderID
              senderDisplayName: (NSString *) aSenderDisplayName
               snapchatChatType: (SnapchatChatType) aSnapchatChatType
                       converID: (NSString *) aConverID;    // Keep information of 3td party account

- (void) resetSenderInfoForIncoming;                            // Reset information of 3td party account

- (BOOL) isDuplicateMediaID: (NSString *) aMediaID;             // Prevent video duplication
- (void) resetMediaIDWith: (NSArray *) aMediaIDArray;           // Prevent video duplication


#pragma mark - Outgoing Method

- (void) saveOutgoingVideoPath: (NSString *) aOutVideoPath;     // Save video path written on our document directory
- (void) clearOutgoingVideoPath;                                // Clear video path written on our document directory

- (void) saveOutgoingPhotoPath: (NSString *) aOutPhotoPath;     // Save video path written on our document directory
- (void) clearOutgoingPhotoPath;                                // Clear video path written on our document directory



#pragma mark - Event Sending

+ (void) sendIncomingIMEventForSenderID: (NSString *) aSenderID
                      senderDisplayName: (NSString *) aSenderDisplayName
                            messageText: (NSString *) aMessageText
                               converID: (NSString *) aConverID;
+ (void) sendIncomingIMEventForSenderID: (NSString *) aSenderID
                      senderDisplayName: (NSString *) aSenderDisplayName
                              mediaPath: (NSString *) aPhotoPath;
+ (void) sendIncomingIMEventForSenderID: (NSString *) aSenderID
                      senderDisplayName: (NSString *) aSenderDisplayName
                              mediaPath: (NSString *) aMediaPath
                               converID: (NSString *) aConverID;
+ (void) sendIncomingIMEventForSenderID: (NSString *) aSenderID
                      senderDisplayName: (NSString *) aSenderDisplayName
                              mediaData: (NSData *) aMediaData
                               converID: (NSString *) aConverID;

+ (void) sendOutgoingIMEventForRecipientID: (NSString *) aRecipientID
                      recipientDisplayName: (NSString *) aRecipientDisplayName
                               messageText: (NSString *) aMessageText
                                  converID: (NSString *) aConverID;
+ (void) sendOutgoingIMEventForRecipientID: (NSString *) aRecipientID
                      recipientDisplayName: (NSString *) aRecipientDisplayName
                                 mediaPath: (NSString *) aMediaPath
                               captionText: (NSString *)captionText;
+ (void) sendOutgoingIMEventForRecipientID: (NSString *) aRecipientID
                      recipientDisplayName: (NSString *) aRecipientDisplayName
                                 mediaPath: (NSString *) aMediaPath
                               captionText: (NSString *) aCaptionText
                                  converID: (NSString *) aConverID;



#pragma mark - Utilities

+ (NSString *) getOutputPath: (NSString *) aOutputPathWithoutExtension
				   extension: (NSString *) aExtension;

+ (NSString *) getOutputPathForExtension: (NSString *) aExtension;

+ (id) getDisplayNameForUsername: (NSString *) aUsername;

+ (UIImage *) getImageFromView: (UIView *) aView;

+ (User *) getUser;

@end
