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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (selected_snapshot_id > -1){
        UITableViewCell* cell = [self.myTableView
                                 cellForRowAtIndexPath:
                                 [NSIndexPath indexPathForRow: selected_snapshot_id
                                                    inSection: 0]];
        // bug? The first row is quite small...
        cell.textLabel.text =
        self.model->snapshot_array[selected_snapshot_id].name;
        selected_snapshot_id = -1;
    }
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.model->snapshot_array.size();
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
    
    int i = [indexPath row];
    
    // Configure Cell
    cell.textLabel.text = self.model->snapshot_array[i].name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", i];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)path {

    int row_id = [path row];
    self.rootViewController.snapshot_id_toshow = row_id;
    
    //--------------
    // We might need to do something for iPad
    //--------------
    [self.navigationController popViewControllerAnimated:NO];
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
//    // Get the row ID
    int i = [indexPath row];
//    int section_id = [indexPath section];
    selected_snapshot_id = i;
    // Perform segue
    [self performSegueWithIdentifier:@"ToSnapshotDetailView"
                              sender:nil];
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
    
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        int i = [indexPath row];
        self.model->snapshot_array.erase(
            self.model->snapshot_array.begin() + i );
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


//-------------
// Save file
//-------------
- (IBAction)saveKML:(id)sender {
    
    NSString *filename = @"snapshot.kml";
    
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

#pragma mark -----Exit-----
- (IBAction)dismissModalVC:(id)sender {
    iOSViewController* parentVC = self.rootViewController;
    [self dismissViewControllerAnimated:YES completion:^{
        // call your completion method:
        [parentVC viewWillAppear:YES];
    }];
}

@end
