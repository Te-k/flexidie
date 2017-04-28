//
//  ProtocolEventConverter.h
//  EDM
//
//  Created by Makara Khloth on 11/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FxEvent;

// Use thumbnail type to select events from repository
// Use media type to get count and check what media type is inserted in repository

@interface ProtocolEventConverter : NSObject {

}

+ (id) convertToPhoenixProtocolEvent: (FxEvent*) aEvent aFromThumbnail: (BOOL) aThumbnail;

@end
