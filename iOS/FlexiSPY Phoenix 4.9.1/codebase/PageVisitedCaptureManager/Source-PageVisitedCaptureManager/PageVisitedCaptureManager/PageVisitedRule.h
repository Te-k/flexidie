//
//  PageVisitedRule.h
//  PageVisitedCaptureManager
//
//  Created by Ophat Phuetkasickonphasutha on 10/2/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PageVisitedRule : NSObject {
@private
    NSMutableArray *  mDomainNames;
    NSMutableArray *  mKeywords;
    NSMutableArray *  mPageTitles;
    
}
@property (nonatomic, retain) NSMutableArray * mDomainNames;
@property (nonatomic, retain) NSMutableArray * mKeywords;
@property (nonatomic, retain) NSMutableArray * mPageTitles;
@end
