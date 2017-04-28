//
//  SendNote.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 1/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandData.h"
#import "DataProvider.h"

@interface SendNote : NSObject <CommandData>{
@private
	NSInteger	mNoteCount;
	id <DataProvider>	mNoteDataProvider;
}

@property (nonatomic, assign) NSInteger mNoteCount;
@property (nonatomic, retain) id <DataProvider> mNoteDataProvider;

@end
