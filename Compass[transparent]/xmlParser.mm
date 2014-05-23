//
//  xmlParser.m
//  playCocoa
//
//  Created by Daniel Miau on 3/20/14.
//  Copyright (c) 2014 Daniel Miau. All rights reserved.
//

#import "xmlParser.h"
#include <stdexcept>


int readLocationKml(compassMdl* mdl){
    
    xmlParser *myParser = [[xmlParser alloc]
                           initWithFilename: mdl->location_filename];
    myParser.parseFile;
    
    mdl->current_pos.name = myParser.data_array[0].name;
    // Set the initial orientation to 0
    mdl->current_pos.orientation = 0;
    mdl->current_pos.latitude = myParser.data_array[0].latitude;
    mdl->current_pos.longitude = myParser.data_array[0].longitude;
    
    // Remove the first data (since it is the current location)
//    cout << myParser.data_array.begin()->name << endl;
//    myParser.data_array[0].name = "paris";
//    cout << myParser.data_array[0].name << endl;
//    cout << myParser.data_array.begin()->name << endl;

//    vector<data>::iterator it = myParser.data_array.begin();
//    it->name = "paris";
//    cout << myParser.data_array.begin()->name << endl;
    
    mdl->data_array = myParser.data_array;
    
    return EXIT_SUCCESS;
}


@implementation xmlParser

@synthesize data_array;

-(id)initWithFilename: (string) in_filename{
    filename = in_filename;
    place_flag = false;
    name_flag = false;
    coord_flag = false;
    return self;
}

-(int) parseFile{

    NSString *full_location_file_path = [NSString stringWithCString:filename.c_str()
                                                encoding:[NSString defaultCStringEncoding]];

    parser = [[NSXMLParser alloc]
              initWithContentsOfURL:
              [NSURL fileURLWithPath: full_location_file_path ]];
    
    [parser setDelegate:self];
    BOOL success = [parser parse];
    
    // test the result
    if (success){
        
    }else{
        throw(std::runtime_error("Failed to parse the document!"));
    }
    
#ifdef DM_DEBUG
    // Need to check the result here
    NSLog(@"done!");
    cout << data_array.size() << endl;
#endif
    
    return success;
}


-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
#ifdef DM_DEBUG
    NSLog(@"Started Element %@", elementName);
#endif
//    // initialize element?
//    element = [NSMutableString string];
    
    
    if ([elementName isEqualToString:@"Placemark"]) {
#ifdef DM_DEBUG
        NSLog(@"Placemark block found – create a new instance of data class...");
#endif
        data _data;
        _data.name = "";
        _data.latitude = 0;
        _data.longitude = 0;
        _data.distance = 0;
        _data.orientation = 0;
        data_array.push_back(_data);
        place_flag = true;
    }else if ([elementName isEqualToString:@"name"]){
        name_flag = true;
    }else if ([elementName isEqualToString:@"coordinates"]){
        coord_flag = true;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if (place_flag){
        if (name_flag){
            data_array[data_array.size()-1].name = [string UTF8String];
        }else if (coord_flag){
            // Need to somehow split the sting
            
            NSArray *_coord = [string componentsSeparatedByString:@","];
            // Note that in KML coordinates order are (lon, lat)
            data_array[data_array.size()-1].latitude = [_coord[1] floatValue];
            data_array[data_array.size()-1].longitude = [_coord[0] floatValue];
        }
    }
}


-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
#ifdef DM_DEBUG
    NSLog(@"Found an element named: %@ with a value of: %@", elementName, element);
#endif
    if ([elementName isEqualToString:@"Placemark"]) {
        place_flag = false;
    }else if ([elementName isEqualToString:@"name"]) {
        name_flag = false;
    }else if ([elementName isEqualToString:@"coordinates"]) {
        coord_flag = false;
    }
}

@end
