//
//  FeatureIDFactory.h
//  ConfigurationManager
//
//  Created by Makara Khloth on 11/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeatureIDFactory : NSObject {

}

+ (NSArray*) featuresForConfiguration:(NSString*)configurationID;

@end
