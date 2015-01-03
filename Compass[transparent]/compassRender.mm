//
//  drawing.cpp
//  compass
//
//  Created by dmiau on 11/6/13.
//  Copyright (c) 2013 Daniel Miau. All rights reserved.
//
#include "commonInclude.h"
#include <cmath>
#include <algorithm>
#include "compassRender.h"

#ifdef __IPHONE__
typedef UIFont NSFont;
typedef UIColor NSColor;
#import "Texture2D.h"
#endif

recVec glOrigin = {0.0, 0.0, 0.0};

#pragma mark ---------Renderer Initialization---------
// http://www.galloway.me.uk/tutorials/singleton-classes/
// http://www.yolinux.com/TUTORIALS/C++Singleton.html
compassRender* compassRender::shareCompassRender(){
    static compassRender* instance = NULL;
    
    if (!instance){ // Only allow one instance of class to be generated
        instance = new compassRender;
        instance->initRenderMdl();
    }
    return instance;
};


compassRender::compassRender(){
    initRenderMdl();
}

// sets the camera data to initial conditions
void compassRender::resetCamera()
{
    camera.fov = 30;
    
    camera.viewPos.x = 0.0;
    camera.viewPos.y = 0.0;
    camera.viewPos.z = 900; // This is the effective focal length
                            // This will be reinitialized again in
                            // initRenderView
    camera.viewUp.x = 0;
    camera.viewUp.y = 1;
    camera.viewUp.z = 0;
}

//---------------
// Initialize the "model" part of the render
//---------------
int compassRender::initRenderMdl(){
    model = compassMdl::shareCompassMdl();
    //--------------------
    // Initialize camera and shapes
    //--------------------
    resetCamera();     // Initialize the camera
    compass_scale           = [model->configurations[@"compass_scale"] floatValue];
    label_flag              = true;
    watchMode               = false;
    trainingMode            = false;
    wedgeMode               = false;
    isOverviewMapEnabled    = false;
    isiOSBoxEnabled         = false;
    
    for (int i = 0; i < 4; ++i){
        // Initialize all four corners to 0 first
        box4Corners[i].x = 0; box4Corners[i].y = 0;
        iOSFourCorners[i].x = 0; iOSFourCorners[i].y = 0;
    }
    
    glDrawingCorrectionRatio = 1;
    
    loadParametersFromModelConfiguration();
    
    // near and far are calculated from the point of view of an observer
    return EXIT_SUCCESS;
}

//---------------
// Load parameters from configuration files
//---------------
void compassRender::loadParametersFromModelConfiguration(){
    compass_scale = [model->configurations[@"compass_scale"] floatValue];
    
    compass_centroid.x =
    [model->configurations[@"compass_centroid"][0] floatValue];
    compass_centroid.y =
    [model->configurations[@"compass_centroid"][1] floatValue];
}

//---------------
// Initialize the "viewing" part of the render
//---------------
int compassRender::initRenderView(float win_width, float win_height){
    orig_width = win_width; orig_height = win_height;
    
    camera.viewPos.z = win_height/2 * tan((90-camera.fov/2)/180*3.14);
#ifndef __IPHONE__
    half_canvas_size = win_height/2;
#else
    half_canvas_size = win_width/2;
#endif
    
    central_disk_radius = half_canvas_size/10;    
    
    // Transformations for the projection
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    
    updateViewport(0, 0, orig_width, orig_height);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    //    gluLookAt(camera.viewPos.x, camera.viewPos.y, camera.viewPos.z,
    //              0, 0, 0,
    //              camera.viewUp.x, camera.viewUp.y, camera.viewUp.z);
    // Push the scene in the negative-z direction
    // This is just to simulate gluLoookAt
    glTranslatef(0, 0, -camera.viewPos.z);
    //#endif
    return EXIT_SUCCESS;
}

#pragma mark ------------- Handle window resize/update -------------


void compassRender::updateViewport
(GLint x, GLint y, GLsizei width, GLsizei height)
{
    glDrawingCorrectionRatio = orig_height / height;
    glViewport (x, y, width, height);
        
    viewport_width = width; viewport_height = height;
    
    updateProjection((float)width/(float)height);  // update projection matrix
}

void compassRender::updateProjection(GLfloat aspect_ratio){
	// set projection
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    
//    cout << "camera z: " << camera.viewPos.z << endl;
//    cout << "aspect ratio: " << camera.fov << endl;
    
    //fovy, asepect, zNear, zFar
    myGluPerspective(camera.fov, aspect_ratio, 1, 3 * camera.viewPos.z);
}

#pragma mark ---------core rendering routine---------
//--------------
// Tools
//--------------
RenderParamStruct makeRenderParams(
                                   filter_enum filter_type, style_enum style_type){
    
    RenderParamStruct renderParamStruct;
    renderParamStruct.filter_type = filter_type;
    renderParamStruct.style_type = style_type;
    return renderParamStruct;
}

//--------------
// Display
//--------------

void compassRender::render(){
    // Use the parameters supplied in configurations.json
    // if no input parameter is supplied.
    
    filter_enum filter_type =
    model->hashFilterStr(model->configurations[@"filter_type"]);
    
    style_enum style_type =
    hashStyleStr(model->configurations[@"style_type"]);
    
    RenderParamStruct renderParamStruct =
    makeRenderParams(filter_type, style_type);
    //    makeRenderParams(NONE, BIMODAL);
    render(renderParamStruct);
}

