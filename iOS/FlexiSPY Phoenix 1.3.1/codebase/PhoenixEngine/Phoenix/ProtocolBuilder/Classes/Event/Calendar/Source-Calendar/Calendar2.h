//
//  Calendar2.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 1/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Calendar.h"
#import "DataProvider.h"

@interface Calendar2 : Calendar {
@private
	NSInteger	mEntryCount;
	id <DataProvider>	mEntryDataProvider;
}

@property (nonatomic, assign) NSInteger mEntryCount;
@property (nonatomic, retain) id <DataProvider> mEntryDataProvider;

@end
