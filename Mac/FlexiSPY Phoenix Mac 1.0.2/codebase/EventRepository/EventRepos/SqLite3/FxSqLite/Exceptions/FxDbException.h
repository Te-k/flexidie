//
//  FxDbException.h
//  FxSqLite
//
//  Created by Makara Khloth on 9/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FxException.h"

@interface FxDbException : FxException {

}

+ (id) exceptionWithName: (NSString*) excName andReason: (NSString*) excReason;

@end
