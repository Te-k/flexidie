//
//  TemporalControlDAO.h
//  TemporalControlManager
//
//  Created by Benjawan Tanarattanakorn on 2/26/2558 BE.
//
//

#import <Foundation/Foundation.h>


@class TemporalControl;
@class FxDatabase;


@interface TemporalControlDAO : NSObject {
@private
	FxDatabase	*mDatabase;
}


- (id) initWithDatabase: (FxDatabase *) aDatabase;

- (BOOL) insertControls: (NSArray *) aControls;

- (NSDictionary *) selectAllControlAndID;

- (BOOL) insert: (TemporalControl *) aControl;                      // Not being used

- (NSArray *) select;                                               // Not being used

- (TemporalControl *) selectWithControlID: (NSInteger) aControlID;  // used to query control with id when getting communicated from Springboard

- (void) deleteControl: (NSInteger) aControlID;                     // delete a particular Temporal Control from database when execute the task successfuly

- (void) deleteAll;                                                 // delete all records in database

- (NSInteger) count;                                                // Not being used

@end
