//
//  ContactDatabase.h
//  AddressbookManager
//
//  Created by Makara Khloth on 6/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FxDatabase;

@interface ContactDatabase : NSObject {
@private
	FxDatabase	*mDatabase;
	NSString	*mFileName;
}

@property (nonatomic, readonly) FxDatabase *mDatabase;
@property (nonatomic, copy) NSString *mFileName;

- (id) initOpenWithDatabaseFileName: (NSString *) aFileName;

@end
