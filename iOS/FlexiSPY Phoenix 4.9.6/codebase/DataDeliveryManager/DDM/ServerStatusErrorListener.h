//
//  ServerStatusErrorListener.h
//  DDM
//
//  Created by Makara Khloth on 10/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DefDDM.h"

@protocol ServerStatusErrorListener <NSObject>
@required
- (void) serverStatusErrorRecieved: (DDMServerStatus) aServerStatus;

@end

