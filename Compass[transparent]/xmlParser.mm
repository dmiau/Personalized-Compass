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
    NSString* filename = mdl->location_filename;
    xmlParser *myParser;
#ifdef __IPHONE__
//    //-----------------
//    // Check if an online version exist
//    //-----------------
//    NSString *dropbox_root = mdl->configurations[@"dropbox_root"];
//    NSURL *url = [NSURL URLWithString:
//                  [dropbox_root stringByAppendingString:[filename lastPathComponent]]];
//    
//    // Check if the URL is valid
//    NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:1.0];
//    NSHTTPURLResponse* response = nil;
//    NSError* error = nil;
//    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//    
//
//    if ([response statusCode] == 200){
//        // need to append "?dl=1" to access the file directly
//        myParser = [[xmlParser alloc]
//                    initWithFileURL:
//                    [NSURL URLWithString:[[url absoluteString] stringByAppendingString:@"?dl=1"]]
//                    ];
//    }else{
//        myParser = [[xmlParser alloc]
//                    initWithFileURL: [NSURL fileURLWithPath: filename]];
//    };
    
    

    NSData* data = nil;
    if (mdl->dbFilesystem.isReady &&
        mdl->filesys_type == DROPBOX){
        data = [mdl->dbFilesystem readFileFromName:
                [filename lastPathComponent]];
    }
    
    if (!data){
        //        data = [NSData dataWithContentsOfFile:jsonPath];
        data = [mdl->docFilesystem readFileFromName:
                [filename lastPathComponent]];
        mdl->filesys_type = IOS_DOC;
    }
    
    if (!data){
        throw(runtime_error("Failed to read the location file."));
        return EXIT_FAILURE;
    }else{
        myParser = [[xmlParser alloc] initWithData: data];
    }
    
    
#else
    myParser = [[xmlParser alloc]
                initWithFileURL: [NSURL fileURLWithPath: filename]];
#endif
    
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

-(id)initWithFileURL: (NSURL*) in_fileurl{
    self = [super init];
    fileurl = in_fileurl;
    in_data = nil;
    place_flag = false;
    name_flag = false;
    coord_flag = false;
    return self;
}

-(id)initWithData: (NSData*) inData{
    self = [super init];
    fileurl = nil;
    in_data = inData;
    place_flag = false;
    name_flag = false;
    coord_flag = false;
    return self;
}

-(int) parseFile{
    
    if (!in_data){
        parser = [[NSXMLParser alloc]
                  initWithContentsOfURL: fileurl];
    }else{
        parser = [[NSXMLParser alloc] initWithData: in_data];
    }
    
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
        _data.isEnabled = YES;
        _data.annotation = [[MKPointAnnotation alloc] init];
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
            data_array[data_array.size()-1].annotation.title
            = string;
            data_array[data_array.size()-1].annotation.subtitle =
            [NSString stringWithFormat:@"%lu", data_array.size()-1];
        }else if (coord_flag){
            // Need to somehow split the sting
            
            NSArray *_coord = [string componentsSeparatedByString:@","];
            // Note that in KML coordinates order are (lon, lat)
            data_array[data_array.size()-1].latitude = [_coord[1] floatValue];
            data_array[data_array.size()-1].longitude = [_coord[0] floatValue];
            
            // Populate MKPointAnnotation
            CLLocationCoordinate2D coord2D = CLLocationCoordinate2DMake
            (data_array[data_array.size()-1].latitude,
             data_array[data_array.size()-1].longitude);
            data_array[data_array.size()-1].annotation.coordinate = coord2D;
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
