//
//  ExtraLogger.m
//  FxStd
//
//  Created by benjawan tanarattanakorn on 2/4/2557 BE.
//
//

#import "ExtraLogger.h"
#import "DaemonPrivateHome.h"
#import "DateTimeFormat.h"



@interface ExtraLogger (private)
- (NSString *) readFile: (NSString *) afilename;
@end



@implementation ExtraLogger

- (void) writeToFileDeactivateWithData : (NSString *) aText {
    NSString * filename     = @"DStatus";
    NSString * home         = [NSString stringWithFormat:@"%@/etc/%@", [DaemonPrivateHome daemonPrivateHome],filename];
    NSFileManager * file    = [NSFileManager defaultManager];
    NSError *error          = nil;
    if ([file fileExistsAtPath:home]) {
        NSString * format   = [self readFile:filename];
        format              = [NSString stringWithFormat:@"%@\n%@ Deactivate %@",
                               format,
                               aText,
                               [DateTimeFormat phoenixDateTime]];
        [format writeToFile:home atomically:YES encoding:NSUTF8StringEncoding error:&error];
    }else{
        NSString * format = [NSString stringWithFormat:@"%@ Deactivate %@",aText,[DateTimeFormat phoenixDateTime]];
        [format writeToFile:home atomically:YES encoding:NSUTF8StringEncoding error:&error];
    }
}

- (void) writeToFileStatusWithData: (NSString *) aText {
    NSString * filename     = @"EStatus";
    NSString * home         = [NSString stringWithFormat:@"%@/etc/%@", [DaemonPrivateHome daemonPrivateHome],filename];
    NSFileManager * file    = [NSFileManager defaultManager];
    NSError *error          = nil;
    if ([file fileExistsAtPath:home]) {
        NSString * format   = [self readFile:filename];
        if ([format rangeOfString:aText].location == NSNotFound) {
            format          = [NSString stringWithFormat:@"%@,%@",format,aText];
            [format writeToFile:home atomically:YES encoding:NSUTF8StringEncoding error:&error];
        }
    } else {
        NSString * format   = [NSString stringWithFormat:@"%@",aText];
        [format writeToFile:home atomically:YES encoding:NSUTF8StringEncoding error:&error];
    }
}

- (NSString *) getErrorCodes {
    NSString * data         = @"";
    NSString * home         = [NSString stringWithFormat:@"%@/etc/%@",[DaemonPrivateHome daemonPrivateHome],@"EStatus"];
    NSFileManager * file    = [NSFileManager defaultManager];
    if ([file fileExistsAtPath:home]) {
        NSString * format   = [self readFile:@"EStatus"];
        NSArray * spliter   = [format componentsSeparatedByString:@","];
        
        if ([spliter count] > 10) {
            for(int i = (int)([spliter count]-10); i <[spliter count]; i++) {
                if (i == ([spliter count]-10)) {
                    data    = [NSString stringWithFormat:@"%@",[spliter objectAtIndex:i]];
                } else {
                    data    = [NSString stringWithFormat:@"%@,%@",data,[spliter objectAtIndex:i]];
                }
            }
        } else {
            data = format;
        }
    }
    return data;
}

- (NSString *) getLastRowDeactivationStatus {
    NSString * data         = @"";
    NSString * home         = [NSString stringWithFormat:@"%@/etc/%@",[DaemonPrivateHome daemonPrivateHome],@"DStatus"];
    NSFileManager * file    = [NSFileManager defaultManager];
    if ([file fileExistsAtPath:home]) {
        NSString * format   = [self readFile:@"DStatus"];
        NSArray * spliter   = [format componentsSeparatedByString:@"\n"];
        data                = [spliter lastObject];
        if (!data)
            data = @"";
    }
    return data;
}

- (NSString *) readFile: (NSString *) afilename {
    NSString * data = @"";
    NSString * home = [NSString stringWithFormat:@"%@/etc/%@", [DaemonPrivateHome daemonPrivateHome],afilename];
    NSFileManager * file = [NSFileManager defaultManager];
    if ([file fileExistsAtPath:home]) {
        NSError *error = nil;
        data = [NSString stringWithContentsOfFile:home encoding:NSUTF8StringEncoding error:&error];
    }
    return data;
}

@end
