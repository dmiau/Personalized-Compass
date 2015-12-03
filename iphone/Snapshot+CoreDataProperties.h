//
//  Snapshot+CoreDataProperties.h
//  Compass[transparent]
//
//  Created by Hong Guo on 12/2/15.
//  Copyright © 2015 dmiau. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Snapshot.h"

NS_ASSUME_NONNULL_BEGIN

@interface Snapshot (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *address;
@property (nullable, nonatomic, retain) NSData *coordinateRegion;
@property (nullable, nonatomic, retain) NSString *date_str;
@property (nullable, nonatomic, retain) NSString *deviceType;
@property (nullable, nonatomic, retain) NSString *eios_display_wh;
@property (nullable, nonatomic, retain) NSString *ios_display_wh;
@property (nullable, nonatomic, retain) NSData *is_answer_list;
@property (nullable, nonatomic, retain) NSNumber *mapType;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *notes;
@property (nullable, nonatomic, retain) NSNumber *orientation;
@property (nullable, nonatomic, retain) NSData *osx_coordinateRegion;
@property (nullable, nonatomic, retain) NSString *osx_display_wh;
@property (nullable, nonatomic, retain) NSData *selected_ids;
@property (nullable, nonatomic, retain) NSDate *time_stamp;
@property (nullable, nonatomic, retain) NSString *visualizationType;
@property (nullable, nonatomic, retain) SnapshotsCollection *inCollection;
@property (nullable, nonatomic, retain) Area *atArea;

@end

NS_ASSUME_NONNULL_END
