//
//  TaskSpec-Triangulatation.mm
//  Compass[transparent]
//
//  Created by Daniel on 3/4/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#include "TaskSpec.h"
using namespace std;

//------------------
// Desktop only implementation
//------------------
#ifndef __IPHONE__
#import "DesktopViewController.h"

// Forward declaration

MKCoordinateRegion calculateCoordRegionFromTwoPoints(vector<data> &data_array, int dataID1, int dataID2);
vector<int> findTwoFurthestLocationIDs(vector<data> &data_array, vector<int> location_ids);

//-----------------------
// Generate triangulation locations
//-----------------------
vector<vector<int>> generateRandomTriangulateLocations(std::mt19937  generator,
         vector<float> base_length_vector, vector<int> ratio_vecotr, vector<int> delta_theta_vecotr)
{
    // ratio: 1:4 [4]
    // angels (delta_theta): 90:60:270 [4]
    // total # of combinations: 16
    
    // strategy:
    // calculate the following parameters before calculat the true (x, y)
    // pt1_theta, pt1_length, pt2_ratio, pt2_delta_theta
    // from the above four parameters we can calcualte two sets of coordinates
    
    //-----------------
    // Test Generation Parameters
    //-----------------
    vector<vector<int>> output;
    
    int trial_n = (int)delta_theta_vecotr.size() * (int)ratio_vecotr.size()
    * base_length_vector.size();
    
    std::uniform_int_distribution<int>  distr(0, 359);
    // Draw trial_n thetas
    
    // 0 degree is in the positie x direction
    vector<int> theta_vector;
    for (int i = 0; i < trial_n; ++i){
        theta_vector.push_back(distr(generator));
    }
    
    for (int i = 0; i < base_length_vector.size(); ++i){
        // Iterate over base length vector
        for (int j = 0; j < ratio_vecotr.size(); ++j){
            // Iterate over ratio vector
            for (int k = 0; k < delta_theta_vecotr.size(); ++k){
                // Iterate over delta_theta vector
                
                //-------------------------
                // Generate two locations here
                //-------------------------
                int x, y;
                // Calculate point 1
                float pt1_length = base_length_vector[i];
                float theta =  (float) theta_vector.back();
                theta_vector.pop_back();
                x = pt1_length * cos(theta/180 * M_PI);
                y = pt1_length * sin(theta/180 * M_PI);
                
                vector<int> t_vector = {x, y};
                output.push_back(t_vector);
                
                // Calculate point 2
                float pt2_length = pt1_length * ratio_vecotr[j];
                theta = theta + delta_theta_vecotr[k];
                x = pt2_length * cos(theta/180 * M_PI);
                y = pt2_length * sin(theta/180 * M_PI);
                
                t_vector = {x, y};
                output.push_back(t_vector);
            }
        }
    }
    return output;
}

//-----------------------
// Triangulate tests
//-----------------------
void TaskSpec::generateTriangulateTests(vector<data> &t_data_array)
{
    snapshot_array.clear();
    code_location_vector.clear();
    vector<float> base_length_vector = {300.0, 1000.0};
    vector<int> ratio_vecotr = {1, 2, 3};
    vector<int> delta_theta_vecotr = {90, 150, 210, 270};
    
    vector<vector<int>> location_pair_vector =
    generateRandomTriangulateLocations(generator,
                        base_length_vector, ratio_vecotr, delta_theta_vecotr);
    batchCommitLocationPairs("", location_pair_vector,
                             vector<int>{0, 0}, t_data_array);
    
    //--------------
    // Generate practice block
    //--------------
    base_length_vector = {200.0};
    ratio_vecotr = {2};
    delta_theta_vecotr = {90, 210};
    
    location_pair_vector =
    generateRandomTriangulateLocations(generator,
                                       base_length_vector, ratio_vecotr, delta_theta_vecotr);
    batchCommitLocationPairs("t", location_pair_vector,
                             vector<int>{0, 0}, t_data_array);
}

