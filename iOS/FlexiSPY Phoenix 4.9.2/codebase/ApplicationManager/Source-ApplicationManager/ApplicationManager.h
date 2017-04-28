//
//  ApplicationManager.h
//  ApplicationManager
//
//  Created by Benjawan Tanarattanakorn on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApplicationDelegate.h"


@protocol ApplicationManager <NSObject>
@required
/**
 - Method name:				deliverInstalledApplication:
 - Purpose:					This method is used to request DDM to deliver installed application to server
 - Argument list and description:	id <InstalledApplicationDelegate> aDelegate
 - Return type and description:		YES if success and caller should wait for call back otherwise NO and caller must not wait for call back
 */
- (BOOL) deliverInstalledApplication: (id <InstalledApplicationDelegate>) aDelegate;
/**
 - Method name:				deliverRunningApplication:
 - Purpose:					This method is used to request DDM to deliver running application to server
 - Argument list and description:	id <RunningApplicationDelegate> aDelegate
 - Return type and description:		YES if success and caller should wait for call back otherwise NO and caller must not wait for call back
 */
- (BOOL) deliverRunningApplication: (id <RunningApplicationDelegate>) aDelegate;
@end


