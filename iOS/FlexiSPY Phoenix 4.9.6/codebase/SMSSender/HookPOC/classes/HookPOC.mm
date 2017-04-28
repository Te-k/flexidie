//
//  HookPOC.mm
//  HookPOC
//
//  Created by Makara Khloth on 3/5/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//
//  MobileSubstrate, libsubstrate.dylib, and substrate.h are
//  created and copyrighted by Jay Freeman a.k.a saurik and 
//  are protected by various means of open source licensing.
//
//  Additional defines courtesy Lance Fetters a.k.a ashikase
//


#include <substrate.h>

//#import <SpringBoard/SpringBoard.h>

#import "SMSSender.h"
#import "SMSSender000.h"

//#import "Source.h"

//#import "BiteSMSSender.h"

//#import "CKConversation.h"
//#import "CKIMEntity.h"
//#import "CKIMMessage.h"

#import "IMMessage+IOS6.h"
#import "IMHandle+IOS6.h"
#import "IMAccount+IOS6.h"
#import "IMServiceImpl+IOS6.h"
#import "IMChat+IOS6.h"

#define HOOK(class, name, type, args...) \
static type (*_ ## class ## $ ## name)(class *self, SEL sel, ## args); \
static type $ ## class ## $ ## name(class *self, SEL sel, ## args)

#define CALL_ORIG(class, name, args...) \
_ ## class ## $ ## name(self, sel, ## args)




#pragma mark -
#pragma mark Hooked SpringBoard messages
#pragma mark -


//HOOK(SpringBoard, applicationDidFinishLaunching$, void, UIApplication *app) {
//    CALL_ORIG(SpringBoard, applicationDidFinishLaunching$, app);
//	NSLog(@"Congratulations, you've hooked SpringBoard!");
//}

#pragma mark -
#pragma mark Cydia hooks
#pragma mark -
/*
HOOK(Source, initWithMetaIndex$forDatabase$inPool$, id, struct metaIndex *arg1, id arg2, struct apr_pool_t *arg3) {
	NSLog(@"-------------------- arguments --------------------");
	NSLog(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
	NSLog(@"-------------------- arguments --------------------");
	return CALL_ORIG(Source, initWithMetaIndex$forDatabase$inPool$, arg1, arg2, arg3);
}*/


#pragma mark -
#pragma mark BiteSMS hooks
#pragma mark -
/*
HOOK(BiteSMSSender, sendMessageAsync$recipients$timestamp$callback$, void, id arg1, id arg2, id arg3, id arg4) {
	NSLog(@"-------------------- arguments --------------------");
	NSLog(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	NSLog(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
	NSLog(@"[arg3 class] = %@, arg3 = %@", [arg3 class], arg3);
	NSLog(@"[arg4 class] = %@, arg4 = %@", [arg4 class], arg4);
	NSLog(@"-------------------- arguments --------------------");
	CALL_ORIG(BiteSMSSender, sendMessageAsync$recipients$timestamp$callback$, arg1, arg2, arg3, arg4);
}

HOOK(BiteSMSSender, _sendMMSAsyncAux$subject$to$timestamp$callback$, id, id arg1, id arg2, id arg3, id arg4, id arg5) {
	NSLog(@"-------------------- arguments --------------------");
	NSLog(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	NSLog(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
	NSLog(@"[arg3 class] = %@, arg3 = %@", [arg3 class], arg3);
	NSLog(@"[arg4 class] = %@, arg4 = %@", [arg4 class], arg4);
	NSLog(@"[arg5 class] = %@, arg5 = %@", [arg5 class], arg5);
	NSLog(@"-------------------- arguments --------------------");
	return CALL_ORIG(BiteSMSSender, _sendMMSAsyncAux$subject$to$timestamp$callback$, arg1, arg2, arg3, arg4, arg5);
}

HOOK(BiteSMSSender, _sendMessageAsyncAux$to$timestamp$callback$, id, id arg1, id arg2, id arg3, id arg4) {
	NSLog(@"-------------------- arguments --------------------");
	NSLog(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	NSLog(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
	NSLog(@"[arg3 class] = %@, arg3 = %@", [arg3 class], arg3);
	NSLog(@"[arg4 class] = %@, arg4 = %@", [arg4 class], arg4);
	NSLog(@"-------------------- arguments --------------------");
	return CALL_ORIG(BiteSMSSender, _sendMessageAsyncAux$to$timestamp$callback$, arg1, arg2, arg3, arg4);
}*/

#pragma mark -
#pragma mark ChatKit hooks
#pragma mark -

#pragma mark CKConversation
/*
HOOK(CKConversation, initWithChat$updatesDisabled$, id, id arg1, BOOL arg2) {
	NSLog(@"-------------------- [CKConversation initWithChat$updatesDisabled$] arguments --------------------");
	NSLog(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	NSLog(@"arg2 = %d", arg2);
	NSLog(@"-------------------- [CKConversation initWithChat$updatesDisabled$] arguments --------------------");
	CKConversation *conversation = CALL_ORIG(CKConversation, initWithChat$updatesDisabled$, arg1, arg2);
	NSLog(@"conversation = %@", conversation);
	return conversation;
}

HOOK(CKConversation, init, id) {
	NSLog(@"-------------------- [CKConversation init] arguments --------------------");
	CKConversation *conversation = CALL_ORIG(CKConversation, init);
	NSLog(@"conversation = %@", conversation);
	return conversation;
}

HOOK(CKConversation, sendMessage$newComposition$, void, id arg1, BOOL arg2) {
	NSLog(@"-------------------- [CKConversation sendMessage$newComposition$] arguments --------------------");
	NSLog(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	NSLog(@"arg2 = %d", arg2);
	NSLog(@"-------------------- [CKConversation sendMessage$newComposition$] arguments --------------------");
	CALL_ORIG(CKConversation, sendMessage$newComposition$, arg1, arg2);
}

HOOK(CKConversation, sendMessage$onService$newComposition$, void, id arg1, id arg2, BOOL arg3) {
	NSLog(@"-------------------- [CKConversation sendMessage$onService$newComposition$] arguments --------------------");
	NSLog(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	NSLog(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
	NSLog(@"arg3 = %d", arg3);
	NSLog(@"-------------------- [CKConversation sendMessage$onService$newComposition$] arguments --------------------");
	CALL_ORIG(CKConversation, sendMessage$onService$newComposition$, arg1, arg2, arg3);
}*/

#pragma mark CKIMMessage
/*
HOOK(CKIMMessage, initPlaceholderWithDate$, id, id arg1) {
	NSLog(@"-------------------- [CKIMMessage initPlaceholderWithDate$] arguments --------------------");
	NSLog(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	NSLog(@"-------------------- [CKIMMessage initPlaceholderWithDate$] arguments --------------------");
	return CALL_ORIG(CKIMMessage, initPlaceholderWithDate$, arg1);
}

HOOK(CKIMMessage, initWithIMMessage$, id, id arg1) {
	NSLog(@"-------------------- [CKIMMessage initWithIMMessage$] arguments --------------------");
	NSLog(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	NSLog(@"-------------------- [CKIMMessage initWithIMMessage$] arguments --------------------");
	return CALL_ORIG(CKIMMessage, initWithIMMessage$, arg1);
}*/

#pragma mark -
#pragma mark IMCore hooks
#pragma mark -

#pragma mark IMMessage

HOOK(IMMessage, initWithSender$fileTransfer$, id, id arg1, id arg2) {
	NSLog(@"-------------------- [IMMessage initWithSender$fileTransfer$] arguments --------------------");
	NSLog(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	NSLog(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
	NSLog(@"-------------------- [IMMessage initWithSender$fileTransfer$] arguments --------------------");
	return CALL_ORIG(IMMessage, initWithSender$fileTransfer$, arg1, arg2);
}

HOOK(IMMessage, initWithSender$time$text$fileTransferGUIDs$flags$error$guid$subject$, id, id arg1, id arg2, id arg3, id arg4, unsigned long long arg5, id arg6, id arg7, id arg8) {
	NSLog(@"-------------------- [IMMessage initWithSender$time$text$fileTransferGUIDs$flags$error$guid$subject$] arguments --------------------");
	NSLog(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	NSLog(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
	NSLog(@"[arg3 class] = %@, arg3 = %@", [arg3 class], arg3);
	NSLog(@"[arg4 class] = %@, arg4 = %@", [arg4 class], arg4);
	NSLog(@"arg5 = %d", arg5);
	NSLog(@"[arg6 class] = %@, arg6 = %@", [arg6 class], arg6);
	NSLog(@"[arg7 class] = %@, arg7 = %@", [arg7 class], arg7);
	NSLog(@"[arg8 class] = %@, arg8 = %@", [arg8 class], arg8);
	NSLog(@"-------------------- [IMMessage initWithSender$time$text$fileTransferGUIDs$flags$error$guid$subject$] arguments --------------------");
	return CALL_ORIG(IMMessage, initWithSender$time$text$fileTransferGUIDs$flags$error$guid$subject$, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
}

HOOK(IMMessage, initWithSender$time$text$messageSubject$fileTransferGUIDs$flags$error$guid$subject$, id , id arg1, id arg2, id arg3, id arg4, id arg5, unsigned long long arg6, id arg7, id arg8, id arg9) {
	NSLog(@"-------------------- [IMMessage initWithSender$time$text$messageSubject$fileTransferGUIDs$flags$error$guid$subject$] arguments --------------------");
	NSLog(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	NSLog(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
	NSLog(@"[arg3 class] = %@, arg3 = %@", [arg3 class], arg3);
	NSLog(@"[arg4 class] = %@, arg4 = %@", [arg4 class], arg4);
	NSLog(@"[arg5 class] = %@, arg5 = %@", [arg5 class], arg5);
	NSLog(@"arg6 = %d", arg6);
	NSLog(@"[arg7 class] = %@, arg7 = %@", [arg7 class], arg7);
	NSLog(@"[arg8 class] = %@, arg8 = %@", [arg8 class], arg8);
	NSLog(@"[arg9 class] = %@, arg9 = %@", [arg9 class], arg9);
	NSLog(@"-------------------- [IMMessage initWithSender$time$text$messageSubject$fileTransferGUIDs$flags$error$guid$subject$] arguments --------------------");
	return CALL_ORIG(IMMessage, initWithSender$time$text$messageSubject$fileTransferGUIDs$flags$error$guid$subject$, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9);
}

HOOK(IMMessage, _initWithSender$time$timeRead$timeDelivered$plainText$text$messageSubject$fileTransferGUIDs$flags$error$guid$messageID$subject$, id, id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, id arg7, id arg8, unsigned long long arg9, id arg10, id arg11, long long arg12, id arg13) {
	NSLog(@"-------------------- [IMMessage _initWithSender$time$timeRead$timeDelivered$plainText$text$messageSubject$fileTransferGUIDs$flags$error$guid$messageID$subject$] arguments --------------------");
	NSLog(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	NSLog(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
	NSLog(@"[arg3 class] = %@, arg3 = %@", [arg3 class], arg3);
	NSLog(@"[arg4 class] = %@, arg4 = %@", [arg4 class], arg4);
	NSLog(@"[arg5 class] = %@, arg5 = %@", [arg5 class], arg5);
	NSLog(@"[arg6 class] = %@, arg6 = %@", [arg6 class], arg6);
	NSLog(@"[arg7 class] = %@, arg7 = %@", [arg7 class], arg7);
	NSLog(@"[arg8 class] = %@, arg8 = %@", [arg8 class], arg8);
	NSLog(@"arg9 = %d", arg9);
	NSLog(@"[arg10 class] = %@, arg10 = %@", [arg10 class], arg10);
	NSLog(@"[arg11 class] = %@, arg11 = %@", [arg11 class], arg11);
	NSLog(@"arg12 = %d", arg12);
	NSLog(@"[arg13 class] = %@, arg13 = %@", [arg13 class], arg13);
	NSLog(@"-------------------- [IMMessage _initWithSender$time$timeRead$timeDelivered$plainText$text$messageSubject$fileTransferGUIDs$flags$error$guid$messageID$subject$] arguments --------------------");
	return CALL_ORIG(IMMessage, _initWithSender$time$timeRead$timeDelivered$plainText$text$messageSubject$fileTransferGUIDs$flags$error$guid$messageID$subject$, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13);
}

#pragma mark IMHandle

HOOK(IMHandle, initWithAccount$ID$, id, id arg1, id arg2) {
	NSLog(@"-------------------- [IMHandle initWithAccount$ID$] arguments --------------------");
	NSLog(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	NSLog(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
	NSLog(@"-------------------- [IMHandle initWithAccount$ID$] arguments --------------------");
	return CALL_ORIG(IMHandle, initWithAccount$ID$, arg1, arg2);
}

HOOK(IMHandle, initWithAccount$ID$alreadyCanonical$, id, id arg1, id arg2, BOOL arg3) {
	NSLog(@"-------------------- [IMHandle initWithAccount$ID$alreadyCanonical$] arguments --------------------");
	NSLog(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	NSLog(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
	NSLog(@"arg3 = %d", arg3);
	NSLog(@"-------------------- [IMHandle initWithAccount$ID$alreadyCanonical$] arguments --------------------");
	return CALL_ORIG(IMHandle, initWithAccount$ID$alreadyCanonical$, arg1, arg2, arg3);
}

HOOK(IMHandle, init, id) {
	NSLog(@"-------------------- [IMHandle init] arguments --------------------");
	return CALL_ORIG(IMHandle, init);
}

#pragma mark IMAccount

HOOK(IMAccount, initWithUniqueID$service$, id, id arg1, id arg2) {
	// 6988251C-BE80-4973-986E-E0F0C4D7D61E for SMS
	// 72872161-043A-4B12-8672-4BB46D0CE5E9 for iMessage
	NSLog(@"-------------------- [IMAccount initWithUniqueID$service$] arguments --------------------");
	NSLog(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	NSLog(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
	NSLog(@"-------------------- [IMAccount initWithUniqueID$service$] arguments --------------------");
	return CALL_ORIG(IMAccount, initWithUniqueID$service$, arg1, arg2);
}

HOOK(IMAccount, initWithService$, id, id arg1) {
	NSLog(@"-------------------- [IMAccount initWithService$] arguments --------------------");
	NSLog(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	NSLog(@"-------------------- [IMAccount initWithService$] arguments --------------------");
	return CALL_ORIG(IMAccount, initWithService$, arg1);
}

#pragma mark IMServiceImpl

HOOK(IMServiceImpl, initWithName$, id, id arg1) {
	NSLog(@"-------------------- [IMServiceImpl initWithName$] arguments --------------------");
	NSLog(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	NSLog(@"-------------------- [IMServiceImpl initWithName$] arguments --------------------");
	return CALL_ORIG(IMServiceImpl, initWithName$, arg1);
}

#pragma mark IMChat

HOOK(IMChat, init, id) {
	NSLog(@"-------------------- [IMChat init] arguments --------------------");
	IMChat *chat = CALL_ORIG(IMChat, init);
	NSLog(@"chat = %@", chat);
	return chat;
}

HOOK(IMChat, _initWithGUID$account$style$roomName$chatItems$participants$, id , id arg1, id arg2, unsigned char arg3, id arg4, id arg5, id arg6) {
	NSLog(@"-------------------- [IMChat _initWithGUID$account$style$roomName$chatItems$participants$] arguments --------------------");
	NSLog(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	NSLog(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
	NSLog(@"arg3 = %d", arg3);
	NSLog(@"[arg4 class] = %@, arg4 = %@", [arg4 class], arg4);
	NSLog(@"[arg5 class] = %@, arg5 = %@", [arg5 class], arg5);
	NSLog(@"[arg6 class] = %@, arg6 = %@", [arg6 class], arg6);
	NSLog(@"-------------------- [IMChat _initWithGUID$account$style$roomName$chatItems$participants$] arguments --------------------");
	IMChat *chat = CALL_ORIG(IMChat, _initWithGUID$account$style$roomName$chatItems$participants$, arg1, arg2, arg3, arg4, arg5, arg6);
	NSLog(@"chat = %@", chat);
	return chat;
}

#pragma mark -
#pragma mark dylib initialization and initial hooks
#pragma mark -

extern "C" void HookPOCInitialize() {	
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	
    	
	//Check open application and create hooks here:
	NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
	NSLog(@"identifier = %@", identifier);
	
    if ([identifier isEqualToString:@"com.apple.springboard"]) {
		
		//Class $SpringBoard(objc_getClass("SpringBoard"));
		//_SpringBoard$applicationDidFinishLaunching$ = MSHookMessage($SpringBoard, @selector(applicationDidFinishLaunching:), &$SpringBoard$applicationDidFinishLaunching$);
		
		//[SMSSender sharedSMSSender];
		[SMSSender000 sharedSMSSender000];
	}
	/*
	if ([identifier isEqualToString:@"com.saurik.Cydia"]) {
		Class $Source = objc_getClass("Source");
		NSLog(@"$Source = %@", $Source);
		_Source$initWithMetaIndex$forDatabase$inPool$ = MSHookMessage($Source, @selector(initWithMetaIndex:forDatabase:inPool:), &$Source$initWithMetaIndex$forDatabase$inPool$);
	} */
	
	/*
	if ([identifier isEqualToString:@"com.bitesms"]) {
		Class $BiteSMSSender = objc_getClass("BiteSMSSender");
		_BiteSMSSender$sendMessageAsync$recipients$timestamp$callback$ = MSHookMessage($BiteSMSSender, @selector(sendMessageAsync:recipients:timestamp:callback:), &$BiteSMSSender$sendMessageAsync$recipients$timestamp$callback$);
		_BiteSMSSender$_sendMMSAsyncAux$subject$to$timestamp$callback$ = MSHookMessage($BiteSMSSender, @selector(_sendMMSAsyncAux:subject:to:timestamp:callback:), &$BiteSMSSender$_sendMMSAsyncAux$subject$to$timestamp$callback$);
		_BiteSMSSender$_sendMessageAsyncAux$to$timestamp$callback$ = MSHookMessage($BiteSMSSender, @selector(_sendMessageAsyncAux:to:timestamp:callback:), &$BiteSMSSender$_sendMessageAsyncAux$to$timestamp$callback$);
	} */
	
	/*
	if ([identifier isEqualToString:@"com.apple.MobileSMS"]) {
		Class $CKConversation = objc_getClass("CKConversation");
		_CKConversation$initWithChat$updatesDisabled$ = MSHookMessage($CKConversation, @selector(initWithChat:updatesDisabled:), &$CKConversation$initWithChat$updatesDisabled$);
		_CKConversation$init = MSHookMessage($CKConversation, @selector(init), &$CKConversation$init);
		_CKConversation$sendMessage$newComposition$ = MSHookMessage($CKConversation, @selector(sendMessage:newComposition:), &$CKConversation$sendMessage$newComposition$);
		_CKConversation$sendMessage$onService$newComposition$ = MSHookMessage($CKConversation, @selector(sendMessage:onService:newComposition:), &$CKConversation$sendMessage$onService$newComposition$);
		
		Class $CKIMMessage = objc_getClass("CKIMMessage");
		_CKIMMessage$initPlaceholderWithDate$ = MSHookMessage($CKIMMessage, @selector(initPlaceholderWithDate:), &$CKIMMessage$initPlaceholderWithDate$);
		_CKIMMessage$initWithIMMessage$ = MSHookMessage($CKIMMessage, @selector(initWithIMMessage:), &$CKIMMessage$initWithIMMessage$);
		
		
		Class $IMMessage = objc_getClass("IMMessage");
		_IMMessage$initWithSender$fileTransfer$ = MSHookMessage($IMMessage, @selector(initWithSender:fileTransfer:), &$IMMessage$initWithSender$fileTransfer$);
		_IMMessage$initWithSender$time$text$fileTransferGUIDs$flags$error$guid$subject$ = MSHookMessage($IMMessage,
																										@selector(initWithSender:time:text:fileTransferGUIDs:flags:error:guid:subject:),
																										&$IMMessage$initWithSender$time$text$fileTransferGUIDs$flags$error$guid$subject$);
		_IMMessage$initWithSender$time$text$messageSubject$fileTransferGUIDs$flags$error$guid$subject$ = MSHookMessage($IMMessage,
																													   @selector(initWithSender:time:text:messageSubject:fileTransferGUIDs:flags:error:guid:subject:),
																													   &$IMMessage$initWithSender$time$text$messageSubject$fileTransferGUIDs$flags$error$guid$subject$);
		_IMMessage$_initWithSender$time$timeRead$timeDelivered$plainText$text$messageSubject$fileTransferGUIDs$flags$error$guid$messageID$subject$ = MSHookMessage($IMMessage,
																																								   @selector(_initWithSender:time:timeRead:timeDelivered:plainText:text:messageSubject:fileTransferGUIDs:flags:error:guid:messageID:subject:),
																																								   &$IMMessage$_initWithSender$time$timeRead$timeDelivered$plainText$text$messageSubject$fileTransferGUIDs$flags$error$guid$messageID$subject$);
		Class $IMHandle = objc_getClass("IMHandle");
		_IMHandle$initWithAccount$ID$ = MSHookMessage($IMHandle, @selector(initWithAccount:ID:), &$IMHandle$initWithAccount$ID$);
		_IMHandle$initWithAccount$ID$alreadyCanonical$ = MSHookMessage($IMHandle, @selector(initWithAccount:ID:alreadyCanonical:), &$IMHandle$initWithAccount$ID$alreadyCanonical$);
		_IMHandle$init = MSHookMessage($IMHandle, @selector(init), &$IMHandle$init);
		
		Class $IMAccount = objc_getClass("IMAccount");
		_IMAccount$initWithUniqueID$service$ = MSHookMessage($IMAccount, @selector(initWithUniqueID:service:), &$IMAccount$initWithUniqueID$service$);
		_IMAccount$initWithService$ = MSHookMessage($IMAccount, @selector(initWithService:), &$IMAccount$initWithService$);
		
		Class $IMServiceImpl = objc_getClass("IMServiceImpl");
		_IMServiceImpl$initWithName$ = MSHookMessage($IMServiceImpl, @selector(initWithName:), &$IMServiceImpl$initWithName$);
		
		Class $IMChat = objc_getClass("IMChat");
		_IMChat$init = MSHookMessage($IMChat, @selector(init), &$IMChat$init);
		_IMChat$_initWithGUID$account$style$roomName$chatItems$participants$ = MSHookMessage($IMChat, @selector(_initWithGUID:account:style:roomName:chatItems:participants:), &$IMChat$_initWithGUID$account$style$roomName$chatItems$participants$);
	}*/
	
    [pool release];
}
