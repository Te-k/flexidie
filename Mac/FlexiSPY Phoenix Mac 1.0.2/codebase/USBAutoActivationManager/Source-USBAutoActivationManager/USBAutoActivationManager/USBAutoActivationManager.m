//
//  USBAutoActivationManager.m
//  USBAutoActivationManager
//
//  Created by ophat on 6/11/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "USBAutoActivationManager.h"
#import "USBAutoActivationDelegate.h"

#import "ActivationManager.h"
#import "AppContextImp.h"
#import "ActivationInfo.h"
#import "ActivationResponse.h"  

@interface USBAutoActivationManager (private)
- (void) notifyDelegateWithError: (NSError *) aError;
- (NSArray *) searchForLicenseInUSBPath;
-(void) deleteLicenseCode:(NSString *)aCode andPath:(NSString *)aPath;
-(void)createCSVFileLogWithlLicense:(NSString * )aLicense path:(NSString *)aPath result:(NSString *)aResult;
@end

@implementation USBAutoActivationManager
@synthesize mActivationManager;
@synthesize mAppContext;
@synthesize mDelegate;

@synthesize mLicenseCode, mLicensePath, mCSVLogPath;

- (id) initWithActivationManager:(ActivationManager *) aActivationManager withAppContext:(id <AppContext>)aAppContext{
    if ((self = [super init])) {
        self.mActivationManager = aActivationManager;
        self.mAppContext = aAppContext;
    }
    return self;
}


- (void) startAutoCheckAndStartActivate {
    self.mLicensePath = nil;
    NSMutableArray * temp = [[self searchForLicenseInUSBPath] mutableCopy];
    if (temp) {
        self.mLicenseCode = [[temp objectAtIndex:0] stringByReplacingOccurrencesOfString:@" " withString:@""];
        self.mLicenseCode = [self.mLicenseCode stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        self.mLicenseCode = [self.mLicenseCode stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        self.mLicensePath = [temp objectAtIndex:1];
        self.mCSVLogPath  = [temp objectAtIndex:2];
        DLog(@"licenseCode %@",self.mLicenseCode);
        DLog(@"licensePath %@",self.mLicensePath);
        DLog(@"csvLogPath %@",self.mCSVLogPath);
        
        ActivationInfo *activationInfo = [[[ActivationInfo alloc] init] autorelease];
        [activationInfo setMActivationCode:self.mLicenseCode];
        [activationInfo setMDeviceInfo:[[mAppContext getPhoneInfo] getDeviceInfo]];
        [activationInfo setMDeviceModel:[[mAppContext getPhoneInfo] getDeviceModel]];
        [mActivationManager activate:activationInfo andListener:self];
    }
    [temp release];
}

- (void) onComplete:(ActivationResponse *)aActivationResponse {
    NSError *error = nil;
    if ([aActivationResponse isMSuccess]) { // Success
        DLog(@"### AutoCActivateSuccess ###");
        [self deleteLicenseCode:self.mLicenseCode andPath:self.mLicensePath];
        [self createCSVFileLogWithlLicense:self.mLicenseCode path:self.mCSVLogPath result:@"SUCCESS"];
        
    } else { // Fail
        DLog(@"### AutoCActivateFail ###");
        [self deleteLicenseCode:self.mLicenseCode andPath:self.mLicensePath];
        [self createCSVFileLogWithlLicense:self.mLicenseCode path:self.mCSVLogPath result:[NSString stringWithFormat:@"FAIL %@",[aActivationResponse mMessage]]];
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:aActivationResponse forKey:@"Activation response"];
        error = [NSError errorWithDomain:@"USBAutoActivation error" code:[aActivationResponse mResponseCode] userInfo:userInfo];
    }
    [self notifyDelegateWithError:error];
}

#pragma mark - Private methods -

-(void) notifyDelegateWithError:(NSError *) aError {
    DLog(@"### Ready to notify delegate, %@", aError);
    if ([mDelegate respondsToSelector:@selector(USBAutoActivationCompleted:)]) {
        [mDelegate USBAutoActivationCompleted:aError];
    }
}

- (NSArray *) searchForLicenseInUSBPath {
    NSString * startPath = @"/Volumes/";
    NSString * licenseFileName = @"license.txt";
    NSString * logFile = @"log.csv";
    NSString * pathToLog = nil;
    NSString * pathToLicense = nil;
    Boolean foundLicense = false;
    NSFileManager * seeker = [NSFileManager defaultManager];
    NSArray  * childLists = [seeker contentsOfDirectoryAtPath:startPath error:nil];
    for (int i=0; i<[childLists count]; i++) {
        if ([[childLists objectAtIndex:i] rangeOfString:@"."].location == NSNotFound) {
            NSString * usbPath = [NSString stringWithFormat:@"%@%@",startPath,[childLists objectAtIndex:i]];
            NSArray  * subChildLists = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:usbPath error:nil];
            for (int j=0; j<[subChildLists count]; j++) {
                if( [[subChildLists objectAtIndex:j] rangeOfString:licenseFileName].location != NSNotFound ) {
                    pathToLicense = [NSString stringWithFormat:@"%@/%@",usbPath,[subChildLists objectAtIndex:j]];
                    pathToLog = [NSString stringWithFormat:@"%@/%@",usbPath,logFile];
                    foundLicense = true;
                    break;
                }
            }
            if (foundLicense) {
                break;
            }
        }
    }
    if (pathToLicense) {
        NSString * licenseContent = [NSString stringWithContentsOfFile:pathToLicense encoding:NSUTF8StringEncoding error:nil];
        if ([licenseContent length]>0) {
            NSArray * licenseList = [licenseContent componentsSeparatedByString:@"\n"];
            if ([licenseList count]>0) {
                NSMutableArray  * content  = [[[NSMutableArray alloc]init]autorelease];
                [content addObject:[licenseList objectAtIndex:0]];
                [content addObject:pathToLicense];
                [content addObject:pathToLog];
                return content;
            }
        }else{
            DLog(@"No License Found");
        }
    }
    return nil;
}

