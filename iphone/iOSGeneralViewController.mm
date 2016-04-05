//
//  iOSGeneralViewController.m
//  Compass[transparent]
//
//  Created by Daniel on 4/4/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "iOSGeneralViewController.h"
#import "AppDelegate.h"

@interface iOSGeneralViewController ()

@end

@implementation iOSGeneralViewController


- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
        // Do something
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.rootViewController.mapView.mapType == MKMapTypeStandard){
        self.mapSegmentControl.selectedSegmentIndex = 0;
    }else if (self.rootViewController.mapView.mapType == MKMapTypeHybrid){
        self.mapSegmentControl.selectedSegmentIndex = 1;
    }else if (self.rootViewController.mapView.mapType == MKMapTypeSatelliteFlyover){
        self.mapSegmentControl.selectedSegmentIndex = 2;
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
     [UIColor whiteColor], UITextAttributeTextShadowColor,nil];
    
    
    [myNavigationController.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
    myNavigationController.navigationBar.tintColor = [UIColor blackColor];
    
    myNavigationController.navigationBar.barTintColor =
    [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    myNavigationController.navigationBar.topItem.title = @"General";
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)setMapSegmentControl:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSString *label = [segmentedControl
                       titleForSegmentAtIndex: [segmentedControl selectedSegmentIndex]];
    
    if ([label isEqualToString:@"None"]){

    }else if ([label isEqualToString:@"Standard"]){
        self.rootViewController.mapView.mapType = MKMapTypeStandard;
    }else if ([label isEqualToString:@"Hybrid"]){
        self.rootViewController.mapView.mapType = MKMapTypeHybrid;
    }else if ([label isEqualToString:@"Satellite"]){
        self.rootViewController.mapView.mapType = MKMapTypeSatelliteFlyover;
    }
    [self.rootViewController.glkView setNeedsDisplay];
}

@end
