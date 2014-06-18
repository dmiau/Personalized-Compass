//
//  compassRender+Bimodal.mm
//  Compass[transparent]
//
//  Created by Daniel Miau on 6/16/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//
#include "commonInclude.h"
#include "compassRender.h"
#include <vector>
#include <numeric>
#include <iostream>
#include <sstream>
using namespace std;

// Forward declaration
void calculateDistInBox(double width, double height, CGPoint aPoint,
                        double* dist, double* rotation);

//------------------------------------
// Bimodal
//------------------------------------
void compassRender::renderStyleWedge(vector<int> &indices_for_rendering){    
    ostringstream db_stream;
    
    // Assume indices_for_rendering stores sorted distances
    
    // Cache all the distance candidates into a vector
    vector <double> filtered_dist_list;
    for (int i = 0; i < indices_for_rendering.size(); ++i){
        int j = indices_for_rendering[i];
        filtered_dist_list.push_back(model->data_array[j].distance);
    }
    
    int landmark_n = filtered_dist_list.size();
    
    if (landmark_n <= 1){
        // In rare cases we may ended up with a single landmark?
        throw(runtime_error("Only single landmark!!"));
    }
    
    // Declarations
    CLLocationCoordinate2D myCoord;
    CGPoint screen_pt, center_pt;
    center_pt.x = orig_width/2;
    center_pt.y = orig_height/2;
    double screen_dist, off_screen_dist, leg, aperture;
    double rotation, x_diff, y_diff;
    
    if (this->mapView == nil)
        throw(runtime_error("mapView is uninitialized.c"));
    
    for (int i = 0; i < indices_for_rendering.size(); ++i){
        int j = indices_for_rendering[i];
        
        // Calculate the screen coordinates
        myCoord.latitude = model->data_array[j].latitude;
        myCoord.longitude = model->data_array[j].longitude;
        screen_pt =
        [this->mapView convertCoordinate:myCoord toPointToView:this->mapView];
        
        screen_pt.y = -screen_pt.y + orig_height; //b/c the coordinate sys is flipped...
        
        // Calculate the parameters to draw a wedge
        x_diff = screen_pt.x - center_pt.x;
        y_diff = screen_pt.y - center_pt.y;
        
        // isFlipped is undefined in iOS
//        BOOL flag = [this->mapView isFlipped];
        
        // construction
        cout << "-----------------" << endl;
        
        NSLog(@"Map frame: %@", NSStringFromCGRect(this->mapView.frame));
        
        cout << "landmark: " << model->data_array[j].name << endl;
        cout << "x: " << x_diff << " y:" << y_diff << endl;
        
        calculateDistInBox(this->orig_width, this->orig_height,
                           CGPointMake(x_diff, y_diff),
                           &screen_dist, &rotation);
        off_screen_dist = sqrt(pow(x_diff, 2) + pow(y_diff, 2)) - screen_dist;
        // distance needs to be corrected
        
        
        // The parameters here may need to be tweeked)
        leg = off_screen_dist + log((off_screen_dist + 20)/12)*10;
        
        aperture = (5+off_screen_dist*0.3)/leg;
        

        cout << "leg: " << leg << endl;
        cout << "rotation (deg): " << rotation << endl;
        cout << "-----------------" << endl;
        
        // Draw the wedge
        //        v2
        // v1
        //        v3
        glLineWidth(4);
        glColor4f(1, 0, 0, 1);
        glPushMatrix();
        // Plot the triangle first, then rotate and translate
        glTranslatef(x_diff, y_diff, 0);

        glRotatef(rotation, 0, 0, 1);
        
        Vertex3D    vertex1 = Vertex3DMake(0, 0, 0);
        Vertex3D    vertex2 = Vertex3DMake(leg * cos(aperture/2),
                                           leg * sin(aperture/2), 0);
        
        Vertex3D    vertex3 = Vertex3DMake(leg * cos(aperture/2),
                                           -leg * sin(aperture/2), 0);
        
        TriangleLine3D  triangle = TriangleLine3DMake(vertex1, vertex2, vertex3);
        glVertexPointer(3, GL_FLOAT, 0, &triangle);
        glDrawArrays(GL_LINE_STRIP, 0,4);
        
        glPopMatrix();
    }
    cout << "Done!" << endl;
}

//--------------
// Tools
//--------------

// Calculate the length of the line segment within the box
void calculateDistInBox(double width, double height, CGPoint aPoint,
                          double* dist, double* rotation){
    // Assume the origin is at (0,0),
    // aPoint are the coordinates of the landamrk wrt to the origin (0,0)
    //
    // The two outputs are distance and rotation (in degree)
    
    double m1 = height/width, f1, f2;
    CGFloat x = aPoint.x, y = aPoint.y;
    double xx, yy;
    
    // calculate the signs of f1 and f2
    f1 = m1 * x - y;
    f2 = -m1 * x - y;
    // Four cases
    //      c2  [f1]
    //  c3       c1
    //      c4  [f2]
    
    if ((f1 >0) && (f2 <= 0)){
        // c1
        xx = width/2;
        yy = aPoint.y/aPoint.x * xx;
        *dist = sqrt(pow(xx, 2) + pow(yy, 2));
        *rotation = atan2(aPoint.y, aPoint.x) * 180/M_PI + 180;
    }else if ((f1 <= 0) && (f2 <0)){
        // c2
        yy = height/2;
        xx = aPoint.x / aPoint.y * yy;
        *dist = sqrt(pow(xx, 2) + pow(yy, 2));
        *rotation = atan2(aPoint.y, aPoint.x) * 180/M_PI - 180;
    }else if ((f1 <= 0) && (f2 >0)){
        // c3
        xx = -width/2;
        yy = aPoint.y/aPoint.x * xx;
        *dist = sqrt(pow(xx, 2) + pow(yy, 2));
        *rotation = atan2(aPoint.y, aPoint.x) * 180/M_PI - 180;
    }else{
        // c4
        yy = -height/2;
        xx = aPoint.x/aPoint.y  * yy;
        *dist = sqrt(pow(xx, 2) + pow(yy, 2));
        *rotation = 180 + atan2(aPoint.y, aPoint.x) * 180/M_PI;
    }
}
