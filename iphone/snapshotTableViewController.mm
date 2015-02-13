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
    
    [self updateSnapshotFileList];
}

- (void)updateSnapshotFileList{
    //-------------------
    // Collect a list of history files
    //-------------------
    // Collect a list of kml files
    NSArray *dirFiles;
    if (self.model->filesys_type == IOS_DOC){
        dirFiles = [self.model->docFilesystem listFiles];
    }else{
        dirFiles = [self.model->dbFilesystem listFiles];
    }
    
    snapshot_file_array = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self CONTAINS 'snapshot'"]];
}


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

}

- (void)viewWillDisappear:(BOOL)animated{
    [self saveKML:nil];
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

#pragma mark -----Table View Data Source Methods-----
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section ==0){
        return [snapshot_file_array count];
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
        cell.textLabel.text = snapshot_file_array[i];
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
         snapshot_file_array[row_id]];
    }else{
        //----------------
        // User selects a snapshot
        //----------------
        self.rootViewController.snapshot_id_toshow = row_id;
        
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
        if ([snapshot_file_array[i] isEqualToString:@"snapshot.kml"])
            return;
        
        if (self.model->filesys_type == DROPBOX){
            [self.model->dbFilesystem
             deleteFilename:snapshot_file_array[i]];

        }else{
            [self.model->docFilesystem
             deleteFilename:snapshot_file_array[i]];
        }
        [self updateSnapshotFileList];
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
        [alert show];
        NSLog(@"Failed to write file.");
    }
    
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
        
        if ([filename rangeOfString:@".kml"].location == NSNotFound) {
            filename = [filename stringByAppendingString:@".kml"];
        }
        [self saveSnapshotWithFilename:filename];
        
        // There are some more works to do at the point
        [self updateSnapshotFileList];
        
        // At this point we are operating on the new file
        self.model->snapshot_filename = filename;
        // Need to update the section header too
        [self.myTableView reloadData];
        
    }
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
        [alert show];
        NSLog(@"Failed to write file.");
        return false;
    }
    return true;
}

@end
