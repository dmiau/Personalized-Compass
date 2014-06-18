//
//  iOSGLKView.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 6/3/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSGLKView.h"
#include "commonInclude.h"

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
    self.context.multiThreaded = YES;
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
    glClearColor([renderer->model->configurations[@"bg_color"][0] floatValue]/255,
                 [renderer->model->configurations[@"bg_color"][1] floatValue]/255,
                 [renderer->model->configurations[@"bg_color"][2] floatValue]/255,
                 [renderer->model->configurations[@"bg_color"][3] floatValue]/255);
    
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable( GL_DEPTH_TEST);
    
    //-----------------
    // Draw Personalized Compass
    //-----------------
    NSString* personalized_compass_status =
    self.renderer->model->configurations[@"personalized_compass_status"];
    
    if ([personalized_compass_status isEqualToString:@"on"]){
        renderer->render();
    }

    //-----------------
    // Draw Wedge
    //-----------------
    NSString* original_style = self.renderer->model->configurations[@"style_type"];
    NSString* wedge_status = self.renderer->model->configurations[@"wedge_status"];
    
    if ([wedge_status isEqualToString:@"on"]){
        // call twice for debug pruposes
        bool original_label_flag = self.renderer->label_flag;
        self.renderer->label_flag = false;
        self.renderer->model->configurations[@"style_type"] = @"WEDGE";
        renderer->render();    
        self.renderer->label_flag = original_label_flag;
        self.renderer->model->configurations[@"style_type"] = original_style;
    }
    
    //-----------------
    // Debugging code
    //-----------------
//    [self drawDebugTriangle:bounds];
    
    // glFlush draws the content provided by the routine to the view
    glFlush();
}

- (void) drawDebugTriangle: (NSRect) bounds
{    glEnableClientState(GL_VERTEX_ARRAY);
    
    double width = bounds.size.width-10, height = bounds.size.height-10;
    
    
    cout << "bound width: " << bounds.size.width <<
    " bound height: " << bounds.size.height << endl;
    glColor4f(0, 1, 0, 1);
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    
    glTranslatef(-width/2, -height/2, 0);
    //    cout << "rotation: " << rotation << endl;
    Vertex3D    vertex1 = Vertex3DMake(0, 0, 0);
    Vertex3D    vertex2 = Vertex3DMake(width, 0, 0);
    Vertex3D    vertex3 = Vertex3DMake(width, height, 0);
    
    Triangle3D  triangle = Triangle3DMake(vertex1, vertex2, vertex3);
    glVertexPointer(3, GL_FLOAT, 0, &triangle);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    glPopMatrix();
    glDisableClientState(GL_VERTEX_ARRAY);
}
@end

