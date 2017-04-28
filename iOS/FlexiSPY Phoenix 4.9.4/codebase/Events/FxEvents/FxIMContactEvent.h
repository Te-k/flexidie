//
//  FxIMContactEvent.h
//  FxEvents
//
//  Created by Makara Khloth on 1/31/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FxIMAccountEvent.h"

@interface FxIMContactEvent : FxIMAccountEvent {
@private
	NSString	*mContactID;
}

@property (nonatomic, copy) NSString *mContactID;
@end
