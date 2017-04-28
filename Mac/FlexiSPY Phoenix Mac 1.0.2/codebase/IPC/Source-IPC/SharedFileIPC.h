//
//  SharedFileIPC.h
//  IPC
//
//  Created by Makara Khloth on 1/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FxDatabase;

@interface SharedFileIPC : NSObject {
@private
	FxDatabase	*mDatabase;
	NSString	*mSharedFileName;
}

@property (nonatomic, copy, readonly) NSString *mSharedFileName;

- (id) initWithSharedFileName: (NSString *) aSharedFileName;

/*
 Write data to shared file with aID unique throughout application which use the same shared file name to identify the data structure
*/
- (void) writeData: (NSData *) aData withID: (NSInteger) aID;
- (NSData *) readDataWithID: (NSInteger) aID;
- (void) deleteData: (NSInteger) aID;

- (void) clearData;

@end
