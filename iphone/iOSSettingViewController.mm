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

@interface iOSSettingViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@end

@implementation iOSSettingViewController
@synthesize model;
#pragma mark ---------initialization---------

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
        // Do something
        
        self.mainViewController = (iOSViewController*)self.parentViewController;
        
        model = compassMdl::shareCompassMdl();
        if (model == NULL)
            throw(runtime_error("compassModel is uninitialized"));
        
        // Get the pointer to render
        // At this point the render may not be fully initialized
        self.renderer = compassRender::shareCompassRender();
        
        pinVisible = FALSE;
        
        [self initPickerData];
        
        self.needUpdateDisplayRegion = false;
        
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
    // Do any additional setup after loading the view.
    [self selectDefaultLocationFromPicker];
    
    // Initialize system message
    self.systemMessage.text = @"OK";
    self.systemMessage.editable = NO;
    
    // Initialize data source indicator
    if (model->filesys_type == IOS_DOC)
        self.dataSource.selectedSegmentIndex = 0;
    else
        self.dataSource.selectedSegmentIndex = 1;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//----------------------
// Picker related stuff
//----------------------

- (void) initPickerData{
    // Collect a list of kml files
    NSArray *dirFiles;
    if (model->filesys_type == IOS_DOC){
        dirFiles = [model->docFilesystem listFiles];
    }else{
        dirFiles = [model->dbFilesystem listFiles];
        //            dirFiles = [model->docFilesystem listFiles];
    }
    
    kml_files = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.kml'"]];
}

- (void) selectDefaultLocationFromPicker{
    NSString *file_name = model->location_filename;
    
    NSInteger anIndex=[kml_files indexOfObject:[file_name lastPathComponent]];
    //[todo] need to update the index dynamically
    [self.dataPicker selectRow:anIndex inComponent:0 animated:NO];
}


- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView{
        return 1;
}

- (NSInteger) pickerView:( UIPickerView *) pickerView numberOfRowsInComponent:(NSInteger) component
{
    return [kml_files count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component{
    
    if ([pickerView isEqual:self.dataPicker]){
        
        /* Row is zero-based and we want the first row (with index 0)
         to be rendered as Row 1 so we have to +1 every row index */
        NSString* dataName = [kml_files objectAtIndex:row];
           return dataName;
    }
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    model->location_filename = [kml_files objectAtIndex:row];
    model->reloadFiles();
    self.needUpdateDisplayRegion = true;
    // updateMapDisplayRegion will be called in unwindSegue

}


#pragma mark - Navigation

//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//    if (self.needUpdateDisplayRegion)
//    {
//        iOSViewController *destViewController = segue.destinationViewController;
//        destViewController.needUpdateDisplayRegion = true;
//        destViewController.needUpdateAnnotations = true;
//    }
//}

-(void) viewWillDisappear:(BOOL)animated {
    if (self.needUpdateDisplayRegion)
    {
        iOSViewController *destViewController =
        [self.navigationController.viewControllers objectAtIndex:0];
        
        //---------------
        // iPad case (because we use modal dialog)
        //---------------
        if (destViewController == nil){
            UINavigationController *temp;
            temp = (UINavigationController*)
            self.presentingViewController;
            destViewController = [[temp viewControllers] objectAtIndex:0];
        }
        
        destViewController.needUpdateDisplayRegion = true;
        destViewController.needUpdateAnnotations = true;
    }
    [super viewWillDisappear:animated];
}


//--------------
// Data source selector
//--------------
- (IBAction)toggleDataSource:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSString *label = [segmentedControl
                       titleForSegmentAtIndex: [segmentedControl selectedSegmentIndex]];
    bool refreshPicker = false;
    
    if ([label isEqualToString:@"Local"]){
        if (model->filesys_type == DROPBOX){
            model->filesys_type = IOS_DOC;
            refreshPicker = true;
        }
    }else{
        if (!model->dbFilesystem.isReady){
            [model->dbFilesystem linkDropbox:(UIViewController*)self];
        }
        
        if ([model->dbFilesystem.db_filesystem completedFirstSync]){
            // reload
            model->filesys_type = DROPBOX;
            refreshPicker = true;
        }else{
            self.systemMessage.text = @"Dropbox is not ready. Try again later.";
            self.dataSource.selectedSegmentIndex = 0;
        }
    }
    
    if (refreshPicker){
        model->reloadFiles();
        model->location_filename = model->configurations[@"default_location_filename"];
        [self initPickerData];
        [self.dataPicker reloadAllComponents];
        [self selectDefaultLocationFromPicker];
        self.needUpdateDisplayRegion = true;
    }
    
}

- (IBAction)dismissModalVC:(id)sender {
    
    UINavigationController *temp = (UINavigationController *) (self.presentingViewController);
    iOSViewController* parentVC = (iOSViewController*) [[temp viewControllers] objectAtIndex:0];
    [self dismissViewControllerAnimated:YES completion:^{
        // call your completion method:
        [parentVC viewWillAppear:YES];
    }];
}
@end
