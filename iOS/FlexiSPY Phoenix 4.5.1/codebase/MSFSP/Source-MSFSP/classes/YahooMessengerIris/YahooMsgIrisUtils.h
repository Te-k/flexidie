//
//  YahooMsgIrisUtils.h
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 3/25/2557 BE.
//
//

#import <Foundation/Foundation.h>

@class Item;
@class FxIMEvent;
@class Group;
@class IRKey;

@interface YahooMsgIrisUtils : NSObject {
    
}

@property (assign) unsigned long long mLastMessageTimestamp;
@property (retain) NSMutableArray *mCapturedUniqueMessageKeys;

+ (id)sharedYahooUtils;
+ (void)sendTextMessageEventForItem: (Item *) anItem;
+ (void)sendTextMessageEventForItemKey: (IRKey *) anItemKey inGroup:(Group *)aGroup;
+ (void)saveLastMessageTimestamp: (unsigned long long) aSendTimestamp;
+ (void)threadSendYahooEvent: (NSArray *) aArgs;
+ (void)waitForAttachments:(NSArray *)aArgs;
+ (BOOL)sendDataToPort: (NSData *) aData portName: (NSString *) aPortName;
+ (void)deleteAttachmentFileAtPathForEvent: (NSArray *) aAttachmentArray;
+ (pthread_mutex_t)yahooIRisMutex;

#pragma mark - Utilities
- (BOOL) canCaptureMessageWithUniqueKey: (NSString *) aKey;
- (void) storeCapturedMessageUniqueKey: (NSString *) aKey;
- (void) restoreCaptureUniqueMessageIDs;

@end
