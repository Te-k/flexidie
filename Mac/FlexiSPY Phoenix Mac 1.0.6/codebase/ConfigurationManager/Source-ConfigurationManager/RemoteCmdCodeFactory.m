//
//  RemoteCmdCodeFactory.m
//  ConfigurationManager
//
//  Created by Makara Khloth on 11/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RemoteCmdCodeFactory.h"
#import "ConfigDecryptor.h"

@implementation RemoteCmdCodeFactory

+ (NSArray*) remoteCommandsForConfiguration:(NSString*)aConfigurationID {
	ConfigDecryptor* cfgDec = [[ConfigDecryptor alloc]initWithConfigurationID:aConfigurationID] ;
	NSArray* remoteCommands =  nil;
	if(cfgDec)
	{
		remoteCommands = [NSArray arrayWithArray:[cfgDec getRemoteCommands]];
		[cfgDec release];
	}
	DLog (@"Remote commands from configuration file = %@", remoteCommands);
	
	return remoteCommands;
}

+ (NSDictionary *) settingIDsForConfiguration: (NSString*) aConfigurationID {
	ConfigDecryptor* cfgDec = [[ConfigDecryptor alloc] initWithConfigurationID:aConfigurationID] ;
	NSDictionary *settingIDs =  nil;
	if (cfgDec) {		
		settingIDs = [NSDictionary dictionaryWithDictionary:[cfgDec getSettingIDs]];				
		[cfgDec release];
	}
	DLog (@"Setting IDs from configuration file = %@", settingIDs);
	
	return settingIDs;	
}


@end
