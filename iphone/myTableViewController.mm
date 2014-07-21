//
//  myTableViewController.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 6/20/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "myTableViewController.h"
#import "DetailViewController.h"
#import "AppDelegate.h"

@interface myTableViewController ()

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
        if (self.model == NULL)
            throw(runtime_error("compassModel is uninitialized"));
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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-------------------
// Table related methods
//-------------------
#pragma mark -----Table View Data Source Methods-----
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0)
        return 1;
    else
        return self.model->data_array.size();
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *list = @[@"Special (user)",
                      [self.model->location_filename lastPathComponent]];
    
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
    data *data_ptr;
    
    
    if (section_id == 0){
        cell.textLabel.text = @"My Location";

        data_ptr = &(self.model->user_pos);
    }else{
        // Configure Cell
        cell.textLabel.text =
        [NSString stringWithUTF8String:self.model->data_array[i].name.c_str()];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", i];

        data_ptr = &(self.model->data_array[i]);
    }
    
    if (data_ptr->isEnabled){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
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
    
    data *data_ptr;
    
    if (section_id == 0){
        data_ptr = &(self.model->user_pos);
    }else{
        data_ptr = &(self.model->data_array[i]);
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
    
    if (section_id == 0){
        data_ptr = &(self.model->user_pos);
        self.rootViewController.needToggleLocationService = true;
    }else{
        data_ptr = &(self.model->data_array[row_id]);
    }
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        data_ptr->isEnabled = false;
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        data_ptr->isEnabled = true;
    }
    
    self.rootViewController.needUpdateAnnotations = true;
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
        if ([indexPath section] == 1){
            int i = [indexPath row];
            self.model->data_array.erase(
                                         self.model->data_array.begin() + i );
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            self.model->data_array_dirty = true;
        }
    }
}

#pragma mark -----Tool bar-----

//-------------
// Toolbar related stuff
//-------------
- (IBAction)toggleLandmakrSelection:(id)sender {
    UIBarButtonItem *myButton = (UIBarButtonItem*) sender;
    if ([[myButton title] isEqualToString:@"SelectAll"]){
        for (int i = 0; i < self.model->data_array.size(); ++i) {
            self.model->data_array[i].isEnabled = true;
        }
    }else{
        for (int i = 0; i < self.model->data_array.size(); ++i) {
            self.model->data_array[i].isEnabled = false;
        }
    }
    [self.myTableView reloadData];
}

//-------------
// Save file
//-------------
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

- (IBAction)go2Landmark:(id)sender {
    NSIndexPath *indexPath = [self.myTableView indexPathForSelectedRow];
    if ([indexPath section] == 1){
        self.rootViewController.landmark_id_toshow = [indexPath row];
        
        //--------------
        // We might need to do something for iPad
        //--------------
        [self.navigationController popViewControllerAnimated:NO];
    }
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

//------------------
// This is needed for iPad
//------------------
- (IBAction)dismissModalVC:(id)sender {    
    iOSViewController* parentVC = self.rootViewController;
    [self dismissViewControllerAnimated:YES completion:^{
        // call your completion method:
        [parentVC viewWillAppear:YES];
    }];
}
@end