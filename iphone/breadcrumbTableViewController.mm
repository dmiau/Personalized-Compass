//
//  breadcrumbTableViewController.m
//  Compass[transparent]
//
//  Created by dmiau on 7/20/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "breadcrumbTableViewController.h"
#import "AppDelegate.h"

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -----Table View Data Source Methods-----
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    int numberOfBreadcrumb = self.model->breadcrumb_array.size();
    starting_index = 0;
    // Display the last 20 history entries
    if (numberOfBreadcrumb > 20){
        starting_index = numberOfBreadcrumb - 20;
        numberOfBreadcrumb = 20;
    }
    
    return numberOfBreadcrumb;
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
    cell.textLabel.text = @"Breadcrumb";
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", starting_index + i];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)path {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:path];
    int row_id = [path row];
    self.rootViewController.breadcrumb_id_toshow = row_id;
    
    //--------------
    // We might need to do something for iPad
    //--------------
    [self.navigationController popViewControllerAnimated:NO];
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
    NSString *content = genHistoryString(self.model->breadcrumb_array);
    
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
