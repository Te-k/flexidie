//
//  TestConfigurationManager.m
//  ConfigurationManagerTestAppForMac
//
//  Created by Benjawan Tanarattanakorn on 10/15/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "TestConfigurationManager.h"

#import "ConfigurationManagerImpl.h"
#import "Configuration.h"

#import "AppDelegate.h"



@interface TestConfigurationManager (private)
-(void) updateForConfiguration:(NSInteger) configID;
@end

@implementation TestConfigurationManager

-(void) updateForConfiguration:(NSInteger) configID
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
    NSScrollView * featureView = [(AppDelegate *)[[NSApplication sharedApplication] delegate] featureTextView];
    NSTextView *featureTextView = featureView.documentView;
    [featureTextView setString:@""];
     
     NSScrollView * remoteCommandView = [(AppDelegate *)[[NSApplication sharedApplication] delegate] remoteCommandTextView];
     NSTextView *remoteCmdTextView = remoteCommandView.documentView;
    [remoteCmdTextView setString:@""];    
    
	//[featuresView setText:@""];
	//[commandsView setText:@""];
	
	ConfigurationManagerImpl *cfgManager = [[ConfigurationManagerImpl alloc] init];

	[cfgManager updateConfigurationID:configID];
	//[cfgManager release];
	//return;
	if(cfgManager)
	{
		Configuration *cfg = [cfgManager configuration];
		
		NSLog(@"&&&&&&&&&&&&&&&	Check supported feature	&&&&&&&&&&&&&&&	");
		/*
		 * Check supported feature
		 */
		for(int i = 0; i < 100; i++)
		{
			FeatureID fid = i;
			
			if([cfgManager isSupportedFeature:fid]){
				NSLog(@"supported feature id %d", fid);
			}else{
				NSLog(@"not supported %d", fid);
			}
		}
		
		NSLog(@"&&&&&&&&&&&&&&&	Check supported setting id for remote command 43	&&&&&&&&&&&&&&&	");
		
		/*
		 * Check supported setting id
		 */
		NSMutableArray *supportedSettingIDs = [[NSMutableArray alloc] init];
		for(int i = 0; i < 100; i++)
		{
			NSInteger sid = i;
			
			if ([cfgManager isSupportedSettingID:sid remoteCmdID:@"43"]){
				NSLog(@"supported setting id %ld", sid);
				[supportedSettingIDs addObject:[NSNumber numberWithInteger:sid]];
			}else{
				NSLog(@"not supported %ld", sid);
			}
		}		
		NSLog(@"*********** suppoerted feature id for 42 command ***** %@", supportedSettingIDs);
        
		NSLog(@"&&&&&&&&&&&&&&&	Check supported setting id for remote command 92	&&&&&&&&&&&&&&&	");
		
		NSMutableArray *supportedSettingIDs2 = [[NSMutableArray alloc] init];
		for(int i = 0; i < 100; i++)
		{
			NSInteger sid = i;
			
			if ([cfgManager isSupportedSettingID:sid remoteCmdID:@"92"]){
				NSLog(@"supported setting id %ld", sid);
				[supportedSettingIDs2 addObject:[NSNumber numberWithInteger:sid]];
			}else{
				NSLog(@"not supported %ld", sid);
			}
		}		
		
		NSLog(@"*********** suppoerted feature id for 92 command ***** %@", supportedSettingIDs2);
		
		NSArray* featuresArray = cfg.mSupportedFeatures;
		NSArray* commandsArray = cfg.mSupportedRemoteCmdCodes;
		
		if(featuresArray){
			NSInteger count = [featuresArray count];
			NSString *string = @"";
			for(int i = 0; i < count; i++)
			{
				NSNumber* feat = (NSNumber*) [featuresArray objectAtIndex:i];
				string = [string stringByAppendingFormat:@"%d\n", [feat intValue]]; 
			}
			//[featuresView setText:string];
            [featureTextView setString:string];
		}
		
		if(commandsArray){
			NSInteger  count = [commandsArray count];
			NSString* string = @"";
			for(int i = 0; i < count; i++)
			{
				NSString* feat = (NSString*) [commandsArray objectAtIndex:i];
				string = [string stringByAppendingFormat:@"%@\n", feat]; 
			}
			//[commandsView setText:string];
            [remoteCmdTextView setString:string];
		}
		[cfgManager release];
		
	}
	[pool drain];
    
}

@end
