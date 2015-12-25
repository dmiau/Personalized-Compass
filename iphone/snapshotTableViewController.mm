//
//  snapshotTableViewController.m
//  Compass[transparent]
//
//  Created by dmiau on 7/19/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "snapshotTableViewController.h"
#import "AppDelegate.h"
#import "SnapshotDetailViewController.h"
#import "snapshotParser.h"
#import "Snapshot.h"
#import "compassModel.h"
#import "SnapshotsCollection.h"
#import "Area.h"
#import "Place.h"

@interface snapshotTableViewController ()

@end

@implementation snapshotTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Connect to the parent view controller to update its
    // properties directly
    
    //-------------------
    // Set the rootViewController
    //-------------------
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    UINavigationController *myNavigationController =
    app.window.rootViewController;
    
    self.rootViewController =
    [myNavigationController.viewControllers objectAtIndex:0];
    selected_snapshot_id = -1;
    [self initCollections];
    
//    [self updateSnapshotFileList];
}

//- (void)updateSnapshotFileList{
//    //-------------------
//    // Collect a list of history files
//    //-------------------
//    // Collect a list of kml files
//    NSArray *dirFiles;
//    if (self.model->filesys_type == IOS_DOC){
//        dirFiles = [self.model->docFilesystem listFiles];
//    }else{
//        dirFiles = [self.model->dbFilesystem listFiles];
//    }
//    
//    snapshot_file_array = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self CONTAINS '.snapshot'"]];
//}


- (void)viewWillAppear:(BOOL)animated {
    //    [super viewWillAppear:animated];
    if (selected_snapshot_id > -1){
        UITableViewCell* cell = [self.myTableView
                                 cellForRowAtIndexPath:
                                 [NSIndexPath indexPathForRow: selected_snapshot_id
                                                    inSection: 0]];
        // bug? The first row is quite small...
        cell.textLabel.text =
        self.model->snapshot_array[selected_snapshot_id].name;
        selected_snapshot_id = -1;
        [self.myTableView reloadData];
    }
    [self initCollections];
    [self.myTableView reloadData];
    //-------------------
    // Change navigation bar color
    //-------------------
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    UINavigationController *myNavigationController =
    app.window.rootViewController;
    
    
    NSDictionary *navbarTitleTextAttributes =
    [NSDictionary dictionaryWithObjectsAndKeys:
     [UIColor whiteColor],UITextAttributeTextColor,
     [UIColor blackColor], UITextAttributeTextShadowColor,nil];
    
    
    [myNavigationController.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
    myNavigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    myNavigationController.navigationBar.barTintColor =
    [UIColor colorWithRed:78.0/255 green:199.0/255 blue:40.0/255 alpha:1];
    myNavigationController.navigationBar.topItem.title = @"Snapshot";
    
    //-------------------
    // Highlight the row associated with the current snapshot
    //-------------------
    if (self.rootViewController.testManager->testManagerMode != OFF)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:
                                  self.rootViewController.testManager->test_counter
                                                    inSection: 1];
        [self.myTableView selectRowAtIndexPath:indexPath
                                      animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    
    //    [self saveKML:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        // Do something
        
        self.model = compassMdl::shareCompassMdl();
        if (self.model == NULL)
            throw(runtime_error("compassModel is uninitialized"));
    }
    return self;
}

-(void) initCollections {
    AppDelegate* app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SnapshotsCollection"];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SnapshotsCollection" inManagedObjectContext:app.managedObjectContext];
    fetchRequest.resultType = NSDictionaryResultType;
    fetchRequest.propertiesToFetch = [NSArray arrayWithObject:[[entity propertiesByName] objectForKey:@"name"]];
    fetchRequest.returnsDistinctResults = YES;
    NSError *error;
    NSArray *areasDic = [app.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSMutableArray *temp_area = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < [areasDic count]; i++) {
        if (areasDic[i][@"name"]) {
            [temp_area addObject:areasDic[i][@"name"]];
        }
    }
    collections = temp_area;
}

#pragma mark -----Table View Data Source Methods-----
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section ==0){
//        return [snapshot_file_array count];
        return [collections count];
    }else{
        return self.model->snapshot_array.size();
    }
}


- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *list = @[@"Snapshot files",
                      [self.model->snapshot_filename lastPathComponent]];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
    [label setFont:[UIFont boldSystemFontOfSize:12]];
    NSString *string =[list objectAtIndex:section];
    /* Section header is in 0th index... */
    [label setText:string];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithRed:166/255.0 green:177/255.0 blue:186/255.0 alpha:1.0]]; //your background color...
    return view;
}

