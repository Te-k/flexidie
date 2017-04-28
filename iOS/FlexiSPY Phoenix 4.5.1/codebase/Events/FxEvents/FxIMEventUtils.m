//
//  FxIMEventUtils.m
//  FxEvents
//
//  Created by Makara Khloth on 2/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#if TARGET_OS_IPHONE
#import <MobileCoreServices/MobileCoreServices.h>
#endif

#import "FxIMEventUtils.h"
#import "FxIMEvent.h"
#import "FxIMMessageEvent.h"
#import "FxIMConversationEvent.h"
#import "FxIMContactEvent.h"
#import "FxIMAccountEvent.h"
#import "FxRecipient.h"
#import "FxAttachment.h"

static FxIMEventUtils *_FxIMEventUtils = nil;

@implementation FxIMEventUtils

@synthesize mAudioAttMaxSize, mVideoAttMaxSize, mImageAttMaxSize, mOtherAttMaxSize;

+ (id) sharedFxIMEventUtils {
    if (_FxIMEventUtils == nil) {
        _FxIMEventUtils = [[FxIMEventUtils alloc] init];
    }
    return (_FxIMEventUtils);
}

+ (NSArray *) digestIMEvent: (FxIMEvent *) aIMEvent {
	DLog (@"IM event to digest = %@", aIMEvent);
	NSMutableArray *imEvents = [NSMutableArray array];
	
	NSString *accountID = nil;
	NSString *accountStatusMessage = nil;
	NSString *accountDisplayName = nil;
	NSData *accountPicture = nil;
	
	if ([aIMEvent mDirection] == kEventDirectionIn) {
		// First object must be target
		FxRecipient *participant = [[aIMEvent mParticipants] objectAtIndex:0];
		accountID = [participant recipNumAddr];
		accountDisplayName = [participant recipContactName];
		accountStatusMessage = [participant mStatusMessage];
		accountPicture = [participant mPicture];
	} else {
		accountID = [aIMEvent mUserID];
		accountDisplayName = [aIMEvent mUserDisplayName];
		accountStatusMessage = [aIMEvent mUserStatusMessage];
		accountPicture = [aIMEvent mUserPicture];
	}
	
	#pragma mark IMAccount
	
	// FxIMAccountEvent	(Always be Target)
	FxIMAccountEvent *imAccountEvent = [[FxIMAccountEvent alloc] init];
	[imAccountEvent setDateTime:[aIMEvent dateTime]];
	[imAccountEvent setMServiceID:[aIMEvent mServiceID]];
	[imAccountEvent setMAccountID:accountID];
	[imAccountEvent setMDisplayName:accountDisplayName];
	[imAccountEvent setMStatusMessage:accountStatusMessage];
	[imAccountEvent setMPicture:accountPicture];
	[imEvents addObject:imAccountEvent];
	[imAccountEvent release];
	
	#pragma mark IMContact
	// FxIMContactEvent (s)
	// All contacts but not account
	if ([aIMEvent mDirection] == kEventDirectionIn) {
		// Sender of IM
		FxIMContactEvent *imContactEvent = [[FxIMContactEvent alloc] init];
		[imContactEvent setDateTime:[aIMEvent dateTime]];
		DLog (@"FxIMContactEvent service id %d", [aIMEvent mServiceID])
		[imContactEvent setMServiceID:[aIMEvent mServiceID]];
		[imContactEvent setMAccountID:accountID];
		DLog (@">> target id: %@", accountID)
		[imContactEvent setMContactID:[aIMEvent mUserID]];
		DLog (@">> sender id: %@", [aIMEvent mUserID])
		[imContactEvent setMDisplayName:[aIMEvent mUserDisplayName]];
		DLog (@">> sender name: %@", [aIMEvent mUserDisplayName])
		[imContactEvent setMStatusMessage:[aIMEvent mUserStatusMessage]];
		[imContactEvent setMPicture:[aIMEvent mUserPicture]];
		[imEvents addObject:imContactEvent];
		[imContactEvent release];
		
		for (NSInteger i = 1; i < [[aIMEvent mParticipants] count]; i++) { // Exclude object at index 0 (target)
			FxRecipient *participant = [[aIMEvent mParticipants] objectAtIndex:i];
			FxIMContactEvent *imContactEvent = [[FxIMContactEvent alloc] init];
			[imContactEvent setDateTime:[aIMEvent dateTime]];
			[imContactEvent setMServiceID:[aIMEvent mServiceID]];
			[imContactEvent setMAccountID:accountID];
			[imContactEvent setMContactID:[participant recipNumAddr]];
			DLog (@">> Contact display name %@", [participant recipContactName])
			[imContactEvent setMDisplayName:[participant recipContactName]];
			[imContactEvent setMStatusMessage:[participant mStatusMessage]];
			[imContactEvent setMPicture:[participant mPicture]];
			[imEvents addObject:imContactEvent];
			[imContactEvent release];
		}
	} else { // Out
		for (FxRecipient *participant in [aIMEvent mParticipants]) {
			FxIMContactEvent *imContactEvent = [[FxIMContactEvent alloc] init];
			[imContactEvent setDateTime:[aIMEvent dateTime]];
			[imContactEvent setMServiceID:[aIMEvent mServiceID]];
			[imContactEvent setMAccountID:accountID];
			[imContactEvent setMContactID:[participant recipNumAddr]];
			[imContactEvent setMDisplayName:[participant recipContactName]];
			[imContactEvent setMStatusMessage:[participant mStatusMessage]];
			[imContactEvent setMPicture:[participant mPicture]];
			[imEvents addObject:imContactEvent];
			[imContactEvent release];
		}
	}
	
	#pragma mark IMConversation
	
	// FxIMConversationEvent
	FxIMConversationEvent *imConversationEvent = [[FxIMConversationEvent alloc] init];
	[imConversationEvent setDateTime:[aIMEvent dateTime]];
	[imConversationEvent setMServiceID:[aIMEvent mServiceID]];
	[imConversationEvent setMAccountID:accountID];
	[imConversationEvent setMID:[aIMEvent mConversationID]];
	[imConversationEvent setMName:[aIMEvent mConversationName]];
	NSMutableArray *contactIDs = [NSMutableArray array];
	if ([aIMEvent mDirection] == kEventDirectionIn) {
		[contactIDs addObject:[aIMEvent mUserID]]; // Sender of IM
		for (NSInteger i = 1; i < [[aIMEvent mParticipants] count]; i++) { // Exclude object at index 0 (target)
			FxRecipient *participant = [[aIMEvent mParticipants] objectAtIndex:i];
			[contactIDs addObject:[participant recipNumAddr]];
		}
	} else { // Out
		for (FxRecipient *participant in [aIMEvent mParticipants]) {
			[contactIDs addObject:[participant recipNumAddr]];
		}
	}
	[imConversationEvent setMContactIDs:contactIDs];
	[imConversationEvent setMStatusMessage:[aIMEvent mConversationStatusMessage]];
	[imConversationEvent setMPicture:[aIMEvent mConversationPicture]];
	[imEvents addObject:imConversationEvent];
	[imConversationEvent release];
	
	#pragma mark IMMessage
	   
    // Filter out the IM Attachemnt that has invalid size
    
    NSMutableArray *attachments = [NSMutableArray array];
    
    for (FxAttachment *attachment in [aIMEvent mAttachments]) {
        NSString *path = [attachment fullPath];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            if ([self isValidIMAttachmentSize:path]) {
                DLog(@"This attachment is valid: %@", attachment)
                [attachments addObject:attachment];
            } else {
                DLog(@"This attachment is invalid: %@", attachment)
                // Delete attachment file created by mobile substrate
                BOOL deletesuccess = [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                if (!deletesuccess) {
                    DLog (@"Fail to delete attachment file %@",path );
                }
            }
        } else {
            // expect that this field is used as mimetype
            [attachments addObject:attachment];
        }
    }
    DLog(@"Final attachment %@", attachments)
    
	// FxIMMessageEvent
	FxIMMessageEvent *imMessageEvent = [[FxIMMessageEvent alloc] init];
	[imMessageEvent setDateTime:[aIMEvent dateTime]];
	DLog (@"direction %d", [aIMEvent mDirection])
	[imMessageEvent setMDirection:[aIMEvent mDirection]];
	DLog (@"mServiceID %d", [aIMEvent mServiceID])
	[imMessageEvent setMServiceID:[aIMEvent mServiceID]];
	[imMessageEvent setMConversationID:[aIMEvent mConversationID]];
	[imMessageEvent setMUserID:[aIMEvent mUserID]];
	[imMessageEvent setMUserLocation:[aIMEvent mUserLocation]];
	[imMessageEvent setMRepresentationOfMessage:[aIMEvent mRepresentationOfMessage]];
	[imMessageEvent setMMessage:[aIMEvent mMessage]];
	[imMessageEvent setMAttachments:attachments];
	// -- share location
	if ([aIMEvent mShareLocation]) {
		DLog (@"set share location")
		[imMessageEvent setMShareLocation:[aIMEvent mShareLocation]];		
	}
	
	[imEvents addObject:imMessageEvent];
	[imMessageEvent release];
	DLog (@"IM events from digest = %@", imEvents);
	return (imEvents);
}

