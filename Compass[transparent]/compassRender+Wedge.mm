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
#include "Wedge+Ortho.h"

using namespace std;

//------------------------------------
// Wedge
//------------------------------------
void compassRender::renderStyleWedge(vector<int> &indices_for_rendering){    
    
    //-------------------
    // Cluster the data
    //-------------------
    vector<double> mode_max_dist_array =
    model->clusterData(indices_for_rendering);
    
    // Assume indices_for_rendering stores sorted distances
    if (indices_for_rendering.size() <= 0 &&
        !(model->user_pos.isEnabled && !model->user_pos.isVisible))
    {
        // Nothing to be drawn, return
        return;
    }
    
    // Declarations
    CGPoint center_pt;
    center_pt.x = view_width/2;
    center_pt.y = view_height/2;
    
    if (this->mapView == nil){
        NSLog(@"***********mapView is uninitialized");
        return;
    }
#ifndef __IPHONE__
    glPushMatrix();    
    if (emulatediOS.is_enabled){
        glTranslatef(emulatediOS.centroid_in_opengl.x,
                     emulatediOS.centroid_in_opengl.y, 0);
    }
#endif
    
    //--------------------
    // Calculate the parameters of each wedge
    //--------------------
    CLLocationCoordinate2D myCoord;
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

            glColor4f(1, 0, 0, 1);
            if ([model->configurations[@"style_type"] isEqualToString: @"BIMODAL"])
            {
                //----------------
                // In bimodal mode, the color of wedge changes based on
                // the clustering result.
                //----------------
                if (model->data_array[j].distance > mode_max_dist_array[0])
                {
                    glColor4f(186.0/255, 54.0/255, 235.0/255, 1);
                }
            }
        }
        
        CGPoint screen_pt =
        [this->mapView convertCoordinate:myCoord toPointToView:this->mapView];
        
        screen_pt.y = -screen_pt.y + view_height; //b/c the coordinate sys is flipped...
        // We want the origin to be at the top left corner,
        // but screen_pt was calculated from the botton left corner
        
        // Calculate the parameters to draw a wedge
        double x_diff = screen_pt.x - center_pt.x;
        double y_diff = screen_pt.y - center_pt.y;
        
        double dist = sqrt(pow(x_diff, 2) + pow(y_diff, 2));
        

        // This control the visible area where a wedge can be plotted.
        float wedge_disp_width, wedge_disp_height;
        wedge_disp_width = view_width;
        wedge_disp_height = view_height;
        
        double aperture, leg;
        label_info myLabelinfo;
        if ([model->configurations[@"wedge_style"]
             isEqualToString:@"modified-orthographic"])
        {
            //------------------------
            // Wedge (othographic style)
            //------------------------

#ifndef __IPHONE__
            if (emulatediOS.is_enabled &&
                model->tilt > -0.0001)
            {
                //-------------------
                // The display area is smaller when the emulated iOS mode is on
                //-------------------
                wedge_disp_width = emulatediOS.width - 10;
                wedge_disp_height = emulatediOS.height - 10;
                x_diff = x_diff - emulatediOS.centroid_in_opengl.x;
                y_diff = y_diff - emulatediOS.centroid_in_opengl.y;
            }
#endif
            box screen_box(wedge_disp_width, wedge_disp_height);
        
            
            wedge my_wedge(model, screen_box,
                           CGPointMake(x_diff, y_diff));
            my_wedge.render();
            my_wedge.showInfo();
            leg = my_wedge.leg;
            aperture = my_wedge.aperture;
            //---------------------
            // Populate label_info_array
            //---------------------
            myLabelinfo = my_wedge.wedgeLabelinfo;

        }else{
            //------------------------
            // Wedge (other style)
            //------------------------
            
#ifndef __IPHONE__
            if (emulatediOS.is_enabled &&
                model->tilt > -0.0001)
            {
                //-------------------
                // The display area is smaller when the emulated iOS mode is on
                //-------------------
                wedge_disp_width = emulatediOS.width - 10;
                wedge_disp_height = emulatediOS.height - 10;
                x_diff = x_diff - emulatediOS.centroid_in_opengl.x;
                y_diff = y_diff - emulatediOS.centroid_in_opengl.y;
            }
#endif
            double rotation, tx, ty, new_width, new_height;
            applyCoordTransform(x_diff, y_diff,
                                wedge_disp_width, wedge_disp_height,
                                &rotation, &tx, &ty,
                                &new_width, &new_height);
            

            drawOneSide(rotation, new_width, new_height, tx, ty,
                        &leg, &aperture);
            //---------------------
            // Populate label_info_array
            //---------------------
            double label_radius = leg * cos(aperture/2);
            double label_orientation = atan2(y_diff, x_diff);
            myLabelinfo.aperture = aperture;
            myLabelinfo.leg = leg;
            myLabelinfo.distance = dist - label_radius;
            myLabelinfo.orientation =
            -label_orientation / M_PI * 180 + 90;
        
        }
        
        if (i != -1){
            int j = indices_for_rendering[i];
            model->data_array[j].my_label_info = myLabelinfo;
        }
    }
    glPopMatrix();
}

