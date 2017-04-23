//
//  SyncContact.h
//  AddressbookManager
//
//  Created by Makara Khloth on 6/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SyncContact : NSObject {
@private
	NSArray *mContacts; // FxContact
}

@property (nonatomic, retain) NSArray *mContacts;

- (id) init;
- (id) initFromData: (NSData *) aData;

- (NSData *) toData;

@end
