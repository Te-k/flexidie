//
//  SkypeOperation.m
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 6/16/2557 BE.
//
//

#import <objc/runtime.h>
#import <CoreLocation/CoreLocation.h>

#import "FxEvent.h"
#import "FxRecipient.h"
#import "FxIMEvent.h"
#import "FxIMGeoTag.h"
#import "FxAttachment.h"

#import "DateTimeFormat.h"
#import "DaemonPrivateHome.h"

// Skype Classes
//#import "SKPALEMappedObject.h"
#import "SKPConversation.h"
#import "SKPContact.h"
#import "SKPContact+6-5-152.h"
#import "SKPContact+6-14-143.h"
#import "SKPParticipant.h"
#import "SKPAccount.h"

#import "SKPMessage.h"
#import "SKPTextChatMessage.h"
#import "SKPMediaDocument.h"
#import "SKPMediaDocument+6-4-152.h"
#import "SKPMediaDocument+6-17-1.h"
#import "SKPMediaDocumentMessage.h"
#import "SKPVideoMessageMessage.h"
#import "SKPVideoMessage.h"
#import "SKPCallEventCompoundMessage.h"
#import "SKPCallEventMessage.h"
#import "SKPTransfer.h"
#import "SKPFileTransferMessage.h"
#import "SKPLocationMessage.h"
#import "SKPSMS.h"
#import "SKPSMSMessage.h"
#import "SKPGenericMediaFallbackMessage.h"
#import "SKPFileSharingMessage.h"
#import "SDImageCache.h"
#import "SKPShareContactsMessage.h"
#import "SKPMojiMessage.h"
#import "SKPMoji.h"
#import "SKPAsyncVideoMediaDocumentMessage.h"
#import "SKPAsyncVideoMediaDocument.h"
#import "SKPAsyncVideoMediaDocument+6-12-133.h"
#import "SKPAsyncVideoMediaDocument+6-17-1.h"

#import "SKPAsyncMediaProfileVideo.h"

// Skype 6.22
#import "SKPFileSharingDocument.h"

// Our Utils Classes
#import "SkypeUtils.h"
#import "SkypeAccountUtils.h"
#import "SkypeOperation.h"
#import "SkypePendingMessageStore.h"

#import "SKPConversationLists.h"


@interface SkypeOperation (private)
//- (void) captureMessage: (id) aMessage;   // obsolete
//- (void) processPendingMessage;           // obsolete
//- (void) processRealTimeMessage;          // obsolete
//- (void) captureVOIPForSKPCallEventMessage: (SKPCallEventMessage *) aCallMessage;     // obsolete
- (void) captureMessageV2: (id) aMessage;
- (void) processRealTimeMessageV2;
- (void) captureVOIPForSKPCallEventMessageV2: (SKPCallEventMessage *) aCallMessage;
- (FxEventDirection) getVoIPDirection: (SKPCallEventMessage *) aCallMessage;

#pragma mark Utilities
- (NSArray *) sortArray: (NSArray *) aInputArray accordingTo: (NSString *) aStringKey;
- (SKPMessage *) findMessageWithID: (unsigned) aMessageID SKPMessageArray: (NSArray *) aSKPMessageArray;
- (SKPCallEventMessage *) findEarlierCallMessageWithID: (unsigned) aMessageID SKPMessageArray: (NSArray *) aSKPMessageArray;
//- (SKPMessage *) getSKPMessageWithObjectID: (unsigned) aObjectID inSKPMessageArray: (NSArray *) aSKPMessageArray;
- (BOOL) isSupportedMessageClass : (SKPMessage *) aMessage;

#pragma mark Participant

- (FxRecipient *) createFxRecipientFromSKContact: (SKPContact *) aContact;
- (FxRecipient *) getFxRecipientOfAccount;
- (BOOL) isTargetAccouts: (SKPContact *) aInputContact;
- (NSMutableArray *) createFxParticipant: (NSArray *) aSKPParticipantArray;
- (NSMutableArray *) removeSKPContactSkypename: (NSString *) aUnwantedContactSkypename
                                    inputArray: (NSArray *) aInputArray;

#pragma mark Attachment
- (NSString *) getOriginalImageFromThumbnailPath: (NSString *) aThumbnailPath;
- (NSMutableArray *) createFxAttachment: (SKPMessage *) aSKPMessage isResetMessage: (BOOL *) aIsResetMessage;
- (NSData *) getThumbnailDataForURL: (NSURL *) aURL;
- (NSData *) getIncomingVideoThumbnailDataFromSKPVideoMessage: (SKPVideoMessage *) aVideoMessage;
- (NSData *) getIncomingPhotoThumbnailDataFromSKPMediaDocumentMessage: (SKPMediaDocumentMessage *) aMediaDocumentMessage;

#pragma mark Printing
- (void) printSKPMessageArray: (NSArray *) aSKPMessageArray;
- (void) printSKPTextChatMessage: (SKPTextChatMessage *) aTextChatMessage;
- (void) printSKPMediaDocumentMessage: (SKPMediaDocumentMessage *) aMediaDocumentMessage;
- (void) printSKPVideoMessageMessage: (SKPVideoMessageMessage *) aVideoMessageMessage;
- (void) printSKPMessage: (SKPMessage *) aMsgObj;
- (void) printSKPCallEventCompoundMessage: (SKPCallEventCompoundMessage *) aCallMessage;
- (void) printSKPCallEventMessage: (SKPCallEventMessage *) aCallMessage;
- (void) printSKPConversation: (SKPConversation *) aConversation;
- (void) printWaitingChatView;
@end



@implementation SkypeOperation


#pragma mark - Initialization


- (id) initWithMessageID: (unsigned) aMessageID
            conversation: (SKPConversation *) aConversation
           operationType: (SkypeOperationType) aSkpOperationType {
    self = [super init];
    
    if (self) {
        _mConversation                          = [aConversation retain];
        _mMessageID                             = aMessageID;                                // id to be aimed to process
        _mSkypeOperationType                    = aSkpOperationType;
    }
    return self;
}


#pragma mark - MAIN


- (void) main {
    @try {
        if (_mSkypeOperationType == kSkypeOperationTypeRealTimeMessage) {
            [self processRealTimeMessageV2];
        }
//        else if (_mSkypeOperationType == kSkypeOperationTypePendingMessage) {
//            [self processPendingMessage];
//        }
    }
    @catch (NSException *exception) {
        DLog(@"Skype operation exception: %@", exception);
    }
    @finally {
        ;
    }
}

// Called by processRealTimeMessageV2
- (void) captureMessageV2: (id) aMessage {
    DLog(@"capture message of class %@", [aMessage class])
    
    //Capture date and time first to prevent incorrect order
    NSString *dateTimeString = [DateTimeFormat phoenixDateTime];
    
    Class $SKPMediaDocumentMessage              = objc_getClass("SKPMediaDocumentMessage");
    Class $SKPVideoMessageMessage               = objc_getClass("SKPVideoMessageMessage");
    Class $SKPCallEventCompoundMessage          = objc_getClass("SKPCallEventCompoundMessage");
    Class $SKPMessage                           = objc_getClass("SKPMessage");
    
    /*************************************************************
     Capture OUTGOING Text, Photo, Video
     Capture INCOMING Text
     *************************************************************/
    if ([aMessage isKindOfClass:[$SKPMessage class]]) {
        //[self printSKPMessage:aMessage];
        
        FxEventDirection direction          = kEventDirectionUnknown;
        NSString *imServiceId               = @"skp";
        NSMutableArray *attachments         = [NSMutableArray array];
        NSString *message                   = [aMessage body];                          // message
        
        // -- STEP 1    Find out sender information
        /*
            Note that [aMessage author] can be nil for historical message
            However authorDisplayName and authorSkypeName still be valid
         */
        SKPContact *senderContact           = [aMessage author];
        NSString *userId                    = [aMessage authorSkypeName];               // sender id
        NSString *userDisplayName           = [aMessage authorDisplayName];             // sender display name        
        NSString *senderStatusMessage       = nil;                                      // sender status message
        NSData *senderPictureData           = nil;                                      // sender picture profile
        
        
        // -- Fix wrong direction because of the object is null
        // -- solution for get [aMessage author] as (null)
        
        if (!senderContact) {
            // We need to keep these information
            // - 1 get direction
            // - 2 get sender status message
            // - 3 get sender picture profile
            
            SKPAccount *account             = [[SkypeAccountUtils sharedSkypeAccountUtils] mAccount];
            NSString *accountSkypeName      = [account skypeName];
            DLog (@"account skypeName = %@", [account skypeName]);
            
            // If the one who wrote this message is the target device, so the direction should be OUTGOING
            if ([accountSkypeName isEqualToString:[aMessage authorSkypeName]]) {
                direction                   = kEventDirectionOut;                           // 1
                
                senderContact               = [account contact];
                
                UIImage *avartarImage       = [senderContact avatarImage];
                senderPictureData           = UIImagePNGRepresentation(avartarImage);       // 2
                
                senderStatusMessage         = [senderContact moodMessage];                  // 3
            } else {
                direction                   = kEventDirectionIn;                            // 1
                // In this case we cannot capture sender picture profile and status message. However, we not yet found this case happens
            }
            DLog(@"##### DIRECTION %d", direction)
        }
        else {
            if ([[aMessage author] respondsToSelector:@selector(isCurrentAccoutContact)]) {
                direction                   = ([[aMessage author] isCurrentAccoutContact]) ? kEventDirectionOut : kEventDirectionIn ;
            }
            else {
                direction                   = ([[aMessage author] isCurrentAccountContact]) ? kEventDirectionOut : kEventDirectionIn ;
            }
            
            UIImage *avartarImage       = [senderContact avatarImage];
            senderPictureData           = UIImagePNGRepresentation(avartarImage);
            
            senderStatusMessage         = [senderContact moodMessage];
        }
        
        // -- STEP 2    Find out participant
        NSArray *origParticipants           = [_mConversation otherConsumers];          // Not include sender for outgoing. For incoming, include the sender (need to filter it out)
        NSMutableArray *SKPParticipantArray = [origParticipants mutableCopy];
        NSMutableArray *finalParticipants   = nil;
        
        if (direction == kEventDirectionOut) {
            finalParticipants                       = [self createFxParticipant:SKPParticipantArray];   // Map to FxRecipient array
        } else {
            // -- filter out message sender first
            NSArray *participantsNotIncludeAuthor   = [self removeSKPContactSkypename:userId
                                                                           inputArray:SKPParticipantArray];
            finalParticipants                       = [self createFxParticipant:participantsNotIncludeAuthor];   // Map to FxRecipient array
            // -- Insert the target account to be the first index of array
            [finalParticipants insertObject:[self getFxRecipientOfAccount]
                                    atIndex:0];
        }
        [SKPParticipantArray release];
        
        // -- STEP 3
        // -- 3.1 Find out attachment
        BOOL isResetMessae                  = NO;
        attachments                         = [self createFxAttachment:aMessage isResetMessage:&isResetMessae];
        if (isResetMessae) {
            message                         = nil;
        }
        
        // -- 3.2 Shared location
        FxIMGeoTag *sharedLocation = nil;
        Class $SKPLocationMessage = objc_getClass("SKPLocationMessage");
        if ([aMessage isKindOfClass:$SKPLocationMessage]) {
            SKPLocationMessage *locMessage = (SKPLocationMessage *)aMessage;
            CLLocation *cllocation = [locMessage location];
            sharedLocation = [[[FxIMGeoTag alloc] init] autorelease];
            [sharedLocation setMLongitude:(float)[cllocation coordinate].longitude];
            [sharedLocation setMLatitude:(float)[cllocation coordinate].latitude];
            [sharedLocation setMHorAccuracy:(float)[cllocation horizontalAccuracy]];
            
            NSString *locationName = nil;
            if ([locMessage address] && [locMessage pointOfInterest]) {
                locationName = [NSString stringWithFormat:@"%@ %@", [locMessage pointOfInterest], [locMessage address]];
            } else {
                if ([locMessage address]) locationName = [locMessage address];
                if ([locMessage pointOfInterest]) locationName = [locMessage pointOfInterest];
            }
            
            [sharedLocation setMPlaceName:locationName];
            
            DLog(@"address, %@, pointOfInterest, %@", [locMessage address], [locMessage pointOfInterest]);
        }
        
        // -- 3.3 Shared contact
        NSMutableArray *arrayOfSharedContacts = [NSMutableArray array];
        Class $SKPShareContactsMessage = objc_getClass("SKPShareContactsMessage");
        if ([aMessage isKindOfClass:$SKPShareContactsMessage]) {
            DLog(@"contacts, %@", [aMessage contacts]);
            NSOperationQueue *operationQueue = [[[NSOperationQueue alloc]init] autorelease];
            [operationQueue addOperation:[aMessage fetchContactsOperation]];
            [NSThread sleepForTimeInterval:2.0];
            DLog(@"Fetched contacts, %@", [aMessage contacts]);
            for (SKPContact *contact in [aMessage contacts]) {
                DLog(@"skypeName, %@", [contact skypeName]);
                DLog(@"unescapedDisplayName, %@", [contact unescapedDisplayName]);
                DLog(@"originalUnescapedDisplayName, %@", [contact originalUnescapedDisplayName]);
                NSString *sharedContact = [NSString stringWithFormat:@"Name: %@", [contact originalUnescapedDisplayName]];
                [arrayOfSharedContacts addObject:sharedContact];
            }
        }
        
        // -- STEP 4    Construct FXIMEvent
        
        /*****************************
         Construct FxIMEvent
         *****************************/
        DLog(@"============= SKYPE =============")
        DLog(@"userId \t\t%@", userId)
        DLog(@"userDisplayName \t%@", userDisplayName)
        DLog(@"senderStatusMessage \t%@", senderStatusMessage)                // Fail to capture if [aMessage author] is nil
        DLog(@"senderPictureData \t%lu", (unsigned long)[senderPictureData length])           // Fail to capture if [aMessage author] is nil
        DLog(@"============= SKYPE =============")
        FxIMEvent *imEvent = [[FxIMEvent alloc] init];
        [imEvent setMIMServiceID:imServiceId];
        [imEvent setMServiceID:kIMServiceSkype];
        [imEvent setMDirection:direction];
        [imEvent setDateTime:dateTimeString];
        
        [imEvent setMUserID:userId];
        [imEvent setMUserDisplayName:userDisplayName];
        [imEvent setMUserStatusMessage:senderStatusMessage];			// sender status message
        [imEvent setMUserPicture:senderPictureData];					// sender image profile
        [imEvent setMUserLocation:nil];
        
        // Add file name for the attachment that is not supported by Skype version 5.x.x
        /*
         if ([aMessage isKindOfClass:[$SKPFileTransferMessage class]]) {
         SKPFileTransferMessage *transferMessage = (SKPFileTransferMessage *)aMessage;
         for (SKPTransfer *eachTransfer in [transferMessage transfers]) {
         message = [NSString stringWithFormat:@"This version of Skype does not support receiving files [filename: %@]", [eachTransfer filename]];
         
         DLog(@"transfer filename %@", [eachTransfer filename])
         DLog(@"transfer path %@", [eachTransfer path])
         DLog(@"transfer type %d", [eachTransfer type])
         DLog(@"transfer status %d", [eachTransfer status])
         
         }
         */
        // If cannot get an attachment, we will include the hard-code text to the event, and no attachment come with the event
    
        // Add mesage to mention that we cannot capture an attachment
        if (![attachments count]) {
            if ([aMessage isKindOfClass:[$SKPMediaDocumentMessage class]])
                message = @"Cannot capture photo attachment";
            else if ([aMessage isKindOfClass:[$SKPVideoMessageMessage class]] ||
                     [aMessage isKindOfClass:objc_getClass("SKPAsyncVideoMediaDocumentMessage")])
                message = @"Cannot capture video attachment";
        }
        [imEvent setMMessage:message];
        
        [imEvent setMParticipants:finalParticipants];
        
        [imEvent setMAttachments:attachments];

        if ([message length] > 0)
            [imEvent setMRepresentationOfMessage:kIMMessageText];		// text message
        else
            [imEvent setMRepresentationOfMessage:kIMMessageNone];		// attachment message
        // -- conversation
        [imEvent setMConversationID:[_mConversation conversationIdentity]];
        [imEvent setMConversationName:[_mConversation displayName]];
        [imEvent setMConversationPicture:nil];
        
        [imEvent setMShareLocation:sharedLocation];
        if (sharedLocation) {
            [imEvent setMRepresentationOfMessage:kIMMessageShareLocation];
        }
        
        if ([arrayOfSharedContacts count]) {
            for (NSString *sharedContact in arrayOfSharedContacts) {
                FxIMEvent *cloneIMEvent = [imEvent copyWithZone:nil];
                [cloneIMEvent setMMessage:sharedContact];
                [cloneIMEvent setMRepresentationOfMessage:kIMMessageContact];
                [cloneIMEvent setMAttachments:nil];
                
                [SkypeUtils sendSkypeEvent:cloneIMEvent];
                
                [cloneIMEvent release];
                
                [NSThread sleepForTimeInterval:1.5];
            }
        } else {
            [SkypeUtils sendSkypeEvent:imEvent];                            // !!! SENDING
        }
        
        [imEvent release];
    }
    else if ([aMessage isKindOfClass:[$SKPCallEventCompoundMessage class]]) {
        DLog(@"VOIP call start, but we ignore this event")
        //[self printSKPCallEventCompoundMessage:aMessage];
    }
}

