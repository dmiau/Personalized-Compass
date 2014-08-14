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
#include <Box2D/Box2D.h>
#include "wedgeClass.h"

using namespace std;

//------------------------------------
// Wedge
//------------------------------------
void compassRender::renderStyleWedge(vector<int> &indices_for_rendering){    
    ostringstream db_stream;
    
    //-------------------
    // Cluster the data
    //-------------------
    vector<double> mode_max_dist_array =
    model->clusterData(indices_for_rendering);
    
    model->label_info_array.clear();
    
    // Assume indices_for_rendering stores sorted distances
    if (indices_for_rendering.size() <= 0 &&
        !(model->user_pos.isEnabled && !model->user_pos.isVisible))
    {
        // Nothing to be drawn, return
        return;
    }
    
    // Declarations
    CLLocationCoordinate2D myCoord;
    CGPoint center_pt;
    center_pt.x = orig_width/2;
    center_pt.y = orig_height/2;
    
    if (this->mapView == nil){
        NSLog(@"***********mapView is uninitialized");
        return;
    }
    
    
    //--------------------
    // Calculate the parameters of each wedge
    //--------------------
    for (int i = -1; i < (int)indices_for_rendering.size(); ++i){
        
        if (i == -1){
            if (model->user_pos.isEnabled && !model->user_pos.isVisible){
                myCoord.latitude = model->user_pos.latitude;
                myCoord.longitude = model->user_pos.longitude;
            }else{
                continue;
            }
            glColor4f(0, 1, 0, 1);
        }else{
            int j = indices_for_rendering[i];
            // Calculate the screen coordinates
            myCoord.latitude = model->data_array[j].latitude;
            myCoord.longitude = model->data_array[j].longitude;
            
            if (model->data_array[j].distance > mode_max_dist_array[0])
            {
                glColor4f(186.0/255, 54.0/255, 235.0/255, 1);
            }else{
                glColor4f(1, 0, 0, 1);
            }
        }
        
        CGPoint screen_pt =
        [this->mapView convertCoordinate:myCoord toPointToView:this->mapView];
        
        screen_pt.y = -screen_pt.y + orig_height; //b/c the coordinate sys is flipped...
        // We want the origin to be at the top left corner,
        // but screen_pt was calculated from the botton left corner
        
        // Calculate the parameters to draw a wedge
        double x_diff = screen_pt.x - center_pt.x;
        double y_diff = screen_pt.y - center_pt.y;
        
        double dist = sqrt(pow(x_diff, 2) + pow(y_diff, 2));
        

        
        double aperture, leg;
        //-------------------------
        // Construction
        
        box screen_box(orig_width, orig_height);
        wedge my_wedge(model, screen_box, CGPointMake(x_diff, y_diff));
        my_wedge.render();
        leg = my_wedge.leg;
        aperture = my_wedge.aperture;
        //-------------------------
        
//        //---------------------
//        // Draw a single wedge
//        //---------------------
//        double rotation, tx, ty, new_width, new_height;
//        applyCoordTransform(x_diff, y_diff,
//                            orig_width, orig_height,
//                            &rotation, &tx, &ty,
//                            &new_width, &new_height);
//        
//
//        drawOneSide(rotation, new_width, new_height, tx, ty,
//                    &leg, &aperture);
        
        if (i != -1){
            //---------------------
            // Populate label_info_array
            //---------------------
            label_info myLabelinfo;
            double label_radius = leg * cos(aperture/2);
            double label_orientation = atan2(y_diff, x_diff);
            myLabelinfo.aperture = aperture;
            myLabelinfo.leg = leg;
            myLabelinfo.distance = dist - label_radius;
            myLabelinfo.centroid = CGPointMake
            (label_radius * cos(label_orientation),
             label_radius * sin(label_orientation));
            myLabelinfo.data_id = indices_for_rendering[i];
            myLabelinfo.orientation =
            -label_orientation / M_PI * 180 + 90;
            model->label_info_array.push_back(myLabelinfo);
        }
    }
    
    db_stream << "Done!" << endl;
    
    if ([this->model->configurations[@"db_stream_flag"] isEqualToString:@"on"])
    {
        cout << db_stream.str() << endl;
    }

}

void compassRender::drawOneSide(double rotation, double width, double height,
                                double tx, double ty,
                                double *out_leg, double *out_aperture)
{
    double dist = sqrt(pow(tx, 2) + pow(ty, 2));
    
    // parameters:
    // screen_dist is the distance from the center to the poitn where the
    // the line that connects the center and the landmark intersect with
    // the screen border.
    double screen_dist, wedge_rotation, max_aperture;
    calculateDistInBox(height, width,
                       tx, ty,
                       &screen_dist, &wedge_rotation, &max_aperture);
    
    // We will use rotation and max_aperture from calculateDistInBox
    if (watchMode){
        screen_dist = [model->configurations[@"watch_radius"] floatValue];
    }
    double off_screen_dist = dist - screen_dist;
    
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
    
    
    double leg = corrected_off_screen_dist + log((corrected_off_screen_dist + 20)/12)*10;
    
    double aperture = (5+corrected_off_screen_dist*0.3)/leg;
    leg = leg / correction_x;
    
    //-------------------
    // Apply constraints
    //-------------------
    if ([model->configurations[@"wedge_style"] isEqualToString:@"modified"]){
        
        if (!watchMode){
            if (aperture > max_aperture)
            {
                // Calculate the distance of base
                double base = leg*tan(max_aperture/2)*2;
                if (base < 100)
                    aperture = atan2(50, leg) * 2;
                else
                    aperture = max_aperture;
            }
        }else{
            double max_leg = 0.0;
            
            // This part can be optimized later
            float radius = [model->configurations[@"watch_radius"] floatValue];
            
            float max_intrusion = radius * 0.25;
            
            float max_half_base = sqrt(pow(radius, 2) - pow(radius * 0.75, 2)) * 0.90;
            max_aperture = atan2(max_half_base, dist - radius * 0.75);
            max_leg = sqrt(pow(dist - radius*0.75, 2) + pow(max_half_base, 2));
            
            if (aperture > max_aperture){
                aperture = max_aperture;
                leg = max_leg;
            }
        }
    }
    
    *out_aperture = aperture; *out_leg = leg;
    
    //-----------------
    // Draw the wedge
    //-----------------
    //        v2
    // v1
    //        v3
    glLineWidth(4);
    
    glPushMatrix();
    
    
    // Plot the triangle first, then rotate and translate
    glRotatef(rotation, 0, 0, 1);
    
    glTranslatef(tx, ty, 0);
    glRotatef(wedge_rotation, 0, 0, 1);
    
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