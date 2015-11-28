//
//  iOSSettingViewController.m
//  Compass[transparent]
//
//  Created by dmiau on 6/13/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSSettingViewController.h"
#import "iOSViewController.h"
#import "AppDelegate.h"

@interface iOSSettingViewController ()

@end

@implementation iOSSettingViewController
@synthesize model;
#pragma mark ---------initialization---------

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
        // Do something
        
        model = compassMdl::shareCompassMdl();
        if (model == NULL)
            throw(runtime_error("compassModel is uninitialized"));
        
        // Get the pointer to render
        // At this point the render may not be fully initialized
        self.renderer = compassRender::shareCompassRender();
        
        pinVisible = FALSE;
        
        
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
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Initialize system message
    
    // Append the new message
    self.systemMessage.text =
    [self.rootViewController.system_message stringByAppendingString:
     [NSString stringWithFormat:@"\n%@", self.systemMessage.text]];
}

- (void)viewWillAppear:(BOOL)animated {
    
//    [super viewWillAppear:animated];

    // Update Label Control
    self.labelControl.selectedSegmentIndex =
    (int)(!self.renderer->label_flag);
    
    
    // Initialize data source indicator
    if (model->filesys_type == IOS_DOC)
        self.dataSource.selectedSegmentIndex = 0;
    else if (model->filesys_type == DROPBOX)
        self.dataSource.selectedSegmentIndex = 1;
    else
        self.dataSource.selectedSegmentIndex = 2;
    
    // Watch socket status
    [self.rootViewController addObserver:self forKeyPath:@"socket_status"
                                 options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionNew) context:NULL];
    
    // Watch the system_message variable
    [self.rootViewController addObserver:self forKeyPath:@"system_message"
                                 options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionNew) context:NULL];
    
    //-------------------
    // Update the connection parameters
    //-------------------
    bool socket_status = [self.rootViewController.socket_status boolValue];
    if (socket_status){
        self.ipTextField.text = self.rootViewController.ip_string;
        [self.serverSegmentControl setSelectedSegmentIndex:1];
        self.portTextfield.text =
        [NSString stringWithFormat:@"%d", self.rootViewController.port_number];
    }else{
        // Cache the last successful connection IP
        self.ipTextField.text = self.rootViewController.ip_string;
        [self.serverSegmentControl setSelectedSegmentIndex:0];
        self.portTextfield.text = @"10583";
    }
    
    //-------------------
    // Update distance style segment control
    //-------------------
    if ([model->configurations[@"style_type"]
        isEqualToString: @"REAL_RATIO"])
    {
        self.distStyleSegmentControl.selectedSegmentIndex = 0;
    }else if ([model->configurations[@"style_type"]
               isEqualToString:@"BIMODAL"])
    {
        self.distStyleSegmentControl.selectedSegmentIndex = 1;
    }
    
    //-------------------
    // Change navigation bar color
    //-------------------
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    UINavigationController *myNavigationController =
    app.window.rootViewController;
    
    NSDictionary *navbarTitleTextAttributes =
    [NSDictionary dictionaryWithObjectsAndKeys:
     [UIColor blackColor],UITextAttributeTextColor,
     [UIColor blackColor], UITextAttributeTextShadowColor,nil];
    
    
    [myNavigationController.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
    myNavigationController.navigationBar.tintColor = [UIColor blackColor];
    
    myNavigationController.navigationBar.barTintColor =
    [UIColor whiteColor];
    myNavigationController.navigationBar.topItem.title = @"General";
    
    //-------------------
    // Update dev segment control
    //-------------------
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"iOSDevMode"] boolValue])
    {
        self.devModeSegmentControl.selectedSegmentIndex = 1;
    }else{
        self.devModeSegmentControl.selectedSegmentIndex = 0;
    }
    
}

