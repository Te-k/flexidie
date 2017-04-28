//
//  IGUtils.h
//  MSFSP
//
//  Created by Khaneid Hantanasiriskul on 7/11/2559 BE.
//
//

#import <Foundation/Foundation.h>

//Instagram Class
@class IGDirectInboxNetworker, IGDirectContent, IGDirectThread, IGDirectThreadStore;
@class SharedFile2IPCSender;

@interface IGUtils : NSObject

@property (retain) NSMutableDictionary *mLastestThreadTimestampDic;
@property (retain) SharedFile2IPCSender	*mIMSharedFileSender;

+ (IGUtils *)sharedIGUtils;
+ (void)captureMessageContent:(IGDirectContent *)aContent inThread:(IGDirectThread *)aThread;

- (void)initialize;
- (void)storeLastestThreadTimeStamp: (double)aLastestTimeStamp forThreadID:(NSString *)aThreadID;
- (void)loadAllContentFromThread:(IGDirectThread *)aThread inThreadStore:(IGDirectThreadStore *)aThreadStore firstLoad:(BOOL)isFirstLoad;
- (void)captureMessagesFromThread:(IGDirectThread *)aThread;

@end
