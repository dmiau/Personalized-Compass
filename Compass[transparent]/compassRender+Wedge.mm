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
                        double* dist, double* rotation, double* max_aperture);

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
    double screen_dist, off_screen_dist, max_aperture, leg, aperture;
    double rotation, x_diff, y_diff;
    
    if (this->mapView == nil)
        throw(runtime_error("mapView is uninitialized."));
    
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
        db_stream << "-----------------" << endl;

//#ifndef __IPHONE__
//        NSLog(@"Map frame: %@", NSStringFromRect(this->mapView.frame));
//#else
//        NSLog(@"Map frame: %@", NSStringFromCGRect(this->mapView.frame));
//#endif
        
        db_stream << "landmark: " << model->data_array[j].name << endl;
        db_stream << "x: " << x_diff << " y:" << y_diff << endl;
        
        calculateDistInBox(this->orig_width, this->orig_height,
                           CGPointMake(x_diff, y_diff),
                           &screen_dist, &rotation, &max_aperture);
        off_screen_dist = sqrt(pow(x_diff, 2) + pow(y_diff, 2)) - screen_dist;
        // distance needs to be corrected
        
        // -----------------------
        // The parameters here may need to be tweeked)
        // -----------------------
        
        // I believe the parameters from the paper was based the following
        // parameters:
        //
        // Here are the specs of an Compag iPad:
        // 3"x4" (x 1.33), dpi: 105
        //
        // However, the interface was emulated on a computer monitor,
        // and the paper indicates the screen is 33% larger than the original
        // screen.
        // A typical screen's resolution is 72-96 dpi
        // 3"x4" x 1.33 x 72 = 287.28 x 374
        
        // This means that I need to apply a scale parameter before using
        // the orignal formula to calculate the leg and aperture
        
        //-----------------
        // Calculate the scale parameter
        //-----------------

        float correction_x = [this->model->configurations[@"wedge_correction_x"]
                               floatValue];
        double corrected_off_screen_dist = off_screen_dist * correction_x;
        
        
        leg = corrected_off_screen_dist + log((corrected_off_screen_dist + 20)/12)*10;
        
        aperture = (5+corrected_off_screen_dist*0.3)/leg;
        
        if (aperture > max_aperture){
            aperture = max_aperture;
//            NSLog(@"Aperture is bigger than max_apertue!");
        }
        
        leg = leg / correction_x;

        db_stream << "leg: " << leg << endl;
        db_stream << "rotation (deg): " << rotation << endl;
        db_stream << "-----------------" << endl;
        
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
    
    db_stream << "Done!" << endl;
    
    if ([this->model->configurations[@"db_stream_flag"] isEqualToString:@"on"])
    {
        cout << db_stream.str() << endl;
    }
}

//--------------
// Tools
//--------------

// Calculate the length of the line segment within the box
void calculateDistInBox(double width, double height, CGPoint aPoint,
                          double* dist, double* rotation, double* max_aperture){
    // Assume the origin is at (0,0),
    // aPoint are the coordinates of the landamrk wrt to the origin (0,0)
    //
    // The three outputs are distance and rotation (in degrees),
    // and maximal allowable aperture (in radians)
    
    // Coordinate system
    // yy
    // |
    // |
    // |
    // __________xx
    
    double m1 = height/width, f1, f2;
    CGFloat x = aPoint.x, y = aPoint.y;
    double xx, yy, theta;
    double a2, b2, c, c2; // three sides of the triangle
    
    // calculate the signs of f1 and f2
    // f1 and f2 are two lines that divice the space into 4 quadrants
    f1 = m1 * x - y;
    f2 = -m1 * x - y;
    // Four cases
    //      c2  [f1]
    //  c3       c1
    //      c4  [f2]
    
    // Use law of cosine to calculate max allowable aperture
    double k = 0.8;

    if ((f1 >0) && (f2 <= 0)){
        // c1
        xx = width/2;
        yy = aPoint.y/aPoint.x * xx;
        *dist = sqrt(pow(xx, 2) + pow(yy, 2));
        *rotation = atan2(aPoint.y, aPoint.x) * 180/M_PI + 180;
        
        // calculate maximal alloable aperture
        c = height/2*k - fabs(yy); c2 = pow(c, 2);
        if (aPoint.y >=0){
            b2 = (pow(x-xx, 2) + pow(y-height/2*k, 2));
        }else{
            b2 = (pow(x-xx, 2) + pow(y+height/2*k, 2));
        }
    }else if ((f1 <= 0) && (f2 <0)){
        // c2
        yy = height/2;
        xx = aPoint.x / aPoint.y * yy;
        *dist = sqrt(pow(xx, 2) + pow(yy, 2));
        *rotation = atan2(aPoint.y, aPoint.x) * 180/M_PI - 180;
        
        // calculate maximal alloable aperture
        c = width/2*k - fabs(xx); c2 = pow(c, 2);
        if (aPoint.y >=0){
            b2 = (pow(x-width/2*k, 2) + pow(y-yy, 2));
        }else{
            b2 = (pow(x+width/2*k, 2) + pow(y-yy, 2));
        }
    }else if ((f1 <= 0) && (f2 >0)){
        // c3
        xx = -width/2;
        yy = aPoint.y/aPoint.x * xx;
        *dist = sqrt(pow(xx, 2) + pow(yy, 2));
        *rotation = atan2(aPoint.y, aPoint.x) * 180/M_PI - 180;

        // calculate maximal alloable aperture
        c = height/2*k - fabs(yy); c2 = pow(c, 2);
        if (aPoint.y >=0){
            b2 = (pow(x-xx, 2) + pow(y-height/2*k, 2));
        }else{
            b2 = (pow(x-xx, 2) + pow(y+height/2*k, 2));
        }
    }else{
        // c4
        yy = -height/2;
        xx = aPoint.x/aPoint.y  * yy;
        *dist = sqrt(pow(xx, 2) + pow(yy, 2));
        *rotation = 180 + atan2(aPoint.y, aPoint.x) * 180/M_PI;

        // calculate maximal alloable aperture
        c = width/2*k - fabs(xx); c2 = pow(c, 2);
        if (aPoint.y >=0){
            b2 = (pow(x-width/2*k, 2) + pow(y-yy, 2));
        }else{
            b2 = (pow(x+width/2*k, 2) + pow(y-yy, 2));
        }
    }

    a2 = pow(x-xx, 2) + pow(y-yy, 2);
    theta = acos((a2 + b2 -c2)/(2*sqrt(a2*b2)));
    *max_aperture = 2 * theta;
}
