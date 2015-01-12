//
//  compassRender+Components.mm
//  compass
//
//  Created by dmiau on 6/12/14.
//  Copyright (c) 2014 Daniel Miau. All rights reserved.
//
#include "commonInclude.h"
#include <cmath>
#include <algorithm>
#include "compassRender.h"

#ifdef __IPHONE__
typedef UIFont NSFont;
typedef UIColor NSColor;
#import "Texture2D.h"
#endif

#pragma mark ---------drawing the compass---------
//-------------
// drawCompass
//-------------
void compassRender::drawWayfindingAid(RenderParamStruct renderParamStruct){
    /*
     By the time this funciton is called,
     model->indices_for_rendering shold have been updated by the model
     */
    
    // ------------------
    // Find out the longest distance for normalization
    // ------------------
    vector <double> t_dist_list;
    for (int i = 0; i < model->indices_for_rendering.size(); ++i){
        int j = model->indices_for_rendering[i];
        t_dist_list.push_back(model->data_array[j].distance);
    }
    
    if (t_dist_list.size() >= 1){
        std::vector<double>::iterator result =
        std::max_element(t_dist_list.begin(),
                         t_dist_list.end());
        max_dist = *result;
    }else{
        max_dist = INFINITY;
    }
    // ---------------
    // Render triangles and the background disks
    // based on the specified style
    // ---------------
    
    // indices_for_rendering is updated in compassMdl.updateMdl()
    applyStyle(renderParamStruct.style_type, model->indices_for_rendering);
    
    // ---------------
    // draw labels
    // ---------------
    if (label_flag){
        glPushMatrix();
        vector<double> orientation_array;
        orientation_array.clear();
        

        glTranslatef(0, 0, 1);
        for (int i = 0; i < model->indices_for_rendering.size(); ++i){
            int j = model->indices_for_rendering[i];
            data data_ = model->data_array[j];
            
            double distance, orientation;
            if (!wedgeMode){
                
                orientation = data_.orientation;
                distance = half_canvas_size * 0.9;
                
//                //-----------------
//                // Populate label info here
//                //-----------------
//                model->data_array[j].my_label_info.orientation
//                = orientation;
//                model->data_array[j].my_label_info.distance
//                = distance * compass_scale;
//                model->data_array[j].my_label_info.centroid.x
//                = distance * compass_scale * sin(orientation/180*M_PI);
//                model->data_array[j].my_label_info.centroid.y
//                = distance * compass_scale * cos(orientation/180*M_PI);
//
//                
//                NSLog(@"==Render==");
//                NSLog(@"Name: %@",
//                      [NSString stringWithUTF8String: model->data_array[j].name.c_str()]);
//                NSLog(@"Dist: %f, Orienation: %f", distance * compass_scale,
//                      orientation);
//                
//                NSLog(@"Centroid: %@", NSStringFromCGPoint(model->data_array[j].my_label_info.centroid));
//                NSLog(@"==Render==");
            }else{
                orientation = data_.my_label_info.orientation;
                distance = data_.my_label_info.distance;
            }
            label_info my_label_info = drawLabel(orientation, distance,
                      model->data_array[j].my_texture_info);
            if (!wedgeMode){
                model->data_array[j].my_label_info = my_label_info;
            }
            
            orientation_array.push_back(data_.orientation);
        }

        //--------------
        // Draw scale indicator
        //--------------
        if (model->mode_max_dist_array.size() > 1
            && !wedgeMode)
        {
            double best_orientation = findBestEmptyOrienation(orientation_array);
            
            // Generate the string
            char buff[10];
            sprintf(buff, "1:%2.1f",
                    model->mode_max_dist_array[1]/model->mode_max_dist_array[0]);
            
            texture_info my_texture_info = model->generateTextureInfo
            ([NSString stringWithUTF8String:buff]);
            my_texture_info.box_flag = false;
            drawLabel(best_orientation, half_canvas_size * 0.3, my_texture_info);
        }
        glPopMatrix();
    }
    
}

