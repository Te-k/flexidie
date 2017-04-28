//
//  StringUtils.h
//  FxStd
//
//  Created by Makara Khloth on 10/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface StringUtils : NSObject {

}

+ (NSString *) removePrivateUnicodeSymbols: (NSString *) aInputText;
+ (BOOL) scanString: (NSString *) aString withKeyword: (NSString *) aKeyword;

@end
