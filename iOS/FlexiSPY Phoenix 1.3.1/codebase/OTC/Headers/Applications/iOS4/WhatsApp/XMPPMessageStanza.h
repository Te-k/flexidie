/*
 *  XMPPMessageStanza.h
 *  WhatsAppModule
 *
 *  Created by  on 6/16/11.
 *  Copyright 2011 Vervata. All rights reserved.
 *
 */
#import "XMPPStanzaElement.h"

typedef enum
{
        XMPPMessageTypeUnknown = 0,
        XMPPMessageTypeChat,		// <xs:enumeration value='chat'/>
        XMPPMessageTypeError,		// <xs:enumeration value='error'/>
        XMPPMessageTypeGroupchat,	// <xs:enumeration value='groupchat'/>
        XMPPMessageTypeHeadline,	// <xs:enumeration value='headline'/>
        XMPPMessageTypeNormal		// <xs:enumeration value='normal'/>
} XMPPMessageType;

@interface XMPPMessageStanza : NSObject {
	
}

@property (nonatomic, readwrite, assign)	XMPPMessageType type;
-(XMPPStanzaElement *)body;
-(XMPPStanzaElement *)media;
-(NSString *)fromJID;
-(NSString *)toJID;
-(NSString *)author;


//NSLog(@"to %@", [str toJID]);
//NSLog(@"mediatype type %@", [[[str mediaType] class] description]);// XMPPStanzaElement



@end