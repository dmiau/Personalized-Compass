//
//  iPadTabBarController.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 8/14/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iPadTabBarController.h"
#import "AppDelegate.h"
#import "iOSViewController.h"

@interface iPadTabBarController ()

@end

@implementation iPadTabBarController

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

- (IBAction)dismissModal:(id)sender {
    //-------------------
    // Set the rootViewController
    //-------------------
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    UINavigationController *myNavigationController =
    app.window.rootViewController;
    
    iOSViewController *rootViewController =
    [myNavigationController.viewControllers objectAtIndex:0];
    
    
    [self dismissViewControllerAnimated:YES completion:^{
        // call your completion method:
        [rootViewController viewWillAppear:YES];
    }];
}
@end