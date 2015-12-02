//
//  CoreDataViewController.m
//  Compass[transparent]
//
//  Created by Hong Guo on 11/28/15.
//  Copyright © 2015 dmiau. All rights reserved.
//

#import "CoreDataViewController.h"
#import "AppDelegate.h"
#import "xmlParser.h"
#import "Area.h"
#import "Place.h"
#import "snapshotParser.h"
#import "SnapshotsCollection.h"
#import "Snapshot.h"

@implementation CoreDataViewController

@synthesize model;

//-------------------
// Initialization
//-------------------
- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.model = compassMdl::shareCompassMdl();
    }
    return self;
}

//--------------
// Data source selector
//--------------
- (IBAction)toggleDataSource:(UISegmentedControl *)sender {
    
    switch ([sender selectedSegmentIndex]) {
        case 0:
            model->filesys_type = IOS_DOC;
            break;
        case 1:
            if (!model->dbFilesystem.isReady){
                [model->dbFilesystem linkDropbox:(UIViewController*)self];
            }
            if ([model->dbFilesystem.db_filesystem completedFirstSync]){
                // reload
                model->filesys_type = DROPBOX;
            }else{
                self.dataSource.selectedSegmentIndex = 0;
            }
            break;
        default:
            break;
    }
}

- (IBAction)resetCoreData:(id)sender {
    AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [self deleteAllObjects:@"Place" in:app.managedObjectContext];
    [self deleteAllObjects:@"Area" in:app.managedObjectContext];
    [self deleteAllObjects:@"Snapshot" in:app.managedObjectContext];
    [self deleteAllObjects:@"SnapshotsCollection" in:app.managedObjectContext];
    self.model->data_array.clear();
    self.model->snapshot_array.clear();
}


- (IBAction)importData:(id)sender {
    NSArray *dirFiles;
    dirFiles = [self.model->docFilesystem listFiles];
    NSArray *snapshot_file_array = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self CONTAINS '.snapshot'"]];
    dirFiles = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (self CONTAINS 'snapshot')"]];
    dirFiles = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (self CONTAINS 'history')"]];

    NSArray *kml_files = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.kml'"]];
    AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    for (int i = 0; i < [kml_files count]; i++) {
        NSString *filename = kml_files[i];
        NSLog(@"%@", filename);
        readLocationKml(self.model, filename);
        Area *area = [NSEntityDescription insertNewObjectForEntityForName:@"Area" inManagedObjectContext:app.managedObjectContext];
        area.name = [filename componentsSeparatedByString:@"."][0];
        for (int j = 0; j < self.model->data_array.size(); j++) {
            Place *p1 = [NSEntityDescription
                         insertNewObjectForEntityForName:@"Place"
                         inManagedObjectContext:app.managedObjectContext];

            p1.name = [NSString stringWithCString:self.model->data_array[j].name.c_str() encoding:[NSString defaultCStringEncoding]];
            p1.lon = [NSNumber numberWithDouble:self.model->data_array[j].longitude];
            p1.lat = [NSNumber numberWithDouble:self.model->data_array[j].latitude];
            NSLog(@"%@", p1.name);
            [area addPlacesObject:p1];
        }
    }
    NSError *error;
    if (![app.managedObjectContext save:&error]){
        NSLog(@"Sorry, an error occurred while saving: %@", [error localizedDescription]);
    }
    
//  load into core data
    for (int i = 0; i < [snapshot_file_array count]; i++) {
        [self loadSnapshotWithName:snapshot_file_array[i]];
        SnapshotsCollection *collection = [NSEntityDescription insertNewObjectForEntityForName:@"SnapshotsCollection" inManagedObjectContext:app.managedObjectContext];
        collection.name = [snapshot_file_array[i] componentsSeparatedByString:@"."][0];
        for (int j = 0; j < self.model->snapshot_array.size(); j++) {
            snapshot s = self.model->snapshot_array[j];
            Snapshot *snapshot = [NSEntityDescription insertNewObjectForEntityForName:@"Snapshot" inManagedObjectContext:app.managedObjectContext];

            snapshot.coordinateRegion = [NSData dataWithBytes:&s.coordinateRegion length:sizeof(s.coordinateRegion)];

            NSLog(@"FUNNNNNN");
            NSLog(@"FUN before %f", s.coordinateRegion.center.latitude);
            NSLog(@"FUN before %f", s.coordinateRegion.center.longitude);

            MKCoordinateRegion region;
            [snapshot.coordinateRegion getBytes:&region length:sizeof(region)];

            NSLog(@"FUN after %f", region.center.latitude);
            NSLog(@"FUN after %f", region.center.longitude);

            snapshot.osx_coordinateRegion =[NSData dataWithBytes:&s.osx_coordinateRegion  length:sizeof(s.osx_coordinateRegion)];

            snapshot.orientation = [NSNumber numberWithDouble:s.orientation];

            snapshot.deviceType = [NSString stringWithCString:toString(s.deviceType).c_str() encoding:[NSString defaultCStringEncoding]];

            snapshot.visualizationType = [NSString stringWithCString:toString(s.visualizationType).c_str() encoding:[NSString defaultCStringEncoding]];

            snapshot.name = s.name;
            snapshot.mapType = [NSNumber numberWithInteger: (NSUInteger)s.mapType];

            snapshot.time_stamp = s.time_stamp;
            snapshot.date_str = s.date_str;
            snapshot.notes = s.notes;
            snapshot.address = s.address;
            NSLog(@"%@", s.address);

            NSArray *temp_selected_ids = [self convertVectorToArray:s.selected_ids];
            snapshot.selected_ids = [NSKeyedArchiver archivedDataWithRootObject:temp_selected_ids];
            NSArray *temp_is_answer_list = [self convertVectorToArray:s.is_answer_list];
            snapshot.is_answer_list = [NSKeyedArchiver archivedDataWithRootObject:temp_is_answer_list];

            snapshot.ios_display_wh = NSStringFromCGPoint(s.ios_display_wh);
            snapshot.eios_display_wh = NSStringFromCGPoint(s.eios_display_wh);
            snapshot.osx_display_wh = NSStringFromCGPoint(s.osx_display_wh);

            [collection addSnapshotsObject:snapshot];

            NSError *error;
            if (![app.managedObjectContext save:&error]){
                NSLog(@"Sorry, an error occurred while saving: %@", [error localizedDescription]);
            }

        }
    }
}

