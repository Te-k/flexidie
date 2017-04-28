//
//  ContactPhotoDAO.h
//  AddressbookManager
//
//  Created by Makara Khloth on 10/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ContactPhoto, FxDatabase;

@interface ContactPhotoDAO : NSObject {
@private
	FxDatabase *mDatabase;
}

- (id) initWithDatabase: (FxDatabase *) aDatabase;

- (BOOL) isExist: (NSInteger) aClientID;
- (void) insert: (ContactPhoto *) aPhoto clientID: (NSInteger) aClientID;
- (void) update: (ContactPhoto *) aPhoto clientID: (NSInteger) aClientID;
- (ContactPhoto *) selectWithClientID: (NSInteger) aClientID;
- (void) deletePhoto: (NSInteger) aClientID;
- (void) deleteAllPhoto;

@end
