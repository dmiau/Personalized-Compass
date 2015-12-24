//
//  generalVC.m
//  Compass[transparent]
//
//  Created by Hong Guo on 12/12/15.
//  Copyright © 2015 dmiau. All rights reserved.
//

#import "generalVC.h"
#import "AppDelegate.h"

@interface generalVC ()

@end

@implementation generalVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 250.0)];
    [path addLineToPoint:CGPointMake(380.0, 250)];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor grayColor] CGColor];
    shapeLayer.lineWidth = 2.0;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    
    [self.view.layer addSublayer:shapeLayer];
    
    [_satelliteSwitch addTarget:self
                 action:@selector(switchSatellite:)
       forControlEvents:UIControlEventValueChanged];
    
    //-------------------
    // Set the rootViewController
    //-------------------
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    UINavigationController *myNavigationController =
    app.window.rootViewController;
    
    self.rootViewController =
    [myNavigationController.viewControllers objectAtIndex:0];
    
    _satelliteSwitch.on = (self.rootViewController.mapView.mapType == MKMapTypeStandard)
    ? NO : YES;
    
    
}

-(void) switchSatellite:(id) sender {
    UISwitch *slSwitch = (UISwitch *) sender;
    if (slSwitch.on) {
        [self.rootViewController.mapView setMapType:MKMapTypeSatelliteFlyover];
    } else {
        [self.rootViewController.mapView setMapType:MKMapTypeStandard];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
