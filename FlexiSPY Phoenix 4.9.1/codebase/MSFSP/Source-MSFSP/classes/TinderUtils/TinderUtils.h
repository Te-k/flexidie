//
//  TinderUtils.h
//  MSFSP
//
//  Created by Khaneid Hantanasiriskul on 7/22/2559 BE.
//
//

#import <Foundation/Foundation.h>

@class SharedFile2IPCSender;

@interface TinderUtils : NSObject

@property (retain) SharedFile2IPCSender	*mIMSharedFileSender;
@property (retain) NSOperationQueue *mSendingEventQueue;

+ (TinderUtils *)sharedTinderUtils;
- (void)captureTinderMessageFromMessageDict:(NSDictionary *)aMessageDict inContext:(NSManagedObjectContext *)aContext;

@end
