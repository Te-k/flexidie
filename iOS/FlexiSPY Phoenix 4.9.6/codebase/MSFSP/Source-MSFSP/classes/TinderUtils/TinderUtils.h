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
@property (retain) NSMutableArray *mCapturedUniqueMessageIds;

+ (TinderUtils *)sharedTinderUtils;
- (void)captureTinderMessageFromMessageDict:(NSDictionary *)aMessageDict inContext:(NSManagedObjectContext *)aContext;
- (BOOL) canCaptureMessageWithUniqueId: (NSString *) anId;
- (void) storeCapturedMessageUniqueId: (NSString *) anId;
- (void) restoreCaptureUniqueMessageIds;

@end
