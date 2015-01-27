//
//  TestManager-Location.cpp
//  Compass[transparent]
//
//  Created by dmiau on 1/26/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#import "TestManager.h"

//--------------
// Methods to generate tests
//--------------
vector<data> TestManager::generateLocateTests(DeviceType deviceType){
    // locations in close_vector should be witin the display area,
    // so we can perform the old wedge test on the display
    
    vector<data> tests;
    
    if (deviceType == PHONE){
        // PHONE
        float em_width, em_height;
        float ios_width = 320, ios_height = 503;
        
        //           close_n steps    far_n steps
        // -------|------------|------------------|
        // screen_edge  close_boundary   far_boundary
        
        double close_boundary = ios_width/2 * close_boundary_x;
        double far_boundary = ios_height/2 * close_boundary_x;
        
        double em_diag = sqrt(em_width*em_width + em_height*em_height);
        double ios_diag = sqrt(ios_width*ios_width + ios_height*ios_height);
        
        double close_step = ios_diag/2 * close_boundary_x / close_n;
        
        //TODO: Need to think about random number generation
        vector<int> close_bias(close_n, 0);
        
        vector<double> close_vector; close_vector.clear();
        for (int i = 0; i < close_n; ++i){
            
        }
        
        
        
        double far_step = ios_width/2 * far_boundary_x / far_n;
        
    }else{
        // WATCH
        
        
        
    }
    
    
    return tests;
}

vector<data> TestManager::generateTriangulateTests(DeviceType deviceType){
    vector<data> tests;
    return tests;
}

vector<data> TestManager::generateOrientTests(DeviceType deviceType){
    vector<data> tests;
    return tests;
}
