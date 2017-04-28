/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RemoteCmdManager
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  17/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

@class SMSCmd, PushCmd;
@protocol RemoteCmdManager <NSObject>
@required

/**
 - Method name: processSMSCommand
 - Purpose:This method is used to process the SMS Command
 - Argument list and description: aSMSCommand (SMSCmd)
 - Return description: No return type
*/

- (void) processSMSCommand: (SMSCmd*) aSMSCommand;

/**
 - Method name: processPCCCommand
 - Purpose:This method is used to process the PCC Command
 - Argument list and description: aPCCCommand (NSArray)
 - Return description: No return type
*/

- (void) processPCCCommand: (NSArray*) aPCCCommand;

/**
 - Method name: processPushCommand
 - Purpose:This method is used to process the Push Command
 - Argument list and description: aPushCommand (PushCmd)
 - Return description: No return type
 */

- (void) processPushCommand: (PushCmd *) aPushCommand;

@end
