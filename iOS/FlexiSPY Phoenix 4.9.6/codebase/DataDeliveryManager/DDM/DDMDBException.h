//
//  DDMDBException.h
//  DDM
//
//  Created by Makara Khloth on 10/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FxException.h"

@interface DDMDBException : FxException {

}

+ (id) exceptionWithName: (NSString*) aExcName andReason: (NSString*) aExcReason;

@end
