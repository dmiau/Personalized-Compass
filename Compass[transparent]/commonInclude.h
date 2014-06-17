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

bool compareAscending
(const std::pair<float, int> &l, const std::pair<float, int> &r);

struct Vertex3D{
    GLfloat x;
    GLfloat y;
    GLfloat z;
    
};

// Open GL related stuff
struct Triangle3D{
    Vertex3D v1;
    Vertex3D v2;
    Vertex3D v3;
    
};

struct TriangleLine3D{
    Vertex3D v1;
    Vertex3D v2;
    Vertex3D v3;
    Vertex3D v4;
};

static inline Triangle3D Triangle3DMake(Vertex3D vertex1, Vertex3D vertex2, Vertex3D vertex3){
    Triangle3D triangle;
    triangle.v1 = vertex1;
    triangle.v2 = vertex2;
    triangle.v3 = vertex3;
    return triangle;
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
}
#endif