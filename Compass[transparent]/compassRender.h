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
#import "GLString.h"
// http://stackoverflow.com/questions/4714698/mixing-objective-c-m-mm-c-cpp-files

typedef struct {
    GLdouble x,y,z;
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

// Note the filter functions are defined in compassModel.mm
//


enum style_enum {
    BIMODAL = 1,
    REAL_RATIO = 2,
    THRESHOLD_STICK = 3
};

typedef struct{
    filter_enum filter_type;
    style_enum style_type;
    int filter_fun_param;
} RenderParamStruct;

RenderParamStruct makeRenderParams(filter_enum filter_type, style_enum style_type);

//-------------
class compassRender
{
public:
    
    // Compass presenation parameters
    float glDrawingCorrectionRatio;
    float compass_scale;
    float compass_radius; // The size of compass relative to the canvas size
    int half_canvas_size; // Specify the boundary of orthographic projection
    float central_disk_radius;
    recVec compass_centroid;
    compassMdl* model;
    
    // Parameters for perspective projection
    float orig_wigth;
    float orig_height;
    float fov;
    
    // String parameters
    bool label_flag;
    float label_size;
	NSMutableDictionary *stringAttrib; // Text attributes
	
	GLString *label_string;
    
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
    void updateProjection(GLdouble aspect_ratio);
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
    
};

#endif /* defined(__compass__drawing__) */
