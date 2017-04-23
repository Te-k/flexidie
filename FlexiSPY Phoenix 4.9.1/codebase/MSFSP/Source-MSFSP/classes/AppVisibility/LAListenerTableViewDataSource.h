//
//  LAListenerTableViewDataSource.h
//  MSFSP
//
//  Created by Makara Khloth on 3/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

__attribute__((visibility("hidden")))
@interface LAListenerTableViewDataSource : NSObject <UITableViewDataSource> {
@private
	NSMutableDictionary *_listeners;
	NSMutableDictionary *_filteredListeners;
	NSArray *_groups;
	NSMutableArray *_filteredGroups;
	NSString *_searchText;
	NSMutableArray *_pendingListenerNames;
	NSMutableDictionary *_pendingTableCells;
}

@property (nonatomic, copy) NSString *searchText;

- (NSString *)listenerNameForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
