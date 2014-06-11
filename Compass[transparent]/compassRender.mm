//
//  drawing.cpp
//  compass
//
//  Created by dmiau on 11/6/13.
//  Copyright (c) 2013 Daniel Miau. All rights reserved.
//
#include "commonInclude.h"
#include <math.h>
#include <algorithm>
#include "compassRender.h"

#ifdef __IPHONE__
typedef UIFont NSFont;
typedef UIColor NSColor;
#import "Texture2D.h"
#endif

recVec glOrigin = {0.0, 0.0, 0.0};

#pragma mark ---------Renderer Initialization---------
// http://www.galloway.me.uk/tutorials/singleton-classes/
// http://www.yolinux.com/TUTORIALS/C++Singleton.html
compassRender* compassRender::shareCompassRender(){
    static compassRender* instance = NULL;
    
    if (!instance){ // Only allow one instance of class to be generated
        instance = new compassRender;
        instance->initRenderMdl();
    }
    return instance;
};


compassRender::compassRender(){
    initRenderMdl();
}

// sets the camera data to initial conditions
void compassRender::resetCamera()
{
    camera.fov = 30;
    
    camera.viewPos.x = 0.0;
    camera.viewPos.y = 0.0;
    camera.viewPos.z = 900; // This is the effective focal length
    
    camera.viewUp.x = 0;
    camera.viewUp.y = 1;
    camera.viewUp.z = 0;
}

int compassRender::initRenderMdl(){
    
    //--------------------
    // Initialize camera and shapes
    //--------------------
    resetCamera();     // Initialize the camera
    
    compass_scale = 1;
    label_flag = true;
    glDrawingCorrectionRatio = 1;
    half_canvas_size = camera.viewPos.z * tan(camera.fov/360*3.14);
    central_disk_radius = half_canvas_size/10;
    
    compass_centroid = glOrigin;
    
    //--------------------
    // Initialize string parameters
    //--------------------
    
    // init fonts for use with strings
	NSFont * font =[NSFont fontWithName:@"Helvetica" size:18.0];
    
	stringAttrib = [NSMutableDictionary dictionary];
	[stringAttrib setObject:font forKey:NSFontAttributeName];
    //	[stringAttrib setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
	[stringAttrib setObject:
     [NSColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f]
                     forKey:NSForegroundColorAttributeName];
    
#ifndef __IPHONE__
    label_string = [[GLString alloc] initWithString:@"" withAttributes:stringAttrib
                                      withTextColor:[NSColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f]
                                       withBoxColor:[NSColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:0.0f]
                                    withBorderColor:[NSColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f]];
#endif
    
    // near and far are calculated from the point of view of an observer
    return EXIT_SUCCESS;
}


int compassRender::initRenderView(float win_width, float win_height){
    orig_wigth = win_width; orig_height = win_height;
    model = compassMdl::shareCompassMdl();
    
    // Transformations for the projection
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();    
    
#ifdef __IPHONE__
    // left, right, bottom, top, z_near, z_far
    glOrthof(-half_canvas_size*200, half_canvas_size*200, -half_canvas_size*200, half_canvas_size*200,
             -150, 150);
#else
    //fovy, asepect, zNear, zFar
    gluPerspective(camera.fov, 1, 1, 3 * camera.viewPos.z );
#endif
    
    glMatrixMode(GL_MODELVIEW);
    
#ifndef __IPHONE__
    glLoadIdentity();
    gluLookAt(camera.viewPos.x, camera.viewPos.y, camera.viewPos.z,
              0, 0, 0,
              camera.viewUp.x, camera.viewUp.y, camera.viewUp.z);
#endif
    
    return EXIT_SUCCESS;
}

#pragma mark ------------- Handle window resize/update -------------


void compassRender::updateViewport
            (GLint x, GLint y, GLsizei width, GLsizei height)
{
    glDrawingCorrectionRatio = orig_height / height;
    glViewport (x, y, width, height);
    updateProjection((float)width/(float)height);  // update projection matrix
}

