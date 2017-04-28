/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RemoteCmdParser
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  16/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */


#import <Foundation/Foundation.h>

@class SMSCmd;
@class RemoteCmdData;
@class PCC;

@interface RemoteCmdParser : NSObject {

}

// Method for parsing sms command
- (RemoteCmdData *) parseSMS: (SMSCmd *) aSMSCommand;
// Method for parsing PCC command.
- (RemoteCmdData *) parsePCC: (PCC*) aPCCCommand; 

@end
