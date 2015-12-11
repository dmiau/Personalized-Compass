//
//  settingTBVC.m
//  Compass[transparent]
//
//  Created by Hong Guo on 12/11/15.
//  Copyright © 2015 dmiau. All rights reserved.
//

#import "settingTBVC.h"

@interface settingTBVC ()

@end

@implementation settingTBVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
- (IBAction)backToMainView:(id)sender {
    CATransition* transition = [CATransition animation];
    transition.duration = .25;
    transition.timingFunction =
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    
    [self.navigationController.view.layer addAnimation:transition
                                                forKey:kCATransition];
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}



@end
