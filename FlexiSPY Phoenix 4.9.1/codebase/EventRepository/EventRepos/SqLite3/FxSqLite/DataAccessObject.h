//
//  DataAccessObject.h
//  FxSqLite
//
//  Created by Makara Khloth on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FxEvent;
@class DetailedCount;
@class EventCount;

@protocol DataAccessObject <NSObject>
@required
- (NSInteger) deleteEvent: (NSInteger) eventID;
- (NSInteger) insertEvent: (FxEvent*) newEvent;
- (FxEvent*) selectEvent: (NSInteger) eventID;
- (NSArray*) selectMaxEvent: (NSInteger) maxEvent;
- (NSInteger) updateEvent: (FxEvent*) newEvent;
- (DetailedCount*) countEvent;

@end

@protocol DataAccessObject1 <NSObject>
@required
- (NSInteger) deleteRow: (NSInteger) rowId;
- (NSInteger) insertRow: (id) row;
- (id) selectRow: (NSInteger) rowId;
- (NSArray*) selectMaxRow: (NSInteger) maxRow;
- (NSInteger) updateRow: (id) row;
- (NSInteger) countRow;
@optional
- (NSArray *) selectRows: (NSInteger) xId;

@end

@protocol DataAccessObject2 <DataAccessObject1>
@required
- (EventCount*) countAllEvent;
- (NSUInteger) totalEventCount;
- (void) executeSql: (NSString*) aSqlStatement;
- (id) selectRow: (NSInteger) aEventTypeId andEventType: (NSInteger) aEventType;

@end

@protocol DataAccessObject3 <DataAccessObject>
@required
- (NSUInteger) updateMediaEvent: (NSInteger) mediaEventId;
- (NSArray*) selectThumbnail: (NSInteger) aPairId;
// Select media event with no associate thumbnail
- (NSArray*) selectMaxMediaNoThumbnail: (NSInteger) aMaxMedia andEventType: (NSInteger) aEventType;
// Select media event with associate thumbnail and not deliver to server
- (NSArray*) selectMaxMediaThumbnailEvent: (NSInteger) aMaxMedia andEventType: (NSInteger) aEventType;
// Select media event with associate thumbnail either delivered or not delivered to server
- (NSArray *) selectAllMediaThumbnailEvent: (NSInteger) aEventType delivered: (BOOL) aDelivered; 

@end