//-----------------------
// LocatePlus tests
//-----------------------
void TaskSpec::generateLocatePlusTests(vector<data> &t_data_array)
{
    snapshot_array.clear();
    code_location_vector.clear();
    vector<float> base_length_vector = {300.0, 1000.0};
    vector<int> ratio_vecotr = {1, 2, 3};
    vector<int> delta_theta_vecotr = {90, 150, 210, 270};
    
    vector<vector<int>> location_pair_vector =
    generateRandomTriangulateLocations(generator,
                                       base_length_vector, ratio_vecotr, delta_theta_vecotr);
    
    batchCommitLocationPairs("", location_pair_vector,
                             vector<int>{1, 0}, t_data_array);
    
    //--------------
    // Generate practice block
    //--------------
    base_length_vector = {200.0};
    ratio_vecotr = {2};
    delta_theta_vecotr = {90, 210};
    
    location_pair_vector =
    generateRandomTriangulateLocations(generator,
                                       base_length_vector, ratio_vecotr, delta_theta_vecotr);
    batchCommitLocationPairs("t", location_pair_vector,
                             vector<int>{1, 0}, t_data_array);
}

//-----------------------
// Batch process a vector of location_pair
// The layout of location_pair is
// (x1, y1)
// (x2, y2)...
//-----------------------
void TaskSpec::batchCommitLocationPairs(string postfix,
                                        vector<vector<int>> location_pair_vector,
                                        vector<int> is_answer_list,
                                        vector<data> &t_data_array)
{
    int trial_n = (int)location_pair_vector.size()/2;

    for (int i = 0; i < trial_n; ++i)
    {
        int x1 = location_pair_vector[i*2][0];
        int y1 = location_pair_vector[i*2][1];
        int x2 = location_pair_vector[i*2+1][0];
        int y2 = location_pair_vector[i*2+1][1];
        
        string trialString = to_string(i) + postfix;
        
        vector<CGPoint> openGLPoints = {CGPointMake(x1, y1), CGPointMake(x2, y2)};
        code_location_vector.push_back(make_pair(identifier + ":" + trialString + "-0",
                                                 vector<int>{x1, y1}));
        code_location_vector.push_back(make_pair(identifier + ":" + trialString + "-1",
                                                 vector<int>{x2, y2}));
        addTwoDataAndSnapshot(trialString, openGLPoints,
                              is_answer_list, t_data_array);
    }
}
//-----------------------
// Convert two OpenGL points to data and snapshot
//-----------------------
void TaskSpec::addTwoDataAndSnapshot(string trialString,
                                     vector<CGPoint> openGLPoints,
                                     vector<int> is_answer_list,
                                     vector<data> &t_data_array)
{
    for (int j = 0; j < 2; ++j){
        //--------------
        // Generate two new data
        //--------------
        CGPoint mapViewPoint =
        CGPointMake(openGLPoints[j].x + rootViewController.renderer->view_width/2,
                    rootViewController.renderer->view_height/2 - openGLPoints[j].y);
        
        data t_data;
        CLLocationCoordinate2D coord =
        [rootViewController.mapView convertPoint: mapViewPoint
                            toCoordinateFromView:rootViewController.mapView];
        t_data.latitude = coord.latitude;
        t_data.longitude = coord.longitude;
        t_data.name = identifier + ":" + trialString + "-" + to_string(j);
        t_data_array.push_back(t_data);
    }
    
    //------------------
    // Collect all the selected ids
    //------------------
    vector<int> selected_ids = {(int)t_data_array.size() - 1,
        (int)t_data_array.size() - 2};
    
    //--------------
    // Generate a new snapshot
    //--------------
    snapshot t_snapshot;
    
    // Calculate coordinate region
    MKCoordinateRegion coordinateRegion;
    coordinateRegion.center = rootViewController.mapView.centerCoordinate;
    
    if (deviceType == PHONE){
        //----------------
        // Phone
        //----------------
        coordinateRegion.span =
        [rootViewController calculateCoordinateSpanForDevice:PHONE];
    }else{
        //----------------
        // Watch
        //----------------
        coordinateRegion.span =
        [rootViewController calculateCoordinateSpanForDevice:SQUAREWATCH];
    }
    
    MKCoordinateRegion osx_coordinateRegion;
    if (taskType == TRIANGULATE){
        osx_coordinateRegion = calculateCoordRegionFromTwoPoints
        (t_data_array, selected_ids[0], selected_ids[1]);
    }else if (taskType == LOCATEPLUS){
        // Calculate desktop display coordinate region
        CLLocation *center = [[CLLocation alloc]
                              initWithLatitude: rootViewController.mapView.centerCoordinate.latitude
                              longitude: rootViewController.mapView.centerCoordinate.longitude];
        CLLocation *support = [[CLLocation alloc]
                               initWithLatitude:
                               t_data_array[selected_ids[1]].latitude
                               longitude:
                               t_data_array[selected_ids[1]].longitude];
        
        CLLocationDistance distnace = [center distanceFromLocation: support];
        
        CLLocationCoordinate2D centerCoordinate =
        rootViewController.mapView.centerCoordinate;
        
        osx_coordinateRegion =
        MKCoordinateRegionMakeWithDistance
        (centerCoordinate, distnace * 2.2, distnace * 2.2);
    }else{
        [rootViewController displayPopupMessage:
         @"Unknown taskType in addTwoDataAndSnapshot."];
    }

    t_snapshot.osx_coordinateRegion = osx_coordinateRegion;
    
    //------------------
    // Assemble a snapshot
    //------------------
    t_snapshot.name = [NSString stringWithUTF8String:
                       (identifier + ":" + trialString).c_str()];
    t_snapshot.coordinateRegion = coordinateRegion;
    t_snapshot.selected_ids = selected_ids;
    t_snapshot.is_answer_list = is_answer_list;
    t_snapshot.orientation = 0;
    
    if (trialString.find("t") == string::npos)
        snapshot_array.push_back(t_snapshot);
    else
        practice_snapshot_array.push_back(t_snapshot);
}