#pragma mark ---------drawing shapes---------
//-------------
// coreTriangle
//-------------
void compassRender::drawTriangle(int central_disk_radius, float rotation, float height)
{
    glPushMatrix();
    glRotatef(rotation, 0, 0, -1);
    //    cout << "rotation: " << rotation << endl;
    Vertex3D    vertex1 = Vertex3DMake(0, height, 0);
    Vertex3D    vertex2 = Vertex3DMake(-central_disk_radius, 0, 0);
    Vertex3D    vertex3 = Vertex3DMake(central_disk_radius, 0, 0);
        
    Triangle3D  triangle = Triangle3DMake(vertex1, vertex2, vertex3);
    glVertexPointer(3, GL_FLOAT, 0, &triangle);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    glPopMatrix();
}

//-------------
// coreCircle
// http://slabode.exofire.net/circle_draw.shtml
//-------------
void compassRender::drawCircle(float cx, float cy, float r,
                               int num_segments, bool isSolid)
{
    float* p_vertex_array = new float[num_segments * 2 + 2];
    
    // draw a filled circle
    for(int ii = 0; ii < num_segments; ii++)
    {
        float theta = 2.0f * 3.1415926f * float(ii) / float(num_segments);//get the current angle
        
        float x = r * cosf(theta);//calculate the x component
        float y = r * sinf(theta);//calculate the y component
        
        p_vertex_array[ii*2] = x + cx;
        p_vertex_array[ii*2 + 1] = y + cy;
    }
    
    glVertexPointer(2, GL_FLOAT, 0, p_vertex_array);
    
    if (isSolid)
        glDrawArrays(GL_TRIANGLE_FAN, 0, num_segments);
    else{
        // Need to
        p_vertex_array[num_segments*2] = p_vertex_array[0];
        p_vertex_array[num_segments*2 + 1] = p_vertex_array[1];
        glDrawArrays(GL_LINE_STRIP, 0,num_segments + 1);
    }
    
    delete[] p_vertex_array;
}


void compassRender::drawClearWatch(){
    
    glPushMatrix();
    glTranslatef(0, 0, -1);
    // ---------------
    // draw the background (transparent) disk
    // ---------------
    float outer_disk_radius =
    half_canvas_size *
    [model->configurations[@"outer_disk_ratio"] floatValue];
    
    // Translate the compass to the desired screen location
    glTranslatef(compass_centroid.x, compass_centroid.y, 0);
    
    glColor4f(0, 0, 0, 0);

    float scale = glDrawingCorrectionRatio * compass_scale;
    glScalef(scale, scale, 1);
    drawCircle(0, 0, outer_disk_radius, 50, true);

    glPopMatrix();
}

//-------------
// draws the mini box to signify scale
//-------------
BOOL compassRender::drawBoxInCompass(double renderD2realDRatio)
{
    // drawBoxInCompass returns true when the box is successfully drawn
    // drawBoxInCompass returns false when the box is too small to be drawn
    
    // calculate the parameters needed to draw the box
    
    CLLocationDistance box_width = getMapWidthInMeters();
    CLLocationDistance box_height = getMapHeightInMeters();
    
//    NSLog(@"box_width %f", box_width);
//    NSLog(@"box_height %f", box_height);
    
    double render_width = box_width * renderD2realDRatio;
    double render_height = box_height * renderD2realDRatio;
    
    if (render_width <= central_disk_radius ||
        render_height <= central_disk_radius){
        return false;
    }
    
    // Then the origin
    double x, y;
    
    // The following formula needs to be corrected
//model->compassCenterXY.x / mapView.frame.size.width
//    x = -render_width * (0.5* orig_width + compass_centroid.x) / orig_width;
//    y = render_height * (0.5 * orig_height - compass_centroid.y) / orig_height;

    x = -render_width * model->compassCenterXY.x / mapView.frame.size.width;
    y = render_height * model->compassCenterXY.y / mapView.frame.size.height;
    
//    //---------------
//    // Debug info
//    //---------------
//    NSLog(@"-------------");
//    NSLog(@"x: %f, y: %f", x, y);
//    NSLog(@"render width: %f, render height %f", render_width, render_height);
//    NSLog(@"renderD2realD: %f", renderD2realDRatio);
//    NSLog(@"box width/height: %f", box_width/box_height);
//    NSLog(@"-------------");
    
    // Draw the box
    glLineWidth(3);
    glColor4f(1, 0, 0, 0.5);
    glPushMatrix();
    // Plot the triangle first, then rotate and translate
    
    Vertex3D    vertex1 = Vertex3DMake(x, y, 0);
    Vertex3D    vertex2 = Vertex3DMake(x+render_width,
                                       y, 0);
    
    Vertex3D    vertex3 = Vertex3DMake(x+render_width,
                                       y-render_height, 0);

    Vertex3D    vertex4 = Vertex3DMake(x,
                                       y-render_height, 0);
    
    RectangleLine3D  rectangle = RectangleLine3DMake(vertex1, vertex2,
                                                     vertex3, vertex4);
    glVertexPointer(3, GL_FLOAT, 0, &rectangle);
    glDrawArrays(GL_LINE_STRIP, 0,5);
    
    glPopMatrix();
    return true;
}

