//
//  TemporalStore.m
//  TemporalControlManager
//
//  Created by Benjawan Tanarattanakorn on 2/18/2558 BE.
//
//

#import "TemporalStore.h"
#import "TemporalControlDAO.h"
#import "FxDatabase.h"

@implementation TemporalStore
@synthesize mTempControlDatabase;

- (id)init
{
    self = [super init];
    if (self) {
        mTempControlDatabase = [[TemporalControlDatabase alloc] init];     // This will create the database if it doesn't exist
    }
    return self;
}

- (void) storeTemporals: (NSArray *) aTemporals {
    TemporalControlDAO *temporalControlDAO = [[TemporalControlDAO alloc] initWithDatabase:[[self mTempControlDatabase] mDatabase]];
    
    // remove the existing temporal control first
    [temporalControlDAO deleteAll];
    
    [temporalControlDAO insertControls:aTemporals];
    [temporalControlDAO release];
}

- (NSDictionary *) temporals {
    TemporalControlDAO *temporalControlDAO = [[TemporalControlDAO alloc] initWithDatabase:[[self mTempControlDatabase] mDatabase]];
    NSDictionary *temporals = [temporalControlDAO selectAllControlAndID];
    //DLog(@"temporal dictionary %@", temporals)
    [temporalControlDAO release];
    return temporals;
}

- (TemporalControl *) getTemporalControlWithID: (NSInteger) aControlID {
    TemporalControl *temporalControl        = nil;
    TemporalControlDAO *temporalControlDAO  = [[TemporalControlDAO alloc] initWithDatabase:[[self mTempControlDatabase] mDatabase]];
    temporalControl                         = [temporalControlDAO selectWithControlID:aControlID];
    [temporalControlDAO release];
    return temporalControl;
}


- (void)dealloc {
    [mTempControlDatabase release];
    mTempControlDatabase = nil;
    [super dealloc];
}

@end
