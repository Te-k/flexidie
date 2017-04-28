//
//  TelephoneNumber.h
//  FxStd
//
//  Created by Makara Khloth on 4/25/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TelephoneNumber : NSObject {

}

- (NSString *) formatMonitorNumber: (NSString *) aMonitorNumber;
- (BOOL) isNumber: (id) aNumber matchWithMonitorNumber: (id) aMonitorNumber;

@end