BOOL compassRender::drawBoundaryCircle(double renderD2realDRatio)
{
    // drawBoundaryCircle returns true when the circle is successfully drawn
    // drawBoundaryCircle returns false when the circle is too small to be drawn
    
    // calculate the parameters needed to draw the box
    
    CLLocationDistance box_width = getMapWidthInMeters();
    float radius = [model->configurations[@"watch_radius"] floatValue];
    
    double boundary_radius = box_width * renderD2realDRatio
    * radius / mapView.frame.size.width;

    if (boundary_radius <= central_disk_radius)
    {
        return false;
    }
    
    // Draw the circle
    glLineWidth(2);
    glColor4f(1, 0, 0, 0.5);
    drawCircle(0, 0, boundary_radius, 50, false);
    return true;
}

void compassRender::drawBoxInView(CGPoint fourCorners[4]){
    // Draw the box
    glLineWidth(2);
    glColor4f(1, 0, 0, 1);
    glPushMatrix();
    // Plot the triangle first, then rotate and translate
    
    Vertex3D    vertex1 = Vertex3DMake(fourCorners[0].x, fourCorners[0].y, 0);
    Vertex3D    vertex2 = Vertex3DMake(fourCorners[1].x, fourCorners[1].y, 0);
    Vertex3D    vertex3 = Vertex3DMake(fourCorners[2].x, fourCorners[2].y, 0);
    Vertex3D    vertex4 = Vertex3DMake(fourCorners[3].x, fourCorners[3].y, 0);
        
    RectangleLine3D  rectangle = RectangleLine3DMake(vertex1, vertex2,
                                                     vertex3, vertex4);
    glVertexPointer(3, GL_FLOAT, 0, &rectangle);
    glDrawArrays(GL_LINE_STRIP, 0,5);
    
    glPopMatrix();
}



//-------------------------
//
//-------------------------
void compassRender::drawiOSMask(CGPoint fourCorners[4]){
    // Draw the box
    glLineWidth(2);
    glColor4f(0, 0, 0, 0);
    glPushMatrix();
    
    Vertex3D    vertex1, vertex2, vertex3, vertex4;
    RectangleLine3D rectangle;
    // Need to draw four rectangles: top, left, bottom, right
    
    // Draw the top rectangle:
    vertex1 = Vertex3DMake(0, 0, 0);
    vertex2 = Vertex3DMake(orig_width, 0, 0);
    vertex3 = Vertex3DMake(orig_width, fourCorners[0].y, 0);
    vertex4 = Vertex3DMake(0, fourCorners[0].y, 0);
    
    rectangle = RectangleLine3DMake(vertex1, vertex2,
                                                     vertex3, vertex4);
    glVertexPointer(3, GL_FLOAT, 0, &rectangle);
    glDrawArrays(GL_TRIANGLE_FAN, 0,5);
    

    // Draw the left rectangle:
    vertex1 = Vertex3DMake(fourCorners[1].x, 0, 0);
    vertex2 = Vertex3DMake(orig_width, 0, 0);
    vertex3 = Vertex3DMake(orig_width, orig_height, 0);
    vertex4 = Vertex3DMake(fourCorners[1].x, orig_height, 0);
    
    rectangle = RectangleLine3DMake(vertex1, vertex2,
                                    vertex3, vertex4);
    glVertexPointer(3, GL_FLOAT, 0, &rectangle);
    glDrawArrays(GL_TRIANGLE_FAN, 0,5);
    
    
    // Draw the bottom rectangle:
    vertex1 = Vertex3DMake(0, fourCorners[2].y, 0);
    vertex2 = Vertex3DMake(orig_width, fourCorners[2].y, 0);
    vertex3 = Vertex3DMake(orig_width, orig_height, 0);
    vertex4 = Vertex3DMake(0, orig_height, 0);
    
    rectangle = RectangleLine3DMake(vertex1, vertex2,
                                    vertex3, vertex4);
    glVertexPointer(3, GL_FLOAT, 0, &rectangle);
    glDrawArrays(GL_TRIANGLE_FAN, 0,5);
    
    // Draw the right rectangle:
    vertex1 = Vertex3DMake(0, 0, 0);
    vertex2 = Vertex3DMake(fourCorners[0].x, 0, 0);
    vertex3 = Vertex3DMake(fourCorners[0].x, orig_height, 0);
    vertex4 = Vertex3DMake(0, orig_height, 0);
    
    rectangle = RectangleLine3DMake(vertex1, vertex2,
                                    vertex3, vertex4);
    glVertexPointer(3, GL_FLOAT, 0, &rectangle);
    glDrawArrays(GL_TRIANGLE_FAN, 0,5);
    
    glPopMatrix();
}

