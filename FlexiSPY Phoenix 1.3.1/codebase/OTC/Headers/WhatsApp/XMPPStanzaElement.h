/*
 *  XMPPStanzaElement.h
 *  WhatsAppModule
 *
 *  Created by iPhone2 on 6/16/11.
 *  Copyright 2011 Vervata. All rights reserved.
 *
 */

@interface XMPPStanzaElement : NSObject {
	
}

-(NSString *)value;
- (id)attributes;

// WhatsApp 2.8.2
- (id)allAttributes;
// WhatsApp 2.8.7
@property(copy, nonatomic) NSString* name;

@end