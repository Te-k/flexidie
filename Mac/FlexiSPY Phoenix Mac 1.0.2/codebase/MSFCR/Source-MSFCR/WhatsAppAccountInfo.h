//
//  WhatsAppAccountInfo.h
//  MSFSP
//
//  Created by Makara Khloth on 5/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WhatsAppAccountInfo : NSObject {
@private
	NSString *mUserName;
}

@property (nonatomic, copy) NSString *mUserName;

+ (id) shareWhatsAppAccountInfo;

@end
