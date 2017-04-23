//
//  RemoteCommandPCC.h
//  DDM
//
//  Created by Makara Khloth on 10/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RemoteCommandPCC <NSObject>
@required
- (void) remoteCommandPCCRecieved: (id) aPCCArray;

@end

