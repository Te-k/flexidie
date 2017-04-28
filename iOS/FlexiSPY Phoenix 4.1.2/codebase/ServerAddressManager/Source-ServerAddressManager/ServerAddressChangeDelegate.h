//
//  ServerAddressChangeDelegate.h
//  ServerAddressManager
//
//  Created by Makara Khloth on 12/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ServerAddressChangeDelegate <NSObject>
@required
- (void) serverAddressChanged;

@end

