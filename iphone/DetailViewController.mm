//
//  DetailViewController.m
//  Compass[transparent]
//
//  Created by dmiau on 7/5/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.model = compassMdl::shareCompassMdl();        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.addressView.text = self.annotation.subtitle;
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
    self.annotation.title = self.titleTextField.text;
}

- (IBAction)addLocation:(id)sender {
// Right buttton tapped - add the pin to data_array
            data myData;
            myData.name = "custom";
            myData.annotation = self.annotation;

            myData.annotation.title = @"custom";
            myData.annotation.subtitle =
            [NSString stringWithFormat:@"%lu",
             self.model->data_array.size()];

            myData.latitude =  self.annotation.coordinate.latitude;
            myData.longitude =  self.annotation.coordinate.longitude;

            // Add the new data to data_array
            self.model->data_array.push_back(myData);
}
@end
