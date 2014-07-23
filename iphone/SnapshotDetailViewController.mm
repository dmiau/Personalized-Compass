//
//  SnapshotDetailViewController.m
//  Compass[transparent]
//
//  Created by dmiau on 7/22/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "SnapshotDetailViewController.h"

@interface SnapshotDetailViewController ()

@end

@implementation SnapshotDetailViewController
@synthesize snapshot_id;

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
- (IBAction)dismissModalVC:(id)sender {

    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