- (void) viewWillDisappear:(BOOL)animated{
    [self.rootViewController removeObserver:self forKeyPath:@"socket_status"
                                        context:NULL];
    [self.rootViewController removeObserver:self forKeyPath:@"system_message" context:NULL];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//----------------------
// Picker related stuff
//----------------------



//- (void) selectDefaultLocationFromPicker{
//    NSString *file_name = model->location_filename;
//    
//    NSInteger anIndex=[kml_files indexOfObject:[file_name lastPathComponent]];
//    //[todo] need to update the index dynamically
//    [self.dataPicker selectRow:anIndex inComponent:0 animated:NO];
//}


#pragma mark - Navigation

//--------------
// Data source selector
//--------------
- (IBAction)toggleDataSource:(UISegmentedControl *)sender {
    
    switch ([sender selectedSegmentIndex]) {
        case 0:
            model->filesys_type = IOS_DOC;
            NSLog(@"FUN 1");
            break;
        case 1:
            if (!model->dbFilesystem.isReady){
                [model->dbFilesystem linkDropbox:(UIViewController*)self];
            }
            if ([model->dbFilesystem.db_filesystem completedFirstSync]){
                // reload
                model->filesys_type = DROPBOX;
            }else{
                self.systemMessage.text = @"Dropbox is not ready. Try again later.";
                self.dataSource.selectedSegmentIndex = 0;
            }
            NSLog(@"FUN 2");
            break;
        default:
            NSLog(@"FUN 3");
            break;
    }
}

- (IBAction)dismissModalVC:(id)sender {
    
    iOSViewController* parentVC = self.rootViewController;
    [self dismissViewControllerAnimated:YES completion:^{
        // call your completion method:
        [parentVC viewWillAppear:YES];
    }];
}

- (IBAction)refreshConfiguraitons:(id)sender {
    if (self.model->filesys_type == DROPBOX){
        
    }else{
        [self.model->docFilesystem
         copyBundleConfigurations];
    }
    
    // reload
    readConfigurations(self.model);
    self.renderer->loadParametersFromModelConfiguration();
    [self.rootViewController.glkView setNeedsDisplay];
}


- (IBAction)toggleToolbarMode:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    int index = [segmentedControl selectedSegmentIndex];
    
    self.rootViewController.testManager->testManagerMode = OFF;    
    switch (index) {
        case 0:
            self.rootViewController.UIConfigurations[@"UIToolbarMode"]
            = @"Development";
            
            // Rotate the phone back
            // In the Dev mode, the phone is in the phone configuration by default
            [self.rootViewController setupPhoneViewMode];
            
            self.rootViewController.mapView.layer.borderWidth
            = 0.0f;
            self.rootViewController.mapView.layer.borderColor =
            [UIColor clearColor].CGColor;

            
            break;
        case 1:
            self.rootViewController.UIConfigurations[@"UIToolbarMode"]
            = @"Demo";
            self.rootViewController.mapView.layer.borderColor =
            [UIColor blueColor].CGColor;
            self.rootViewController.mapView.layer.borderWidth
            = 2.0f;
            break;
        case 2:
            self.rootViewController.UIConfigurations[@"UIToolbarMode"]
            = @"Study";
            break;
    }
    self.rootViewController.UIConfigurations[@"UIToolbarNeedsUpdate"]
    = [NSNumber numberWithBool:true];
}


- (IBAction)toggleServerConnection:(UISegmentedControl*) segmentedControl {
    NSMutableDictionary *myDict = [NSMutableDictionary
                                   dictionaryWithDictionary:
                                   @{@"Type" : @"Message"}];
    switch ([segmentedControl selectedSegmentIndex]) {
        case 0:
            // The following lines has no effect on OSX
            // sendPackage is only functional when called on iOS
            myDict[@"Content"] = @"Goodbye!";
            [self.rootViewController sendPackage: myDict];
            [self.rootViewController toggleServerConnection:NO];
            break;
        case 1:
            self.rootViewController.system_message = @"Connecting...";
            self.rootViewController.ip_string =
            self.ipTextField.text;
            self.rootViewController.port_number =
            [self.portTextfield.text intValue];
            
            [self.rootViewController toggleServerConnection:YES];
            break;
    }
}

//---------------
// KVO code
//---------------
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    
    // [todo] In the browser mode,
    // updates should not come from map! Need to fix this
    if ([keyPath isEqual:@"socket_status"]) {
        bool socket_status = [self.rootViewController.socket_status boolValue];
        if (socket_status){
            [self.serverSegmentControl setSelectedSegmentIndex:1];
        }else{
            [self.serverSegmentControl setSelectedSegmentIndex:0];
            self.portTextfield.text = @"10583";
        }
    }else if ([keyPath isEqual:@"system_message"]){
        
        // Append the new message
        self.systemMessage.text = self.rootViewController.system_message;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.portTextfield resignFirstResponder];
    [self.ipTextField resignFirstResponder];
}



//------------------
// Label Control
//------------------
- (IBAction)labelSegmentControl:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            //-----------
            // None
            //-----------
            self.renderer->label_flag = true;
            break;
        case 1:
            //-----------
            // Abbreviation
            //-----------
            self.renderer->label_flag = false;
            break;            
    }
    [self.rootViewController.glkView setNeedsDisplay];
}

- (IBAction)toggleDistStyleSegment:(UISegmentedControl*)sender {
    int selected_id = [sender selectedSegmentIndex];
    if (selected_id == 0)
    {
        model->configurations[@"style_type"] = @"REAL_RATIO";
    }else{
        model->configurations[@"style_type"] = @"BIMODAL";
    }
}


- (IBAction)toggleDevMode:(UISegmentedControl*)sender {
    int selected_id = [sender selectedSegmentIndex];
    if (selected_id == 0)
    {
        // Dev mode is off
        [[NSUserDefaults standardUserDefaults]
    setObject:[NSNumber numberWithBool:NO]
         forKey:@"iOSDevMode"];
    }else{
        // Dev mode is on
        [[NSUserDefaults standardUserDefaults]
         setObject:[NSNumber numberWithBool:YES]
         forKey:@"iOSDevMode"];
    }
}
@end
