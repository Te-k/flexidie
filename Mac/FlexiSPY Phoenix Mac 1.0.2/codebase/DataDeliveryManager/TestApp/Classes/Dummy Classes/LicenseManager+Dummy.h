//
//  LicenseManager+Dummy.h
//  TestApp
//
//  Created by Makara on 12/24/14.
//
//

#import <Foundation/Foundation.h>

@interface LicenseManager : NSObject {
@private
    NSString *mActivationCode;
    NSInteger mConfigID;
}

@property (nonatomic, copy) NSString *mActivationCode;
@property (nonatomic, assign) NSInteger mConfigID;

- (NSInteger) getConfiguration;
- (NSString *) getActivationCode;

@end
