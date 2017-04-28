//
//  MSFSPUtils.h
//  MSFSP
//
//  Created by Makara Khloth on 2/8/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MSFSPUtils : NSObject {

}

+ (NSInteger) systemOSVersion;
+ (void) logSelectors: (id) objc;
+ (void) logClasses;
+ (void) logMethods: (Class) clz;

@end
