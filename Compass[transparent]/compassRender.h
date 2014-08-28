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
#import <MapKit/MapKit.h>

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
    THRESHOLD_STICK = 3,
    WEDGE = 4
};

typedef struct{
    filter_enum filter_type;
    style_enum style_type;
} RenderParamStruct;

RenderParamStruct makeRenderParams(filter_enum filter_type, style_enum style_type);


//--------------
// label info
//--------------
class label_info{
public:
    CGPoint centroid;
    double distance;
    float orientation;
    int data_id;
    
    // Wedge related info
    double aperture;
    double leg;
public:
    label_info(){
        distance = 0;
        centroid = CGPointMake(0, 0);
        orientation = 0;
        data_id = 0;
        aperture = 0.0;
        leg = 0.0;
    }
};

class texture_info{
public:
    CGSize size;
    uint texture_id;
    NSAttributedString *attr_str; // for debug purposes
};

//----------------------------------
// compassRender class
//----------------------------------
class compassRender
{
    //----------------
    // Properties
    //----------------
public:
    
    //----------------
    // References to external objects
    //----------------
    // need to include MapView for wedge drawing
    MKMapView *mapView;
    compassMdl* model;

    
    //----------------
    // Parameters for compass drawing
    //----------------
    // Indicates whether the watch mode is on or not
    bool wedgeMode;
    bool watchMode;
    bool trainingMode;
    
    // Compass presenation parameters
    float glDrawingCorrectionRatio;
    // the scale of the compass, a number between 0 and 1
    float compass_scale;
    int half_canvas_size; // Specify the boundary of orthographic projection
    float central_disk_radius;
    recVec compass_centroid; // Specify the centroid of the compass *in OpenGL frame*


    //----------------
    // Parameters for setting up perspective projection, etc.
    //----------------
    // Parameters for perspective projection
    float orig_width;
    float orig_height;
    float fov;
    
    //----------------
    // Lable related stuff
    //----------------
    // String parameters
    bool label_flag; // Indicates whether labels to be drawn or not

    vector<label_info> label_info_array;
    vector<texture_info> label_texture_array;
    
    void initTextureArray();
    texture_info generateTexture(NSString *label);
    
#ifndef __IPHONE__
	GLString *label_string;
#endif
    
    // Camera handling
    recCamera camera;
    
    // Overview map stuff
    bool isOverviewMapEnabled;
    CGPoint box4Corners[4];
    
private:
    // Compass rendering intermediate parameters
    double max_dist;

    
    //----------------
    // Methods
    //----------------
public:
    static compassRender* shareCompassRender();
    compassRender(); // constructor
    void init();
    int initRenderMdl();
    int initRenderView(float orig_width, float orig_height);

    
    //-----------------
    // Render
    //-----------------
    void render();
    void render(RenderParamStruct renderParamStruct);
    
    void resetCamera();
    void updateViewport(GLint x, GLint y, GLsizei width, GLsizei height);
    void updateProjection(GLfloat aspect_ratio);
    void loadParametersFromModelConfiguration();

    //-----------------
    // Tools
    //-----------------
    double getMapWidthInMeters();
    double getMapHeightInMeters();
    double findBestEmptyOrienation(vector<double> orientation_array);
    CGPoint convertCompassPointToMapUV(CGPoint point);
private:
    // Drawing routines
    void drawWayfindingAid(RenderParamStruct renderParamStruct);
    void drawTriangle(int central_disk_radius, float rotation, float height);
    void drawLabel(float rotation, float height, string name);
    void drawCircle(float cx, float cy, float r, int num_segments, bool isSolid);
    
    BOOL drawBox(double renderD2realDRatio);
    BOOL drawBoundaryCircle(double renderD2realDRatio);
    void drawOverviewBox();
    void drawClearWatch();
    
    // Wedge drawing routines
    void drawOneSide(double rotation, double width, double height,
                     double tx, double ty, double *out_leg, double *out_aperture);
    
    //-----------------
    // style related methods
    //-----------------
    
    style_enum hashStyleStr (NSString *inString);
    int applyStyle(style_enum style_type,
                   vector<int> &indices_for_rendering);
    
    void renderStyleRealRatio(vector<int> &indices_for_rendering);
    void renderStyleBimodal(vector<int> &indices_for_rendering);
    
    
    
    void renderStyleThresholdSticks(vector<int> &indices_for_rendering);
    void renderStyleWedge(vector<int> &indices_for_rendering);
    void renderBareboneCompass();

    CGSize makeGLFrameSize(NSAttributedString *attr_str);
#ifdef __IPHONE__
    void drawiOSText(NSString *string, int font_size,
                     CGFloat width, CGFloat height);
#endif
};

//-------------------------
// Tools
//-------------------------
void myGluPerspective(GLfloat fovy, GLfloat aspect,
                      GLfloat zNear, GLfloat zFar);

#endif /* defined(__compass__drawing__) */
