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
pair<vector<vector<double>>, vector<vector<double>>> TaskSpec::generateRandomTriangulateLocations(
        std::mt19937  &generator,
         vector<int> base_length_vector, vector<float> ratio_vecotr, vector<int> delta_theta_vecotr)
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
    vector<vector<double>> output;
    vector<vector<double>> truth_stats;
    
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
                double x, y;
                // Calculate point 1
                // (need a scale so the tests can be generated on desktop)
                double pt1_length = (double)base_length_vector[i] *
                (double)rootViewController.renderer->emulatediOS.width /
                (double)rootViewController.renderer->emulatediOS.true_ios_width;
                
                float theta =  (float) theta_vector.back();
                theta_vector.pop_back();
                x = pt1_length * cos(theta/180 * M_PI);
                y = pt1_length * sin(theta/180 * M_PI);
                
                vector<double> t_vector = {x, y};
                output.push_back(t_vector);
                
                // Calculate point 2
                double pt2_length = pt1_length * ratio_vecotr[j];
                double theta2 = theta + delta_theta_vecotr[k];
                x = pt2_length * cos(theta2/180 * M_PI);
                y = pt2_length * sin(theta2/180 * M_PI);
                
                t_vector = {x, y};
                output.push_back(t_vector);
                
                
                // base_length, ratio, delta_theta, theta
                vector<double> temp = {static_cast<double>(base_length_vector[i]),
                    static_cast<double>(ratio_vecotr[j]),
                static_cast<double>(delta_theta_vecotr[k]), theta};
                truth_stats.push_back(temp);
            }
        }
    }
    
    return make_pair(truth_stats, output);
}

//-----------------------
// Triangulate tests
//-----------------------
void TaskSpec::generateTriangulateTests(vector<data> &t_data_array, std::mt19937 &generator)
{
    snapshot_array.clear();
    code_location_vector.clear();
    vector<int> base_length_vector = NSArrayIntToVector
    (testSpecDictionary[@"triangulate_trials_base_length"]);
    vector<float> ratio_vecotr = NSArrayFloatToVector
    (testSpecDictionary[@"triangulate_trials_ratio"]);;
    vector<int> delta_theta_vecotr = NSArrayIntToVector
    (testSpecDictionary[@"triangulate_trials_theta"]);
    
    pair<vector<vector<double>>, vector<vector<double>>> pair_output =
    generateRandomTriangulateLocations(generator,
                        base_length_vector, ratio_vecotr, delta_theta_vecotr);
    batchCommitLocationPairs("", pair_output,
                             vector<int>{0, 0}, t_data_array);
    
    //--------------
    // Generate practice block
    //--------------
    base_length_vector = NSArrayIntToVector
    (testSpecDictionary[@"triangulate_practices_base_length"]);
    ratio_vecotr = NSArrayFloatToVector
    (testSpecDictionary[@"triangulate_practices_ratio"]);
    delta_theta_vecotr = NSArrayIntToVector
    (testSpecDictionary[@"triangulate_practices_theta"]);
    
    pair_output =
    generateRandomTriangulateLocations(generator,
                                       base_length_vector, ratio_vecotr, delta_theta_vecotr);
    batchCommitLocationPairs("t", pair_output,
                             vector<int>{0, 0}, t_data_array);
}