- (IBAction)exportData:(id)sender {
    // get all areas
    AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Area"];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Area" inManagedObjectContext:app.managedObjectContext];
    fetchRequest.resultType = NSDictionaryResultType;
    fetchRequest.propertiesToFetch = [NSArray arrayWithObject:[[entity propertiesByName] objectForKey:@"name"]];
    fetchRequest.returnsDistinctResults = YES;
    NSArray *areasDic = [app.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    NSLog(@"FUN init area %@", areasDic);
    NSMutableArray *temp_area = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < [areasDic count]; i++) {
        [temp_area addObject:areasDic[i][@"name"]];
    }
    _area = temp_area;
    
    // for each area fetch all its places
    for (int i = 0; i < [_area count]; i++) {
        self.model->data_array.clear();
        std::vector<data> locationData;
        // Fetch the stored data
        
        NSError *error;
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Area"];
        NSString *initData= _area[i];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name == %@", initData]];
        
        NSArray *requestResults = [app.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if ([requestResults count]) {
            Area *area = requestResults[0];
            NSSet *places = [area valueForKey:@"places"];
            for (Place *place in places) {
                data data;
                data.latitude = [place.lat floatValue];
                data.longitude = [place.lon floatValue];
                data.name = [place.name UTF8String];
                CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(data.latitude, data.longitude);
                data.annotation.coordinate = coor;
                locationData.push_back(data);
            }
            self.model->data_array =  locationData;
            
            self.model->updateMdl();
            self.model->initTextureArray();
        }
        NSString *filename = [_area[i] stringByAppendingString:@".kml"];
        
        // save to kml file
        [self saveKMLWithFilename:filename];
    }
    
    NSFetchRequest *snapFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SnapshotsCollection"];
    NSEntityDescription *snapEntity = [NSEntityDescription entityForName:@"SnapshotsCollection" inManagedObjectContext:app.managedObjectContext];
    snapFetchRequest.resultType = NSDictionaryResultType;
    snapFetchRequest.propertiesToFetch = [NSArray arrayWithObject:[[snapEntity propertiesByName] objectForKey:@"name"]];
    snapFetchRequest.returnsDistinctResults = YES;
    NSError *error;
    NSArray *areasDicSnap = [app.managedObjectContext executeFetchRequest:snapFetchRequest error:&error];
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < [areasDicSnap count]; i++) {
        if (areasDicSnap[i][@"name"]) {
            [temp addObject:areasDicSnap[i][@"name"]];
        }
    }
    NSLog(@"FUN snapshot %@", areasDicSnap);
    _collections = temp;
    
    for (int i = 0; i < [_collections count]; i++) {
        self.model->snapshot_array.clear();
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"SnapshotsCollection"];
        [request setPredicate:[NSPredicate predicateWithFormat:@"name = %@", _collections[i]]];
        NSArray *result = [app.managedObjectContext executeFetchRequest:request error:&error];
        if ([result count]) {
            SnapshotsCollection *collection = result[0];
            NSSet *snapshots = [collection valueForKey:@"snapshots"];
            for (Snapshot *s in snapshots) {
                snapshot oneShot;
                MKCoordinateRegion region;
                [s.coordinateRegion getBytes:&region length:sizeof(region)];
                oneShot.coordinateRegion = region;
                [s.osx_coordinateRegion getBytes:&region length:sizeof(region)];
                oneShot.osx_coordinateRegion = region;
                
                oneShot.orientation = [s.orientation doubleValue];
                oneShot.kmlFilename = s.inCollection.name;
                
                string *typeString = new std::string([s.deviceType UTF8String]);
                
                oneShot.deviceType = toDeviceType(*typeString);
                oneShot.visualizationType = NSStringToVisualizationType(s.visualizationType);
                
                oneShot.name = s.name;
                oneShot.mapType = (MKMapType)[s.mapType intValue];
                oneShot.time_stamp = s.time_stamp;
                oneShot.date_str = s.date_str;
                oneShot.notes = s.notes;
                oneShot.address = s.address;
                NSArray *temp_array = [NSKeyedUnarchiver unarchiveObjectWithData:s.selected_ids];
                oneShot.selected_ids = [self convertNSArrayToVector:temp_array];
                NSArray *temp_is_answer_list = [NSKeyedUnarchiver unarchiveObjectWithData:s.is_answer_list];
                oneShot.is_answer_list = [self convertNSArrayToVector:temp_is_answer_list];
                
                oneShot.ios_display_wh = CGPointFromString(s.ios_display_wh);
                oneShot.eios_display_wh = CGPointFromString(s.eios_display_wh);
                oneShot.osx_display_wh = CGPointFromString(s.osx_display_wh);
                self.model->snapshot_array.push_back(oneShot);
            }
        }
        NSString *snap_filename = [_collections[i] stringByAppendingString:@".snapshot"];
        [self saveSnapshotWithFilename:snap_filename];
    }
    
}


