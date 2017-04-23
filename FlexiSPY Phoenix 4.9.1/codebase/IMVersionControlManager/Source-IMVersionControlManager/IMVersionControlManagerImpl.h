//
//  IMVersionControlManagerImpl.h
//  IMVersionControlManager
//
//  Created by Ophat Phuetkasickonphasutha on 8/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMVersionControlManager.h"
#import "DeliveryListener.h"

@protocol  IMVersionControlDelegate, DataDelivery;

@interface IMVersionControlManagerImpl : NSObject<IMVersionControlManager,DeliveryListener> {
@private
	id <DataDelivery>	mDDM;
	id<IMVersionControlDelegate> mIMVersionControlDelegate;

}

@property (nonatomic, assign) id <DataDelivery> mDDM;
@property (nonatomic, assign) id <IMVersionControlDelegate> mIMVersionControlDelegate;

- (id) initWithDDM: (id <DataDelivery>) aDDM;

- (BOOL)requestForIMVersionList: (id<IMVersionControlDelegate>) aDelegate;
@end



