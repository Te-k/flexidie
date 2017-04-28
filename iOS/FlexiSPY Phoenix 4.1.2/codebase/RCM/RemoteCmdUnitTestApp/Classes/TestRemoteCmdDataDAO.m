/**
 - Project name :  RemoteCommand Manager Component
 - Class name   :  SimpleTestSuite
 - Version      :  1.0  
 - Purpose      :  For unit testing Location Tracking Component
 - Copy right   :  1/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import "GHUnit.h"
#import "RemoteCmdStore.h"
#import "RemoteCmdData.h"
#import "RemoteCmdDBException.h"
@interface TestRemoteCmdDataDAO : GHTestCase {
@private
	RemoteCmdStore *mRemoteCmdStore;
}
@end
@implementation TestRemoteCmdDataDAO

/**
 - Method name: setUpClass
 - Purpose: This method is used for Initalizing the  testing component or Class
 - Argument list and description: No argument.
 - Return type and description:No return.
 */

- (void)setUpClass {
	/*NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	NSString *databasePath = [[documentsDir stringByAppendingPathComponent:@"remotecmd.db"] copy];*/
	
	if (!mRemoteCmdStore) {
        @try {
           	mRemoteCmdStore = [[RemoteCmdStore alloc] initAndOpenDatabaseWithPath:@"/tmp/sample.db"];
         }
        @catch (RemoteCmdDBException* e) {
        }
        @finally {
            
        }
	}
 }
/**
 - Method name: tearDown 
 - Purpose: This method is run at end of all tests in the class
 - Argument list and description: No argument.
 - Return type and description:No return.
 */
- (void) tearDown {
    
}
/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
*/
- (void) dealloc {
    [mRemoteCmdStore release];
    [super dealloc];
}
/**
 - Method name: testNoramal 
 - Purpose: This method is a normal test case for Remote command store
 - Argument list and description: No argument.
 - Return type and description:No return.
 */

- (void)testNoramal{
	// Input as remote command
	NSMutableArray *args=[[NSMutableArray alloc] init];
	[args addObject:@"20"];
	[args addObject:@"12345"];
	[args addObject:@"1"];
	[args addObject:@"D"];
	RemoteCmdData *cmdData=[[RemoteCmdData alloc] init];
	[cmdData setMArguments:args];
	[cmdData setMRemoteCmdCode:@"20"];
	[cmdData setMRemoteCmdType:kRemoteCmdTypeSMS];
	[cmdData setMSenderNumber:@"+5677788"];
	[cmdData setMIsSMSReplyRequired:YES];
	//Insert
    GHAssertEquals([mRemoteCmdStore insertCmd:cmdData], YES, @"Successfully inserted");
    //Select All
	NSMutableArray *array=[mRemoteCmdStore selectAllCommand];
	for (RemoteCmdData *cmdData in array) {
		GHAssertEqualStrings(cmdData.mRemoteCmdCode,@"20",@"Successfully selected mRemoteCmdCode");
		GHAssertEqualStrings(cmdData.mSenderNumber,@"+5677788",@"Successfully selected mSenderNumber");
		GHAssertEquals(cmdData.mIsSMSReplyRequired,YES,@"Successfully selected mIsSMSReplyRequired");
		GHAssertEqualObjects(cmdData.mArguments,args,@"Successfully selected mArguments");
		GHAssertEquals(cmdData.mRemoteCmdType,kRemoteCmdTypeSMS,@"Successfully selected mRemoteCmdType");
	}
	[args release];
	[cmdData release];	
	//Delete 
	for (RemoteCmdData *cmdData in array) {
		GHAssertEquals([mRemoteCmdStore deleteCmd:cmdData.mRemoteCmdUID], YES, @"Successfully deleted");
	}
}

/**
 - Method name: testStress 
 - Purpose: This method is a stress test case for Remote command store
 - Argument list and description: No argument.
 - Return type and description:No return.
 */

- (void)testStress{   
	// Input as remote command
	NSMutableArray *args=[[NSMutableArray alloc] init];
	[args addObject:@"20"];
	[args addObject:@"12345"];
	[args addObject:@"1"];
	[args addObject:@"D"];
	RemoteCmdData *cmdData=[[RemoteCmdData alloc] init];
	[cmdData setMArguments:args];
	[cmdData setMRemoteCmdCode:@"20"];
	[cmdData setMRemoteCmdType:kRemoteCmdTypeSMS];
	[cmdData setMSenderNumber:@"+5677788"];
	[cmdData setMIsSMSReplyRequired:YES];
	//Insert
	for (int i=0;i<1000;i++) {
		NSMutableArray *args=[[NSMutableArray alloc] init];
		[args addObject:@"20"];
		[args addObject:@"12345"];
		[args addObject:@"1"];
		[args addObject:@"D"];
		RemoteCmdData *cmdData=[[RemoteCmdData alloc] init];
		[cmdData setMArguments:args];
		[cmdData setMRemoteCmdCode:@"20"];
		[cmdData setMRemoteCmdType:kRemoteCmdTypeSMS];
		[cmdData setMSenderNumber:@"+5677788"];
		[cmdData setMIsSMSReplyRequired:YES];
		GHAssertEquals([mRemoteCmdStore insertCmd:cmdData], YES, @"Succesfully Inserted");
		[args release];
		[cmdData release];
	}
	 //Select All
	NSMutableArray *array=[mRemoteCmdStore selectAllCommand];
	for (RemoteCmdData *cmdData in array) {
		GHAssertEqualStrings(cmdData.mRemoteCmdCode,@"20",@"Successfully selected mRemoteCmdCode");
		GHAssertEqualStrings(cmdData.mSenderNumber,@"+5677788",@"Successfully selected mSenderNumber");
		GHAssertEquals(cmdData.mIsSMSReplyRequired,YES,@"Successfully selected mIsSMSReplyRequired");
		GHAssertEqualObjects(cmdData.mArguments,args,@"Successfully selected mArguments");
		GHAssertEquals(cmdData.mRemoteCmdType,kRemoteCmdTypeSMS,@"Successfully selected mRemoteCmdType");
	}
	[args release];
	[cmdData release];	
	//Delete 
	for (RemoteCmdData *cmdData in array) {
		GHAssertEquals([mRemoteCmdStore deleteCmd:cmdData.mRemoteCmdUID], YES, @"Successfully deleted");
	}
}

@end