-(void) deleteLicenseCode:(NSString *)aCode andPath:(NSString *)aPath {
    NSString * licenseContent = [NSString stringWithContentsOfFile:aPath encoding:NSUTF8StringEncoding error:nil];
    NSMutableArray * licenseList = [[NSMutableArray alloc] initWithArray:[licenseContent componentsSeparatedByString:@"\n"]];
    NSMutableArray * temp = licenseList;
    NSString * indexToDelete = nil;
    for (int i=0; i < [temp count]; i++) {
        if ([[temp objectAtIndex:i]isEqualToString:aCode]) {
            indexToDelete = [NSString stringWithFormat:@"%d",i];
        }
    }
    if (indexToDelete) {
        NSString * newLicenseContent = @"";
        [licenseList removeObjectAtIndex:[indexToDelete intValue]];
        for (int i=0; i < [licenseList count]; i++) {
            if ([newLicenseContent length]==0) {
                newLicenseContent = [licenseList objectAtIndex:i];
            }else{
                newLicenseContent = [NSString stringWithFormat:@"%@\n%@",newLicenseContent,[licenseList objectAtIndex:i]];
            }
        }
        [newLicenseContent writeToFile:aPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    [licenseList release];
}

-(void)createCSVFileLogWithlLicense:(NSString * )aLicense path:(NSString *)aPath result:(NSString *)aResult{
    NSString * writer = @"";
    NSString * computerName =  [[NSHost currentHost] localizedName];
    NSDateFormatter *datetimeFormat = [[NSDateFormatter alloc] init];
    [datetimeFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *time = [datetimeFormat stringFromDate:[NSDate date]];
    NSFileManager * file = [NSFileManager defaultManager];
    if ([file fileExistsAtPath:aPath]) {
        NSString * temp = [NSString stringWithContentsOfFile:aPath encoding:NSUTF8StringEncoding error:nil];
        writer = [NSString stringWithFormat:@"%@\n%@, %@, %@, %@",temp,time,aLicense,computerName,aResult];
    }else{
        writer = [NSString stringWithFormat:@"%@, %@, %@, %@",time,aLicense,computerName,aResult];
    }
    [writer writeToFile:aPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [datetimeFormat release];
}

-(void)dealloc{
    self.mLicensePath = nil;
    self.mLicenseCode = nil;
    self.mCSVLogPath = nil;
    [super dealloc];
}

@end
