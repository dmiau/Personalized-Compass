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
    camera.fov = 35;
    
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
    dev_radius              = 0;
    label_flag              = true;
    watchMode               = false;
    trainingMode            = false;
    wedgeMode               = false;
    isOverviewMapEnabled    = false;
    isInteractiveLineVisible=false;
    isInteractiveLineEnabled=false;
    isNorthIndicatorOn      = true;
    
    interactiveLineRadian   = 0;
    isAnswerLinesEnabled    = false;
    isCompassTouched        = false;
    degree_vector.clear();
    loadParametersFromModelConfiguration();
#ifndef __IPHONE__
    emulatediOS = EmulatediOS(model);
    cross.applyDeviceStyle(DESKTOP);
#else
    cross.applyDeviceStyle(PHONE);
#endif
    // near and far are calculated from the point of view of an observer
    return EXIT_SUCCESS;
}

//---------------
// Load parameters from configuration files
//---------------
void compassRender::loadCentroidFromModelConfiguration(){
    compass_centroid.x =
    [model->configurations[@"compass_centroid"][0] floatValue];
    compass_centroid.y =
    [model->configurations[@"compass_centroid"][1] floatValue];
}


void compassRender::loadParametersFromModelConfiguration(){
    loadCentroidFromModelConfiguration();
    compass_disk_radius = [model->configurations[@"compass_disk_radius"] floatValue];
    central_disk_radius = [model->configurations[@"central_disk_radius"] floatValue];
//    compass_disk_radius *
//    [model->configurations[@"central_disk_to_compass_disk_ratio"] floatValue];
}

//---------------
// Initialize the "viewing" part of the render
//---------------
int compassRender::initRenderView(float win_width, float win_height){
    view_width = win_width; view_height = win_height;
    
    camera.viewPos.z = win_height/2 * tan((90-camera.fov/2)/180*3.14);

    // Transformations for the projection
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    
    updateViewport(0, 0, view_width, view_height);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    //    gluLookAt(camera.viewPos.x, camera.viewPos.y, camera.viewPos.z,
    //              0, 0, 0,
    //              camera.viewUp.x, camera.viewUp.y, camera.viewUp.z);
    // Push the scene in the negative-z direction
    // This is just to simulate gluLoookAt
    glTranslatef(0, 0, -camera.viewPos.z);

    return EXIT_SUCCESS;
}

#pragma mark ------------- Handle window resize/update -------------


void compassRender::updateViewport
(GLint x, GLint y, GLsizei width, GLsizei height)
{
    glViewport (x, y, width, height);
    
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
// compassRender constructor
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
        myGluPerspective(camera.fov, (float)view_width/(float)view_height, 1, 3 * camera.viewPos.z);
        
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

    if (isOverviewMapEnabled &&
        model->tilt > -0.0001)
    {
        glPushMatrix();
        // Note UIView's coordinate system is diffrent than OpenGL's
        glTranslatef(-view_width/2, view_height/2, 0);
        glRotatef(180, 1, 0, 0);
        drawBoxInView(box4Corners, false);
        glPopMatrix();
    }

#ifndef __IPHONE__
    //--------------
    // Draw debug info
    //--------------
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if ([prefs boolForKey:@"isDevMode"]){
        glColor4f(1, 0, 0, 1);
        glLineWidth(2);
        drawCircle(0, 0, dev_radius, 50, false);
    }
    
    //--------------
    // Draw the emulated iOS
    //--------------
    if (emulatediOS.is_enabled){
        emulatediOS.render(this);
    }
#endif
    //--------------
    // Draw compass
    //--------------
    NSString* personalized_compass_status =
    model->configurations[@"personalized_compass_status"];
    
    if ([personalized_compass_status isEqualToString:@"on"]){
        
        //--------------
        // Draw compass ref point
        //--------------
        if (compassRefDot.isVisible)
            compassRefDot.render();
                
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
        
        drawWayfindingAid(renderParamStruct);
        glPopMatrix();
    }
    
    // [Delete] Not sure the function of this
//    else if (watchMode){
//        drawClearWatch();
//    }
    glDisableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_VERTEX_ARRAY);
    
    //--------------
    // Draw cross
    //--------------
    if (cross.isVisible){
        cross.render();
    }
    //--------------
    // Draw interactive line
    //--------------
    if (isAnswerLinesEnabled){
        glPushMatrix();
        glRotatef(model->camera_pos.orientation, 0, 0, -1);
        drawAnswerLines();
        
        glPopMatrix();
    }
    if (isInteractiveLineVisible)
        drawInteractiveLine();
    
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