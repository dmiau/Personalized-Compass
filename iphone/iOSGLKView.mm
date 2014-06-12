//
//  iOSGLKView.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 6/3/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSGLKView.h"

@implementation iOSGLKView

@synthesize renderer;

#pragma mark ---- initialization ----

- (id)initWithCoder:(NSCoder *)decoder{
    self = [super initWithCoder:decoder];
    return self;
}


- (id)initWithFrame:(CGRect)frame context:(EAGLContext *)context{
    
    self.context = context;
    
    // Configure renderbuffers created by the view
    self.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    self.drawableDepthFormat = GLKViewDrawableDepthFormat24;
//    self.drawableStencilFormat = GLKViewDrawableStencilFormat8;
    // Enable multisampling
    self.drawableMultisample = GLKViewDrawableMultisample4X;
    //self.multipleTouchEnabled = YES;
    
    self.enableSetNeedsDisplay = YES;

    //-------------------
    // Initialize the render
    //-------------------
    self.renderer = compassRender::shareCompassRender();
    self.renderer->initRenderView(frame.size.width,
                                  frame.size.height);
    
    NSLog(@"width: %f", frame.size.width);
    NSLog(@"height: %f", frame.size.height);
    
    //[self setNeedsDisplay];
    return self;
}

- (void)awakeFromNib
{

}

#pragma mark ---- Rendering ----
//=====================
// drawRect whenever display is needed
//=====================
-(void) drawRect:(CGRect)bounds
{

    //-----------------
    // Clear background and call render
    //-----------------
    [self setOpaque:NO];
    
//    glClearColor(0.0, 0.0, 0.0, 0.5);
    
    glClearColor([renderer->model->configurations[@"bg_color"][0] floatValue]/255,
                 [renderer->model->configurations[@"bg_color"][1] floatValue]/255,
                 [renderer->model->configurations[@"bg_color"][2] floatValue]/255,
                 [renderer->model->configurations[@"bg_color"][3] floatValue]/255);
    
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable( GL_DEPTH_TEST);
    renderer->render();
    // glFlush draws the content provided by the routine to the view
    glFlush();
}
@end

