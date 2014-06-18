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

//------------------------------------
// Bimodal
//------------------------------------
void compassRender::renderStyleBimodal(vector<int> &indices_for_rendering){
    
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
    
    // Two goals here:
    // 1) decide whether it is unimodal or bimodal
    // 2) decide the best threshodl if it is bimodal
    // - Divide into two groups: A, B
    // - index by the end of group A, a_end
    // Assumption: min_d != 0
    double min_d = filtered_dist_list[0];
    double max_d = filtered_dist_list[filtered_dist_list.size()-1];
    double ratio_sum = 0;
    double lamda = 2;
    vector<pair<double, int>>  ratio_sum_list;
    for (int a_end = 0; a_end < filtered_dist_list.size(); ++a_end){
        ratio_sum = filtered_dist_list[a_end]/min_d;
        if (a_end < (filtered_dist_list.size()-1)){
            ratio_sum += max_d / filtered_dist_list[a_end + 1];
            ratio_sum += lamda;
        }
        ratio_sum_list.push_back(make_pair(ratio_sum, a_end));
    }
    
    // Figure out the data is unimodal or bimodal?
    std::vector<pair<double, int>>::iterator result =
    std::min_element(ratio_sum_list.begin(),
                     ratio_sum_list.end(), compareAscending);
    
    // cut_id is the index of the element after which a cut should be placed,
    // so the list of distances is divided into two groups
    int cut_id = result->second;
    
    // The following structure stores the information (needed for rendering)
    // of each mode
    // base_radius is the radius of the base, far landmarks use smaller base
    struct mode_info{
        float base_radius;
        double max_dist;
    };
    
    vector<mode_info> mode_info_list;
    
    // Debug
    if (cut_id != (landmark_n -1)){
        
        // close landmark mode
        mode_info t_mode_info_small = {central_disk_radius,
            filtered_dist_list[cut_id]};
        mode_info_list.push_back(t_mode_info_small);
        
        // far landmark mode
        mode_info t_mode_info_big = { central_disk_radius / (float)4,
            filtered_dist_list[landmark_n-1]};
        mode_info_list.push_back(t_mode_info_big);
        
        db_stream << "Bimodal" <<endl;
    }else{
        // Easy case
        mode_info t_mode_info = {central_disk_radius,
            filtered_dist_list[landmark_n-1]};
        mode_info_list.push_back(t_mode_info);
        db_stream << "Unimodal" <<endl;
    }
    
    // ---------------
    // Debug info
    // ---------------
    db_stream << "filtered_dist_list: " << endl;
    for (int i = 0; i< filtered_dist_list.size(); ++i){
        db_stream << filtered_dist_list[i] << ", ";
        
        if ((mode_info_list.size() == 2) && (cut_id == i)){
            db_stream << " |  ";
        }
    }
    db_stream << endl << "modified_Otsu_list" << endl;
    
    for (int i = 0; i< ratio_sum_list.size(); ++i){
        db_stream << ratio_sum_list[i].first;
        
        if ((mode_info_list.size() == 2) && (cut_id == i)){
            db_stream << "* ";
        }
        db_stream << ", ";
    }
    //    cout << db_stream.str() << endl;

    
    // ---------------
    // Draw the center circle
    // ---------------
    glColor4f([model->configurations[@"circle_color"][0] floatValue]/255,
              [model->configurations[@"circle_color"][1] floatValue]/255,
              [model->configurations[@"circle_color"][2] floatValue]/255,
              1);
    
    // draw the center circle
    glPushMatrix();
    // Translate to the front to avoid broken polygon
    glTranslatef(0, 0, 1);
    drawCircle(0, 0, central_disk_radius, 50);
    glPopMatrix();
    
    
    // ---------------
    // draw the triangle
    // ---------------
    
    // half_canvas_size
    // |-----------------------------------------|
    // outer_radius = half_canvas_size * outer_disk_ratio;
    // |----------------------------------|
    // inner_radius = half_canvas_size * inner_disk_ratio;
    // |-----------------|
    
    
    
    // the radius of the outer disk
    float outer_disk_radius =
    half_canvas_size *
    [model->configurations[@"outer_disk_ratio"] floatValue];
    
    // the radius of the inner disk
    float inner_disk_radius =
    half_canvas_size *
    [model->configurations[@"inner_disk_ratio"] floatValue];
    glPushMatrix();
    for (int i = 0; i < indices_for_rendering.size(); ++i){
        int j = indices_for_rendering[i];
        
        //[todo] fix color map (increase the size?)
        glColor4f((float)model->color_map[j][0]/256,
                  (float)model->color_map[j][1]/256,
                  (float)model->color_map[j][2]/256, 1);
        
        data data_ = model->data_array[j];
        
        
        // **Select appropriate radius and distance based on mode
        
        float base_radius = 0.0;
        double distance;
        
        if (data_.distance <= mode_info_list[0].max_dist){
            base_radius = mode_info_list[0].base_radius;
            if (mode_info_list.size() == 1){
                distance = data_.distance /
                mode_info_list[0].max_dist * outer_disk_radius;
            }else{
                distance = data_.distance /
                mode_info_list[0].max_dist * inner_disk_radius;
            }
        }else{
            base_radius = mode_info_list[1].base_radius;
            
            //             inner_disk_radius
            // |------------------|--------|
            //                         outer_disk_radius
            glColor4f(48/256,
                      217/256,
                      86/256, 1);
            
            distance = outer_disk_radius *
            data_.distance / mode_info_list[1].max_dist;
            
            //            if ((mode_info_list[1].max_dist - data_.distance) < 0.000001){
            //                distance = outer_disk_radius;
            //            }else{
            //                distance = (inner_disk_radius +
            //                            (outer_disk_radius - inner_disk_radius) *
            //                            (data_.distance - filtered_dist_list[cut_id + 1])
            //                            / (mode_info_list[1].max_dist -
            //                               filtered_dist_list[cut_id + 1]));
            //            }
        }
        
        // Need to draw on different depth to avoid broken polygon
        glTranslatef(0, 0, 0.0001);
        drawTriangle(base_radius, data_.orientation, distance);
    }
    glPopMatrix();
    // ---------------
    // draw the background (transparent) disk
    // ---------------
    float alpha = 0;
    
    //    // Draw two disks
    //    if (mode_info_list.size() > 1){
    //        // This is a temporary fix to the broken polygon problem
    //        if (model->tilt == 0)
    //            alpha = [model->configurations[@"inner_disk_color"][3] floatValue]/255;
    //        else
    //            alpha = 1;
    //
    //        glColor4f([model->configurations[@"inner_disk_color"][0] floatValue]/255,
    //                  [model->configurations[@"inner_disk_color"][1] floatValue]/255,
    //                  [model->configurations[@"inner_disk_color"][2] floatValue]/255,
    //                  alpha);
    //        glPushMatrix();
    //        glTranslatef(0, 0, -0.09);
    //        drawCircle(0, 0, inner_disk_radius, 50);
    //        glPopMatrix();
    //    }
    
    glPushMatrix();
    if (model->tilt == 0)
        alpha = [model->configurations[@"disk_color"][3] floatValue]/255;
    else
        alpha = 1;
    glColor4f([model->configurations[@"disk_color"][0] floatValue]/255,
              [model->configurations[@"disk_color"][1] floatValue]/255,
              [model->configurations[@"disk_color"][2] floatValue]/255,
              alpha);
    glTranslatef(0, 0, -1);
    drawCircle(0, 0, outer_disk_radius, 50);
    glPopMatrix();
}