//
//  DebugSettingViewController.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 8/1/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "DebugSettingViewController.h"
#import "AppDelegate.h"

@implementation debugCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
    {
        //-------------------
        // Create an UISwitch
        //-------------------
        UISwitch *onoff = [[UISwitch alloc]
                           initWithFrame:CGRectMake(262, 6, 51, 31)];
        [onoff addTarget: self action: @selector(flipSingItem:)
        forControlEvents:UIControlEventValueChanged];
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

- (void) flipSingItem:(UISwitch*)sender{
    if (sender.isOn) {
        self.param_ptr->isEnabled = true;
    } else {
        self.param_ptr->isEnabled = false;
    }
    
}

//- (void)setEditing:(BOOL)editing animated:(BOOL)animate{
//    
//    if (editing){
//        [self.mySwitch setHidden:YES];
//        [self setEditingAccessoryType: UITableViewCellAccessoryDetailButton];
//    }else{
//        [self.mySwitch setHidden:NO];
//        self.mySwitch.on = self.data_ptr->isEnabled;
//        [self setEditingAccessoryType: UITableViewCellAccessoryNone];
//    }
//    
//    [super setEditing:editing animated:animate];
//}


@end



@interface DebugSettingViewController ()

@end

@implementation DebugSettingViewController
//-------------------
// Initialization
//-------------------
- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.testManager = TestManager::shareTestManager();
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    [self.myTableView registerClass:[debugCell class]
             forCellReuseIdentifier:@"myTableCell"];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.testManager->generateTests();
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

    //-------------------
    // Change navigation bar color
    //-------------------
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    UINavigationController *myNavigationController =
    app.window.rootViewController;
    
    myNavigationController.navigationBar.barTintColor =
    [UIColor whiteColor];
    myNavigationController.navigationBar.topItem.title = @"Debug";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


//-------------------
// Table related methods
//-------------------
#pragma mark -----Table View Data Source Methods-----
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0)
        return self.testManager->visualization_vector.size();
    else
        return self.testManager->device_vector.size();
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *list = @[@"VisualizationTypes", @"DeviceTypes"];
    
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    debugCell *cell = (debugCell *)[tableView                                                dequeueReusableCellWithIdentifier:@"myTableCell"];
    
    if (cell == nil){
        NSLog(@"Something wrong...");
    }
    // Get the row ID
    int section_id = [indexPath section];
    int i = [indexPath row];
    param *param_ptr;
    
    if (section_id == 0){
        cell.textLabel.text =
        self.testManager->visualization_strings[i];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", i];
        
        param_ptr = &(self.testManager->visualization_vector[i]);
    }else{
        // Configure Cell
        cell.textLabel.text =
        self.testManager->device_strings[i];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", i];

        param_ptr = &(self.testManager->device_vector[i]);
    }
    cell.param_ptr = param_ptr;
    cell.mySwitch.on = param_ptr->isEnabled;
    return cell;
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
@end