#pragma mark ----Tools----
double compassRender::getMapWidthInMeters(){

    CLLocationCoordinate2D top_left_coord =
    [this->mapView convertPoint:CGPointMake(0, 0)
           toCoordinateFromView:this->mapView];
    
    CLLocation *top_left_loc =
    [[CLLocation alloc] initWithLatitude:top_left_coord.latitude longitude:top_left_coord.longitude];
    
    CLLocationCoordinate2D top_right_coord =
    [this->mapView convertPoint:CGPointMake(this->mapView.frame.size.width, 0)
           toCoordinateFromView:this->mapView];
    CLLocation *top_right_loc =
    [[CLLocation alloc] initWithLatitude:top_right_coord.latitude longitude:top_right_coord.longitude];
    return [top_left_loc distanceFromLocation:top_right_loc];
}

double compassRender::getMapHeightInMeters(){
    CLLocationCoordinate2D top_left_coord =
    [this->mapView convertPoint:CGPointMake(0, 0)
           toCoordinateFromView:this->mapView];
    
    CLLocation *top_left_loc =
    [[CLLocation alloc] initWithLatitude:top_left_coord.latitude longitude:top_left_coord.longitude];
    
    CLLocationCoordinate2D bottom_left_coord =
    [this->mapView convertPoint:CGPointMake(0, this->mapView.frame.size.height)
           toCoordinateFromView:this->mapView];
    CLLocation *bottom_left_loc =
    [[CLLocation alloc] initWithLatitude:bottom_left_coord.latitude longitude:bottom_left_coord.longitude];
    return [top_left_loc distanceFromLocation:bottom_left_loc];
}

double compassRender::findBestEmptyOrienation(vector<double> orientation_array){
    
    vector<double> debug_array = orientation_array;
    double empty_orientation;
    vector<pair<double, int>> diff_array;
    // sort by ascending order
    sort(orientation_array.begin(), orientation_array.end());
    
    
    //---------------
    // Calculate the differences
    //---------------
    for (int i = 0; i < orientation_array.size(); ++i){
        if (i == 0 ){
            diff_array.push_back
            (make_pair(360 - orientation_array.back() + orientation_array[0], i));
        }else{
            diff_array.push_back
            (make_pair(orientation_array[i] - orientation_array[i-1], i));
        }
    }
    
    //---------------
    // Find the max difference
    //---------------
    // Figure out the data is unimodal or bimodal?
    std::vector<pair<double, int>>::iterator result =
    std::max_element(diff_array.begin(),
                     diff_array.end(), compareAscending);
    int idx = result->second;

    //---------------
    // Decide the empty orientation
    //---------------
    if (idx == 0){
        empty_orientation = orientation_array.back() + diff_array[0].first/2;
        empty_orientation = fmod(empty_orientation, 360);
    }else{
        empty_orientation = 0.5*(orientation_array[idx] + orientation_array[idx-1]);
    }
    return empty_orientation;
}



