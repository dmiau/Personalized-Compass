//
//  iOSSettingViewController.m
//  Compass[transparent]
//
//  Created by dmiau on 6/13/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSSettingViewController.h"
#import "iOSViewController.h"

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
        
        // Collect a list of kml files
        NSString *path = [[[NSBundle mainBundle]
                           pathForResource:@"montreal.kml" ofType:@""]
                          stringByDeletingLastPathComponent];
        
        NSArray *dirFiles = [[NSFileManager defaultManager]
                             contentsOfDirectoryAtPath: path error:nil];
        kml_files = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.kml'"]];
        
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
    
    NSString *file_name = [NSString stringWithUTF8String:model->location_filename.c_str()];
    
    NSInteger anIndex=[kml_files indexOfObject:[file_name lastPathComponent]];
    //[todo] need to update the index dynamically
    [self.dataPicker selectRow:anIndex inComponent:0 animated:NO];
    NSLog(@"*********viewDidLoad called!");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//----------------------
// Picker related stuff
//----------------------
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
           return [kml_files objectAtIndex:row];
    }
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    NSString* astr = [kml_files objectAtIndex:row];
    
    model->location_filename = std::string([ [[NSBundle mainBundle] pathForResource:astr                                                                             ofType:@""] UTF8String]);
    
    NSLog(@"json combon triggered %@", astr);
    
    // The following debug line did work!
    // po ((NSComboBox *)sender).stringValue
    
    model->reloadFiles();
    self.needUpdateDisplayRegion = true;
    // updateMapDisplayRegion will be called in unwindSegue
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"settingSegue"] &&
        self.needUpdateDisplayRegion) {
        iOSViewController *destViewController = segue.destinationViewController;
        destViewController.needUpdateDisplayRegion = true;
    }
}

@end
