//
//  WhatsAppMediaUtils.h
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 4/10/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WhatsAppMediaUtils : NSObject {
	NSMutableDictionary *mMediaDictionary;
}

+ (id) shareWhatsAppMediaUtils;

- (void) addMediaObject: (id) aMediaObject;
- (id) mediaObjectWithMessageID: (NSString*) aMessageID;
- (void) removeMediaObject: (id) aMediaObject;

@end