//----------------
// Populate each row of the table
//----------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = (UITableViewCell *)[tableView                                                dequeueReusableCellWithIdentifier:@"myTableCell"];
    
    if (cell == nil){
        NSLog(@"Something wrong...");
    }
    // Get the row ID
    int section_id = [indexPath section];
    int i = [indexPath row];
    
    if (section_id == 0){
        cell.textLabel.text = collections[i];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", i];
    }else{
        // Configure Cell
        cell.textLabel.text = self.model->snapshot_array[i].name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", i];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)path {
    
    int row_id = [path row];
    int section_id = [path section];
    
    
    if (section_id == 0){
        //----------------
        // User selects a file
        //----------------
        
        [self loadSnapshotWithName:
         collections[row_id]];
        
    }else{
        //----------------
        // User selects a snapshot
        //----------------
        self.rootViewController.snapshot_id_toshow = row_id;
        self.model->location_filename = self.model->snapshot_array[row_id].kmlFilename;
        self.model->data_array.clear();
        std::vector<data> locationData;
        // Fetch the stored data
        AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        
        NSError *error;
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Area"];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name == %@", self.model->location_filename]];
        
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
                data.annotation.title = place.name;
                locationData.push_back(data);
            }
            self.model->data_array =  locationData;
            
            self.model->updateMdl();
            self.model->initTextureArray();
        }
        
        //--------------
        // We might need to do something for iPad
        //--------------
        [self.navigationController popViewControllerAnimated:NO];
        
#ifdef __IPAD__
        iOSViewController* parentVC = self.rootViewController;
        [self dismissViewControllerAnimated:YES completion:^{
            // call your completion method:
            [parentVC viewWillAppear:YES];
        }];
#endif
    }
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    //    // Get the row ID
    int i = [indexPath row];
    int section_id = [indexPath section];
    
    if (section_id ==0){
    }else{
        selected_snapshot_id = i;
        // Perform segue
        [self performSegueWithIdentifier:@"ToSnapshotDetailView"
                                  sender:nil];
    }
}

#pragma mark - Navigation
//------------------
// Prepare for the detail view
//------------------
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(CustomPointAnnotation*)sender
{
    if ([segue.identifier isEqualToString:@"ToSnapshotDetailView"])
    {
        SnapshotDetailViewController *destinationViewController =
        segue.destinationViewController;
        
        // grab the annotation from the sender
        destinationViewController.snapshot_id = selected_snapshot_id;
    }
}

//-------------
// Toggle editing mode
//-------------
- (IBAction)toggleEditing:(id)sender {
    UIBarButtonItem *myButton =
    (UIBarButtonItem*) sender;
    if (self.myTableView.editing == YES){
        [self.myTableView setEditing:NO animated:YES];
        myButton.title = @"Edit";
    }else{
        [self.myTableView setEditing:YES animated:YES];
        myButton.title = @"Done";
    }
    
}

//-------------
// Deleting rows
//-------------
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //https://developer.apple.com/library/ios/documentation/userexperience/conceptual/tableview_iphone/ManageInsertDeleteRow/ManageInsertDeleteRow.html
    
    int section_id = [indexPath section];
    
    if (section_id == 0){
        
        int i = [indexPath row];
        if ([snapshot_file_array[i] isEqualToString:@"default.snapshot"])
            return;
        
        if (self.model->filesys_type == DROPBOX){
            [self.model->dbFilesystem
             deleteFilename:snapshot_file_array[i]];
            
        }else{
            [self.model->docFilesystem
             deleteFilename:snapshot_file_array[i]];
        }
//        [self updateSnapshotFileList];
        [self initCollections];
        [self.myTableView reloadData];
    }else{
        // If row is deleted, remove it from the list.
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            int i = [indexPath row];
            self.model->snapshot_array.erase(
                                             self.model->snapshot_array.begin() + i );
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}


//-------------
// Save file
//-------------
- (IBAction)newKML:(id)sender {
    self.model->snapshot_array.clear();
    [self.myTableView reloadData];
    [self saveSnspahotAs:nil];
}

- (IBAction)saveKML:(id)sender {
    
    NSString *filename = self.model->snapshot_filename;
    
//    bool hasError = false;
//    NSString *content = genSnapshotString(self.model->snapshot_array);
//    
//    if (self.model->filesys_type == DROPBOX){
//        if (![self.model->dbFilesystem
//              writeFileWithName:filename Content:content])
//        {
//            hasError = true;
//        }
//    }else{
//        if (![self.model->docFilesystem
//              writeFileWithName:filename Content:content])
//        {
//            hasError = true;
//        }
//    }
//    
//    if (hasError){
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"File System Error"
//                                                        message:@"Fail to save the file."
//                                                       delegate:self
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        NSLog(@"Failed to write file.");
//        [alert show];
//    }
    [self saveSnapshotWithFilename:filename];
    
}

- (IBAction)reloadSnapshotFile:(id)sender {
    //------------
    // Load snapshot if the file is available
    //------------
    NSString* filename = self.model->snapshot_filename;
    bool snapshotFileExists = false;
    // Check if a snapshot file exists
    if (self.model->filesys_type == DROPBOX){
        snapshotFileExists = [self.model->dbFilesystem fileExists:filename];
    }else{
        snapshotFileExists = [self.model->docFilesystem fileExists:filename];
    }
    
    if (snapshotFileExists){
        self.model->snapshot_filename = filename;
        if (readSnapshotKml(self.model) != EXIT_SUCCESS){
            throw(runtime_error("Failed to load snapshot files"));
        }
    }
    [self.myTableView reloadData];
}

