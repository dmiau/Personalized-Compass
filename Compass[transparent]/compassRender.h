//
//  compassRender.h
//  compass
//
//  Created by dmiau on 11/6/13.
//  Copyright (c) 2013 Daniel Miau. All rights reserved.
//

#ifndef __compass__drawing__
#define __compass__drawing__

#include "compassModel.h"
#import <Foundation/Foundation.h>

#ifndef __IPHONE__
#import "GLString.h"
#else
#import "GLString.h"
#import <GLKit/GLKit.h>
#endif


// http://stackoverflow.com/questions/4714698/mixing-objective-c-m-mm-c-cpp-files

typedef struct {
    GLfloat x,y,z;
} recVec;


typedef struct {
	recVec viewPos; // View position
	recVec viewUp; // View up direction
	float fov; // field of view
//	GLint viewWidth, viewHeight; // current window/screen height and width
} recCamera;

//-------------
// Define different types of filter and styles
//-------------

// Filter functions are defined in compassModel.mm
enum style_enum {
    BIMODAL = 1,
    REAL_RATIO = 2,
    THRESHOLD_STICK = 3
};

typedef struct{
    filter_enum filter_type;
    style_enum style_type;
} RenderParamStruct;

RenderParamStruct makeRenderParams(filter_enum filter_type, style_enum style_type);

//-------------
class compassRender
{
public:
    
    // Compass presenation parameters
    float glDrawingCorrectionRatio;
    // the scale of the compass, a number between 0 and 1
    float compass_scale;
    // the centroid of the compass in percentage of the viewable area
    // (0.5, 0.5) means the centroid is at the center of the screen
    CGPoint compassCentroidXYPercentage;
    int half_canvas_size; // Specify the boundary of orthographic projection
    float central_disk_radius;
    recVec compass_centroid;
    compassMdl* model;
    
    // Parameters for perspective projection
    float orig_width;
    float orig_height;
    float fov;
    
    // String parameters
    bool label_flag;
    float label_size;
	NSMutableDictionary *stringAttrib; // Text attributes
	
#ifndef __IPHONE__
	GLString *label_string;
#endif
    
    // Camera handling
    recCamera camera;
private:
    // Compass rendering intermediate parameters
    double max_dist;
    
public:
    static compassRender* shareCompassRender();
    compassRender(); // constructor
    void init();
    int initRenderMdl();
    int initRenderView(float orig_width, float orig_height);

    
    //
    void render();
    void render(RenderParamStruct renderParamStruct);
    
    void resetCamera();
    void updateViewport(GLint x, GLint y, GLsizei width, GLsizei height);
    void updateProjection(GLfloat aspect_ratio);
private:
    // Drawing routines
    void drawCompass(RenderParamStruct renderParamStruct);
    void drawTriangle(int central_disk_radius, float rotation, float height);
    void drawLabel(float rotation, float height, string name);
    void drawCircle(float cx, float cy, float r, int num_segments);
    
    
    style_enum hashStyleStr (NSString *inString);
    int applyStyle(style_enum style_type,
                   vector<int> &indices_for_rendering);
    
    void renderStyleRealRatio(vector<int> &indices_for_rendering);
    void renderStyleBimodal(vector<int> &indices_for_rendering);
    void renderStyleThresholdSticks(vector<int> &indices_for_rendering);
    
#ifdef __IPHONE__
    void drawiOSText(NSString *string, int font_size,
                     CGFloat width, CGFloat height);
    CGSize makeGLFrameSize(NSAttributedString *attr_str);
#endif
    
};

//-------------------------
// Tools
//-------------------------
void myGluPerspective(GLfloat fovy, GLfloat aspect,
                      GLfloat zNear, GLfloat zFar);

#endif /* defined(__compass__drawing__) */
