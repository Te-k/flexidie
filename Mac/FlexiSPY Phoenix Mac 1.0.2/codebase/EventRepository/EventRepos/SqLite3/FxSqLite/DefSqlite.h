//
//  DefSqlite.h
//  FxSqLite
//
//  Created by Makara Khloth on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

// Sequence table
static const NSString* kDeleteEventTypeIdEventBaseSql	= @"DELETE FROM event_base WHERE event_type = ? AND event_id = ?;";