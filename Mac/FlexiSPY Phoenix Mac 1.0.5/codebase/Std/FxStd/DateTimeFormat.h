//
//  DateTimeFormat.h
//  FxStd
//
//  Created by Makara Khloth on 11/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateTimeFormat : NSObject {

}

+ (NSString *) phoenixDateTime;
+ (NSString *) phoenixDateTime: (NSDate *) aDate;

+ (NSString *) dateTimeWithFormat: (NSString *) aFormat;
+ (NSString *) dateTimeWithDate: (NSDate *) aDate;

+ (NSString *) getLocalTimeZone;

@end


@interface NSDateFormatter (Locale)
- (id) initWithSafeLocaleAndSymbol;
@end