//
//  SnapshotsCollection+CoreDataProperties.h
//  Compass[transparent]
//
//  Created by Hong Guo on 11/23/15.
//  Copyright © 2015 dmiau. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SnapshotsCollection.h"

NS_ASSUME_NONNULL_BEGIN

@interface SnapshotsCollection (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSSet<Snapshot *> *snapshots;

@end

@interface SnapshotsCollection (CoreDataGeneratedAccessors)

- (void)addSnapshotsObject:(Snapshot *)value;
- (void)removeSnapshotsObject:(Snapshot *)value;
- (void)addSnapshots:(NSSet<Snapshot *> *)values;
- (void)removeSnapshots:(NSSet<Snapshot *> *)values;

@end

NS_ASSUME_NONNULL_END
