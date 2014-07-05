//
//  myTableViewController.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 6/20/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "myTableViewController.h"
#import "iOSViewController.h"

@interface myTableViewController ()

@end

@implementation myTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        // Do something
        
        self.model = compassMdl::shareCompassMdl();
        if (self.model == NULL)
            throw(runtime_error("compassModel is uninitialized"));
        self.needUpdateAnnotations = false;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //    // I am not sure wheather this line is necessary or not...
    //    [self.myTableView registerClass:
    //     [UITableViewCell  class] forCellReuseIdentifier:@"myTableCell"];
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
    return self.model->data_array.size();
}


//----------------
// This method is called to populate each row
//----------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[tableView
                                                dequeueReusableCellWithIdentifier:@"myTableCell"];
    if (cell == nil){
        NSLog(@"Something wrong...");
    }
    // Get the row ID
    int i = [indexPath row];
    
    // Configure Cell
    cell.textLabel.text =
    [NSString stringWithUTF8String:self.model->data_array[i].name.c_str()];
    if (self.model->data_array[i].isEnabled){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

//----------------
// This method is called when the accessory button is pressed
//----------------
- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
    // It appears that this method will only be called when
    // accessoryTrype is set to "Detail Disclosure"
    
//    NSLog(@"Accessory button is tapped for cell at index path = %@", indexPath);

    // Get the row ID
    int i = [indexPath row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark){
        self.model->data_array[i].isEnabled = true;
    }else{
        self.model->data_array[i].isEnabled = false;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)path {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:path];
    int i = [path row];
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        self.model->data_array[i].isEnabled = false;
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.model->data_array[i].isEnabled = true;
    }
    
    self.needUpdateAnnotations = true;
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    return YES;
//}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if (self.needUpdateAnnotations)
    {
        iOSViewController *destViewController = segue.destinationViewController;
        destViewController.needUpdateAnnotations = true;
    }
}

- (IBAction)toggleLandmakrSelection:(id)sender {
    UIBarButtonItem *myButton = (UIBarButtonItem*) sender;
    if ([[myButton title] isEqualToString:@"Select All"]){
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
@end
