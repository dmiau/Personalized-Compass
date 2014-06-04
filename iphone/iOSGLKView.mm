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

#pragma mark ---- timer function ----
// Timer callback method
- (void)timerFired:(id)sender
{
    // it's the update routine for our C/C++ renderer
    //    renderer.update();
    //it sets the flag that windows has to be redrawn
    [self setNeedsDisplay];
}

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
    self.drawableStencilFormat = GLKViewDrawableStencilFormat8;
    // Enable multisampling
    self.drawableMultisample = GLKViewDrawableMultisample4X;
    
    self.enableSetNeedsDisplay = YES;
    
    [self setNeedsDisplay];
    
    //-----------------
    // Timer initialization
    //-----------------
    //when UI is created and properly initialized,
    // we set the timer to continual, real-time rendering
    //a 1ms time interval
    renderTimer = [NSTimer timerWithTimeInterval:0.015
                                          target:self
                                        selector:@selector(timerFired:)
                                        userInfo:nil
                                         repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:renderTimer
                                 forMode:NSDefaultRunLoopMode];
    //Ensure timer fires during resize
    [[NSRunLoop currentRunLoop]
     addTimer:renderTimer
     forMode:UITrackingRunLoopMode];
    
    return self;
}

- (void)awakeFromNib
{
    //-------------------
    // Initialize the render
    //-------------------
    self.renderer = compassRender::shareCompassRender();
    self.renderer->initRenderView(self.frame.size.width,
                                  self.frame.size.height);
    
    NSLog(@"width: %f", self.frame.size.width);
    NSLog(@"height: %f", self.frame.size.height);
}

#pragma mark ---- Rendering ----
//=====================
// drawRect whenever display is needed
//=====================
-(void) drawRect:(CGRect)bounds
{
    renderer->updateViewport(bounds.origin.x, bounds.origin.y,
                             bounds.size.width, bounds.size.height);
    //-----------------
    // Clear background and call render
    //-----------------
    [self setOpaque:NO];
    
    glClearColor(0.0, 0.0, 0.0, 0.5);
    /*
    glClearColor([renderer->model->configurations[@"bg_color"][0] floatValue]/255,
                 [renderer->model->configurations[@"bg_color"][1] floatValue]/255,
                 [renderer->model->configurations[@"bg_color"][2] floatValue]/255,
                 [renderer->model->configurations[@"bg_color"][3] floatValue]/255);
    */
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable( GL_DEPTH_TEST);
    renderer->render();
    // glFlush draws the content provided by the routine to the view
    glFlush();
}
@end