- (void) deleteAllObjects: (NSString *) entityDescription in: (NSManagedObjectContext *) managedObjectContext {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setIncludesPropertyValues:NO];

    NSError *error;
    NSArray *items = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *managedObject in items) {
        [managedObjectContext deleteObject:managedObject];
        NSLog(@"%@ object deleted",entityDescription);
    }
    if (![managedObjectContext save:&error]) {
        NSLog(@"Error deleting %@ - error:%@",entityDescription,error);
    }
    
}


- (void)loadSnapshotWithName: (NSString*) filename{
    NSString* filename_cache = self.model->snapshot_filename;
    self.model->snapshot_filename = filename;
    if (readSnapshotKml(self.model)!= EXIT_SUCCESS){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"File System Error"
                                                        message:@"Fail to read the snapshot file."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        self.model->snapshot_filename = filename_cache;
        [alert show];
    }
}


- (NSArray *) convertVectorToArray: (std::vector<int>)vec {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < vec.size(); i++) {
        NSNumber *temp = [NSNumber numberWithInteger:vec[i]];
        [array addObject:temp];
    }
    return array;
}


- (BOOL) saveKMLWithFilename:(NSString*) filename{
    bool hasError = false;
    NSString *content = genKMLString(self.model->data_array);

    if (self.model->filesys_type == DROPBOX){
        if (![self.model->dbFilesystem
              writeFileWithName:filename Content:content])
        {
            hasError = true;
        }
    }else{
        if (![self.model->docFilesystem
              writeFileWithName:filename Content:content])
        {
            hasError = true;
        }
    }

    if (hasError){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"File System Error"
                                                        message:@"Fail to save the file."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        NSLog(@"Failed to write file.");
        return false;
    }
    return true;
}


- (std::vector<int> ) convertNSArrayToVector: (NSArray *) array {
    std::vector<int> res;
    for (int i = 0; i < [array count]; i++) {
        res.push_back([array[i] intValue]);
    }
    return res;
}

- (BOOL) saveSnapshotWithFilename:(NSString*) filename{
    bool hasError = false;
    NSString *content = genSnapshotString(self.model->snapshot_array);
    
    if (self.model->filesys_type == DROPBOX){
        if (![self.model->dbFilesystem
              writeFileWithName:filename Content:content])
        {
            hasError = true;
        }
    }else{
        if (![self.model->docFilesystem
              writeFileWithName:filename Content:content])
        {
            hasError = true;
        }
    }
    
    if (hasError){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"File System Error"
                                                        message:@"Fail to save the file."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        NSLog(@"Failed to write file.");
        [alert show];
        return false;
    }
    return true;
}

@end
