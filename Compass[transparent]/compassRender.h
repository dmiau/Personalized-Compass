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
typedef UIFont NSFont;
typedef UIColor NSColor;
#import "Texture2D.h"
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
    float compass_disk_radius;    // Specify the radius of the compass disk (in pixels)

    float central_disk_radius;  // Specify the radius of the blue dots of the compass
    recVec compass_centroid;    // Specify the centroid of the compass *in OpenGL frame*

    //----------------
    // Parameters for setting up perspective projection, etc.
    //----------------
    // Parameters for perspective projection
    float view_width;           // The height of the view (in pixels)
    float view_height;          // The width of the view (in pixels)
    float fov;
    
    // Parameters for the emulated device
    float em_ios_width;         // emulated ios screen width (in pixels)
    float em_ios_height;        // emulated ios screen height (in pixels)
    float em_watch_radius;      // emulated watch radius
    
    float true_ios_width;       // ios view width (in pixels)
    float true_ios_height;      // ios view height (in pixels)
    float true_watch_radius;    // watch radius (in pixels)
    
    //----------------
    // Lable related stuff
    //----------------
    // String parameters
    bool label_flag; // Indicates whether labels to be drawn or not
    
    void initTextureArray();
    texture_info generateTextureInfo(NSString *label);
    
#ifndef __IPHONE__
	GLString *label_string;
#endif
    
    // Camera handling
    recCamera camera;
    
    //-------------------
    // Overview map stuff
    //-------------------
    bool isOverviewMapEnabled;
    CGPoint box4Corners[4];

    //-------------------
    // Displaying iOS box in OSX
    //-------------------
    bool isiOSBoxEnabled;
    // The four corners of the iOS display
    // (is NSView coordinates)
    CGPoint iOSFourCornersInNSView[4];
    
    bool isiOSMaskEnabled;
    
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
    int initRenderView(float view_width, float view_height);

    
    //-----------------
    // Render
    //-----------------
    void render();
    void render(RenderParamStruct renderParamStruct);
    
    void resetCamera();
    void updateViewport(GLint x, GLint y, GLsizei width, GLsizei height);
    void updateProjection(GLfloat aspect_ratio);
    void loadParametersFromModelConfiguration();
    void loadCentroidFromModelConfiguration();

    //-----------------
    // Tools
    //-----------------
    double getMapWidthInMeters();
    double getMapHeightInMeters();
    double findBestEmptyOrienation(vector<double> orientation_array);
    CGPoint convertCompassPointToMapUV(CGPoint point, CGFloat window_width, CGFloat window_height);

    //-----------------
    // Control the scale of the compass
    //-----------------
    void adjustAbsoluteCompassScale(float scale);
    void incrementCompassRadisByFactor(float factor);
private:
    //-----------------
    // Drawing routines
    //-----------------
    void drawWayfindingAid(RenderParamStruct renderParamStruct);
    void drawTriangle(int central_disk_radius, float rotation, float height);
    label_info drawLabel(float rotation, float height,
                   texture_info my_texture_info);
    void drawCircle(float cx, float cy, float r, int num_segments, bool isSolid);
    
    BOOL drawBoxInCompass(double renderD2realDRatio);
    BOOL drawBoundaryCircle(double renderD2realDRatio);
    void drawBoxInView(CGPoint fourCorners[4]);
    void drawiOSMask(CGPoint fourCorners[4]);

    //    void drawClearWatch(); //Not sure the function of this.
    
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

#ifdef __IPHONE__
    void drawiOSText(NSString *string, int font_size,
                     CGFloat width, CGFloat height,
                     bool box_flag);
//    void drawiOSText(texture_info my_texture_info);
#endif
};

//-------------------------
// Tools
//-------------------------
void myGluPerspective(GLfloat fovy, GLfloat aspect,
                      GLfloat zNear, GLfloat zFar);

#endif /* defined(__compass__drawing__) */
