//
//  iOSViewController.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 6/3/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController.h"

@interface iOSViewController ()

@end

@implementation iOSViewController

#pragma mark ---- timer function ----
// Timer callback method
- (void)timerFired:(id)sender
{
    // it's the update routine for our C/C++ renderer
    //    renderer.update();
    //it sets the flag that windows has to be redrawn
    [self.glkView setNeedsDisplay];
}

#pragma mark ---- initialization ----
-(void)awakeFromNib
{
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
}

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
    
    // Create an OpenGL ES context and assign it to the view loaded from storyboard
    GLKView *view = (GLKView *)self.glkView;
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    // Configure renderbuffers created by the view
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.drawableStencilFormat = GLKViewDrawableStencilFormat8;
    // Enable multisampling
    view.drawableMultisample = GLKViewDrawableMultisample4X;
    
    view.enableSetNeedsDisplay = YES;
    
    [self.glkView setNeedsDisplay];    
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

@end