void compassRender::updateProjection(GLfloat aspect_ratio){
#ifdef __IPHONE__
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    
    // left, right, bottom, top, z_near, z_far
    glOrthof(-half_canvas_size, half_canvas_size, -half_canvas_size, half_canvas_size,
             -150, 150);
#else
	// set projection
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    //fovy, asepect, zNear, zFar
    gluPerspective(camera.fov, aspect_ratio, 1, 3 * camera.viewPos.z);
#endif
}

#pragma mark ---------core rendering routine---------
//--------------
// Tools
//--------------
RenderParamStruct makeRenderParams(
            filter_enum filter_type, style_enum style_type){
    
    RenderParamStruct renderParamStruct;
    renderParamStruct.filter_type = filter_type;
    renderParamStruct.style_type = style_type;
    return renderParamStruct;
}

//--------------
// Display
//--------------

void compassRender::render(){
    // Use the parameters supplied in configurations.json
    // if no input parameter is supplied.
    
    filter_enum filter_type =
    model->hashFilterStr(model->configurations[@"filter_type"]);
    
    style_enum style_type =
    hashStyleStr(model->configurations[@"style_type"]);
        
    RenderParamStruct renderParamStruct =
    makeRenderParams(filter_type, style_type);
//    makeRenderParams(NONE, BIMODAL);
    render(renderParamStruct);
}

void compassRender::render(RenderParamStruct renderParamStruct) {
    glEnableClientState(GL_VERTEX_ARRAY);
    //    glEnable(GL_BLEND);
    //    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    //
    //    glHint( GL_LINE_SMOOTH_HINT, GL_NICEST );
    //    glHint( GL_POLYGON_SMOOTH_HINT, GL_NICEST);
    //    glEnable(GL_MULTISAMPLE);
    
#ifdef __IPHONE__
    //--------------
    // This is something strnage. On iPhone I have to keep
    // resetting the projection matrix...
    //--------------
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();

    // left, right, bottom, top, z_near, z_far
    glOrthof(-half_canvas_size, half_canvas_size, -half_canvas_size, half_canvas_size,
             -150, 150);
#endif
    
    glMatrixMode(GL_MODELVIEW);
    
    glPushMatrix();
    
    // Figureing out translation
    glTranslatef(compass_centroid.x, compass_centroid.y, compass_centroid.z);
    

    // [todo] Careful! Potential bug here...
    // tilt
    glRotatef(model->tilt, 1, 0, 0);
    
    glRotatef(model->current_pos.orientation, 0, 0, -1);

    float scale = glDrawingCorrectionRatio * compass_scale;
    glScalef(scale, scale, 1);
    
    //--------------
    // Draw compass
    //--------------
    drawCompass(renderParamStruct);
    
    glPopMatrix();
    glDisableClientState(GL_VERTEX_ARRAY);
    
    // glFlush is called in OpenGLView
    //    glFlush();
}

//-------------
// drawCompass
//-------------
void compassRender::drawCompass(RenderParamStruct renderParamStruct){
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
    std::vector<double>::iterator result =
    std::max_element(t_dist_list.begin(),
                     t_dist_list.end());
    max_dist = *result;
    
    // ---------------
    // Draw the center circle
    // ---------------
    glColor4f([model->configurations[@"circle_color"][0] floatValue]/255,
              [model->configurations[@"circle_color"][1] floatValue]/255,
              [model->configurations[@"circle_color"][2] floatValue]/255,
              1);
    
    // draw the center circle
    drawCircle(0, 0, central_disk_radius, 50);

    
    // ---------------
    // Render triangles and the background disks
    // based on the specified style
    // ---------------
    
    // [todo] more rendering style should be supported
    applyStyle(renderParamStruct.style_type, model->indices_for_rendering);
//    renderStyleBimodal(indices_for_rendering);
    
    // ---------------
    // draw the labels
    // ---------------
    if (label_flag){
        glPushMatrix();
        
#ifdef __IPHONE__
        glTranslatef(0, 0, 1);
#endif
        for (int i = 0; i < model->indices_for_rendering.size(); ++i){
            int j = model->indices_for_rendering[i];
            data data_ = model->data_array[j];
            
            double distance = data_.distance / max_dist * half_canvas_size * 0.9;
            drawLabel(data_.orientation, distance, data_.name);
        }
        glPopMatrix();
    }

}

