//
//  UINavigationController+rotation.m
//  Compass[transparent]
//
//  Created by dmiau on 7/28/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "UINavigationController+rotation.h"
#import "iOSViewController.h"


@implementation UINavigationController (rotation)

-(BOOL)shouldAutorotate {
    if ([[self.viewControllers objectAtIndex:0] isKindOfClass:
         [iOSViewController class]])
    {
        iOSViewController* rootViewController =
        [self.viewControllers objectAtIndex:0];
        return ![rootViewController.
                 UIConfigurations[@"UIRotationLock"] boolValue];
    }else{
        return false;
    }
}

@end