//-----------------------
// LocatePlus tests
//-----------------------
void TaskSpec::generateLocatePlusTests(vector<data> &t_data_array, std::mt19937 &generator)
{
    snapshot_array.clear();
    code_location_vector.clear();
    vector<int> base_length_vector = NSArrayIntToVector
    (testSpecDictionary[@"lplus_trials_base_length"]);
    vector<float> ratio_vecotr = NSArrayFloatToVector
    (testSpecDictionary[@"lplus_trials_ratio"]);
    vector<int> delta_theta_vecotr = NSArrayIntToVector
    (testSpecDictionary[@"lplus_trials_theta"]);
    
    pair<vector<vector<double>>, vector<vector<double>>> pair_output =
    generateRandomTriangulateLocations(generator,
                                       base_length_vector, ratio_vecotr, delta_theta_vecotr);
    batchCommitLocationPairs("", pair_output,
                             vector<int>{1, 0}, t_data_array);
    
    //--------------
    // Generate practice block
    //--------------
    base_length_vector = NSArrayIntToVector
    (testSpecDictionary[@"lplus_practices_base_length"]);
    ratio_vecotr = NSArrayFloatToVector
    (testSpecDictionary[@"lplus_practices_ratio"]);
    delta_theta_vecotr = NSArrayIntToVector
    (testSpecDictionary[@"lplus_practices_theta"]);
    
    pair_output =
    generateRandomTriangulateLocations(generator,
                                       base_length_vector, ratio_vecotr, delta_theta_vecotr);
    batchCommitLocationPairs("t", pair_output,
                             vector<int>{1, 0}, t_data_array);
}

//-----------------------
// Batch process a vector of location_pair
// The layout of location_pair is
// (x1, y1)
// (x2, y2)...
//-----------------------
void TaskSpec::batchCommitLocationPairs(string postfix,
        pair<vector<vector<double>>, vector<vector<double>>> location_pair_vector,
                                        vector<int> is_answer_list,
                                        vector<data> &t_data_array)
{
    // The first vector<vector<float>> hold truth stats,
    // one vector per test
    int trial_n = (int)location_pair_vector.first.size();

    for (int i = 0; i < trial_n; ++i)
    {
        double x1 = location_pair_vector.second[i*2][0];
        double y1 = location_pair_vector.second[i*2][1];
        double x2 = location_pair_vector.second[i*2+1][0];
        double y2 = location_pair_vector.second[i*2+1][1];
        
        string trialString = to_string(i) + postfix;
        
        vector<DoublePoint> openGLPoints = {DoublePointMake(x1, y1), DoublePointMake(x2, y2)};
        code_location_vector.push_back(make_pair(identifier + ":" + trialString + "-0",
                                                 vector<int>{(int)x1, (int)y1}));
        code_location_vector.push_back(make_pair(identifier + ":" + trialString + "-1",
                                                 vector<int>{(int)x2, (int)y2}));
        addTwoDataAndSnapshot(trialString, openGLPoints,
                              is_answer_list,
                              location_pair_vector.first[i],
                              t_data_array);
    }
}
//-----------------------
// Convert two OpenGL points to data and snapshot
//-----------------------
void TaskSpec::addTwoDataAndSnapshot(string trialString,
                                     vector<DoublePoint> openGLPoints,
                                     vector<int> is_answer_list,
                                     vector<double> truth_stats,
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
    vector<int> selected_ids = {(int)t_data_array.size() - 2,
        (int)t_data_array.size() - 1};
    
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
        [rootViewController calculateCoordinateSpanForDevice:WATCH];
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
        (centerCoordinate, distnace * 2.2, distnace * 2.2 * 1920.0/932.0);
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
    // Each task is associated with a device
    t_snapshot.deviceType = deviceType;
    t_snapshot.orientation = 0;
    
    // Generate notes from truth stats
    NSString* notes = [NSString stringWithFormat:
        @"base: %.2f, ratio: %.2f, delta_theta: %.2f, theta: %.2f",
        truth_stats[0], truth_stats[1], truth_stats[2], truth_stats[3]];
    
    t_snapshot.notes = notes;
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
    CLLocationCoordinate2DMake(((double)data_a.latitude + (double)data_b.latitude)/(double)2,
                               ((double)data_a.longitude + (double)data_b.longitude)/(double)2);
    
    
    MKCoordinateRegion coord_region =
    MKCoordinateRegionMakeWithDistance
    (centerCoordinate, distnace * 1.3, distnace * 1.3* 1920.0/932.0);
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