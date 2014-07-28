//
//  UINavigationController+rotation.m
//  Compass[transparent]
//
//  Created by dmiau on 7/28/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "UINavigationController+rotation.h"
#import "compassModel.h"

@implementation UINavigationController (rotation)

-(BOOL)shouldAutorotate {
    compassMdl*  model = compassMdl::shareCompassMdl();
    return ![model->configurations[@"UIRotationLock"] boolValue];
}

@end