- (void) processRealTimeMessageV2 {
    DLog(@"****** OPERATION conver %@ (msg id %d) queue: %@ ******", [_mConversation conversationIdentity], _mMessageID, [[NSOperationQueue currentQueue] name])
    
    Class $SKPCallEventMessage                  = objc_getClass("SKPCallEventMessage");
    
    // !!! Wait for property messageItems NSArray to be updated with the newest message
    [NSThread sleepForTimeInterval:2];
    
    
    // -- Retrieve all the messages of this conversation
    NSArray *messages                           = [_mConversation messageItems];

    DLog(@"messageItems %@",    messages)
    DLog(@"conversationIdentity %@", [_mConversation conversationIdentity])
    //DLog(@"conver object id %d", (int) [_mConversation objectId])
    
    //[self printSKPConversation:_mConversation];
    //[self printSKPMessageArray:messages];

    BOOL isProcessed = NO;
    
    NSString *operationName = [[NSOperationQueue currentQueue] name];

    /*
        0001   --> not print
        0010   --> not print
        0100   --> not print
        1000   --> print
     */
    // For printing purpose only
    NSUInteger printBit = 1;
    NSUInteger maxPrintBit = printBit << 3;
    
    while (!isProcessed) {
        
        // -----  For printing purpose only (BEGIN)
        printBit = printBit << 1;
        if (maxPrintBit & maxPrintBit) {
            DLog(@"oooooooooooooo STEP 1: WAIT until Chat View opens oooooooooooooooo msg id %d [%lu message left in queue %@]",
                 _mMessageID, (unsigned long)[[NSOperationQueue currentQueue] operationCount], operationName)
            printBit = 1;
        }
        // -----  For printing purpose only (END)
        
        messages                                = [_mConversation messageItems];

        if ([_mConversation respondsToSelector:@selector(numberOfMessageItemsToLoad)]) {
            DLog(@"messageItems count %lu numberOfMessageItemsToLoad %d",  (unsigned long)[messages count], [_mConversation numberOfMessageItemsToLoad])
        }

        /**************************************
            Ensure it is in Chat View
         **************************************/
        if (messages && [messages lastObject]) {
            
            DLog(@"xxxxxxxxxxxxxxx STEP 2: CHAT VIEW OPEN xxxxxxxxxxxxxxx msg id %d [%lu message left in queue %@]",
                 _mMessageID, (unsigned long)[[NSOperationQueue currentQueue] operationCount], operationName)
            

            // -- Sort message in the message array according to the skyLibObjectID (the id that we get as the argument "message")
            NSArray *sortedArray                    = [self sortArray:[_mConversation messageItems] accordingTo:@"objectId"];
            DLog(@"AFTER SORT\n\n")
            [self printSKPMessageArray:sortedArray];
            
            // -- Find the matched SKMessage
            SKPMessage *matchedMsgObj               = [self findMessageWithID:_mMessageID SKPMessageArray:sortedArray];
            
            /**************************************
                Found the matched SKPMesage
             **************************************/
            if (matchedMsgObj) {
                if ([self isSupportedMessageClass:matchedMsgObj]) {
                    [self captureMessageV2:matchedMsgObj];
                } else if ([matchedMsgObj isKindOfClass:$SKPCallEventMessage]) {
                    
                    /*************************************************************
                                    Capture VOIP
                     *************************************************************/
                    
                    if ([(SKPCallEventMessage *)matchedMsgObj liveStatus] == 1) {
                        DLog(@"!!! capturing VoIP !!!")
                        [self captureVOIPForSKPCallEventMessageV2:(SKPCallEventMessage *)matchedMsgObj];
                    } else {
                        DLog(@"Wait for another call message")
                    }
                } else {
                    DLog(@"Not support this message type %@", matchedMsgObj)
                }
                
                isProcessed = YES;                      /******     DONE OPERATION      *****/
            }
            else {
                DLog(@"The message %d is not in array, load more if not enough", _mMessageID)
                
                unsigned  greatestID        = [[sortedArray firstObject] objectId];
                unsigned  lowestID          = [[sortedArray lastObject] objectId];
                
                NSInteger loadMoreCount     = [[_mConversation messageItems] count];
                
                DLog(@"######################################################")
                DLog(@"@@@@@@@@ Lowest ID: %d, [this id %d], Greatest id %d", lowestID, _mMessageID, greatestID)
                DLog(@"######################################################\n\n")
                
                
                if (_mMessageID > lowestID && _mMessageID < greatestID ) {
                    DLog(@"Missing Message %u [REASON: message is missing from message array], 1st id: [%d], last id: [%d]",
                         _mMessageID, lowestID, greatestID)
                    isProcessed = YES;
                    
                    
                    /******     DONE OPERATION      *****/
                }
                
                NSInteger previousItemCount  = [[_mConversation messageItems] count];
                NSInteger attempt       = 0;
                
                while (_mMessageID < lowestID    || _mMessageID > greatestID) {
                    DLog(@"######################################################")
                    DLog(@"LOOP: finding message id [%d] firstID in item array [%d] last id [%d]", _mMessageID, lowestID, greatestID)
                    DLog(@"######################################################\n\n")
                    
                    
                    /******     LOAD MORE MESSAGES      *****/
                    [_mConversation ensureMinimumNumberOfMessageItemsHaveBeenLoaded:(unsigned)(loadMoreCount += 30)];
                    
                    [NSThread sleepForTimeInterval:1.5];
                    
                    // Update sorted array, first id, and last id
                    sortedArray     = [self sortArray:[_mConversation messageItems] accordingTo:@"objectId"];
                    greatestID     = [[sortedArray firstObject] objectId];
                    lowestID        = [[sortedArray lastObject] objectId];
                    
                    DLog(@"AFTER SORT IN LOOP\n\n")
                    [self printSKPMessageArray:sortedArray];
                    
                    
                    DLog(@"previous item count %ld", (long)previousItemCount)
                    DLog(@"We tried to load %ld items [actually can load %ld items]. New 1st item: [%d]",
                         (long)loadMoreCount,
                         (unsigned long)[[_mConversation messageItems] count],
                         lowestID)
                    
                    if (previousItemCount == [[_mConversation messageItems] count]) {
                        // Cannot load more
                        if (attempt < 3) {
                            attempt++;
                            DLog(@"Increase attempt to %ld", (long)attempt)
                        } else {
                            DLog(@"Cannot load more message, so message %u is NOT captured", _mMessageID)
                            isProcessed = YES;
                            break;
                        }
                    } else {
                        // update item count
                        previousItemCount = [[_mConversation messageItems] count];
                    }
                }
            }
        }
        else {
            DLog(@"No message %@ last object %@ mutableMessageItems %@ unconsumedNormalMessages %d",
                 messages,
                 [messages lastObject],
                 [_mConversation mutableMessageItems],
                 [_mConversation unconsumedNormalMessages])
            // Wait the user to open chat view
            [NSThread sleepForTimeInterval:5];
        }
    } // While

}

