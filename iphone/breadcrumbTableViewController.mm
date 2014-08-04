//
//  breadcrumbTableViewController.m
//  Compass[transparent]
//
//  Created by dmiau on 7/20/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "breadcrumbTableViewController.h"
#import "AppDelegate.h"
#import "historyParser.h"
#import "BreadcrumbDetailViewController.h"

@interface breadcrumbTableViewController ()

@end

@implementation breadcrumbTableViewController
- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        // Do something
        self.model = compassMdl::shareCompassMdl();
        if (self.model == NULL)
            throw(runtime_error("compassModel is uninitialized"));
        dirty_flag = false;
    }
    return self;
}


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
    
    [self updateHistoryFileList];
}

- (void)updateHistoryFileList{
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
    
    history_file_array = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self CONTAINS 'history'"]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (dirty_flag){
        [self updateHistoryFileList];
        [self.myTableView reloadData];
        dirty_flag = false;
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
    [UIColor colorWithRed:46.0/255 green:154.0/255 blue:213.0/255 alpha:1];
    myNavigationController.navigationBar.topItem.title = @"Breadcrumbs";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -----Table View Data Source Methods-----
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0){
        return [history_file_array count];
    }else{
        int numberOfBreadcrumb = self.model->breadcrumb_array.size();
        starting_index = 0;
        // Display the last 20 history entries
        if (numberOfBreadcrumb > 20){
            starting_index = numberOfBreadcrumb - 20;
            numberOfBreadcrumb = 20;
        }
        
        return numberOfBreadcrumb;
    }
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *list = @[@"History files",
                      [self.model->history_filename lastPathComponent]];
    
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
        cell.textLabel.text = history_file_array[i];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", i];
    }else{
        // Configure Cell
        cell.textLabel.text = @"Breadcrumb";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", starting_index + i];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)path {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:path];
    int section_id = [path section];
    int row_id = [path row];
    
    if (section_id == 0){
        [self loadHistoryWithIndex: row_id];
    }else{

        self.rootViewController.breadcrumb_id_toshow = row_id;
        
        //--------------
        // We might need to do something for iPad
        //--------------
        [self.navigationController popViewControllerAnimated:NO];
    }
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{

    int i = [indexPath row];
    int section_id = [indexPath section];

    if (section_id == 0){
        [self loadHistoryWithIndex: i];
        dirty_flag = true;
        selected_filename = history_file_array[i];
        // Perform segue
        [self performSegueWithIdentifier:@"ToBreadcrumbDetailView"
                                  sender:nil];
    }
}

- (void)loadHistoryWithIndex: (int) row_id{
    self.model->history_filename = history_file_array[row_id];
    if (readHistoryKml(self.model)!= EXIT_SUCCESS){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"File System Error"
                                                        message:@"Fail to read the history file."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

    }else{
        [self.myTableView reloadData];
    }
}

//-------------
// Save file
//-------------
- (IBAction)saveKML:(id)sender {
    
    //------------------
    // Prevent file overwritten
    //------------------
    // Collect a list of kml files
    NSArray *dirFiles, *kml_files;
    if (self.model->filesys_type == IOS_DOC){
        dirFiles = [self.model->docFilesystem listFiles];
    }else{
        dirFiles = [self.model->dbFilesystem listFiles];
    }
    
    dirFiles = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self CONTAINS 'history'"]];
    kml_files = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.kml'"]];
    
    int counter = [kml_files count];
    
    NSString *filename = [NSString
                          stringWithFormat:@"history%d.kml", counter];
    
    bool hasError = false;
    NSString *content = genHistoryString(self.model);
    
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


#pragma mark - Navigation
//------------------
// Prepare for the detail view
//------------------
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(CustomPointAnnotation*)sender
{
    if ([segue.identifier isEqualToString:@"ToBreadcrumbDetailView"])
    {
        BreadcrumbDetailViewController *destinationViewController =
        segue.destinationViewController;
        
        // grab the annotation from the sender
        destinationViewController.filename = selected_filename;
    }
}
@end
