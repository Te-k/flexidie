//
//  FxSqlString.h
//  FxSqLite
//
//  Created by Makara Khloth on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FxSqlString : NSObject {
@private
	NSString*	sqlStatement;
	NSMutableArray*	tokenArray;
}

- (id) initWithSqlFormat: (const NSString*) sqlFormat;

// Use index of [?] to format int, float and string of NSString in DefSqlite.h; index 0 mean first [?] in NSString
- (void) formatInt: (NSInteger) intParam atIndex: (NSInteger) index;
- (void) formatFloat: (float) floatParam atIndex: (NSInteger) index;
- (void) formatString: (const NSString*) stringParam atIndex: (NSInteger) index;
- (NSString*) finalizeSqlString;

@end