- (FxEventDirection) getVoIPDirection: (SKPCallEventMessage *) aCallMessage {
    DLog(@"GET DIRECTION")

    FxEventDirection direction = kEventDirectionUnknown;
    
    SKPCallEventMessage *earlierCallMessage = [self findEarlierCallMessageWithID:[aCallMessage objectId] SKPMessageArray:[_mConversation messageItems]];
        
    DLog(@"earlierCallMessage direction %d", [earlierCallMessage incoming])
    DLog(@"earlierCallMessage %@", [earlierCallMessage prettyEventType])

    if ([[aCallMessage prettyEventType] isEqualToString:@"Missed"]) {
        direction = kEventDirectionMissedCall;
        DLog(@"THIS IS MISSCALL VOIP")
    } else if ([[earlierCallMessage prettyEventType] isEqualToString:@"CallStarted"] || [[earlierCallMessage prettyEventType] isEqualToString:@"NoAnswer"]) {
        if ([earlierCallMessage incoming]) {
            direction = kEventDirectionIn;
            DLog(@"THIS IS INCOMING VOIP")
        } else {
            direction = kEventDirectionOut;
            DLog(@"THIS IS OUTGOING VOIP")
        }
    }

    return direction;
}

- (void) captureVOIPForSKPCallEventMessageV2: (SKPCallEventMessage *) aCallMessage {
    
    //[self printSKPMessage:aCallMessage];
    
    // -- Find out participant
    NSArray *origParticipants                   = [_mConversation otherConsumers];  // Not include sender for outgoing. For incoming, not yet test
    NSMutableArray *SKPParticipantArray         = [origParticipants mutableCopy];
    NSMutableArray *finalParticipants           = [self createFxParticipant:SKPParticipantArray];   // Map to FxRecipient array
    [SKPParticipantArray release];
    
    DLog(@"VOIP participant %@", finalParticipants)
    
    FxEventDirection direction                  = [self getVoIPDirection:aCallMessage];

    if (finalParticipants) {
        FxRecipient *recipient                  = (FxRecipient *)[finalParticipants objectAtIndex:0];
        FxVoIPEvent *skypeVoIPEvent             = [SkypeUtils createSkypeVoIPEventForMessagev2:aCallMessage
                                                                                     direction:direction
                                                                                     recipient:recipient];
        [SkypeUtils sendSkypeVoIPEvent:skypeVoIPEvent];
    } else {
        DLog(@"!!!!!!!!!!! Fail to get participant !!!!!!!!!!!!")   // It comes to this case when there is a miss call while the chat view of that caller is not being seen
    }
}


#pragma mark - Utilities


- (NSArray *) sortArray: (NSArray *) aInputArray accordingTo: (NSString *) aStringKey {
    NSSortDescriptor *valueDescriptor           = [[[NSSortDescriptor alloc] initWithKey:aStringKey ascending:NO] autorelease];
    NSArray * descriptors                       = [NSArray arrayWithObject:valueDescriptor];
    NSArray * sortedArray                       = [aInputArray sortedArrayUsingDescriptors:descriptors];
    return sortedArray;
}

- (SKPMessage *) findMessageWithID: (unsigned) aMessageID SKPMessageArray: (NSArray *) aSKPMessageArray {
    SKPMessage *matchedMsgObj                   = nil;
    //DLog(@"&&&&&&&&&&&&&&&&&&&&& FIND %d &&&&&&&&&&&&&&&&&&&&&&&", aMessageID)
    
    for (id aMessage in aSKPMessageArray) {
        //DLog(@"--------- object id %d %@", [aMessage objectId], [aMessage class])
        
        Class $SKPCallEventCompoundMessage           = objc_getClass("SKPCallEventCompoundMessage");
        
        if ([aMessage isKindOfClass:[$SKPCallEventCompoundMessage class]]) {
            SKPCallEventCompoundMessage *compoundMessage = aMessage;
            
//            DLog(@"type %d messages %lu incoming %d duration %d eventType %d", [compoundMessage type], (unsigned long)[[compoundMessage messages] count],
//                 [compoundMessage incoming], [compoundMessage duration], [compoundMessage eventType])
            
            // !!! RECURSIVE
            SKPCallEventMessage *matchedCallMessage = (SKPCallEventMessage *)[self findMessageWithID:aMessageID
                                                                                     SKPMessageArray:[compoundMessage messages]];
            if (matchedCallMessage) {
                DLog(@"!!! found Call event %@ with object id %d", matchedCallMessage, [matchedCallMessage objectId])
                matchedMsgObj = matchedCallMessage;
                [self printSKPMessage:matchedMsgObj];
            
                break;
            }
        }
        
        // Not yet found the matched object
        if (!matchedMsgObj  && [aMessage objectId] == aMessageID) {
            DLog (@"!!!! match %d", [aMessage objectId])
            matchedMsgObj                       = aMessage;
            break;
        }
    }
    return matchedMsgObj;
}

- (SKPCallEventMessage *) findEarlierCallMessageWithID: (unsigned) aMessageID SKPMessageArray: (NSArray *) aSKPMessageArray {
    SKPCallEventMessage *matchedMsgObj                   = nil;
    
    //DLog(@"&&&&&&&&&&&&&&&&&&&&& FIND EARLIER of VOIP %d &&&&&&&&&&&&&&&&&&&&&&&", aMessageID)
    
    for (id aMessage in aSKPMessageArray) {

        Class $SKPCallEventCompoundMessage              = objc_getClass("SKPCallEventCompoundMessage");
        Class $SKPCallEventMessage                      = objc_getClass("SKPCallEventMessage");
        
        SKPCallEventMessage *earlierCallMessage = nil;
        
        // Process only the kinds of call
        
        if ([aMessage isKindOfClass:[$SKPCallEventCompoundMessage class]]) {
            //DLog(@"--------- Call Compound Message - object id %d %@", [aMessage objectId], [aMessage class])
            
            SKPCallEventCompoundMessage *compoundMessage = aMessage;
            //DLog(@"compound incoming %d",    [compoundMessage incoming])
            
            // !!! RECURSIVE
            earlierCallMessage = (SKPCallEventMessage *)[self findEarlierCallMessageWithID:aMessageID
                                                                           SKPMessageArray:[compoundMessage messages]];
            
            if (earlierCallMessage) {
                DLog(@"!!! found Earlier Call event %@ with object id %d incoming %d",
                     earlierCallMessage,
                     [earlierCallMessage objectId],
                     [earlierCallMessage incoming])
                
                matchedMsgObj = earlierCallMessage;
                [self printSKPMessage:matchedMsgObj];
                break;
            }
            
        } else if ([aMessage isKindOfClass:[$SKPCallEventMessage class]]) {
            //DLog(@"--------- Call Event Message - object id %d %@", [aMessage objectId], [aMessage class])
            
            
            // Not yet found the matched object
            if ([aMessage objectId] == aMessageID) {
                DLog (@"!!!! match call %d incoming ? %d", [aMessage objectId], [aMessage incoming])

                
                // --  get the previous object
                NSInteger index = [aSKPMessageArray indexOfObject:aMessage];
                index           -= 1;
                

                if ([aSKPMessageArray count] > index && index >= 0) {
                    matchedMsgObj = [aSKPMessageArray objectAtIndex:index];
                }
                
                break;
            }

        }
    }
    return matchedMsgObj;
}

/*
- (SKPMessage *) getSKPMessageWithObjectID: (unsigned) aObjectID inSKPMessageArray: (NSArray *) aSKPMessageArray {
    SKPMessage *matchedMessage          = nil;
    DLog(@">>> Find message id %d", aObjectID)
    
    for (SKPMessage *aMessage in aSKPMessageArray) {
        DLog(@"aMessage id %d", [aMessage objectId])
        if ([aMessage objectId] ==  aObjectID) {            // -- Match the objectID being processed
            DLog (@"!!!! match %d", [aMessage objectId])
            matchedMessage      = aMessage;
            break;
        }
    }
    return matchedMessage;
}
 */

- (BOOL) isSupportedMessageClass : (SKPMessage *) aMessage {
    BOOL isSupported                    = NO;
    
    Class $SKPTextChatMessage           = objc_getClass("SKPTextChatMessage");
    Class $SKPMediaDocumentMessage      = objc_getClass("SKPMediaDocumentMessage");
    Class $SKPVideoMessageMessage       = objc_getClass("SKPVideoMessageMessage");
    //Class $SKPFileTransferMessage       = objc_getClass("SKPFileTransferMessage");
    //Class $SKPInlineMessage             = objc_getClass("SKPInlineMessage");
    //Class $SKPVoiceMailMessage          = objc_getClass("SKPVoiceMailMessage");
    Class $SKPLocationMessage = objc_getClass("SKPLocationMessage");
    Class $SKPSMSMessage = objc_getClass("SKPSMSMessage");
    Class $SKPShareContactsMessage = objc_getClass("SKPShareContactsMessage");
    Class $SKPMojiMessage = objc_getClass("SKPMojiMessage");
    Class $SKPAsyncVideoMediaDocumentMessage = objc_getClass("SKPAsyncVideoMediaDocumentMessage");
    Class $SKPGenericMediaFallbackMessage = objc_getClass("SKPGenericMediaFallbackMessage");
    Class $SKPFileSharingMessage = objc_getClass("SKPFileSharingMessage");

    if ([aMessage isKindOfClass:[$SKPTextChatMessage class]]           ||       // Text
        [aMessage isKindOfClass:[$SKPMediaDocumentMessage class]]      ||       // Photo
        [aMessage isKindOfClass:[$SKPVideoMessageMessage class]]       ||       // Video
        [aMessage isKindOfClass:[$SKPLocationMessage class]]           ||       // Location (shared)
        [aMessage isKindOfClass:[$SKPSMSMessage class]]                ||       // SMS
        [aMessage isKindOfClass:$SKPShareContactsMessage]              ||       // Shared contact
        [aMessage isKindOfClass:$SKPMojiMessage]                       ||       // Moji
        [aMessage isKindOfClass:$SKPAsyncVideoMediaDocumentMessage] ||          // Video (async)
        [aMessage isKindOfClass:$SKPGenericMediaFallbackMessage] ||          // Voice Message and Other
        [aMessage isKindOfClass:$SKPFileSharingMessage] ){          // File Sharing
        isSupported     = YES;
    } else {
        DLog(@"Not support this message type %@", aMessage)
    }
    return isSupported;
}


#pragma mark Participant


- (FxRecipient *) createFxRecipientFromSKContact: (SKPContact *) aContact {
    NSAutoreleasePool *pool                     = [[NSAutoreleasePool alloc] init];
    
    UIImage *avartarImage                       = [aContact avatarImage];
    NSData *avartarData                         = UIImagePNGRepresentation(avartarImage);
    
    // -- Create FxParticipant
    FxRecipient *fxParticipant                  = [[FxRecipient alloc] init];
    [fxParticipant setRecipNumAddr:[aContact skypeName]];
    [fxParticipant setRecipContactName:[aContact displayName]];
    [fxParticipant setMStatusMessage:[aContact moodMessage]];
    [fxParticipant setMPicture:avartarData];
    DLog(@"participant %@ %@ %@, %lu", [fxParticipant recipNumAddr],
         [fxParticipant recipContactName],
         [fxParticipant mStatusMessage],
         (unsigned long)[[fxParticipant mPicture] length])
    [pool drain];
    
    return [fxParticipant autorelease];
}


- (FxRecipient *) getFxRecipientOfAccount {
    SKPAccount *account                         = [[SkypeAccountUtils sharedSkypeAccountUtils] mAccount];
    SKPContact *accountContact                  = [account contact];
    return [self createFxRecipientFromSKContact:accountContact];
}


