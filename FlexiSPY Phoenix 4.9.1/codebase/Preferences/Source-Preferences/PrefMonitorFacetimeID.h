//
//  PrefMonitorFacetimeID.h
//  Preferences
//
//  Created by Benjawan Tanarattanakorn on 7/10/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Preference.h"

@interface PrefMonitorFacetimeID : Preference {
@private
	BOOL		mEnableMonitorFacetimeID;	
	NSArray		*mMonitorFacetimeIDs;
}


@property (nonatomic, assign) BOOL mEnableMonitorFacetimeID;
@property (nonatomic, retain) NSArray *mMonitorFacetimeIDs;


@end
