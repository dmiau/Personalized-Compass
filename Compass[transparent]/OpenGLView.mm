//
//  OpenGLView.m
//  exploration
//
//  Created by dmiau on 2/25/14.
//  Copyright (c) 2014 Daniel Miau. All rights reserved.
//

#import "OpenGLView.h"
#include <OpenGL/gl.h>
#include "commonInclude.h"
#include "compassRender.h"
#include "compassModel.h"

@implementation OpenGLView

@synthesize renderer;

#pragma mark ---- Accept External Command ----
//[todo]
//- (BOOL)acceptsFirstResponder
//{
//    return NO;
//}
//
//- (BOOL)becomeFirstResponder
//{
//    return  NO;
//}
//
//- (BOOL)resignFirstResponder
//{
//    return YES;
//}

-(void)flagsChanged:(NSEvent*)theEvent {
    if ([theEvent modifierFlags] & NSControlKeyMask) {
        NSLog(@"Ctrl key Down (again)!");
    }else if ([theEvent keyCode] == 59){
        NSLog(@"Key is up!");
    }
    NSLog(@"%d", [theEvent keyCode]);
}

- (void)keyDown:(NSEvent *)theEvent {
    NSLog(@"Key event received");
    [super keyDown:theEvent];
}


#pragma mark ---- Initialization ----
//========================
// Initialization sutff
//========================

// Timer callback method
- (void)timerFired:(id)sender
{
    // This is needed so the OpenGl view gets refreshed periodically
    // it's the update routine for our C/C++ renderer
//    renderer->updateProjection();
    //it sets the flag that windows has to be redrawn
    [self setNeedsDisplay:YES];
}


-(void)awakeFromNib
{
    //when UI is created and properly initialized,
    // we set the timer to continual, real-time rendering
    //a 1ms time interval
    renderTimer = [NSTimer timerWithTimeInterval:0.001
                                          target:self
                                        selector:@selector(timerFired:)
                                        userInfo:nil
                                         repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:renderTimer
                                 forMode:NSDefaultRunLoopMode];
    //Ensure timer fires during resize
    [[NSRunLoop currentRunLoop]
     addTimer:renderTimer
     forMode:NSEventTrackingRunLoopMode];
    
    
//    [self setBackgroundColor:[NSColor clearColor]];
//    [self setOpaque:NO];
    
}

// An excellenct reference from an ex-Microsoft developer
// http://www.dbiesiada.com/blog/2013/04/simple-skeleton-framework-for-cocoa-osx-opengl-application/

