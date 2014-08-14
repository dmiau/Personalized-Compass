//
//  SnapshotDetailViewController.m
//  Compass[transparent]
//
//  Created by dmiau on 7/22/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "SnapshotDetailViewController.h"
#import "xmlParser.h"
#import "AppDelegate.h"

@interface SnapshotDetailViewController ()

@end

@implementation SnapshotDetailViewController
@synthesize snapshot_id;

- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        cache_kml_filename = nil;
        cache_data_array.clear();
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
    if (cache_kml_filename != nil){
        self.mySnapshot->selected_ids.clear();
        
        // Update selected IDs
        for (int i = 0; i < self.model->data_array.size(); ++i){
            if (self.model->data_array[i].isEnabled){
                self.mySnapshot->selected_ids.push_back(i);
            }
        }
        
        self.model->location_filename = cache_kml_filename;
        self.model->data_array = cache_data_array;
        cache_kml_filename = nil;
        cache_data_array.clear();
    }
    
    // Generated selected ID string
    self.selectedIDTextView.text =
    [NSString stringWithFormat:@"%lu selected", self.mySnapshot->selected_ids.size()];
    
    
    //-------------------
    // Change navigation bar color
    //-------------------
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    UINavigationController *myNavigationController =
    app.window.rootViewController;
    
    NSDictionary *navbarTitleTextAttributes =
    [NSDictionary dictionaryWithObjectsAndKeys:
     [UIColor blueColor],UITextAttributeTextColor,
     [UIColor blackColor], UITextAttributeTextShadowColor,nil];
    
    [myNavigationController.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
    myNavigationController.navigationBar.tintColor = [UIColor blueColor];
    
    myNavigationController.navigationBar.barTintColor =
    [UIColor whiteColor];
    myNavigationController.navigationBar.topItem.title = @"Snapshot Detail";
    
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.model = compassMdl::shareCompassMdl();
    self.mySnapshot = &(self.model->snapshot_array[snapshot_id]);
    
    // Do any additional setup after loading the view.
    self.titleTextField.text = self.mySnapshot->name;
    self.noteTextField.text = self.mySnapshot->notes;
    self.dateTextField.text = self.mySnapshot->date_str;
    self.addressView.text = self.mySnapshot->address;
    
    NSString *address;
    CLLocation *location = [[CLLocation alloc]
                            initWithLatitude:self.mySnapshot->coordinateRegion.center.latitude
                            longitude:self.mySnapshot->coordinateRegion.center.longitude];
    
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
    
    self.mySnapshot->name = self.titleTextField.text;
    self.mySnapshot->notes = self.noteTextField.text;
}

#pragma mark -----Exit-----


- (IBAction)go2LocationView:(id)sender {
    // Temporay swap out some data
    cache_kml_filename = self.model->location_filename;
    self.model->location_filename = self.mySnapshot->kmlFilename;
    
    cache_data_array = self.model->data_array;
    self.model->data_array = readLocationKml
    (self.model,self.mySnapshot->kmlFilename);
    
    
    //-----------------
    // Restore selection status
    //-----------------
    for (int i = 0; i < self.model->data_array.size(); ++i){
        self.model->data_array[i].isEnabled = false;
    }
    for(vector<int>::iterator it = self.mySnapshot->selected_ids.begin();
        it != self.mySnapshot->selected_ids.end(); ++it)
    {
        self.model->data_array[*it].isEnabled = true;
    }
    
    
    [self performSegueWithIdentifier:@"snapshot2LocationViewSegue" sender:nil];
}

@end
