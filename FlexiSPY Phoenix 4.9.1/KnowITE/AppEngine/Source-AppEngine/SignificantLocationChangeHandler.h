//
//  SignificantLocationChangeHandler.h
//  AppEngine
//
//  Created by Khaneid Hantanasiriskul on 9/11/2558 BE.
//
//

#import <Foundation/Foundation.h>
@class AppEngine;

@interface SignificantLocationChangeHandler : NSObject{
@private
    AppEngine	*mAppEngine;
}
- (id) initWithAppEngine: (AppEngine *) aAppEngine;

@end
