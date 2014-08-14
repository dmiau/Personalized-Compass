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
        
        if ([model->configurations[@"wedge_style"]
             isEqualToString:@"modified-orthographic"]){
          
            box screen_box(orig_width-30, orig_height-30);
            wedge my_wedge(model, screen_box, CGPointMake(x_diff, y_diff));
            my_wedge.render();
            leg = my_wedge.leg;
            aperture = my_wedge.aperture;
 
        }else{
             double rotation, tx, ty, new_width, new_height;
            applyCoordTransform(x_diff, y_diff,
                                orig_width, orig_height,
                                &rotation, &tx, &ty,
                                &new_width, &new_height);
            
            
            drawOneSide(rotation, new_width, new_height, tx, ty,
                        &leg, &aperture);
        
        }
        
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

