//
//  NoteDataProvider.h
//  NoteManager
//
//  Created by Ophat on 1/17/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataProvider.h"

@class NoteContext;

@interface NoteDataProvider : NSObject <DataProvider> {
@private
	NoteContext	*mNoteContext;
    NSArray     *mNoteObjects;
	
	NSInteger		mNoteCount;
	NSInteger		mNoteIndex;
    
    void *mNotesSharedHandle;
}

@property (retain) NoteContext *mNoteContext;

@property (nonatomic, assign) NSInteger mNoteCount;
@property (nonatomic, assign) NSInteger mNoteIndex;

- (BOOL) hasNext;	// DataProvider protocol
- (id) getObject;	// DataProvider protocol

- (id) commandData;

@end
