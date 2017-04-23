//
//  YahooAttachmentUtils.h
//  ExampleHook
//
//  Created by Benjawan Tanarattanakorn on 3/24/2557 BE.
//
//

#import <Foundation/Foundation.h>

@class  FxIMEvent;

@interface YahooAttachmentUtils : NSObject

@property (retain) NSMutableDictionary *mInAttachmentBySessionIDCollection;   // NSDictionary where FxIMEvent NSArray is a value and Session ID NSString is a key

+ (id) sharedYahooAttachmentUtils;

- (void) storeIMEvent: (FxIMEvent *) aIMEvent
           sessionID : (NSString *) aSessionID;

- (FxIMEvent *) imEventForSessionID: (NSString *) aSessionID;

- (void) removeIMEventForSessionID: (NSString *) aSessionID;

+ (BOOL) isImageVideo: (NSString *) aMediaName;

@end
