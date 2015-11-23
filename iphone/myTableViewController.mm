//
//  myTableViewController.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 6/20/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "myTableViewController.h"
#import "xmlParser.h"
#import "DetailViewController.h"
#import "AppDelegate.h"
#import "Place.h"
#import "Area.h"

@interface myTableViewController ()

@end

@implementation landmarkCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
    {
        //-------------------
        // Create an UISwitch
        //-------------------
        UISwitch *onoff = [[UISwitch alloc]
                           initWithFrame:CGRectMake(262, 6, 51, 31)];
        [onoff addTarget: self action: @selector(flipSingleLandmark:) forControlEvents:UIControlEventValueChanged];
        onoff.on = false;
        self.mySwitch = onoff;
        [self addSubview:onoff];
        
        //-------------------
        // Set the rootViewController
        //-------------------
        AppDelegate *app = [[UIApplication sharedApplication] delegate];
        
        UINavigationController *myNavigationController =
        app.window.rootViewController;
        
        self.rootViewController =
        [myNavigationController.viewControllers objectAtIndex:0];
        
    }
    return self;
}

- (void) flipSingleLandmark:(UISwitch*)sender{
    if (sender.isOn) {
        self.data_ptr->isEnabled = true;
    } else {
        self.data_ptr->isEnabled = false;
    }
    
    if (self.isUserLocation){
        self.rootViewController.needToggleLocationService = true;
    }else{
        self.rootViewController.needUpdateAnnotations = true;
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animate{
    
    if (editing){
        [self.mySwitch setHidden:YES];
        [self setEditingAccessoryType: UITableViewCellAccessoryDetailButton];
    }else{
        [self.mySwitch setHidden:NO];
        if (self.data_ptr)
            self.mySwitch.on = self.data_ptr->isEnabled;
        [self setEditingAccessoryType: UITableViewCellAccessoryNone];
    }
    
    [super setEditing:editing animated:animate];
}


@end


@implementation myTableViewController

#pragma mark -----Initialization-----
//-------------------
// Initialization
//-------------------
- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        // Do something
        
        self.model = compassMdl::shareCompassMdl();
        selected_id = -1;
        data_dirty_flag = false;
        if (self.model == NULL)
            throw(runtime_error("compassModel is uninitialized"));
        [self initArea];
        [self initKMLList];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    
    //-----------------
    // Register the custom cell
    //-----------------
    [self.myTableView registerClass:[landmarkCell class]
             forCellReuseIdentifier:@"myTableCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    //    [super viewWillAppear:animated];
    
    // Update the KML list
    [self initArea];
    [self initKMLList];
    
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
    [UIColor colorWithRed:213.0/255 green:108.0/255 blue:46.0/255 alpha:1];
    myNavigationController.navigationBar.topItem.title = @"Bookmarks";
    
    [self.myTableView reloadData];
    if (selected_id > -1){
        UITableViewCell* cell = [self.myTableView
                                 cellForRowAtIndexPath:
                                 [NSIndexPath indexPathForRow: selected_id
                                                    inSection: 2]];
        cell.textLabel.text =
        [NSString stringWithUTF8String:
         self.model->data_array[selected_id].name.c_str()];
        selected_id = -1;
        
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    // Save kml before exiting
    //    [self saveKML:nil];
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//------------------
// Collect a list of KML files
//------------------
- (void) initKMLList{
    // Collect a list of kml files
    NSArray *dirFiles;
    if (self.model->filesys_type == IOS_DOC){
        dirFiles = [self.model->docFilesystem listFiles];
    }else{
        dirFiles = [self.model->dbFilesystem listFiles];
    }
    
    dirFiles = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (self CONTAINS 'snapshot')"]];
    dirFiles = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (self CONTAINS 'history')"]];
    
    kml_files = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.kml'"]];
    
//    AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    for (int i = 0; i < [kml_files count]; i++) {
//        NSString *filename = kml_files[i];
//        NSLog(@"%@", filename);
//        readLocationKml(self.model, filename);
//        Area *area = [NSEntityDescription insertNewObjectForEntityForName:@"Area" inManagedObjectContext:app.managedObjectContext];
//        area.name = [filename componentsSeparatedByString:@"."][0];
//        for (int j = 0; j < self.model->data_array.size(); j++) {
//            Place *p1 = [NSEntityDescription
//                         insertNewObjectForEntityForName:@"Place"
//                         inManagedObjectContext:app.managedObjectContext];
//            
//            p1.name = [NSString stringWithCString:self.model->data_array[j].name.c_str() encoding:[NSString defaultCStringEncoding]];
//            p1.lon = [NSNumber numberWithDouble:self.model->data_array[j].longitude];
//            p1.lat = [NSNumber numberWithDouble:self.model->data_array[j].latitude];
//            [area addPlacesObject:p1];
//        }
//    }
//    NSError *error;
//    if (![app.managedObjectContext save:&error]){
//        NSLog(@"Sorry, an error occurred while saving: %@", [error localizedDescription]);
//    }
}

#pragma mark -----Table View Data Source Methods-----
//-------------------
// Table related methods
//-------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Three sections: the location file listing, user location and bookmarks
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 1;
    else if (section == 1)
        return self.model->data_array.size();
    else
        return [areas count];
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *list = @[@"User Location",
                      self.model->location_filename,
                      @"Location Files"];
    
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

- (void) initArea{
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
    areas = temp_area;
}

//----------------
// Populate each row of the table
//----------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    landmarkCell *cell = (landmarkCell *)[tableView                                                dequeueReusableCellWithIdentifier:@"myTableCell"];
    
    if (cell == nil){
        NSLog(@"Something wrong...");
    }
    // Get the row ID
    int section_id = [indexPath section];
    int i = [indexPath row];
    data *data_ptr = NULL;
    
    if (section_id == 0){
        cell.textLabel.text = @"My Location";
        cell.isUserLocation = true;
        data_ptr = &(self.model->user_pos);
    }else if (section_id == 1){
        // Configure Cell
        cell.textLabel.text =
        [NSString stringWithUTF8String:self.model->data_array[i].name.c_str()];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", i];
        cell.isUserLocation = false;
        data_ptr = &(self.model->data_array[i]);
        
        //        cell.backgroundColor = [UIColor redColor];
    }else{
        cell.textLabel.text =  areas[i];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", i];
        cell.isUserLocation = false;
    }
    
    cell.data_ptr = data_ptr;
    if (data_ptr){
        cell.mySwitch.enabled = true;
        cell.mySwitch.on = data_ptr->isEnabled;
    }else{
        cell.mySwitch.enabled = false;
    }
    return cell;
}

//----------------
// This method is called when the accessory button is pressed
// *************
// It appears that this method will only be called when
// accessoryTrype is set to "Detail Disclosure"
//----------------
- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    // Get the row ID
    int i = [indexPath row];
    int section_id = [indexPath section];
    selected_id = i;
    data *data_ptr;
    
    
    if (section_id == 0){
        data_ptr = &(self.model->user_pos);
    }else if (section_id == 1){
        data_ptr = &(self.model->data_array[i]);
    }else{
        // Do nothing
        return;
    }
    
    // Perform segue
    [self performSegueWithIdentifier:@"TableDetailVC"
                              sender:data_ptr->annotation];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)path {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:path];
    int row_id = [path row];
    int section_id = [path section];
    data *data_ptr;
    NSLog(@"FUN %d %d", section_id, row_id);
    
    if (section_id == 0){
        data_ptr = &(self.model->user_pos);
        self.rootViewController.needToggleLocationService = true;
    }else if (section_id == 1){
        data_ptr = &(self.model->data_array[row_id]);
    }else{
        // Reload and display the landmarks
        //        if ( ![[kml_files objectAtIndex:row_id] isEqualToString:self.model->location_filename])
        //        {
        
        // Read the location data
        // texture cache is generated within readLocationKml
        //            readLocationKml(self.model, self.model->location_filename);
        self.model->location_filename = areas[row_id];
        self.model->data_array.clear();
        std::vector<data> locationData;
        // Fetch the stored data
        AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        
        NSError *error;
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Area"];
        NSString *initData= areas[row_id];
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
        //--------------
        // new.kml is a speical location file used to creating new data,
        // it is therefore not necessary to go to the first location
        //--------------
        if ([self.model->location_filename isEqualToString:@"new.kml"])
        {
            // Do nothing
        }else{
            self.rootViewController.landmark_id_toshow = 0;
            // updateMapDisplayRegion will be called in unwindSegue
        }
        self.rootViewController.needUpdateAnnotations = true;
        
        [self.myTableView reloadData];
        //        }
        
        
    }
    
    self.rootViewController.needUpdateAnnotations = true;
    
    
    // Go to landmarks
    if (section_id == 1){
        self.rootViewController.landmark_id_toshow = row_id;
        [self.navigationController popViewControllerAnimated:NO];
        
        //--------------
        // We might need to do something for iPad
        //--------------
#ifdef __IPAD__
        iOSViewController* parentVC = self.rootViewController;
        [self dismissViewControllerAnimated:YES completion:^{
            // call your completion method:
            [parentVC viewWillAppear:YES];
        }];
#endif
    }
    // UIAlertView has to be in the end, because it will return immediately
    if (self.rootViewController.testManager->testManagerMode != OFF){
        [self.rootViewController displayPopupMessage: @"TestManager is ON, and the location has been changed."];
    }
}

- (UIView *) superviewOfType:(Class)paramSuperviewClass
                     forView:(UIView*) paramView
{
    if (paramView.superview != nil){
        if ([paramView.superview isKindOfClass:paramSuperviewClass]){
            return paramView.superview;
        }else{
            return [self superviewOfType:paramSuperviewClass
                                 forView:paramView.superview];
        }
    }
    return nil;
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    return YES;
//}

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
    
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        int i = [indexPath row];
        if ([indexPath section] == 1){
            [self.rootViewController.mapView removeAnnotation:
             self.model->data_array[i].annotation];
            self.model->data_array.erase(
                                         self.model->data_array.begin() + i );
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            self.model->data_array_dirty = true;
        }else if ([indexPath section] == 2){
            //--------------
            // Delete a KML file
            //--------------
            if ([kml_files[i] isEqualToString:@"new.kml"])
                return;
            
            if (self.model->filesys_type == DROPBOX){
                [self.model->dbFilesystem
                 deleteFilename:kml_files[i]];
                
            }else{
                [self.model->docFilesystem
                 deleteFilename:kml_files[i]];
            }
            [self initArea];
            [self initKMLList];
            [self.myTableView reloadData];
        }
    }
}

