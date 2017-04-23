//
//  DaemonPrivateHome.h
//  FxStd
//
//  Created by Makara Khloth on 12/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DaemonPrivateHome : NSObject {

}

+ (NSString *) daemonPrivateHome;
+ (NSString *) daemonSharedHome;
+ (BOOL) createDirectoryAndIntermediateDirectories: (NSString *) aDirectory;

@end
