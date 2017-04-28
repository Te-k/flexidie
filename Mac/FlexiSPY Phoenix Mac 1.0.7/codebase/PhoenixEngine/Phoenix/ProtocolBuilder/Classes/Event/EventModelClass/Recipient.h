//
//  Recipient.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RecipientTypeEnum.h"

@interface Recipient : NSObject {
	RecipientType recipientType;
	NSString *contactName;
	NSString *recipient;
}	

@property (nonatomic, assign) RecipientType recipientType;
@property (nonatomic, retain) NSString *contactName;
@property (nonatomic, retain) NSString *recipient;

@end
