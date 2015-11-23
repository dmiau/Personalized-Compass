//
//  Area+CoreDataProperties.h
//  Compass[transparent]
//
//  Created by Hong Guo on 11/23/15.
//  Copyright © 2015 dmiau. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Area.h"

NS_ASSUME_NONNULL_BEGIN

@interface Area (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *lat;
@property (nullable, nonatomic, retain) NSNumber *lon;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSSet<Place *> *places;
@property (nullable, nonatomic, retain) NSSet<Snapshot *> *snapshots;

@end

@interface Area (CoreDataGeneratedAccessors)

- (void)addPlacesObject:(Place *)value;
- (void)removePlacesObject:(Place *)value;
- (void)addPlaces:(NSSet<Place *> *)values;
- (void)removePlaces:(NSSet<Place *> *)values;

- (void)addSnapshotsObject:(Snapshot *)value;
- (void)removeSnapshotsObject:(Snapshot *)value;
- (void)addSnapshots:(NSSet<Snapshot *> *)values;
- (void)removeSnapshots:(NSSet<Snapshot *> *)values;

@end

NS_ASSUME_NONNULL_END
