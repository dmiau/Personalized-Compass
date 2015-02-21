//
//  commonInclude.h
//  compass
//
//  Created by dmiau on 11/6/13.
//  Copyright (c) 2013 Daniel Miau. All rights reserved.
//

#ifndef compass_commonInclude_h
#define compass_commonInclude_h

#include <iostream>
#include <string>
#include <vector>
#import <CoreGraphics/CGGeometry.h>

#ifdef __IPHONE__

#elif __APPLE__
#include <GLUT/glut.h>
#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#else
#include <GL/glut.h>
#include <GL/gl.h>
#include <GL/glu.h>
#endif

////---------------
//// Needed for string conversion
////---------------
//#ifndef __IPHONE__
//#import <Cocoa/Cocoa.h>
//#else
//#import <UIKit/UIKit.h>
//#endif


using namespace std;

inline bool compareAscending(const pair<float, int> &l,
                             const pair<float, int> &r)
{
    return(l.first < r.first);
}

inline bool compareDecending(const pair<float, int> &l,
                             const pair<float, int> &r)
{
    return(l.first > r.first);
}

inline string convert2CPPString(NSString *nsstring){
    string out_str = string([nsstring UTF8String]);
    return out_str;
}

inline CGPoint rotateCCW(CGPoint xy, double deg){
    CGPoint out_xy;
    double theta = deg/180 * M_PI; // in radians
    out_xy.x = cos(theta)*xy.x - sin(theta)*xy.y;
    out_xy.y = sin(theta)*xy.x + cos(theta)*xy.y;
    return out_xy;
}

struct Vertex3D{
    GLfloat x;
    GLfloat y;
    GLfloat z;
    
};

// Open GL related stuff
//------------------
// Triangle
//------------------
struct Triangle3D{
    Vertex3D v1;
    Vertex3D v2;
    Vertex3D v3;
    
};

static inline Triangle3D Triangle3DMake(Vertex3D vertex1, Vertex3D vertex2, Vertex3D vertex3){
    Triangle3D triangle;
    triangle.v1 = vertex1;
    triangle.v2 = vertex2;
    triangle.v3 = vertex3;
    return triangle;
};

//------------------
// Simple Line
//------------------
struct Line3D{
    Vertex3D v1;
    Vertex3D v2;
};

static inline Line3D Line3DMake(Vertex3D vertex1, Vertex3D vertex2){
    Line3D line;
    line.v1 = vertex1;
    line.v2 = vertex2;
    return line;
};

//------------------
// Triangle Line
//------------------
struct TriangleLine3D{
    Vertex3D v1;
    Vertex3D v2;
    Vertex3D v3;
    Vertex3D v4;
};

static inline TriangleLine3D TriangleLine3DMake(Vertex3D vertex1, Vertex3D vertex2, Vertex3D vertex3){
    TriangleLine3D triangle;
    triangle.v1 = vertex1;
    triangle.v2 = vertex2;
    triangle.v3 = vertex3;
    triangle.v4 = vertex1;
    return triangle;
};

static inline Vertex3D Vertex3DMake(GLfloat x, GLfloat y, GLfloat z){
    Vertex3D vertex;
    vertex.x = x;
    vertex.y = y;
    vertex.z = z;
    return vertex;
};

//----------------
// Rectangle Line
//----------------
struct RectangleLine3D{
    Vertex3D v1;
    Vertex3D v2;
    Vertex3D v3;
    Vertex3D v4;
    Vertex3D v5;
};

static inline RectangleLine3D RectangleLine3DMake
(Vertex3D vertex1, Vertex3D vertex2,
 Vertex3D vertex3, Vertex3D vertex4)
{
    RectangleLine3D rectangle;
    rectangle.v1 = vertex1;
    rectangle.v2 = vertex2;
    rectangle.v3 = vertex3;
    rectangle.v4 = vertex4;
    rectangle.v5 = vertex1;
    return rectangle;
};

#endif