//========================
// pixel format definition
//========================
+ (NSOpenGLPixelFormat*) basicPixelFormat
{
    NSOpenGLPixelFormatAttribute attributes [] = {
        NSOpenGLPFAWindow,
        NSOpenGLPFADoubleBuffer,	// double buffered
        NSOpenGLPFADepthSize, (NSOpenGLPixelFormatAttribute)16, // 16 bit depth buffer
        (NSOpenGLPixelFormatAttribute)nil
    };
    return [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    //below code helps optimize Open GL context
    // initialization for the best available resolution
    // important for Retina screens for example
    if (self) {
        [self wantsBestResolutionOpenGLSurface];
    }
    
    return self;
}


- (void)prepareOpenGL
{
    // Synchronize buffer swaps with vertical refresh rate
    GLint swapInt = 1;
    [[self openGLContext]
     setValues:&swapInt
     forParameter:NSOpenGLCPSwapInterval];
    
    NSRect rectView = [self bounds];
    
    // *** important!
    // Need two init routines
    if ([[[self window] title] rangeOfString:@"Style"]
        .location == NSNotFound)
    {
        //--------------
        // Init for the main window
        //--------------
        renderer = compassRender::shareCompassRender();
        renderer->initRenderView(rectView.size.width, rectView.size.height);
    }else{
        //--------------
        // Init for the style window
        //--------------
        renderer = new compassRender;
        renderer->initRenderView(rectView.size.width/2, rectView.size.height/2);
    }
}

#pragma mark ---- Rendering ----
//=====================
// drawRect whenever display is needed
//=====================
-(void) drawRect:(NSRect)bounds
{
    
    //-----------------
    // Clear background and call render
    //-----------------
    glClearColor([renderer->model->configurations[@"bg_color"][0] floatValue]/255,
                 [renderer->model->configurations[@"bg_color"][1] floatValue]/255,
                 [renderer->model->configurations[@"bg_color"][2] floatValue]/255,
                 [renderer->model->configurations[@"bg_color"][3] floatValue]/255);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable( GL_DEPTH_TEST);

    
    // Need two drawing routines
    if ([[[self window] title] rangeOfString:@"Style"]
        .location == NSNotFound)
    {
        [self drawMainWindow:bounds];
    }else{
//        NSString* original_style = self.renderer->model->configurations[@"style_type"];
//        self.renderer->model->configurations[@"style_type"] = @"WEDGE";
        [self drawStyleWindow:bounds];
//        self.renderer->model->configurations[@"style_type"] = original_style;
    }
    
    //-----------------
    // Debugging code
    //-----------------
//    [self drawDebugTriangle:bounds];
    
    // glFlush draws the content provided by the routine to the view
    glFlush();
	glReportError();
    
    // int depth;
    // glGetIntegerv(GL_DEPTH_BITS, &depth);
    // NSLog(@"%i bits depth", depth);
}

- (void) drawDebugTriangle: (NSRect) bounds
{
    [[self openGLContext] makeCurrentContext];
    //-----------------
    // Handle window size/resize
    //-----------------

	if ((viewHeight != bounds.size.height) || (viewWidth != bounds.size.width))
    {
		viewHeight = bounds.size.height;
		viewWidth = bounds.size.width;
        
        renderer->initRenderView(bounds.size.width, bounds.size.height);
        renderer->updateViewport(bounds.origin.x, bounds.origin.y,
                                 bounds.size.width, bounds.size.height);
    }
    
    //-----------------
    // Make the OpenGL context to have transparent background
    //-----------------
    // http://www.cocoabuilder.com/archive/cocoa/82041-nsopenglview-with-transparent-background.html
    const GLint aValue = 0;
    [[self openGLContext] setValues:&aValue
                       forParameter:NSOpenGLCPSurfaceOpacity];
    //    const GLint aValue1 = 0;
    //    [[self openGLContext] setValues:&aValue1
    //                       forParameter:NSOpenGLCPSurfaceOrder];
    
    //    //-----------------
    //    // Clear background and call render
    //    //-----------------
    ////    glClearColor(0.0, 0.0, 0.0, 0.0);
    //    glClearColor([renderer->model->configurations[@"bg_color"][0] floatValue]/255,
    //                 [renderer->model->configurations[@"bg_color"][1] floatValue]/255,
    //                 [renderer->model->configurations[@"bg_color"][2] floatValue]/255,
    //                [renderer->model->configurations[@"bg_color"][3] floatValue]/255);
    //
    //    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    //    glEnable( GL_DEPTH_TEST);
    glEnableClientState(GL_VERTEX_ARRAY);
    
    double width = bounds.size.width, height = bounds.size.height;
    
    
    cout << "bound width: " << bounds.size.width <<
    " bound height: " << bounds.size.height << endl;
    
    glColor4f(1, 0, 0, 1);
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    
    float scale = self.renderer->glDrawingCorrectionRatio * self.renderer->compass_scale;
    glScalef(scale, scale, 1);
    
    
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

- (void) drawMainWindow:(NSRect) bounds
{
    [[self openGLContext] makeCurrentContext];
    //-----------------
    // Handle window size/resize
    //-----------------

	if ((viewHeight != bounds.size.height) || (viewWidth != bounds.size.width))
    {
		viewHeight = bounds.size.height;
		viewWidth = bounds.size.width;
        renderer->initRenderView(bounds.size.width, bounds.size.height);
        renderer->updateViewport(bounds.origin.x, bounds.origin.y,
                                 bounds.size.width, bounds.size.height);
    }

    //    //-----------------
    //    // Clear background and call render
    //    //-----------------
    ////    glClearColor(0.0, 0.0, 0.0, 0.0);
    //    glClearColor([renderer->model->configurations[@"bg_color"][0] floatValue]/255,
    //                 [renderer->model->configurations[@"bg_color"][1] floatValue]/255,
    //                 [renderer->model->configurations[@"bg_color"][2] floatValue]/255,
    //                [renderer->model->configurations[@"bg_color"][3] floatValue]/255);
    //
    //    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    //    glEnable( GL_DEPTH_TEST);
    
    //-----------------
    // Make the OpenGL context to have transparent background
    //-----------------
    // http://www.cocoabuilder.com/archive/cocoa/82041-nsopenglview-with-transparent-background.html
    const GLint aValue = 0;
    [[self openGLContext] setValues:&aValue
                       forParameter:NSOpenGLCPSurfaceOpacity];
    //    const GLint aValue1 = 0;
    //    [[self openGLContext] setValues:&aValue1
    //                       forParameter:NSOpenGLCPSurfaceOrder];
    

    renderer->render();

}

- (void) drawStyleWindow:(NSRect) bounds
{
    float x, y, width, height;
    x = bounds.origin.x; y = bounds.origin.y;
    width = bounds.size.width; height = bounds.size.height;
//    //-----------------
//    // Clear background and call render
//    //-----------------
////    glClearColor(0.0, 0.0, 0.0, 0.0);
//    glClearColor([renderer->model->configurations[@"bg_color"][0] floatValue]/255,
//                 [renderer->model->configurations[@"bg_color"][1] floatValue]/255,
//                 [renderer->model->configurations[@"bg_color"][2] floatValue]/255,
//                [renderer->model->configurations[@"bg_color"][3] floatValue]/255);
//    
//    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
//    glEnable( GL_DEPTH_TEST);

    //-----------------
    // Style(0,0)
    //-----------------
    renderer->updateViewport(x, y,width/2, height/2);
    renderer->glDrawingCorrectionRatio = 1;
    renderer->render(makeRenderParams(NONE, BIMODAL));

    //-----------------
    // Style(0,1)
    //-----------------
    renderer->updateViewport(width/2, 0, width/2, height/2);
    renderer->glDrawingCorrectionRatio = 1;
    renderer->render(makeRenderParams(K_NEARESTLOCATIONS, REAL_RATIO));

    //-----------------
    // Style(1,0)
    //-----------------
    renderer->updateViewport(0, height/2, width/2, height/2);
    renderer->glDrawingCorrectionRatio = 1;
    renderer->render(makeRenderParams(NONE, REAL_RATIO));
    
    //-----------------
    // Style(1,1)
    //-----------------
    renderer->updateViewport(width/2, height/2, width/2, height/2);
    renderer->glDrawingCorrectionRatio = 1;    
    renderer->render(makeRenderParams(K_ORIENTATIONS, BIMODAL));
}

#pragma mark ---- Error Reporting ----
//===================
// error reporting as both window message and debugger string
//===================
void reportError (char * strError)
{
    NSMutableDictionary *attribs = [NSMutableDictionary dictionary];
    [attribs setObject: [NSFont fontWithName: @"Monaco" size: 9.0f] forKey: NSFontAttributeName];
    [attribs setObject: [NSColor whiteColor] forKey: NSForegroundColorAttributeName];
    

	NSString * errString = [NSString stringWithFormat:@"Error: %s.", strError];
	NSLog (@"%@\n", errString);
}

// if error dump gl errors to debugger string, return error
GLenum glReportError (void)
{
	GLenum err = glGetError();
	if (GL_NO_ERROR != err)
		reportError ((char *) gluErrorString (err));
	return err;
}

#pragma mark ---- Mouse Event ----

- (void)mouseDown:(NSEvent *)theEvent{
    //----------------
    //http://lists.apple.com/archives/mac-opengl/2003/Feb/msg00069.html
    NSPoint mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    // This reports the correct mouse position.
    NSLog(@"MyOpenGLView: %@", NSStringFromPoint(mouseLoc));
    
    
    NSLog(@"***Mouse down");
	GLint viewport[4];
	GLubyte pixel[3];
    
	glReadPixels(mouseLoc.x,mouseLoc.y,1,1,
                 GL_RGB,GL_UNSIGNED_BYTE,(void *)pixel);
    
    // Print pixel colors
    printf("%d %d %d\n",pixel[0],pixel[1],pixel[2]);
    
    // http://stackoverflow.com/questions/6590763/mouse-events-bleeding-through-nsview
    // I want the event to bleed.
    [super mouseDown:theEvent];
}


- (void)magnifyWithEvent:(NSEvent *)event {
    NSLog(@"happy");
//    if ([event magnification] > 0)
//    {
//        self.renderer->compass_scale = self.renderer->compass_scale + 0.1;        
//    }
//    else if ([event magnification] < 0)
//    {
//        self.renderer->compass_scale = self.renderer->compass_scale - 0.1;
//    }    
}

- (void)rotateWithEvent:(NSEvent *)event {
    NSLog(@"happy");

}
@end