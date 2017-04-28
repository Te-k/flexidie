//
//  WebPageVisitedRule.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 10/22/13.
//  Copyright (c) 2013 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebPageVisitedRule : NSObject {
@private
    NSArray *mDomainNames;
    NSArray *mKeywords;
    NSArray *mPageTitles;
}

@property (nonatomic, retain) NSArray *mDomainNames;
@property (nonatomic, retain) NSArray *mKeywords;
@property (nonatomic, retain) NSArray *mPageTitles;

@end