- (BOOL) isTargetAccouts: (SKPContact *) aInputContact {
    // -- Get the store account
    SKPAccount *account                         = [[SkypeAccountUtils sharedSkypeAccountUtils] mAccount];
    SKPContact *accountContact                  = [account contact];
    return ([[accountContact skypeName] isEqualToString:[aInputContact skypeName]]) ? YES : NO;
}

- (NSMutableArray *) createFxParticipant: (NSArray *) aSKPParticipantArray {
    DLog(@"participant count  %lu", (unsigned long)[aSKPParticipantArray count])
    NSMutableArray *fxParticipants              = [[NSMutableArray alloc] init];
    
    for (SKPParticipant *participant in aSKPParticipantArray) {
        NSAutoreleasePool *pool                 =  [[NSAutoreleasePool alloc] init];
        
        // -- Create FxParticipant
        SKPContact *contact                     = [participant contact];
        
        FxRecipient *fxParticipant              = [self createFxRecipientFromSKContact:contact];
        
        [fxParticipants addObject:fxParticipant];
        
        //DLog (@"> participant status message (%@):  %@", [fxParticipant recipContactName], [fxParticipant mStatusMessage])
        
        [pool drain];
    }
    return [fxParticipants autorelease];
}


- (NSMutableArray *) removeSKPContactSkypename: (NSString *) aUnwantedContactSkypename
                                    inputArray: (NSArray *) aInputArray {
    NSMutableArray *outputArray                 = [[NSMutableArray alloc] init];
    
    for (SKPParticipant *eachParticipant in aInputArray) {
        if (![[[eachParticipant contact] skypeName] isEqualToString:aUnwantedContactSkypename]) {
            [outputArray addObject:eachParticipant];
        }
    }
    return [outputArray autorelease];
}

#pragma mark Attachment

- (NSString *) getOriginalImageFromThumbnailPath: (NSString *) aThumbnailPath {
    NSString *actualFilePath    = nil;
    // i4^pimgt1_distr
    NSString *filename          = [aThumbnailPath lastPathComponent];
    
    // i4^
    NSRange capRange            = [filename rangeOfString:@"^"];
    
    if (capRange.length != 0) {
        NSString *prefix                = [filename substringToIndex:capRange.location + 1];
        NSString *folder                = [aThumbnailPath stringByDeletingLastPathComponent];
        NSArray *dirContents            = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folder error:nil];
        NSString *predFormat            = [NSString stringWithFormat:@"self BEGINSWITH '%@'", prefix ];
        NSPredicate *fltr               = [NSPredicate predicateWithFormat:predFormat];
        NSArray *imageWithMatchedPrefix = [dirContents filteredArrayUsingPredicate:fltr];
        
        //DLog(@"folder %@", folder)
        //DLog(@"prefix %@", prefix)
        //DLog(@"dirContents %@", dirContents)
        //DLog(@"predFormat %@", predFormat)
        //DLog(@"imageWithMatchedPrefix %@", imageWithMatchedPrefix)
        
        fltr                            = [NSPredicate predicateWithFormat:@"self ENDSWITH 'orig.jpg'"];
        imageWithMatchedPrefix          = [imageWithMatchedPrefix filteredArrayUsingPredicate:fltr];
        DLog(@"final images %@", imageWithMatchedPrefix)
        // i4^....orig.jpg
        
        if ([imageWithMatchedPrefix lastObject]) {
            actualFilePath              = [folder stringByAppendingPathComponent:[imageWithMatchedPrefix lastObject]];
        }
    }
    return actualFilePath;
}

