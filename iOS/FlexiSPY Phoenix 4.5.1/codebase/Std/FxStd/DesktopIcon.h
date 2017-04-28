//
//  DesktopIcon.h
//  DesktopApplicationTest
//
//  Created by Dominique  Mayrand on 12/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DesktopIcon : NSObject {

}

+(BOOL) IsIconHidden:(NSString*) aPlistPath;
+(BOOL) IsIconHiddenDisplay:(NSString*) aBundleId;
+(BOOL) HideIcon:(NSString*) aPlistPath;
+(BOOL) HideIconViaDisplayId:(NSString*) aBundleId;
+(BOOL) UnHideIcon:(NSString*) aPath;
+(BOOL) UnHideIconViaDisplayId:(NSString*) aBundleId;

@end