- (void)loadSnapshotWithName: (NSString*) filename{
    NSError *error;
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString* filename_cache = self.model->snapshot_filename;
    self.model->snapshot_filename = filename;
    self.model->snapshot_array.clear();
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"SnapshotsCollection"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"name = %@", filename]];
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
            oneShot.kmlFilename = s.atArea.name;
            
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

    if (![result count]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"File System Error"
                                                        message:@"Fail to read the snapshot file."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        self.model->snapshot_filename = filename_cache;
        [alert show];
    }else{
        [self.myTableView reloadData];
    }
}


- (IBAction)saveSnspahotAs:(id)sender {
    // Prompt a dialog box to get the filename
    UIAlertView *alertView =
    [[UIAlertView alloc] initWithTitle:@"File Name"
                               message:@"Please enter a filename"
                              delegate:self
                     cancelButtonTitle:@"Cancel"
                     otherButtonTitles:@"OK", nil];
    
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    [alertView show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:@"OK"]){
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSString *filename = textField.text;
        
//        if ([filename rangeOfString:@".snapshot"].location == NSNotFound) {
//            filename = [filename stringByAppendingString:@".snapshot"];
//        }
        [self saveSnapshotWithFilename:filename];
        
        // There are some more works to do at the point
//        [self updateSnapshotFileList];
        [self initCollections];
        
        // At this point we are operating on the new file
        self.model->snapshot_filename = filename;
        // Need to update the section header too
        [self.myTableView reloadData];
        
    }
}

- (BOOL) saveSnapshotWithFilename:(NSString*) filename{
//    bool hasError = false;
//    NSString *content = genSnapshotString(self.model->snapshot_array);
//    
//    if (self.model->filesys_type == DROPBOX){
//        if (![self.model->dbFilesystem
//              writeFileWithName:filename Content:content])
//        {
//            hasError = true;
//        }
//    }else{
//        if (![self.model->docFilesystem
//              writeFileWithName:filename Content:content])
//        {
//            hasError = true;
//        }
//    }
//    
//    if (hasError){
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"File System Error"
//                                                        message:@"Fail to save the file."
//                                                       delegate:self
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        NSLog(@"Failed to write file.");
//        [alert show];
//        return false;
//    }
    AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [self deleteAllObjects:@"SnapshotsCollection" withName:filename in:app.managedObjectContext];
    SnapshotsCollection *collection = [NSEntityDescription insertNewObjectForEntityForName:@"SnapshotsCollection" inManagedObjectContext:app.managedObjectContext];
    collection.name = filename;
    for (int i = 0; i < self.model->snapshot_array.size(); i++) {
        snapshot s = self.model->snapshot_array[i];
        Snapshot *snapshot = [NSEntityDescription insertNewObjectForEntityForName:@"Snapshot" inManagedObjectContext:app.managedObjectContext];

        snapshot.coordinateRegion = [NSData dataWithBytes:&s.coordinateRegion length:sizeof(s.coordinateRegion)];

        MKCoordinateRegion region;
        [snapshot.coordinateRegion getBytes:&region length:sizeof(region)];

        snapshot.osx_coordinateRegion =[NSData dataWithBytes:&s.osx_coordinateRegion  length:sizeof(s.osx_coordinateRegion)];

        snapshot.orientation = [NSNumber numberWithDouble:s.orientation];

        snapshot.deviceType = [NSString stringWithCString:toString(s.deviceType).c_str() encoding:[NSString defaultCStringEncoding]];

        snapshot.visualizationType = [NSString stringWithCString:toString(s.visualizationType).c_str() encoding:[NSString defaultCStringEncoding]];
        snapshot.atArea.name = s.kmlFilename;
        snapshot.name = s.name;
        snapshot.mapType = [NSNumber numberWithInteger: (NSUInteger)s.mapType];

        snapshot.time_stamp = s.time_stamp;
        snapshot.date_str = s.date_str;
        snapshot.notes = s.notes;
        snapshot.address = s.address;

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
    
    NSError *error;
    if (![app.managedObjectContext save:&error]){
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

- (NSArray *) convertVectorToArray: (std::vector<int>)vec {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < vec.size(); i++) {
        NSNumber *temp = [NSNumber numberWithInteger:vec[i]];
        [array addObject:temp];
    }
    return array;
}

- (std::vector<int> ) convertNSArrayToVector: (NSArray *) array {
    std::vector<int> res;
    for (int i = 0; i < [array count]; i++) {
        res.push_back([array[i] intValue]);
    }
    return res;
}


- (void) deleteAllObjects: (NSString *) entityDescription withName: (NSString *) name in: (NSManagedObjectContext *) managedObjectContext {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name = %@", name]];
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

@end