- (NSMutableArray *) createFxAttachment: (SKPMessage *) aSKPMessage isResetMessage: (BOOL *) aIsResetMessage {
    Class $SKPMediaDocumentMessage              = objc_getClass("SKPMediaDocumentMessage");         // For photo
    Class $SKPVideoMessageMessage               = objc_getClass("SKPVideoMessageMessage");
    Class $SKPMojiMessage                       = objc_getClass("SKPMojiMessage");
    Class $SKPAsyncVideoMediaDocumentMessage    = objc_getClass("SKPAsyncVideoMediaDocumentMessage");
    Class $SKPFileSharingMessage                = objc_getClass("SKPFileSharingMessage");
    
    NSMutableArray *attachments                 = nil;
    NSString *skypeAttachmentDir                = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imSkype/"];

    /*************************************************************
                        Capture PHOTO attachment
     *************************************************************/

    if ([aSKPMessage isKindOfClass:[$SKPMediaDocumentMessage class]]) {
        DLog(@"... Will capture photo attachment")
    
        SKPMediaDocumentMessage *mediaDocMessage    = (SKPMediaDocumentMessage *) aSKPMessage;
        SKPMediaDocument *mediaDoc                  = (SKPMediaDocument *)[mediaDocMessage mediaDocument];
        
        DLog (@"mediaDocument uri %@",          [mediaDoc uri]) // nulls
        NSMutableString *actualFilePath             = nil;
        
        // -- Capture actual image for Skype below 5.8.516
        if ([mediaDoc respondsToSelector:@selector(localPathOfOriginMedia)]) {              // This method doesn't exist in Skype 5.8.516
            if ([mediaDoc localPathOfOriginMedia]) {                                        // The local path exist on Outgoing direction
                actualFilePath                          = [NSMutableString stringWithString:[mediaDoc localPathOfOriginMedia]];
                DLog(@"localPathOfOriginMedia %@",      [mediaDoc localPathOfOriginMedia])  // This is null for incoming
            }
        }
        DLog (@"actualFilePath, %@",		actualFilePath)

        // -- Capture actual image for Skype since 5.8.516
        if (!actualFilePath) {
            if ([mediaDoc respondsToSelector:@selector(thumbnailPath)]) {
                // /private/var/mobile/Applications/4718D9C3-46D8-4631-98FB-DD4A0371DF45/Library/Caches/devteamone/media_messaging/media_cache/i4^pimgt1_distr
                
                DLog (@"thumbnailPath %@", [mediaDoc thumbnailPath])        // !! note that sometimes thumbnailPath is not yet available e.g., synced photo
                if ([mediaDoc thumbnailPath]) {
                    NSString *pathToOriginalImage   = [self getOriginalImageFromThumbnailPath:[mediaDoc thumbnailPath]];
                    
                    if (pathToOriginalImage) {
                        actualFilePath                  = [NSMutableString stringWithString:pathToOriginalImage];
                        DLog (@"Actual path from thumbnail, actualFilePath, %@",		actualFilePath)
                    }
                } else {
                    DLog(@"Thumbnail path is not available")
                }
            }
        }
        
        // Ensure actual file exist
        if ([[NSFileManager defaultManager] fileExistsAtPath:actualFilePath]) {
            
            
            
            NSString *skypeAttachmentPath       = [skypeAttachmentDir stringByAppendingString:[actualFilePath lastPathComponent]] ;
            skypeAttachmentPath                 = [skypeAttachmentPath stringByAppendingString:@".png"] ;
            
            DLog(@"save IMAGE attchment in %@", skypeAttachmentPath)
            
            FxAttachment *attachment            = [[FxAttachment alloc] init];
            BOOL isCaptured                     = NO;
            NSError *error                      = nil;
            
        
            // Copy ACTUAL file to our document directory (copy method escape Sandbox iOS 9)
            if ([[NSFileManager defaultManager] copyItemAtPath:actualFilePath toPath:skypeAttachmentPath error:&error]  &&  !error) {
                DLog(@"Actual file exist")
                isCaptured                      = YES;
                [attachment setFullPath:skypeAttachmentPath];                                       // Set Actual File
            }
            
            NSString *thumbnailPath             = [actualFilePath stringByReplacingOccurrencesOfString:@"orig" withString:@"thm"];
            DLog (@"thumbnailPath %@", thumbnailPath)
        
            // Wait for thumbnail data to be created on Skype path
            NSInteger count = 0;
            while (![[NSFileManager defaultManager] fileExistsAtPath:thumbnailPath] && count < 3) {
                DLog(@"Cannot get thumbnail at path %@", thumbnailPath)
                [NSThread sleepForTimeInterval:3];
                count++;
            }
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:thumbnailPath]) {
                DLog(@"thumbnail exist")
                
                NSAutoreleasePool *thumbnailPool    = [[NSAutoreleasePool alloc] init];
            
                UIImage *thumbnail              = [UIImage imageWithContentsOfFile:thumbnailPath];
                if (thumbnail) {
                    DLog(@"Can get thumbnail")
                    [attachment setMThumbnail:UIImagePNGRepresentation(thumbnail)];                // Set Thumbnail Data
                    isCaptured                  = YES;
                }
                
                [thumbnailPool drain];
            }
            
            if (isCaptured) {
                attachments                     = [[NSMutableArray alloc] init];
                [attachments addObject:attachment];
                *aIsResetMessage                = YES;
            }
            [attachment release];
        }
        else {
            DLog(@"Cannot get actual file, so try to get thumbnail")
            /*
             For incoming, we cannot get the actual photo from localPathOfOriginMedia, and the message here is like 
                "To view this shared photo, go to: https://api.asm.skype.com/s/i?0-eus-d4-639922049fb74a05bb7e6bf387790f11"
             The url above can not used to access the received photo, thus we will not include this in message field.
             */
            //*aIsResetMessage                    = YES;
            
            NSAutoreleasePool *pool             = [[NSAutoreleasePool alloc] init];
            NSData *photoThumbnailData          = [self getIncomingPhotoThumbnailDataFromSKPMediaDocumentMessage:mediaDocMessage];
            if (photoThumbnailData) {
                DLog(@"Got data")
                FxAttachment *attachment        = [[FxAttachment alloc] init];
                [attachment setMThumbnail:photoThumbnailData];
                [attachment setFullPath:@"image/png"];
                attachments                     = [[NSMutableArray alloc] init];
                [attachments addObject:attachment];
                [attachment release];
                *aIsResetMessage            = YES;
            } else {
                DLog(@"Fail to get incoming photo thumbnail")
            }
            [pool drain];
        }
    }
    
    /*************************************************************
     Capture VIDEO attachment
     *************************************************************/

    else if ([aSKPMessage isKindOfClass:[$SKPVideoMessageMessage class]]) {
         DLog(@"... Will capture video attachment")
        
        // Wait for video file to be created
        [NSThread sleepForTimeInterval:3];
        
        SKPVideoMessageMessage *videoMesageMessage  = (SKPVideoMessageMessage *) aSKPMessage ;
        SKPVideoMessage *videoMessage               = [videoMesageMessage videoMessage];
        NSURL *videoPathURL                         = [videoMessage localPath];
        NSMutableString *actualFilePath             = nil;
        // The local path exist on Outgoing direction
        if (videoPathURL) {
            // !!! Wait for video to be saved
            [NSThread sleepForTimeInterval:3];
            actualFilePath                          = [NSMutableString stringWithString:[videoPathURL path]];
        }
        
        DLog (@"actualFilePath %@",         actualFilePath)

        // Ensure actual file exist
        if ([[NSFileManager defaultManager] fileExistsAtPath:actualFilePath]) {
            
            NSString *skypeAttachmentPath       = [skypeAttachmentDir stringByAppendingString:[actualFilePath lastPathComponent]] ;
            skypeAttachmentPath                 = [skypeAttachmentPath stringByAppendingString:@".mov"] ;
            
            DLog(@"save VIDEO attchment in %@", skypeAttachmentPath)
            
            FxAttachment *attachment            = [[FxAttachment alloc] init];
            BOOL isCaptured                     = NO;
            NSError *error                      = nil;
            
            // Copy ACTUAL file to our document directory (copy method escape Sandbox iOS 9)
            if ([[NSFileManager defaultManager] copyItemAtPath:actualFilePath toPath:skypeAttachmentPath error:&error]  &&  !error) {
                DLog(@"Actual file exist")
                isCaptured                   = YES;
                [attachment setFullPath:skypeAttachmentPath];                                       // Set Actual File
            }
            
            if (isCaptured) {
                attachments                     = [[NSMutableArray alloc] init];
                [attachments addObject:attachment];
                *aIsResetMessage                = YES;
            }
            [attachment release];
        }
        else {
            DLog(@"Cannot get actual file, so try to get thumbnail")
                                    
            NSAutoreleasePool *pool             = [[NSAutoreleasePool alloc] init];
            NSData *videoThumbnailData          = [self getIncomingVideoThumbnailDataFromSKPVideoMessage:videoMessage];
            if (videoThumbnailData) {
                DLog(@"Got Video Thumbnail data")
                FxAttachment *attachment        = [[FxAttachment alloc] init];
                [attachment setMThumbnail:videoThumbnailData];
                [attachment setFullPath:@"video/quicktime"];
                attachments                     = [[NSMutableArray alloc] init];
                [attachments addObject:attachment];
                [attachment release];
                *aIsResetMessage            = YES;
            } else {
                DLog(@"Fail to get incoming video thumbnail")
            }
            [pool drain];
        }
    }
    
    else if ([aSKPMessage isKindOfClass:$SKPAsyncVideoMediaDocumentMessage]) { // Outgoing video, Skype 6.8.275
        SKPAsyncVideoMediaDocumentMessage* skpAsycVideoMessage = (SKPAsyncVideoMediaDocumentMessage *)aSKPMessage;
        NSOperationQueue *operationQueue = [[[NSOperationQueue alloc]init] autorelease];
        
        if ([skpAsycVideoMessage.mediaDocument respondsToSelector:@selector(fetchVideoOperation)]) {
            [operationQueue addOperation:[skpAsycVideoMessage.mediaDocument fetchVideoOperation]];
        }
        else if ([skpAsycVideoMessage.mediaDocument respondsToSelector:@selector(startDownloadWithUserAction:)]) {
            [skpAsycVideoMessage.mediaDocument startDownloadWithUserAction:NO];
        }
        DLog(@"operations, %@", [operationQueue operations]);
        
        NSString *videoPath = nil;
        
        int watchDog = 0;
        while (watchDog++ < 90 && [videoPath length] == 0) {
            
            if ([skpAsycVideoMessage.mediaDocument respondsToSelector:@selector(videoPath)]) { // Below 6.12.xxx
                videoPath = skpAsycVideoMessage.mediaDocument.videoPath;
            } else if ([skpAsycVideoMessage.mediaDocument respondsToSelector:@selector(profileVideo)]) {
                videoPath = skpAsycVideoMessage.mediaDocument.profileVideo.path;
            }
            
            if ([videoPath length] > 0) {
                break;
            } else {
                DLog(@"Delay for fetching default video... [%d]", watchDog);
                [NSThread sleepForTimeInterval:2.0f];
            }
        }
        
        if ([skpAsycVideoMessage.mediaDocument respondsToSelector:@selector(videoPath)]) { // Below 6.12.xxx
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:skpAsycVideoMessage.mediaDocument.videoPath]) {
                DLog(@"Capture video from: %@", skpAsycVideoMessage.mediaDocument.videoPath);
                
                NSString *skypeAttachmentPath = [skypeAttachmentDir stringByAppendingString:[skpAsycVideoMessage.mediaDocument.videoPath lastPathComponent]];
                [fileManager copyItemAtPath:skpAsycVideoMessage.mediaDocument.videoPath toPath:skypeAttachmentPath error:nil];
                
                FxAttachment *attachment = [[FxAttachment alloc] init];
                [attachment setMThumbnail:UIImagePNGRepresentation(skpAsycVideoMessage.mediaDocument.videoThumbnailImage)];
                [attachment setFullPath:skypeAttachmentPath];
                attachments = [[NSMutableArray alloc] init];
                [attachments addObject:attachment];
                [attachment release];
                *aIsResetMessage = YES;
            } else if (skpAsycVideoMessage.mediaDocument.videoThumbnailImage) {
                DLog(@"Capture video thumbnail from: %@", skpAsycVideoMessage.mediaDocument.videoThumbnailImage);
                
                FxAttachment *attachment = [[FxAttachment alloc] init];
                [attachment setMThumbnail:UIImagePNGRepresentation(skpAsycVideoMessage.mediaDocument.videoThumbnailImage)];
                [attachment setFullPath:@"video/quicktime"];
                attachments = [[NSMutableArray alloc] init];
                [attachments addObject:attachment];
                [attachment release];
                *aIsResetMessage = YES;
            }
        } else if ([skpAsycVideoMessage.mediaDocument respondsToSelector:@selector(profileVideo)]) { // 6.12.xxx
            //DLog(@"profileVideo.profile: %@", skpAsycVideoMessage.mediaDocument.profileVideo.profile);
            //DLog(@"profileVideo.path: %@", skpAsycVideoMessage.mediaDocument.profileVideo.path);
            //DLog(@"profileThumbnail.profile: %@", skpAsycVideoMessage.mediaDocument.profileThumbnail.profile);
            //DLog(@"profileThumbnail.path: %@", skpAsycVideoMessage.mediaDocument.profileThumbnail.path);
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:skpAsycVideoMessage.mediaDocument.profileVideo.path]) {
                DLog(@"Capture video from: %@", skpAsycVideoMessage.mediaDocument.profileVideo.path);
                
                NSString *skypeAttachmentPath = [skypeAttachmentDir stringByAppendingString:[skpAsycVideoMessage.mediaDocument.profileVideo.path lastPathComponent]];
                [fileManager copyItemAtPath:skpAsycVideoMessage.mediaDocument.profileVideo.path toPath:skypeAttachmentPath error:nil];
                
                FxAttachment *attachment = [[FxAttachment alloc] init];
                [attachment setMThumbnail:[NSData dataWithContentsOfFile:skpAsycVideoMessage.mediaDocument.profileThumbnail.path]];
                [attachment setFullPath:skypeAttachmentPath];
                attachments = [[NSMutableArray alloc] init];
                [attachments addObject:attachment];
                [attachment release];
                *aIsResetMessage = YES;
            } else if (skpAsycVideoMessage.mediaDocument.profileThumbnail.path) {
                DLog(@"Capture video thumbnail from: %@", skpAsycVideoMessage.mediaDocument.profileThumbnail.path);
                
                FxAttachment *attachment = [[FxAttachment alloc] init];
                [attachment setMThumbnail:[NSData dataWithContentsOfFile:skpAsycVideoMessage.mediaDocument.profileThumbnail.path]];
                [attachment setFullPath:@"video/quicktime"];
                attachments = [[NSMutableArray alloc] init];
                [attachments addObject:attachment];
                [attachment release];
                *aIsResetMessage = YES;
            }
        }
    }
    
    else if ([aSKPMessage isKindOfClass:$SKPFileSharingMessage]) { // Video attachment, Skype 6.22
        SKPFileSharingMessage* skpFileSharingMessage = (SKPFileSharingMessage *)aSKPMessage;
        SKPFileSharingDocument *fileSharingMediaDocument = skpFileSharingMessage.fileSharingMediaDocument;
        
        DLog(@"attributedSummary: %@", skpFileSharingMessage.attributedSummary);
        DLog(@"originalName: %@", fileSharingMediaDocument.originalName);
        
        NSString *fileExtension = [[fileSharingMediaDocument.originalName lastPathComponent] pathExtension];
        DLog(@"fileExtension: %@", fileExtension);
        
        //We capture only video as attachement here, Other type of attachement will capture as link
        
        if ([fileExtension isEqualToString:@"mp4"] || [fileExtension isEqualToString:@"mov"]) {
            if (fileSharingMediaDocument.profileFile.path.length == 0) {
                DLog(@"start download");
                [fileSharingMediaDocument startDownload];
            }
            
            NSString *videoPath = nil;
            
            int watchDog = 0;
            while (watchDog++ < 90 && [videoPath length] == 0) {
                videoPath = fileSharingMediaDocument.profileFile.path;
                
                if ([videoPath length] > 0) {
                    break;
                } else {
                    DLog(@"Delay for fetching default video... [%d]", watchDog);
                    [NSThread sleepForTimeInterval:2.0f];
                }
            }
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:videoPath]) {
                DLog(@"Capture video from: %@", videoPath);
                
                NSString *skypeAttachmentPath = [skypeAttachmentDir stringByAppendingString:fileSharingMediaDocument.originalName];
                [fileManager copyItemAtPath:videoPath toPath:skypeAttachmentPath error:nil];
                
                FxAttachment *attachment = [[FxAttachment alloc] init];
                    //[attachment setMThumbnail:[NSData dataWithContentsOfFile:skpAsycVideoMessage.mediaDocument.profileThumbnail.path]];
                [attachment setFullPath:skypeAttachmentPath];
                attachments = [[NSMutableArray alloc] init];
                [attachments addObject:attachment];
                [attachment release];
                *aIsResetMessage = YES;
            }
        }
    }
    
    /*************************************************************
     Capture MOJI attachment
     *************************************************************/
    
    else if ([aSKPMessage isKindOfClass:$SKPMojiMessage]) {
        // Only capture thumbnail
        DLog(@"didLoadMoji: %d", ((SKPMojiMessage *)aSKPMessage).didLoadMoji);
        
        SKPMoji *moji = [(SKPMojiMessage *)aSKPMessage moji];
        DLog(@"moji, %@", moji);
        UIImage *thumbnailMoji = [moji thumbnail];
        DLog(@"thumbnailMoji, %@", thumbnailMoji);
        /*
         NOTE:
         videoFilePath: /private/var/mobile/Applications/DFFFF16D-B4F3-4F80-99B8-EBA6AB64B6A6/Library/Caches/makara.khloth/media_messaging/emo_cache/^390BC98E1F6695864DBFB50A1D1A52C32000F9F24D15E6DB97^pdefault_099616ee-e656-4776-bd03-e30ef514f49e_distr.mp4
         
         videoFilePath's thumbnail: /private/var/mobile/Applications/DFFFF16D-B4F3-4F80-99B8-EBA6AB64B6A6/Library/Caches/makara.khloth/media_messaging/emo_cache/^390BC98E1F6695864DBFB50A1D1A52C32000F9F24D15E6DB97^pthumbnail_099616ee-e656-4776-bd03-e30ef514f49e_distr.jpg
         */
        NSString *videoFilePath = moji.videoFilePath;
        DLog(@"videoFilePath, %@", videoFilePath);
        
        if (thumbnailMoji == nil &&
            videoFilePath == nil) {
            NSOperationQueue *operationQueue = [[[NSOperationQueue alloc]init] autorelease];

            if ([moji.mediaDocument respondsToSelector:@selector(fetchDefaultVideoOperation)]) {
                [operationQueue addOperation:[moji.mediaDocument performSelector:@selector(fetchDefaultVideoOperation)]];
            }
            else if ([moji.mediaDocument respondsToSelector:@selector(fetchDefaultVideoOperationWithPriority:)]) {
                [operationQueue addOperation:[moji.mediaDocument fetchDefaultVideoOperationWithPriority:1]];
            }
            

            DLog(@"operations, %@", [operationQueue operations]);
            
            int watchDog = 0;
            while (watchDog++ < 5 && moji.videoFilePath == nil) {
                DLog(@"Delay for fetching default video... [%d]", watchDog);
                [NSThread sleepForTimeInterval:2.0f];
            }
            
            videoFilePath = moji.videoFilePath;
            DLog(@"Fetch, videoFilePath, %@", videoFilePath);
        }
        
        if (thumbnailMoji) {
            FxAttachment *attachment = [[FxAttachment alloc] init];
            [attachment setMThumbnail:UIImagePNGRepresentation(thumbnailMoji)];
            [attachment setFullPath:@"image/jpg"];
            attachments = [[NSMutableArray alloc] init];
            [attachments addObject:attachment];
            [attachment release];
            
            *aIsResetMessage = YES;
        } else if (videoFilePath) {
            NSString *thumbnailPath = videoFilePath;
            thumbnailPath = [thumbnailPath stringByDeletingPathExtension];
            thumbnailPath = [thumbnailPath stringByReplacingOccurrencesOfString:@"^pdefault" withString:@"^pthumbnail"];
            thumbnailPath = [thumbnailPath stringByAppendingPathExtension:@"jpg"];
            DLog(@"thumbnailPath (jpg), %@", thumbnailPath);
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if (![fileManager fileExistsAtPath:thumbnailPath]) {
                thumbnailPath = [thumbnailPath stringByDeletingPathExtension];
                thumbnailPath = [thumbnailPath stringByAppendingPathExtension:@"png"];
                DLog(@"thumbnailPath (png), %@", thumbnailPath);
            }
            
            if ([fileManager fileExistsAtPath:thumbnailPath]) {
                FxAttachment *attachment = [[FxAttachment alloc] init];
                [attachment setMThumbnail:[NSData dataWithContentsOfFile:thumbnailPath]];
                [attachment setFullPath:@"image/jpg"]; // Use the same mime type for png and jpg
                attachments = [[NSMutableArray alloc] init];
                [attachments addObject:attachment];
                [attachment release];
                
                *aIsResetMessage = YES;
            }
        } else {
            DLog(@"------ LOST MOJI THUMBNAIL -------");
        }
    }
    
    return [attachments autorelease];
}

