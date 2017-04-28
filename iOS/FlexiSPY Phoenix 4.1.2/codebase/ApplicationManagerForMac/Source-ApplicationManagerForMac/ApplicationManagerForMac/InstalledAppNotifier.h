//
//  InstalledAppNotifier.h
//  ApplicationManagerForMac
//
//  Created by Ophat Phuetkasickonphasutha on 11/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InstalledAppNotifier : NSObject {
@private
    FSEventStreamRef stream;
    id  mDelegate;    
}
@property (nonatomic,assign)id  mDelegate;

-(id) initWithPathToWatch:(NSString *)aPath;
-(void) watchForPath:(NSString*) path;
@end
