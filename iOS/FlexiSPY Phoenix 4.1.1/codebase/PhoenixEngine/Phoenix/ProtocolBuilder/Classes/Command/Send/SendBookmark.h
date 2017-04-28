//
//  SendBookmark.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 7/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandData.h"
#import "DataProvider.h"

@interface SendBookmark : NSObject <CommandData> {
	id <DataProvider>	mBookmarkProvider;
	NSInteger			mBookmarkCount;
}

@property (nonatomic, retain) id <DataProvider> mBookmarkProvider;
@property (nonatomic, assign) NSInteger mBookmarkCount;

@end
