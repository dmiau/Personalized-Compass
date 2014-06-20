//
//  bottomUpSegue.m
//  lab_ViewProgramming[ios]
//
//  Created by dmiau on 6/19/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "bottomUpSegue.h"

@implementation bottomUpSegue

-(void)perform {
    //UIViewAnimationOptions options;
    UIViewController *sourceViewController = (UIViewController*)[self sourceViewController];
    UIViewController *destinationController = (UIViewController*)[self destinationViewController];
    
    CATransition* transition = [CATransition animation];
    transition.duration = 0.2f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    transition.subtype = kCATransitionFromTop; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    
    [destinationController.view.layer addAnimation:transition forKey:kCATransition];
    [sourceViewController presentViewController:destinationController animated:YES completion:nil];
}

@end