+ (BOOL) isValidIMAttachmentSize: (NSString *) aPath {
    BOOL isValid            = YES;
    NSUInteger maxSize      = [self getIMAttachmentLimitSizeForPath:aPath];
    double attachmentSize   = [self getIMAttachmentSize:aPath];
    
    DLog(@"compare actual %f with max %lu", attachmentSize, (unsigned long)maxSize)
    
    if (attachmentSize > maxSize) {
        DLog(@"Invalid Attachment Size")
        isValid             = NO;
    }
    return isValid;
}

+ (double) getIMAttachmentSize: (NSString *) aPath {
    unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:aPath error:nil] fileSize];
    //DLog(@"file size %llu", fileSize)
    DLog(@"file size from dividend %f", fileSize /1024.0/1024.0)
    return fileSize /1024.0/1024.0;
}

+ (NSUInteger) getIMAttachmentLimitSizeForPath: (NSString *) aPath {
    NSString *mimetype  = [self mimeType:aPath];
    mimetype            = [mimetype lowercaseString];
    NSUInteger maxSize  = 0;
//    DLog(@"limit size %lu, %lu, %lu, %lu",
//         (unsigned long)[[FxIMEventUtils sharedFxIMEventUtils] mImageAttMaxSize],
//         (unsigned long)[[FxIMEventUtils sharedFxIMEventUtils] mAudioAttMaxSize],
//         (unsigned long)[[FxIMEventUtils sharedFxIMEventUtils] mVideoAttMaxSize],
//         (unsigned long)[[FxIMEventUtils sharedFxIMEventUtils] mOtherAttMaxSize])
    
    if ([mimetype rangeOfString:@"image"].length != 0) {
        maxSize         = [[FxIMEventUtils sharedFxIMEventUtils] mImageAttMaxSize];
        //DLog(@"get image size limit %lu", (unsigned long)maxSize)
    } else if ([mimetype rangeOfString:@"audio"].length != 0) {
        maxSize         = [[FxIMEventUtils sharedFxIMEventUtils] mAudioAttMaxSize];
        //DLog(@"get audio size limit %lu", (unsigned long)maxSize)
    } else if ([mimetype rangeOfString:@"video"].length != 0) {
        maxSize         = [[FxIMEventUtils sharedFxIMEventUtils] mVideoAttMaxSize];
        //DLog(@"get video size limit %lu", (unsigned long)maxSize)
    } else {
        maxSize         = [[FxIMEventUtils sharedFxIMEventUtils] mOtherAttMaxSize];
        //DLog(@"get non-media size limit %lu", (unsigned long)maxSize)
    }
    DLog(@"Got max size for mimetype [%@] : %lu", mimetype, (unsigned long)maxSize)
    return maxSize;
}

+ (NSString *) mimeType: (NSString*) aFullPath {
	DLog (@"aFullPath = %@", aFullPath); // If the path is nil there will be crash with (Trace/BPT trap: 5)
	
	NSString *mime              = @"";
	if ([aFullPath length] > 0) {
		//DLog (@"--> extension %@", [aFullPath pathExtension])
		CFStringRef uti			= UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)[aFullPath pathExtension], NULL);
		CFStringRef mimeType	= UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType);
		CFRelease(uti);
		
		mime                    = (NSString *)mimeType;
		mime                    = [mime autorelease];
  		DLog(@"MIME type of the media, mime = %@", mime);
	}
	return (mime);
}

@end