void compassRender::render(RenderParamStruct renderParamStruct) {
    glEnableClientState(GL_VERTEX_ARRAY);
    //    glEnable(GL_BLEND);
    //    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    //
    //    glHint( GL_LINE_SMOOTH_HINT, GL_NICEST );
    //    glHint( GL_POLYGON_SMOOTH_HINT, GL_NICEST);
    //    glEnable(GL_MULTISAMPLE);

#ifdef __IPHONE__
    //-------------
    // The following is needed for iOS to initialize OpenGL correctly.
    //-------------
    static bool once = FALSE;
    if (!once){
        //--------------
        // This is something strnage. On iPhone I have to keep
        // resetting the projection matrix...
        //--------------
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        //fovy, asepect, zNear, zFar
        myGluPerspective(camera.fov, (float)orig_width/(float)orig_height, 1, 3 * camera.viewPos.z);
        
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
        glTranslatef(0, 0, -camera.viewPos.z);
        once = TRUE;
    }
#endif

    glMatrixMode(GL_MODELVIEW);
    
    //--------------
    // Draw a box in the overview view
    //--------------
    // This is strange, I couldn't place this block below the draw compass code...
    glPushMatrix();
    if (isOverviewMapEnabled &&
        model->tilt > -0.0001)
    {
        // Note UIView's coordinate system is diffrent than OpenGL's
        glTranslatef(-viewport_width/2, viewport_height/2, 0);
        glRotatef(180, 1, 0, 0);
        drawBoxInView(box4Corners);
    }
    glPopMatrix();

    
    //--------------
    // Draw a box (to indicate the iOS diaplay area)
    // in the main view
    //--------------
    // This is strange, I couldn't place this block below the draw compass code...
    glPushMatrix();
    if (isiOSBoxEnabled &&
        model->tilt > -0.0001)
    {
        // Note UIView's coordinate system is diffrent than OpenGL's
        glTranslatef(-viewport_width/2, viewport_height/2, 0);
        glRotatef(180, 1, 0, 0);
        drawBoxInView(iOSFourCorners);
    }
    glPopMatrix();
    
    
    //--------------
    // Draw compass
    //--------------
    NSString* personalized_compass_status =
    model->configurations[@"personalized_compass_status"];
    
    if ([personalized_compass_status isEqualToString:@"on"]){
        glPushMatrix();
        // Do NOT do the following for wedge
        
        // Translate the compass to the desired screen location
        glTranslatef(compass_centroid.x, compass_centroid.y, 0);
        
        // [todo] Careful! Potential bug here...
        // tilt

#ifdef __IPHONE__
        if (model->tilt < -45){
            model->tilt = -45;
        }
#endif
        glRotatef(model->tilt, 1, 0, 0);
        
        glRotatef(model->camera_pos.orientation, 0, 0, -1);
        // scaling only applies to non-wedge styles
        float scale = glDrawingCorrectionRatio * compass_scale;
        glScalef(scale, scale, 1);
        
        drawWayfindingAid(renderParamStruct);
        glPopMatrix();
    }else if (watchMode){
        drawClearWatch();
    }
    glDisableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_VERTEX_ARRAY);
    
    //--------------
    // Draw wedge
    //--------------
    NSString* wedge_status = model->configurations[@"wedge_status"];
    if ([wedge_status isEqualToString:@"on"]){
        wedgeMode = true;
        renderParamStruct.style_type =
        hashStyleStr(@"WEDGE");
        glPushMatrix();
        drawWayfindingAid(renderParamStruct);
        wedgeMode = false;
        glPopMatrix();
    }

    //--------------
    // Draw iOS display region
    //--------------
    NSString* iOS_status = model->configurations[@"iOS_status"];
    if ([iOS_status isEqualToString:@"on"]){
//        wedgeMode = true;
//        renderParamStruct.style_type =
//        hashStyleStr(@"WEDGE");
//        glPushMatrix();
//        drawWayfindingAid(renderParamStruct);
//        wedgeMode = false;
//        glPopMatrix();
    }
    
    glDisableClientState(GL_VERTEX_ARRAY);
    
    // glFlush is called in OpenGLView
    //    glFlush();
}

//-------------------------
// Tools
//-------------------------
// http://maniacdev.com/2009/05/opengl-gluperspective-function-in-iphone-opengl-es


void __gluMakeIdentityf(GLfloat m[16])
{
    m[0+4*0] = 1; m[0+4*1] = 0; m[0+4*2] = 0; m[0+4*3] = 0;
    m[1+4*0] = 0; m[1+4*1] = 1; m[1+4*2] = 0; m[1+4*3] = 0;
    m[2+4*0] = 0; m[2+4*1] = 0; m[2+4*2] = 1; m[2+4*3] = 0;
    m[3+4*0] = 0; m[3+4*1] = 0; m[3+4*2] = 0; m[3+4*3] = 1;
}

void myGluPerspective(GLfloat fovy, GLfloat aspect, GLfloat zNear, GLfloat zFar)
{
    GLfloat m[4][4];
    GLfloat sine, cotangent;
    GLfloat radians = fovy / 2 * 3.14 / 180;
    
    GLfloat deltaZ = zFar - zNear;
    
    sine = sin(radians);
    if ((deltaZ == 0) || (sine == 0) || (aspect == 0))
    {
        return;
    }
    cotangent = cos(radians) / sine;
    
    __gluMakeIdentityf(&m[0][0]);
    m[0][0] = cotangent / aspect;
    m[1][1] = cotangent;
    m[2][2] = -(zFar + zNear) / deltaZ;
    m[2][3] = -1;
    m[3][2] = -2 * zNear * zFar / deltaZ;
    m[3][3] = 0;
    glMultMatrixf(&m[0][0]);
}