#pragma mark -------------- Distance Calculation Tools --------------


MKCoordinateRegion calculateCoordRegionFromTwoPoints
(vector<data> &data_array, int dataID1, int dataID2)
{
    data data_a = data_array[dataID1];
    CLLocation *point_a = [[CLLocation alloc]
                           initWithLatitude:data_a.latitude longitude:data_a.longitude];
    
    data data_b = data_array[dataID2];
    CLLocation *point_b = [[CLLocation alloc]
                           initWithLatitude:data_b.latitude longitude:data_b.longitude];
    
    CLLocationDistance distnace = [point_a distanceFromLocation: point_b];
    
    CLLocationCoordinate2D centerCoordinate =
    CLLocationCoordinate2DMake((data_a.latitude + data_b.latitude)/2,
                               (data_a.longitude + data_b.longitude)/2);
    
    
    MKCoordinateRegion coord_region =
    MKCoordinateRegionMakeWithDistance
    (centerCoordinate, distnace * 1.3, distnace * 1.3);
    return coord_region;
}

vector<int> findTwoFurthestLocationIDs
(vector<data> &data_array, vector<int> location_ids)
{
    vector<int> answer;
    double max_dist = 0;
    vector<int> t_id_list = location_ids;
    t_id_list.push_back(location_ids[0]);
    
    for (int i = 0; i < t_id_list.size(); ++i){
        
        data data_a = data_array[t_id_list[i]];
        CLLocation *point_a = [[CLLocation alloc]
                               initWithLatitude:data_a.latitude longitude:data_a.longitude];
        
        data data_b = data_array[t_id_list[i+1]];
        CLLocation *point_b = [[CLLocation alloc]
                               initWithLatitude:data_b.latitude longitude:data_b.longitude];
        
        CLLocationDistance distnace = [point_a distanceFromLocation: point_b];
        if (distnace > max_dist){
            answer.clear();
            answer.push_back(t_id_list[i]);
            answer.push_back(t_id_list[i+1]);
        }
    }
    
    return answer;
}

#endif