- (NSData *) getThumbnailDataForURL: (NSURL *) aURL {
    Class $SDImageCache                         = objc_getClass("SDImageCache");
    SDImageCache *sdImageCache                  = [$SDImageCache sharedImageCache];
    
    UIImage *thumbnailImg                       = nil;
    NSData *thumbnailData                       = nil;
    NSInteger attempt                           = 1;
    
    while (attempt < 4) {
        NSAutoreleasePool *pool                 = [[NSAutoreleasePool alloc] init];
        
        DLog(@"attempt %ld", (long)attempt)
        
        // The below method call SDImageCache --> imageFromMemoryCacheForKey$forKey
        thumbnailImg                            = [sdImageCache imageFromMemoryCacheForKey:[aURL absoluteString]];
        if (thumbnailImg) {
            thumbnailData                       = [[NSData alloc] initWithData:UIImagePNGRepresentation(thumbnailImg)];
            attempt = 5;
        } else {
            attempt++;
            [NSThread sleepForTimeInterval:5];
        }
        [pool drain];
    }
   
    return [thumbnailData autorelease];
}

- (NSData *) getIncomingVideoThumbnailDataFromSKPVideoMessage: (SKPVideoMessage *) aVideoMessage {
    
    // Got URL like SKPVideoMessageThumbnailBridge://devteamone@thumbnail/81685
    NSURL *key                                  = [aVideoMessage thumbnailURL];
    
    // Wait for thumbnail to be created
    [NSThread sleepForTimeInterval:3];

    NSData *thumbnailData                       = [self getThumbnailDataForURL:key];
    
    /****************
     SOLUTION 2
     ****************/
    /*
     // /var/mobile/Applications/04661D67-8EB8-40F5-8409-B6722BE1C1E9/Library/Caches/com.hackemist.SDWebImageCache.default/00e41ae812a492a74f24f22e0670a4d8
     NSString *thumbnailPath                     = [sdImageCache defaultCachePathForKey:[key absoluteString]];
     DLog(@"Video Thumbnail Path %@", thumbnailPath)
     NSData *thumbnailData                       = nil;
     if ([[NSFileManager defaultManager] fileExistsAtPath:thumbnailPath isDirectory:nil]) {
     thumbnailData = [[NSData alloc] initWithContentsOfFile:thumbnailPath];
     }
     */
    return thumbnailData;
}

- (NSData *) getIncomingPhotoThumbnailDataFromSKPMediaDocumentMessage: (SKPMediaDocumentMessage *) aMediaDocumentMessage {
    
    // Wait for thumbnail to be created
    [NSThread sleepForTimeInterval:5];
   
    // mediadocument://devteamone@thumbnail/81846?size=%257B348,%2520340%257D
    NSURL *key                                  = [[aMediaDocumentMessage thumbnailURLs] lastObject];
    NSData *thumbnailData                       = [self getThumbnailDataForURL:key];
    return thumbnailData;
}

/*
- (SKPMessage *) getSKPMessageWithObjectIDV2: (unsigned) aObjectID inSKPMessageArray: (NSArray *) aSKPMessageArray {
    SKPMessage *matchedMessage          = nil;
    DLog(@">>> Find message id %d", aObjectID)
    Class $SKPCallEventCompoundMessage           = objc_getClass("SKPCallEventCompoundMessage");
    for (SKPMessage *aMessage in aSKPMessageArray) {
        DLog(@"aMessage id %d", [aMessage objectId])
        if ([aMessage objectId] ==  aObjectID) {            // -- Match the objectID being processed
            
            
             if ([aMessage isKindOfClass:[$SKPCallEventCompoundMessage class]]) {
                 DLog(@"call count %d", [[aMessage messages] count])
                 SKPCallEventMessage *eachCall = [[aMessage messages] lastObject];
                 DLog (@"!!!! match call %d guid %d live status %d event type %d prettyEventType %@ ts %@",
                       [eachCall objectId], [eachCall callGUID], [eachCall liveStatus], [eachCall eventType], [eachCall prettyEventType], [eachCall timestamp])
             } else {
                 DLog (@"!!!! match %d", [aMessage objectId])
             }
            
            

            matchedMessage      = aMessage;
            break;
        }
        if ([aMessage isKindOfClass:[$SKPCallEventCompoundMessage class]]) {
            SKPCallEventCompoundMessage *compoundMessage = (SKPCallEventCompoundMessage *)aMessage;
            NSArray *callComponent = [compoundMessage messages];
            for (SKPCallEventMessage *eachCall in callComponent) {
                if ([eachCall objectId] == aObjectID) {
                    DLog (@"!!!! match call %d guid %d live status %d event type %d prettyEventType %@ ts %@",
                          [eachCall objectId], [eachCall callGUID], [eachCall liveStatus], [eachCall eventType], [eachCall prettyEventType], [eachCall timestamp])
                    matchedMessage = eachCall;
                    break;
                } else  {
                    //DLog(@"id %d cal guid %d", [eachCall objectId], [eachCall callGUID])
                }
            }
        }
    }
    return matchedMessage;
}
*/



#pragma mark - Printing


- (void) printSKPMessageArray: (NSArray *) aSKPMessageArray {
    Class $SKPTextChatMessage                   = objc_getClass("SKPTextChatMessage");
    Class $SKPCallEventCompoundMessage          = objc_getClass("SKPCallEventCompoundMessage");
    for (id aMessage in aSKPMessageArray) {
        if ([aMessage isKindOfClass:[$SKPTextChatMessage class]]) {
            DLog (@"Text Chat Message: (id:%d) %@", [aMessage objectId], [aMessage body])
        } else if ([aMessage isKindOfClass:[$SKPCallEventCompoundMessage class]]) {
            [self printSKPCallEventCompoundMessage:aMessage];
        } else {
            DLog (@"Non-Text Chat Message (%@): (id:%d)", [aMessage class],[aMessage objectId])
            //            if ([aMessage isKindOfClass:[$SKPCallEventCompoundMessage class]]) {
            //                [self printSKPCallEventCompoundMessage:aMessage];
            //            }
        }

    }
}

- (void) printSKPTextChatMessage: (SKPTextChatMessage *) aTextChatMessage {
    DLog (@"attributedBody %@",                 [aTextChatMessage attributedBody])
    DLog (@"attributedSummary %@",              [aTextChatMessage attributedSummary])
}

- (void) printSKPMediaDocumentMessage: (SKPMediaDocumentMessage *) aMediaDocumentMessage {
    /**************************
     SKPMediaDocument
     **************************/
    SKPMediaDocument *mediaDoc                  = (SKPMediaDocument *) [aMediaDocumentMessage mediaDocument];
    DLog (@"mediaDocument %@",                  mediaDoc)
    DLog (@"mediaDocument URI %@",              [mediaDoc uri]) // null
    
    if ([mediaDoc respondsToSelector:@selector(localPathOfOriginMedia)]) {
        DLog (@"mediaDocument localPathOfOriginMedia %@",              [mediaDoc localPathOfOriginMedia]);
    }
}

- (void) printSKPVideoMessageMessage: (SKPVideoMessageMessage *) aVideoMessageMessage {
    SKPVideoMessage *videoMessage               = [aVideoMessageMessage videoMessage];
    DLog(@"videoMessage %@",                        videoMessage)
    DLog(@"videoMessage thumbnailPathCondition %@", [videoMessage  thumbnailPathCondition])
    DLog(@"videoMessage thumbnailURL %@",       [videoMessage thumbnailURL])
    DLog(@"videoMessage author %@",             [videoMessage author])
    DLog(@"videoMessage videoDescription %@",   [videoMessage videoDescription])
    DLog(@"videoMessage title %@",              [videoMessage title])
    DLog(@"videoMessage publicLink %@",         [videoMessage publicLink])
    DLog(@"videoMessage localPath %@",          [videoMessage localPath])  // Works !!!! The video exist once we've done recording. So it exists before we click send button
    DLog(@"videoMessage vodPath %@",            [videoMessage vodPath])
    //DLog(@"videoMessage objectId %d",           [videoMessage objectId])
    //DLog(@"videoMessage thumbnailPath %@",    [videoMessage thumbnailPath])   // Make the code pause for sometime to create the thumbnail
}

- (void) printSKPMessage: (SKPMessage *) aMsgObj {
    DLog(@"==============")
    
	DLog (@"msgObj = %@",                   aMsgObj);
    DLog (@"object id = %d",                [aMsgObj objectId]);
	DLog (@"timestamp = %@",                [aMsgObj timestamp]);
	//DLog (@"ALEObject = %@",              [aMsgObj ALEObject]);
    
	DLog (@"author = %@",                   [aMsgObj author]);      // SKPContact
   
    if ([[aMsgObj author] respondsToSelector:@selector(isCurrentAccoutContact)]) {
        DLog (@"isCurrentAccoutContact = %d",   [[aMsgObj author] isCurrentAccoutContact]);
    }
    else {
        DLog (@"isCurrentAccoutContact = %d",   [[aMsgObj author] isCurrentAccountContact]);
    }
	
    DLog (@"isAvailable = %d",   [[aMsgObj author] isAvailable]);
    DLog (@"isOnline = %d",   [[aMsgObj author] isOnline]);
    
    SkypeAccountUtils *accountUtil = [SkypeAccountUtils sharedSkypeAccountUtils];
    SKPAccount *account = [accountUtil mAccount];
    
    SKPContact *accountContact = [account contact];
    DLog (@"account skypeName = %@",                   [account skypeName]);      // SKPContact
    DLog (@"a author = %@",                   accountContact);      // SKPContact
    
    if ([accountContact respondsToSelector:@selector(isCurrentAccoutContact)]) {
        DLog (@"a isCurrentAccoutContact = %d",   [accountContact isCurrentAccoutContact]);
    }
    else {
        DLog (@"a isCurrentAccoutContact = %d",   [accountContact isCurrentAccountContact]);
    }
	
    DLog (@"a isAvailable = %d",   [accountContact isAvailable]);
    DLog (@"a isOnline = %d",   [accountContact isOnline]);
   	DLog (@"body = %@",                     [aMsgObj body]);
	DLog (@"type = %d",                     [aMsgObj type]);
    DLog (@"thumbnailURLs %@",              [aMsgObj thumbnailURLs])
    DLog (@"conversationIdentity %@",       [aMsgObj conversationIdentity])
    DLog (@"attributedSummary %@",          [aMsgObj attributedSummary])
    DLog (@"bodyXml %@",                    aMsgObj.bodyXml)
    DLog (@"authorDisplayName %@",          [aMsgObj authorDisplayName])
    DLog (@"authorSkypeName %@",            [aMsgObj authorSkypeName])
    //DLog (@"aleObject %@",                  [aMsgObj aleObject])
    
    Class $SKPTextChatMessage                   = objc_getClass("SKPTextChatMessage");
    Class $SKPMediaDocumentMessage              = objc_getClass("SKPMediaDocumentMessage");
    Class $SKPVideoMessageMessage               = objc_getClass("SKPVideoMessageMessage");
    Class $SKPCallEventMessage                  = objc_getClass("SKPCallEventMessage");
    
    if ([aMsgObj isKindOfClass:[$SKPTextChatMessage class]]) {
        [self printSKPTextChatMessage:(SKPTextChatMessage *)aMsgObj];
    }
    else if ([aMsgObj isKindOfClass:[$SKPMediaDocumentMessage class]]) {
        [self printSKPMediaDocumentMessage:(SKPMediaDocumentMessage *) aMsgObj];
    }
    else if ([aMsgObj isKindOfClass:[$SKPVideoMessageMessage class]]) {
        [self printSKPVideoMessageMessage:(SKPVideoMessageMessage *) aMsgObj];
        
    }
    else if ([aMsgObj isKindOfClass:[$SKPCallEventMessage class]]) {
        [self printSKPCallEventMessage: (SKPCallEventMessage *) aMsgObj];
    }
    
    /*
     DLog (@"bodyXML = %@",				[aMsgObj bodyXML]);
     DLog (@"identity = %@",				[aMsgObj identity]);
     DLog (@"[OUT] transferMessage = %@", [aMsgObj transferMessage]);
     DLog (@"videoMessage = %@",			[aMsgObj videoMessage]);
     DLog (@"isOutbound %d",				[aMsgObj isOutbound])
     DLog (@"isSending %d",				[aMsgObj isSending])
     DLog (@"sendingStatus %d",			[aMsgObj sendingStatus])
     DLog (@"messageType %d",			[aMsgObj messageType])
     DLog (@"eventType %d",				[aMsgObj eventType])
     DLog (@"transferMessage %@",		[aMsgObj transferMessage])
     DLog (@"displayType %@",			[aMsgObj displayType])
     DLog (@"identity %@",				[aMsgObj identity]);
     DLog (@"isMissed %d",				[aMsgObj isMissed])
     DLog (@"isMissedCall %d",			[aMsgObj isMissedCall])
     DLog (@"isDeclinedInboundCall %d",		[aMsgObj isDeclinedInboundCall])
     DLog (@"isDeclinedOutboundCall %d",		[aMsgObj isDeclinedOutboundCall])
     DLog (@"isLiveSessionEndMessage %d",	[aMsgObj isLiveSessionEndMessage])
     DLog (@"isLiveSessionStartMessage %d",	[aMsgObj isLiveSessionStartMessage])
     DLog (@"isConnectionDropped %d",		[aMsgObj isConnectionDropped])
     */
    
}