#pragma mark ---------drawing helper functions---------
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
void compassRender::drawCircle(float cx, float cy, float r, int num_segments)
{
    float* p_vertex_array = new float[num_segments * 2];
    
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
    glDrawArrays(GL_TRIANGLE_FAN, 0, num_segments);
    delete[] p_vertex_array;
}


#pragma mark ---------drawing labels---------
//-------------
// draw label
//-------------
void compassRender::drawLabel(float rotation, float height, string name)
{

	
    glPushMatrix();
    glRotatef(rotation, 0, 0, -1);
    
    glTranslatef(0, half_canvas_size * 0.9, 0); //central_disk_radius
    
    // Keep the text level
    glRotatef(-rotation, 0, 0, -1);

    // Fix text size
    float scale = 1/ ( compass_scale); // glDrawingCorrectionRatio *
    glScalef(scale, scale, scale);
    
    // This line seems to make the text darker for some reason
//    glColor4f (1.0f, 1.0f, 1.0f, 1.0f);    
    glPushMatrix();
    
    //--------------
    // Font generation
    //--------------
    // Set font size
#ifndef __IPHONE__
	NSFont * font =[NSFont fontWithName:@"Helvetica"
                                   size:
                    [model->configurations[@"font_size"] floatValue]];
#else
	UIFont *font = [UIFont fontWithName:@"Helvetica-Bold"
                                   size:[model->configurations[@"ios_font_size"] floatValue]];
#endif
    NSString * string = [NSString stringWithFormat:@"%@\n",
                         [NSString stringWithUTF8String:name.c_str()]];
    
	stringAttrib = [NSMutableDictionary dictionary];
	[stringAttrib setObject:font forKey:NSFontAttributeName];
    
#ifndef __IPHONE__
    [label_string setString:string withAttributes:stringAttrib];
    glRotatef(180, 1, 0, 0);
    
    [label_string drawAtPoint:NSMakePoint (0, 0)];
#else
    
    NSAttributedString *attr_str =
    [[NSAttributedString alloc] initWithString:string attributes:stringAttrib];

    CGSize str_size = makeGLFrameSize(attr_str);
    glTranslatef(-str_size.width, 0, 0);
    
//    if (rotation < 0)
//        rotation = rotation + 360;
//    
//    if ((rotation >= 180) && (rotation <= 360)) {
//        glRotatef(180, 0, 0, 1);
//        glTranslatef(-str_size.width, 0, 0);
//    }
    drawiOSText(string, [model->configurations[@"ios_font_size"] floatValue],
                str_size.width,
                str_size.height);
#endif
    glPopMatrix();
    
    glPopMatrix();
}

#ifdef __IPHONE__
CGSize compassRender::makeGLFrameSize(NSAttributedString *attr_str){
    CGSize t_size = [attr_str size];
    
    if (t_size.width > half_canvas_size/5){
        t_size.width = t_size.width /2;
        t_size.height = t_size.height * 2;
    }
        t_size.width = 2*round(t_size.width/2) + 8;
    t_size.height = 2*round(t_size.height/2) + 4;
        
    return t_size;
}

void compassRender::drawiOSText(NSString *string, int font_size,
                 CGFloat width, CGFloat height){
    width = width;
    height = height;
    // Use black
    glColor4f(0, 0, 0, 1.0);
    glEnable(GL_TEXTURE_2D);
    // Set up texture
    Texture2D* statusTexture = [[Texture2D alloc] initWithString:string dimensions:CGSizeMake(width, height) alignment:UITextAlignmentLeft fontName:@"Helvetica-Bold" fontSize:font_size];
    
    // Bind texture
    glBindTexture(GL_TEXTURE_2D, [statusTexture name]);
    
    // Enable modes needed for drawing
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    // Draw
    [statusTexture drawInRect:CGRectMake(0, 0, width, height)];
    
    // Disable modes so they don't interfere with other parts of the program
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisable(GL_TEXTURE_2D);
    glDisable(GL_BLEND);
    
}
#endif