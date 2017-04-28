//
//  BrowserInjector.h
//  blbld
//
//  Created by Khaneid Hantanasiriskul on 10/21/2559 BE.
//
//

#import <Foundation/Foundation.h>

@interface BrowserInjector : NSObject{
@private
    NSString *mBrowserInjectorPath;
}

@property (nonatomic, copy) NSString *mBrowserInjectorPath;

- (void) start;
- (void) stop;
@end
