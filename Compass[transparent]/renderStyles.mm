//
//  renderStyles.cpp
//  Compass[transparent]
//
//  Created by Daniel Miau on 4/20/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//
#include "commonInclude.h"
#include "compassRender.h"
#include <vector>
#include <numeric>
#include <iostream>
#include <sstream>
using namespace std;

#pragma mark ------------ Tools
// http://stackoverflow.com/questions/650162/why-switch-statement-cannot-be-applied-on-strings
style_enum compassRender::hashStyleStr (NSString *inString) {
    if ([inString isEqualToString:@"BIMODAL"]) return BIMODAL;
    if ([inString isEqualToString:@"REAL_RATIO"]) return REAL_RATIO;
    if ([inString isEqualToString:@"THRESHOLD_STICK"]) return THRESHOLD_STICK;
    throw(runtime_error("Unknown style string."));
}

int compassRender::applyStyle(style_enum style_type,
                              vector<int> &indices_for_rendering){
    switch (style_type) {
        case BIMODAL:
            renderStyleBimodal(indices_for_rendering);
            break;
        case REAL_RATIO:
            renderStyleRealRatio(indices_for_rendering);
            break;
        case THRESHOLD_STICK:
            renderStyleThresholdSticks(indices_for_rendering);
            break;
        default:
            throw(runtime_error("Unknow style"));
            break;
    }
    return EXIT_SUCCESS;
}

#pragma mark ------------ styles

void compassRender::renderStyleBimodal(vector<int> &indices_for_rendering){
    
    ostringstream db_stream;
    
    // Assume indices_for_rendering stores sorted distances
    
    // Cache all the distance candidates into a vector
    vector <double> filtered_dist_list;
    for (int i = 0; i < indices_for_rendering.size(); ++i){
        int j = indices_for_rendering[i];
        filtered_dist_list.push_back(model->data_array[j].distance);
    }
    
//    // Debug
//    filtered_dist_list.clear();
//    filtered_dist_list.push_back(100);
//    filtered_dist_list.push_back(200);
//    filtered_dist_list.push_back(300);
//    filtered_dist_list.push_back(400);
//    filtered_dist_list.push_back(1000);
    
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
    int cut_id = result->second;
    
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
    // draw the triangle
    // ---------------
    
    // absolute_drawable_radius_percentage specifies the radius
    // of the drawable area of the disk
    // (in terms of absolute percentage)
    // absolute_drawable_radius_percentage is a number between 0 and 1
    float absolute_drawable_radius_percentage = 0.9;
    
    // relative_close_radius_percentage specifies the drawable
    // area of the inner disk
    // (in terms of realative percentage)
    float relative_close_radius_percentage =
    [model->configurations[@"inner_disk_radius"] floatValue];
    
    for (int i = 0; i < indices_for_rendering.size(); ++i){
        int j = indices_for_rendering[i];
        
        //[todo] fix color map (increase the size?)
        glColor3f((float)model->color_map[j][0]/256,
                  (float)model->color_map[j][1]/256,
                  (float)model->color_map[j][2]/256);
        
        data data_ = model->data_array[j];
        
        
        // **Select appropriate radius and distance based on mode
        
        float disk_radius = 0.0;
        double k = 0, distance;
        
        if (data_.distance <= mode_info_list[0].max_dist){
            disk_radius = mode_info_list[0].base_radius;
            if (mode_info_list.size() == 1){
                k = data_.distance /
                mode_info_list[0].max_dist;
            }else{
                k = data_.distance /
                mode_info_list[0].max_dist * relative_close_radius_percentage;
            }
            if (k > 1)
                cout << "bug!" << endl;
        }else{
            disk_radius = mode_info_list[1].base_radius;
            
            k = (relative_close_radius_percentage +
                 (1-relative_close_radius_percentage) *
                        (data_.distance - filtered_dist_list[cut_id + 1])
                        / (mode_info_list[1].max_dist -
                           filtered_dist_list[cut_id + 1]));
            if (k > 1)
                cout << "bug!" << endl;
        }
        distance = k * half_canvas_size * absolute_drawable_radius_percentage;
        drawTriangle(disk_radius, data_.orientation, distance);
    }
    
    // ---------------
    // draw the background (transparent) disk
    // ---------------
    
    // Draw two disks
    if (mode_info_list.size() > 1){
        glColor4f([model->configurations[@"inner_disk_color"][0] floatValue]/255,
                  [model->configurations[@"inner_disk_color"][1] floatValue]/255,
                  [model->configurations[@"inner_disk_color"][2] floatValue]/255,
                  [model->configurations[@"inner_disk_color"][3] floatValue]/255);
        drawCircle(0, 0, half_canvas_size *
                   relative_close_radius_percentage *
                   absolute_drawable_radius_percentage, 50);
    }
    
    glColor4f([model->configurations[@"disk_color"][0] floatValue]/255,
              [model->configurations[@"disk_color"][1] floatValue]/255,
              [model->configurations[@"disk_color"][2] floatValue]/255,
              [model->configurations[@"disk_color"][3] floatValue]/255);
    drawCircle(0, 0, half_canvas_size, 50);
}


void compassRender::renderStyleRealRatio(vector<int> &indices_for_rendering){
    // ------------------
    // Preprocesing:
    // Find out the longest distance for normalization
    // ------------------
    vector <double> t_dist_list;
    for (int i = 0; i < indices_for_rendering.size(); ++i){
        int j = indices_for_rendering[i];
        t_dist_list.push_back(model->data_array[j].distance);
    }
    std::vector<double>::iterator result =
    std::max_element(t_dist_list.begin(),
                     t_dist_list.end());
    max_dist = *result;
    
    // ---------------
    // draw the triangle
    // ---------------
    for (int i = 0; i < indices_for_rendering.size(); ++i){
        int j = indices_for_rendering[i];

        //[todo] fix color map (increase the size?)
        glColor3f((float)model->color_map[j][0]/256,
                  (float)model->color_map[j][1]/256,
                  (float)model->color_map[j][2]/256);

        data data_ = model->data_array[j];

        double distance = data_.distance / max_dist * half_canvas_size * 0.9;
        drawTriangle(central_disk_radius, data_.orientation, distance);
    }
    
    // ---------------
    // draw the background (transparent) disk
    // ---------------
    glColor4f([model->configurations[@"disk_color"][0] floatValue]/255,
              [model->configurations[@"disk_color"][1] floatValue]/255,
              [model->configurations[@"disk_color"][2] floatValue]/255,
              [model->configurations[@"disk_color"][3] floatValue]/255);
    drawCircle(0, 0, half_canvas_size, 50);
}


void compassRender::renderStyleThresholdSticks(vector<int> &indices_for_rendering){
    
}
