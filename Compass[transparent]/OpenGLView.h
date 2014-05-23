//
//  OpenGLView.h
//  exploration
//
//  Created by dmiau on 2/25/14.
//  Copyright (c) 2014 Daniel Miau. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "compassRender.h"

@interface OpenGLView : NSOpenGLView
{
    NSTimer* renderTimer;
    // current window/screen height and width
    GLint viewWidth;
    GLint viewHeight;
}

@property compassRender* renderer;

+ (NSOpenGLPixelFormat*) basicPixelFormat;

- (void) drawRect:(NSRect) bounds;

- (void) drawMainWindow:(NSRect) bounds;
- (void) drawStyleWindow:(NSRect) bounds;
@end
