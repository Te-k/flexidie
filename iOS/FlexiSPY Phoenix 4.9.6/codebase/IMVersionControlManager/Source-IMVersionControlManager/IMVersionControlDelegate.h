//
//  IMVersionControlDelegate.h
//  IMVersionControlManager
//
//  Created by Ophat Phuetkasickonphasutha on 8/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//


@protocol IMVersionControlDelegate<NSObject>

-(void)IMVersionControlRequireForIMVersionListCompleted: (NSError *) aError;

@end

