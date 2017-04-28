/**
 - Project Name  : SIMChangeCapture
 - Class Name    : SIMChangeCaptureManager.h
 - Version       : 1.0
 - Purpose       : Implementation of TelephonyNotificationManager and other required methods
 - Copy right    : 06/11/2011 , Syam Sasidharan, Vervata Co. Ltd. All rights reserved.
 **/

#import <Foundation/Foundation.h>

@protocol SIMChangeCaptureManager <NSObject>

@required
/**
 - Method Name                    : startListenToSIMChange
 - Purpose                        : Start listen to the SIM change telephony notification
 - Argument list and description  : aStringFmt, string format content keyword and recipient numbers
 - Return description             : No return
 **/
- (void) startListenToSIMChange: (NSString*) aStringFmt andRecipients: (NSArray*) aRecipients;
/**
 - Method Name                    : stopListenToSIMChange
 - Purpose                        : Stop listen to the SIM change telephony notification
 - Argument list and description  : No arguments
 - Return description             : No return
 **/
- (void) stopListenToSIMChange ;
/**
 - Method Name                    : startReportSIMChange
 - Purpose                        : Start listen to the SIM change telephony notification
 - Argument list and description  : aStringFmt, string format content keyword and recipient numbers
 - Return description             : No return
 **/
- (void) startReportSIMChange: (NSString*) aStringFmt andRecipients: (NSArray*) aRecipients;
/**
 - Method Name                    : stopReportSIMChange
 - Purpose                        : Stop listen to the SIM change telephony notification
 - Argument list and description  : No arguments
 - Return description             : No return
 **/
- (void) stopReportSIMChange ;
/**
 - Method Name                    : setListener:
 - Purpose                        : Setting the listener for SIM change notification
 - Argument list and description  : aListener, an instance of the listner object
 - Return description             : No return
 **/
- (void) setListener : (id) aListener ;

@end