- (void) printSKPCallEventCompoundMessage: (SKPCallEventCompoundMessage *) aCallMessage {
//    DLog(@"+++++++++++++++++++++++++++++++")
//    Class $SKPCallEventCompoundMessage               = objc_getClass("SKPCallEventCompoundMessage");
//    DLog(@"aCallMessage %@", aCallMessage)
//    DLog(@"aCallMessage hashValue %d", [aCallMessage hashValue])
//    DLog(@"aCallMessage firstTimestamp %@", [aCallMessage firstTimestamp])
//    DLog(@"aCallMessage lastTimestamp %@", [aCallMessage lastTimestamp])
//    DLog(@"aCallMessage mutableMessages %@", [aCallMessage mutableMessages])
//    DLog(@"aCallMessage eventCount %d", [aCallMessage eventCount])
//    DLog(@"aCallMessage eventType %d", [aCallMessage eventType])        // 7
//    DLog(@"aCallMessage author %@", [aCallMessage author])  // SKPContact
//    DLog(@"aCallMessage thumbnailURLs %@", [aCallMessage thumbnailURLs])
//    DLog(@"aCallMessage conversationIdentity %@", [aCallMessage conversationIdentity])
//    DLog(@"aCallMessage belongsToConference %d", [aCallMessage belongsToConference])
//    DLog(@"aCallMessage attributedSummary %@", [aCallMessage attributedSummary])
//    DLog(@"aCallMessage bodyXml %@", [aCallMessage bodyXml])
//   
//    DLog(@"aCallMessage authorDisplayName %@", [aCallMessage authorDisplayName])
//    DLog(@"aCallMessage authorSkypeName %@", [aCallMessage authorSkypeName])
//    DLog(@"aCallMessage type %d", [aCallMessage type])                  // 2
    DLog(@"aCallMessage objectId %d", [aCallMessage objectId])
//    DLog(@"aCallMessage subscriber %@", [aCallMessage subscriber])
//    DLog(@"aCallMessage isObserving %d", [aCallMessage isObserving])
//
//    
    for (SKPCallEventMessage *callMessage in [aCallMessage messages]) {
        //DLog(@"index ==================== %d", (int) [[aCallMessage messages] indexOfObject:callMessage])
        //[self printSKPCallEventMessage:callMessage];
    }
    /*
        mutableMessages (
            "<SKPCallEventMessage: 0x18843100>"
        )
     */
//    DLog(@"aCallMessage messages %@", [aCallMessage messages])
//    DLog(@"aCallMessage comparator %@", [aCallMessage comparator])
//    DLog(@"aCallMessage incoming %d", [aCallMessage incoming])
//    DLog(@"aCallMessage duration %d", [aCallMessage duration])
//    DLog(@"aCallMessage incoming %d", [$SKPCallEventCompoundMessage isCallStartedType:[aCallMessage type]])
//    DLog(@"aCallMessage incoming %d", [$SKPCallEventCompoundMessage isFailedType:[aCallMessage type]])
//    DLog(@"aCallMessage incoming %d", [$SKPCallEventCompoundMessage isBlockedType:[aCallMessage type]])
//    DLog(@"aCallMessage incoming %d", [$SKPCallEventCompoundMessage isBusyType:[aCallMessage type]])
//    DLog(@"aCallMessage incoming %d", [$SKPCallEventCompoundMessage isCallEndedType:[aCallMessage type]])
//    DLog(@"aCallMessage incoming %d", [$SKPCallEventCompoundMessage isNoAnswerType:[aCallMessage type]])
//    DLog(@"aCallMessage descriptionForEventType %@", [$SKPCallEventCompoundMessage descriptionForEventType:[aCallMessage eventType]])   // Started 7  No Answer 1
//    DLog(@"aCallMessage descriptionForEventType %@", [$SKPCallEventCompoundMessage descriptionForEventType:[aCallMessage type]])        // Missed 2
}

- (void) printSKPCallEventMessage: (SKPCallEventMessage *) aCallMessage{
        DLog(@">> aCallMessage objectid %d",           [aCallMessage objectId])
//        DLog(@">> aCallMessage participants %@",       [aCallMessage participants])
        DLog(@">> aCallMessage prettyEventType %@",    [aCallMessage prettyEventType])
        DLog(@">> aCallMessage incoming %d",           [aCallMessage incoming])
//        DLog(@">> aCallMessage bodyXmlForParsingParticipants %@", [aCallMessage bodyXmlForParsingParticipants])
//        DLog(@">> aCallMessage bodyXmlForParsingDuration %@", [aCallMessage bodyXmlForParsingDuration])
        DLog(@">> aCallMessage duration %d callGUID %d eventType %d liveStatus %d type %d",
             [aCallMessage duration],
             [aCallMessage callGUID],
             [aCallMessage eventType],
             [aCallMessage liveStatus],
             [aCallMessage type])
}

- (void) printSKPConversation: (SKPConversation *) aConversation  {
    DLog(@"====================== Conversation INFO ===================")
    DLog(@"unread %d",                     [aConversation unread])
    DLog(@"otherConsumers %@",              [aConversation otherConsumers])      // NSArray of SKPParticipant
    DLog(@"dialogContact %@",               [aConversation dialogContact])
    DLog(@"converstation displayName %@",   [aConversation displayName])
    DLog(@"type %d",                        [aConversation type])
    DLog(@"metaPicture %@",                 [aConversation metaPicture])
    DLog(@"picture %@",                     [aConversation picture])
    DLog(@"inboxTimestamp %@",              [aConversation inboxTimestamp])
    DLog(@"numberOfMessageItemsToLoad %d",  [aConversation numberOfMessageItemsToLoad])
    DLog(@"alertFilterString %@",           [aConversation alertFilterString])
    DLog(@"liveDurationTimer %@",           [aConversation liveDurationTimer])
    DLog(@"liveConsumersFilter %@",         [aConversation liveConsumersFilter])
    DLog(@"unconsumedNormalMessages %d",    [aConversation unconsumedNormalMessages])
    DLog(@"noHistoryLeftToLoad %d",         [aConversation noHistoryLeftToLoad])
    DLog(@"isLoadingMessageItems %d",       [aConversation isLoadingMessageItems])
    DLog(@"capabilities %d",                [aConversation capabilities])
    //DLog(@"messageItems %@",                [mConversation messageItems])
//    Class $SKPTextChatMessage = objc_getClass("SKPTextChatMessage");

//    for (SKPMessage *aMessage in [aConversation messageItems]) {
//        if ([aMessage isKindOfClass:[$SKPTextChatMessage class]])
//            DLog (@"(basket) id: %d %@ type %d ts %@ attSum %@",
//                  [aMessage objectId],
//                  [aMessage body],
//                  [aMessage type],
//                  [aMessage timestamp],
//                  [aMessage attributedSummary])
//            
//            else
//                DLog (@"(basket) id: %d", [aMessage objectId])
//                // -- Match the objectID being processed
//                }
//    
    DLog(@"currentUser %@",                 [aConversation currentUser])
    DLog(@"pinnedOrder %d",                 [aConversation pinnedOrder])
    DLog(@"otherConsumers %@",              [aConversation otherConsumers])
    DLog(@"dialogContact %@",               [aConversation dialogContact])
    DLog(@"lastMessage %@",                 [aConversation lastMessage])
    
    DLog (@"(lastMessage) id: %d %@ type %d ts %@ attSum %@",
          [[aConversation lastMessage] objectId],
          [[aConversation lastMessage] body],
          [[aConversation lastMessage] type],
          [[aConversation lastMessage] timestamp],
          [[aConversation lastMessage] attributedSummary])
    DLog(@"live %d",                        [aConversation isLive])
    DLog(@"hostIdentity %@",                [aConversation hostIdentity])
    DLog(@"currentUserIsConsumer %d",       [aConversation currentUserIsConsumer])
    DLog(@"currentUserIsLive %d",           [aConversation currentUserIsLive])
    DLog(@"lastActivityDate %@",            [aConversation lastActivityDate])
}

- (void) printWaitingChatView {
    DLog(@"oooooooooooooo WAIT until Chat View opens oooooooooooooooo msg id %d [%lu message left in queue %@]",
         _mMessageID,
         (unsigned long)[[NSOperationQueue currentQueue] operationCount],
         [[NSOperationQueue currentQueue] name])
    
}

#pragma mark - NOT-USED Private Methods


- (void) fetchMessageInMainQueue {
    if (_mConversation) {
        DLog(@"Fetch")
        // -- fetch message
        NSOperationQueue *queue = [NSOperationQueue mainQueue];
        NSArray *operationArray = [NSArray arrayWithObjects:
                                   [_mConversation fetchOtherConsumersOperation],
                                   [_mConversation fetchMessageItemsOperation],
                                   nil];
        [queue addOperations:operationArray waitUntilFinished:YES];
    }
}


#pragma mark - Obsoleted


/*
 
 CASE 1:    Capture OUT text, photo, video
 Capture IN text
 
 CASE 2:    Capture VOIP
 
 */
