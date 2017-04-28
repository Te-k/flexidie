//
//  SyncTimeUtils.h
//  SyncTimeManager
//
//  Created by Makara Khloth on 6/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	kRepTimeZoneRegional	= 1,
	kRepTimeZoneTimeSpan	= 2
} TimeZoneSyncRepresentation;

@interface SyncTime : NSObject {
@private
	NSString						*mTime;			// Must be in this format YYYY-MM-DD HH:mm:ss
	NSString						*mTimeZone;		// Must be either +/-HHmm or [Region]/[Country] depend on mTimeZoneRep
	TimeZoneSyncRepresentation		mTimeZoneRep;
}

@property (nonatomic, copy) NSString *mTime;		// setter is overriden to handle case YYYY-MM-DD 24:mm:ss which have to be YYYY-MM-DD 00:mm:ss
@property (nonatomic, copy) NSString *mTimeZone;	// setter is overriden to handle case +/-HH:mm which is not standard format, +/-HHmm
@property (nonatomic, assign) TimeZoneSyncRepresentation mTimeZoneRep;

- (id) init;
- (id) initWithData: (NSData *) aData;

- (NSData *) toData;
- (NSDate *) toDate;

@end
