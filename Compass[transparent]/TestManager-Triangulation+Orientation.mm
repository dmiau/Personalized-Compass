//
//  TestManager-Triangulation.cpp
//  Compass[transparent]
//
//  Created by Daniel on 2/19/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#import "TestManager.h"
#import "CHCSVParser.h"
#include <random>

using namespace std;

//--------------
// Method to generate LOCALIZE (triangulation) tests
// Ooutput k*n x 2 locations, k is the number of supporting locations per test,
// n is the number of tests, the last 2 is for (x, y). All coordinates are in int
//--------------
vector<vector<int>> TestManager::generateRandomTriangulateLocations
(double close_boundary, double far_boundary, int location_n)
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
    vector<float> base_length_vector = {(float)far_boundary};
    vector<int> ratio_vecotr = {1, 2, 3};
    vector<int> delta_theta_vecotr = {90, 150, 210, 270};

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

//--------------
// Generate Orientation trials
//--------------
vector<vector<int>> TestManager::generateRandomOrientLocations
(double close_boundary, double far_boundary, int location_n){
    
    vector<vector<int>> output;
    
    double step = (far_boundary - close_boundary) / location_n;
    
    using namespace std;
    // Initialize random number generator
    
    // Need to provide a seed
    std::uniform_int_distribution<int>  distr(0, step);
    
    vector<double> base_length_vector; base_length_vector.clear();
    for (int i = 0; i < location_n; ++i){
        int temp = close_boundary + step * i + distr(generator);
        base_length_vector.push_back(temp);
    }
    
    // At this point we have location_n lengths
    std::uniform_int_distribution<int>  distr2(0, 359);
    
    // Draw trial_n thetas
    
    // 0 degree is in the positie x direction
    vector<int> theta_vector;
    for (int i = 0; i < location_n; ++i){
        theta_vector.push_back(distr2(generator));
    }

    //-------------------------
    // Generate point (x, y) here
    //-------------------------
    for (int i = 0; i < location_n; ++i){
        int x, y;
        // Calculate point 1
        float pt1_length = base_length_vector[i];
        float theta =  (float) theta_vector.back();
        theta_vector.pop_back();
        x = pt1_length * cos(theta/180 * M_PI);
        y = pt1_length * sin(theta/180 * M_PI);
        
        vector<int> t_vector = {x, y};
        output.push_back(t_vector);
    }
    
    return output;
}