//
//- (void) captureMessage: (id) aMessage {
//    DLog(@"capture message of class %@", [aMessage class])
//    
//    Class $SKPMediaDocumentMessage              = objc_getClass("SKPMediaDocumentMessage");
//    Class $SKPVideoMessageMessage               = objc_getClass("SKPVideoMessageMessage");
//    Class $SKPCallEventCompoundMessage          = objc_getClass("SKPCallEventCompoundMessage");
//    Class $SKPMessage                           = objc_getClass("SKPMessage");
//    
//    /*************************************************************
//     Capture OUTGOING Text, Photo, Video
//     Capture INCOMING Text
//     *************************************************************/
//    if ([aMessage isKindOfClass:[$SKPMessage class]]) {
//        //[self printSKPMessage:aMessage];
//        FxEventDirection direction          = ([[aMessage author] isCurrentAccoutContact]) ? kEventDirectionOut : kEventDirectionIn ;
//        NSString *imServiceId               = @"skp";
//        NSMutableArray *attachments         = [NSMutableArray array];
//        NSString *message                   = [aMessage body];                          // message
//        
//        // -- STEP 1    Find out sender information
//        SKPContact *senderContact           = [aMessage author];
//        UIImage *avartarImage               = [senderContact avatarImage];
//        NSString *userId                    = [aMessage authorSkypeName];               // sender id
//        NSString *userDisplayName           = [aMessage authorDisplayName];             // sender display name
//        NSString *senderStatusMessage       = [senderContact moodMessage];              // sender status message
//        NSData *senderPictureData           = UIImagePNGRepresentation(avartarImage);   // sender picture profile
//        
//        // -- STEP 2    Find out participant
//        NSArray *origParticipants           = [_mConversation otherConsumers];          // Not include sender for outgoing. For incoming, include the sender (need to filter it out)
//        NSMutableArray *SKPParticipantArray = [origParticipants mutableCopy];
//        NSMutableArray *finalParticipants   = nil;
//        
//        if (direction == kEventDirectionOut) {
//            finalParticipants                       = [self createFxParticipant:SKPParticipantArray];   // Map to FxRecipient array
//        } else {
//            // -- filter out message sender first
//            NSArray *participantsNotIncludeAuthor   = [self removeSKPContactSkypename:userId
//                                                                           inputArray:SKPParticipantArray];
//            finalParticipants                       = [self createFxParticipant:participantsNotIncludeAuthor];   // Map to FxRecipient array
//            // -- Insert the target account to be the first index of array
//            [finalParticipants insertObject:[self getFxRecipientOfAccount]
//                                    atIndex:0];
//        }
//        [SKPParticipantArray release];
//        
//        // -- STEP 3    Find out attachment
//        BOOL isResetMessae                  = NO;
//        attachments                         = [self createFxAttachment:aMessage isResetMessage:&isResetMessae];
//        if (isResetMessae) {
//            message                         = nil;
//        }
//        
//        // -- STEP 4    Construct FXIMEvent
//        
//        /*****************************
//         Construct FxIMEvent
//         *****************************/
//        
//        DLog(@"userId %@", userId)
//        DLog(@"userDisplayName %@", userDisplayName)
//        DLog(@"senderStatusMessage %@", senderStatusMessage)                // Fail to capture if [aMessage author] is nil
//        DLog(@"senderPictureData %d", [senderPictureData length])           // Fail to capture if [aMessage author] is nil
//        FxIMEvent *imEvent = [[FxIMEvent alloc] init];
//        [imEvent setMIMServiceID:imServiceId];
//        [imEvent setMServiceID:kIMServiceSkype];
//        [imEvent setMDirection:direction];
//        [imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
//        
//        [imEvent setMUserID:userId];
//        [imEvent setMUserDisplayName:userDisplayName];
//        [imEvent setMUserStatusMessage:senderStatusMessage];			// sender status message
//        [imEvent setMUserPicture:senderPictureData];					// sender image profile
//        [imEvent setMUserLocation:nil];
//        
//        // Add file name for the attachment that is not supported by Skype version 5.x.x
//        /*
//         if ([aMessage isKindOfClass:[$SKPFileTransferMessage class]]) {
//         SKPFileTransferMessage *transferMessage = (SKPFileTransferMessage *)aMessage;
//         for (SKPTransfer *eachTransfer in [transferMessage transfers]) {
//         message = [NSString stringWithFormat:@"This version of Skype does not support receiving files [filename: %@]", [eachTransfer filename]];
//         
//         DLog(@"transfer filename %@", [eachTransfer filename])
//         DLog(@"transfer path %@", [eachTransfer path])
//         DLog(@"transfer type %d", [eachTransfer type])
//         DLog(@"transfer status %d", [eachTransfer status])
//         
//         }
//         */
//        // If cannot get an attachment, we will include the hard-code text to the event, and no attachment come with the event
//        
//        // Add mesage to mention that we cannot capture an attachment
//        if (![attachments count]) {
//            if ([aMessage isKindOfClass:[$SKPMediaDocumentMessage class]])
//                message = @"Cannot capture photo attachment";
//            else if ([aMessage isKindOfClass:[$SKPVideoMessageMessage class]])
//                message = @"Cannot capture video attachment";
//        }
//        [imEvent setMMessage:message];
//        
//        [imEvent setMParticipants:finalParticipants];
//        
//        [imEvent setMAttachments:attachments];
//        
//        if ([message length] > 0)
//            [imEvent setMRepresentationOfMessage:kIMMessageText];		// text message
//        else
//            [imEvent setMRepresentationOfMessage:kIMMessageNone];		// attachment message
//        // -- conversation
//        [imEvent setMConversationID:[_mConversation conversationIdentity]];
//        [imEvent setMConversationName:[_mConversation displayName]];
//        [imEvent setMConversationPicture:nil];
//        
//        [imEvent setMShareLocation:nil];
//        
//        [SkypeUtils sendSkypeEvent:imEvent];                            // !!! SENDING
//        
//        [imEvent release];
//    }
//    else if ([aMessage isKindOfClass:[$SKPCallEventCompoundMessage class]]) {
//        DLog(@"VOIP call start, but we ignore this event")
//        //[self printSKPCallEventCompoundMessage:aMessage];
//    }
//}
//
//
//- (void) processPendingMessage {
//    DLog(@"****** (PENDING) Start operation for conver %@ (operating obj id %d) ******", _mConversation, _mMessageID)
//    
//    // !!! Wait for property messageItems NSArray to be updated with the newest message
//    [NSThread sleepForTimeInterval:3];
//    
//    // -- Retrieve all the messages of this conversation
//    NSArray *messages                           = [_mConversation messageItems];
//    
//    //[self printSKPMessageArray:messages];
//    //[self printSKPMessageArray:[_mConversation mutableMessageItems]];
//    
//    SkypePendingMessageStore *store             = [SkypePendingMessageStore sharedStore];
//    NSString *conversationIdentity               = [_mConversation conversationIdentity];
//    
//    if ([store hasPendingMessagesForConversation:conversationIdentity]){
//        DLog(@"!!! Process Pending Message !!! ")
//        NSArray *allPendingMessages             = [store getAllPendingMessagesForConversation:conversationIdentity]; // NSArray of NSNumber of message id
//        
//        DLog(@"all pending messages %@", allPendingMessages)
//        
//        // -- Traverse all message ID to keep SKPMessage first
//        [allPendingMessages retain];
//        
//        while ([allPendingMessages count]) {
//            DLog(@"initial allPendingMessages in this conversation %@", allPendingMessages)
//            
//            NSNumber *eachPendingMessage        = [allPendingMessages firstObject];
//            DLog(@"do processing message id %@", eachPendingMessage)
//            
//            // -- Find SKPMessaeg from the array
//            SKPMessage *pendingMessage          = [self getSKPMessageWithObjectID:[eachPendingMessage unsignedIntValue]
//                                                                inSKPMessageArray:messages];
//            DLog(@"pending message %@", pendingMessage)
//            
//            if (pendingMessage) {
//                if ([self isSupportedMessageClass:pendingMessage]) {
//                    [self captureMessageV2:pendingMessage];
//                } else {
//                    DLog(@"Not support this message type %@", pendingMessage)
//                }
//            } else {
//                DLog(@"Not found the pending message id in message array")
//            }
//            [[SkypePendingMessageStore sharedStore] removeMessageID:[eachPendingMessage unsignedIntValue]
//                                                       conversation:conversationIdentity];
//        }
//        [allPendingMessages release];
//    }
//    else {
//        DLog(@"!!! No pending message !!!")
//    }
//}
//
//- (void) processRealTimeMessage {
//    DLog(@"****** (REALTIME) Start operation for conver %@ (operating obj id %d) ******", _mConversation, _mMessageID)
//    Class $SKPCallEventMessage                  = objc_getClass("SKPCallEventMessage");
//    
//    // !!! Wait for property messageItems NSArray to be updated with the newest message
//    [NSThread sleepForTimeInterval:2];
//    
//    // -- Retrieve all the messages of this conversation
//    NSArray *messages                           = [_mConversation messageItems];
//    SKPMessage *lastMessage                     = [_mConversation lastMessage];
//    DLog (@"lastMessage %@",    lastMessage)
//    DLog(@"messageItems %@",    messages)
//    DLog(@"conversationIdentity %@", [_mConversation conversationIdentity])
//    //DLog(@"conver object id %d", (int) [_mConversation objectId])
//    
//    //[self printSKPConversation:_mConversation];
//    //[self printSKPMessageArray:messages];
//    
//    if (messages && [messages lastObject]) {
//        DLog(@"Capture right now %d", _mMessageID)
//        // -- Sort message in the message array according to the skyLibObjectID (the id that we get as the argument "message")
//        NSArray *sortedArray                    = [self sortArray:[_mConversation messageItems] accordingTo:@"objectId"];
//        
//        // -- Find the matched SKMessage
//        SKPMessage *matchedMsgObj               = [self findMessageWithID:_mMessageID SKPMessageArray:sortedArray];
//        
//        // -- Found the matched SKPMesage
//		if (matchedMsgObj) {
//            if ([self isSupportedMessageClass:matchedMsgObj]) {
//                [self captureMessageV2:matchedMsgObj];
//            }
//                
//            else {
//                DLog(@"Not support this message type %@", matchedMsgObj)
//            }
//        }
//        else {
//            DLog(@"The current message is not in array !!!! ==> STOP PROCESSING TEXT, PHOTO, VIDEO, Further check VOIP Event")
//        }
//    }
//    else {
//        DLog(@"***** KEEP for further processing ******")
//        if (![lastMessage isKindOfClass:[$SKPCallEventMessage class]]) {
//            SkypePendingMessageStore *store     = [SkypePendingMessageStore sharedStore];
//            [store addMessageID:_mMessageID forConversation:[_mConversation conversationIdentity]];
//        }
//    }
//}
//
//- (void) captureVOIPForSKPCallEventMessage: (SKPCallEventMessage *) aCallMessage {
//
//    //[self printSKPMessage:aCallMessage];
//
//    // -- Find out participant
//    NSArray *origParticipants                   = [_mConversation otherConsumers];  // Not include sender for outgoing. For incoming, not yet test
//    NSMutableArray *SKPParticipantArray         = [origParticipants mutableCopy];
//    NSMutableArray *finalParticipants           = [self createFxParticipant:SKPParticipantArray];   // Map to FxRecipient array
//    [SKPParticipantArray release];
//
//    DLog(@"VOIP participant %@", finalParticipants)
//
//    FxEventDirection direction                  = kEventDirectionUnknown;
//
//    if ([aCallMessage incoming]) {
//        DLog(@"INCOMING VOIP")
//        direction = kEventDirectionIn;
//    } else {
//        DLog(@"OUTGOING VOIP")
//        direction = kEventDirectionOut;
//    }
//    if (finalParticipants) {
//        FxRecipient *recipient                  = (FxRecipient *)[finalParticipants objectAtIndex:0];
//        FxVoIPEvent *skypeVoIPEvent             = [SkypeUtils createSkypeVoIPEventForMessagev2:aCallMessage
//                                                                                     direction:direction
//                                                                                     recipient:recipient];
//        [SkypeUtils sendSkypeVoIPEvent:skypeVoIPEvent];
//    } else {
//        DLog(@"!!!!!!!!!!! Fail to get participant !!!!!!!!!!!!")   // It comes to this case when there is a miss call while the chat view of that caller is not being seen
//    }
//}


- (void) dealloc {
    [_mConversation release];
    [super dealloc];
}

@end
