//
//  SnapShotRule.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 10/22/13.
//  Copyright (c) 2013 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WebPageVisitedRule;

@interface SnapShotRule : NSObject {
@private
    NSArray             *mKeyStrokeRules; // KeyStrokeRule
    //WebPageVisitedRule  *mWebPageVisitedRule;
}

@property (nonatomic, retain) NSArray *mKeyStrokeRules;
//@property (nonatomic, retain) WebPageVisitedRule *mWebPageVisitedRule;

@end
