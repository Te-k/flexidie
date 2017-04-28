//
//  ContactNumberDAO.h
//  AddressbookManager
//
//  Created by Makara Khloth on 6/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FxDatabase;

@interface ContactNumberDAO : NSObject {
@private
	FxDatabase *mDatabase;
}

- (id) initWithDatabase: (FxDatabase *) aDatabase;

- (void) insert: (NSArray *) aNumbers clientID: (NSInteger) aClientID;
- (NSArray *) selectWithClientID: (NSInteger) aClientID;
- (void) deleteNumbers: (NSInteger) aClientID;

@end
