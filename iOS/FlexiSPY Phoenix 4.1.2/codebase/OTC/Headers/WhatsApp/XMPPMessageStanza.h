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
@property(copy, nonatomic) NSString *text;
-(XMPPStanzaElement *)body;
-(XMPPStanzaElement *)media;
-(NSString *)fromJID;
-(NSString *)toJID;
-(NSString *)author;
- (id) attributes;
- (id) chatStateStrings;
- (id) stringsForTypes;


// WhatsApp 2.8.2
@property(copy, nonatomic) NSString *mediaName;
@property(copy, nonatomic) NSString *mediaURL;
@property(readonly, nonatomic) NSString *author;
@property(readonly, nonatomic) NSString *nickname;
@property(readonly, nonatomic) BOOL offline;
@property(readonly, nonatomic) NSString *serverDeliveryAckId;
@property(nonatomic) int chatState;



// WhatsApp 2.8.3, 2.8.4
@property(nonatomic) int mediaType;
- (id)stringForMediaType:(int)arg1;
- (id)stringsForTypes;
- (id)mediaTypeStrings;
- (int)mediaTypeForString:(id)arg1;
- (int)typeForString:(id)arg1;
- (id)mediaTypeStrings;
- (id)vcard;
@property(copy, nonatomic) NSString *vCardContactName;
@property(copy, nonatomic) NSString *vCardStringValue;


// WhatsApp 2.8.7
@property(copy, nonatomic) NSData* thumbnailData;
@property(copy, nonatomic) NSString* locationName;
@property(copy, nonatomic) NSString* locationLongitude;
@property(copy, nonatomic) NSString* locationLatitude;
@property(assign, nonatomic) int mediaDuration;
-(BOOL)hasMedia;
-(BOOL)hasBody;

-(id)vcard;

//NSLog(@"to %@", [str toJID]);
//NSLog(@"mediatype type %@", [[[str mediaType] class] description]);// XMPPStanzaElement



@end