#pragma mark -----Tool bar-----

//-------------
// Toolbar related stuff
//-------------
- (IBAction)toggleLandmakrSelection:(id)sender {
    UIBarButtonItem *myButton = (UIBarButtonItem*) sender;
    
    if ([[myButton title] rangeOfString:@"All"].location != NSNotFound){
        for (int i = 0; i < self.model->data_array.size(); ++i) {
            self.model->data_array[i].isEnabled = true;
        }
    }else{
        for (int i = 0; i < self.model->data_array.size(); ++i) {
            self.model->data_array[i].isEnabled = false;
        }
    }
    [self.myTableView reloadData];
    self.rootViewController.needUpdateAnnotations = true;
}

#pragma mark -----KML file saving-----
//-------------
// Save file
//-------------
- (IBAction)newKML:(id)sender {
    self.model->data_array.clear();
    [self.myTableView reloadData];
    [self saveKMLAs:nil];
    self.rootViewController.needUpdateAnnotations = true;
}

- (IBAction)saveKML:(id)sender {
    
    NSString *filename =
    [self.model->location_filename lastPathComponent];
    [self saveKMLWithFilename:filename];
    
}

- (IBAction)saveKMLAs:(id)sender {
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
        
        if ([filename rangeOfString:@".kml"].location == NSNotFound) {
            filename = [filename stringByAppendingString:@".kml"];
        }
        [self saveKMLWithFilename:filename];
        
        // There are some more works to do at the point
        
        // At this point we are operating on the new file
        self.model->location_filename = filename;
        
        // Need to update the section header too
        [self.myTableView reloadData];
    }
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

#pragma mark -----Navigation and Exit-----
//------------------
// Prepare for the detail view
//------------------
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(CustomPointAnnotation*)sender
{
    if ([segue.identifier isEqualToString:@"TableDetailVC"])
    {
        DetailViewController *destinationViewController =
        segue.destinationViewController;
        
        // grab the annotation from the sender
        destinationViewController.annotation = sender;
    }
}

@end