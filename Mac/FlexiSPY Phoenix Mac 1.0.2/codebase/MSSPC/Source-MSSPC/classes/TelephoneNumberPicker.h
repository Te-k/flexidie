//
//  TelephoneNumberPicker.h
//  MSSPC
//
//  Created by Makara Khloth on 3/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessagePortIPCReader.h"

@interface TelephoneNumberPicker : NSObject <MessagePortIPCDelegate> {
@private
	NSString				*mTelephoneNumber;
}

@property (copy) NSString *mTelephoneNumber;

@end
