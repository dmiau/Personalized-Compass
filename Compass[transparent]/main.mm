//
//  main.m
//  Compass[transparent]
//
//  Created by dmiau on 3/19/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "compassModel.h"
#include "compassRender.h"

int main(int argc, const char * argv[])
{
    // Initialize the location model and the viewer model
    compassRender* render = compassRender::shareCompassRender();
    compassMdl* model = compassMdl::shareCompassMdl();
    return NSApplicationMain(argc, argv);
}
