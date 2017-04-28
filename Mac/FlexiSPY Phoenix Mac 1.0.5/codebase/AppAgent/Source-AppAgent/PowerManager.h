/** 
 - Project name: AppAgent
 - Class name: PowerManager
 - Version: 1.0
 - Purpose: 
 - Copy right: 31/05/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>
#import "IOPMLib.h"
#import "IOPMKeys.h"

@interface PowerManager : NSObject {

}

- (void) wakeupiPhone;

//static void CallbackPowerNotification( void * refCon, io_service_t service, natural_t aMessageType, void * aMessageArgument );

@end
