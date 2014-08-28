//
//  DetailViewController.m
//  Compass[transparent]
//
//  Created by dmiau on 7/5/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "DetailViewController.h"
#import "AppDelegate.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

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

    self.model = compassMdl::shareCompassMdl();
    
    // Do any additional setup after loading the view.
    self.titleTextField.text = self.annotation.title;
    self.noteTextField.text = self.annotation.notes;
    self.addressView.text = self.annotation.subtitle;

    NSString *address;
    CLLocation *location = [[CLLocation alloc]
                            initWithLatitude:[self.annotation coordinate].latitude
                            longitude:[self.annotation coordinate].longitude];
    
    if ([self.addressView.text isEqualToString:@""]){
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:location
                       completionHandler:^(NSArray *placemarks, NSError *error)
         {
             if(placemarks && placemarks.count > 0)
             {
                 CLPlacemark *placemark= [placemarks objectAtIndex:0];
                 //address is NSString variable that declare in .h file.
                 NSString* address =
                 [NSString stringWithFormat:@"%@ %@ , %@ , %@",
                  [placemark subThoroughfare],
                  [placemark thoroughfare],[placemark locality],[placemark administrativeArea]];
                 NSLog(@"New Address Is:%@",address);
                 self.addressView.text = address;
             }
         }];
    }
    
    //-------------------
    // Set the rootViewController
    //-------------------
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    UINavigationController *myNavigationController =
    app.window.rootViewController;
    
    self.rootViewController =
    [myNavigationController.viewControllers objectAtIndex:0];
    
    
    //-------------
    // Configure the add and remove buttons
    //-------------
    if (self.annotation.point_type != landmark){
        self.addButton.enabled = YES;
    }else{
        self.addButton.enabled = NO;
        self.removeButton.enabled = YES;
    }

    //-------------
    // Configure the enable/disable status
    //-------------    
    if (self.annotation.point_type == landmark){
        int i = self.annotation.data_id;
        if (self.model->data_array[i].isEnabled)
            self.statusSegmentControl.selectedSegmentIndex = 0;
        else
            self.statusSegmentControl.selectedSegmentIndex = 1;
    }else{
        self.statusSegmentControl.enabled = false;
    }
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

- (IBAction)doneEditing:(id)sender {
    [self.titleTextField resignFirstResponder];
    [self.noteTextField resignFirstResponder];
    
    self.annotation.title = self.titleTextField.text;
    self.annotation.notes = self.noteTextField.text;
    
    if (self.annotation.point_type == landmark){
        int i = self.annotation.data_id;
        self.model->data_array[i].name =
        [self.annotation.title UTF8String];
    }
}

- (IBAction)addLocation:(id)sender {
    // Right buttton tapped - add the pin to data_array
    data myData;
    myData.name = [self.annotation.title UTF8String];
    myData.annotation = self.annotation;
    myData.annotation.point_type = landmark;
 
    myData.annotation.subtitle =
    [NSString stringWithFormat:@"%lu",
     self.model->data_array.size()];
    
    myData.latitude =  self.annotation.coordinate.latitude;
    myData.longitude =  self.annotation.coordinate.longitude;
    
    myData.annotation.data_id = self.model->data_array.size();

    myData.my_texture_info = self.model->generateTextureInfo
    ([NSString stringWithUTF8String:myData.name.c_str()]);
    // Add the new data to data_array
    self.model->data_array.push_back(myData);

    
    self.addButton.enabled = NO;
    self.removeButton.enabled = YES;

    self.statusSegmentControl.enabled = true;
    self.statusSegmentControl.selectedSegmentIndex = 0;

    self.rootViewController.needUpdateAnnotations = YES;
}

- (IBAction)removeLocation:(id)sender {
    int i = self.annotation.data_id;
    [self.rootViewController.mapView removeAnnotation:
     self.model->data_array[i].annotation];
    self.model->data_array.erase(
                                 self.model->data_array.begin() + i );
    self.removeButton.enabled = NO;
}

- (IBAction)toggleEnable:(id)sender {
    if (self.annotation.point_type == landmark){
        int i = self.annotation.data_id;
        self.model->data_array[i].isEnabled =
        !self.model->data_array[i].isEnabled;
        
        // Update the pin color
        self.rootViewController.needUpdateAnnotations = YES;
    }
}

#pragma mark -----Exit-----
//-------------
// This method is for ipad
//-------------
- (IBAction)dismissModalVC:(id)sender {
    iOSViewController* parentVC = self.rootViewController;
    [self dismissViewControllerAnimated:YES completion:^{
        // call your completion method:
        [parentVC viewWillAppear:YES];
    }];
}
@end
