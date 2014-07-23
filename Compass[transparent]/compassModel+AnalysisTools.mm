//
//  compassModel+AnalysisTools.mm
//
//  Created by Daniel Miau on 7/22/14.
//  Copyright (c) 2014 Daniel Miau. All rights reserved.
//
#include "compassModel.h"
#include "commonInclude.h"

vector<double> compassMdl::clusterData(vector<int> indices_for_rendering){
    mode_max_dist_array.clear();
    
    // Assume indices_for_rendering stores sorted distances
    
    // Cache all the distance candidates into a vector
    vector <double> filtered_dist_list;
    for (int i = 0; i < indices_for_rendering.size(); ++i){
        int j = indices_for_rendering[i];
        filtered_dist_list.push_back(data_array[j].distance);
    }
    
    //-----------------
    // Include
    // the distance to the user's current location
    // to filtered_dist_list
    //-----------------
    if (user_pos.isEnabled && !user_pos.isVisible){
        filtered_dist_list.push_back(user_pos.distance);
        
        // Need to sort the filtered_dist_list again, since
        // user_pos.distance might not be the farthest one
        
        // Sort the list in ascending order
        sort(filtered_dist_list.begin(), filtered_dist_list.end());
    }

    
    int landmark_n = filtered_dist_list.size();
    
    if (landmark_n == 0){
        // No need to proceed if there is no landmark to be clustered
        return mode_max_dist_array;
    }
    
    //-----------------
    // Cluster landmakrs
    //-----------------
    
    // Two goals here:
    // 1) decide whether it is unimodal or bimodal
    // 2) decide the best threshodl if it is bimodal
    // - Divide into two groups: A, B
    // - index by the end of group A, a_end
    // Assumption: min_d != 0
    // filtered_dist_list is sorted
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
    
    // cut_id is the index of the element after which a cut should be made,
    // so the list of distances is divided into two groups
    int cut_id = result->second;
    
    if (cut_id == (landmark_n -1)){
        //-----------------
        // Unimodal
        //-----------------
        mode_max_dist_array.push_back(filtered_dist_list[landmark_n-1]);
    }else{
        //-----------------
        // Bimodal
        //-----------------
        mode_max_dist_array.push_back(filtered_dist_list[cut_id]);
        mode_max_dist_array.push_back(filtered_dist_list[landmark_n-1]);
    }
    return mode_max_dist_array;
}


vector<pair<double, int>> compassMdl::
generateOrientDiffList(vector<int>id_list)
{
    vector<pair<float, int>> orient_id_list;
    
    // Collect all the angles
    for (int i = 0; i < id_list.size(); ++i){
        float orient = data_array[id_list[i]].orientation;
        
        orient_id_list.push_back(make_pair(orient, id_list[i]));
    }
    
    // Sort the list based on orientation
    sort(orient_id_list.begin(), orient_id_list.end(), compareAscending);
    
    // Calculate the differences
    vector<pair<double, int>> orient_diff_list;
    for (int i = 0; i<orient_id_list.size(); ++i){
        
        float t_diff;
        if (i ==0){
            t_diff = 360 - orient_id_list.back().first +
            orient_id_list[0].first;
        }else{
            t_diff = orient_id_list[i].first - orient_id_list[i-1].first;
        }
        orient_diff_list.push_back(
                                   make_pair(t_diff, orient_id_list[i].second));
    }
    
    return orient_diff_list;
}

#pragma mark ----------location distance/orientation tools----------
//===================
// tools for distance and orientation calculation
//===================
double DegreesToRadians(double degrees) {return degrees * M_PI / 180.0;};
double RadiansToDegrees(double radians) {return radians * 180.0/M_PI;};
// calculate bearing
// http://stackoverflow.com/questions/3925942/cllocation-category-for-calculating-bearing-w-haversine-function
//

double data::computeDistanceFromLocation(data& another_data){
    
    // Take advantage of OSX's foundation class
    CLLocation *cur_location = [[CLLocation alloc]
                                initWithLatitude: this->latitude
                                longitude: this->longitude];
    
    
    CLLocation *target_location = [[CLLocation alloc]
                                   initWithLatitude:
                                   another_data.latitude
                                   longitude:
                                   another_data.longitude];
    CLLocationDistance distnace = [cur_location distanceFromLocation: target_location];
    return distnace;
}


double data::computeOrientationFromLocation(data &another_data){
    
    double lat1 = DegreesToRadians(this->latitude);
    double lon1 = DegreesToRadians(this->longitude);
    
    double lat2 = DegreesToRadians(another_data.latitude);
    double lon2 = DegreesToRadians(another_data.longitude);
    
    double dLon = lon2 - lon1;
    
    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    double radiansBearing = atan2(y, x);
    
    double degree = RadiansToDegrees(radiansBearing);
    
    // This guarantees that the orientaiton is always positive
    if (degree < 0) degree += 360;
    return degree;
}