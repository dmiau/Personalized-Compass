//
//  iOSGLKView.h
//  Compass[transparent]
//
//  Created by Daniel Miau on 6/3/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#include "compassRender.h"

@interface iOSGLKView : GLKView{
    NSTimer* renderTimer;
}

@property compassRender* renderer;

- (void) drawRect:(CGRect) bounds;

@end
