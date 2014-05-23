//
//  jsonReader.cpp
//  testJsoncpp
//
//  Created by dmiau on 2/6/14.
//  Copyright (c) 2014 Daniel Miau. All rights reserved.
//

#include "jsonReader.h"

//---------------------
// Functiont that read a json file to root
//---------------------
int readFile(string filename, Json::Value& root){
    
    cout << filename << endl;
    // Read in a file
    ifstream in(filename, ifstream::binary);
    
    while (!in.is_open())
    {
//        // keep trying
//        in.open(filename, ifstream::binary);
        throw(runtime_error("File open failed"));
        return(EXIT_FAILURE);
    }
    Json::Reader reader;
    
    bool success = reader.parse(in, root, false);
    if ( !success )
    {
        // report to the user the failure and their locations in the document.
        std::cout  << reader.getFormatedErrorMessages()
        << "\n";
        return (EXIT_FAILURE);
    }
    return EXIT_SUCCESS;
}