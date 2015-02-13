//
//  iOSTestAuthoringViewController.m
//  Compass[transparent]
//
//  Created by Daniel on 2/12/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#import "iOSTestAuthoringViewController.h"
#import "AppDelegate.h"

@interface iOSTestAuthoringViewController ()

@end

@implementation iOSTestAuthoringViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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


- (void)viewWillAppear:(BOOL)animated {
    
    self.authoringModeControl.on = (self.rootViewController.testManager->testManagerMode == AUTHORING);
    //-------------------
    // Change navigation bar color
    //-------------------
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    UINavigationController *myNavigationController =
    app.window.rootViewController;
    myNavigationController.navigationBar.topItem.title = @"Authoring Pane";
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

- (IBAction)toggleAuthoringMode:(UISwitch*)sender {
    self.rootViewController.UIConfigurations[@"UIToolbarMode"]
    = @"Development";
    if (sender.on){
        self.rootViewController.UIConfigurations[@"UIToolbarMode"]
        = @"Authoring";
        self.rootViewController.testManager->setAuthoringMode(YES);        
    }else{
        self.rootViewController.testManager->setAuthoringMode(NO);
    }
    self.rootViewController.UIConfigurations[@"UIToolbarNeedsUpdate"]
    = [NSNumber numberWithBool:true];
}


@end
