#include "commonInclude.h"
#include <cmath>
#include <algorithm>
#include "compassRender.h"

#pragma mark ---------drawing labels---------
//-------------
// draw label
//-------------
void compassRender::drawLabel(float rotation, float height,
                              texture_info my_texture_info)
{    
    glPushMatrix();
    //--------------------
    // Keep the text level (rotate->translate->rotate)
    //--------------------
    glRotatef(rotation, 0, 0, -1);
    glTranslatef(0, height, 0); //central_disk_radius
    glRotatef(-rotation, 0, 0, -1);
    
    if (!wedgeMode){
        // Fix text size
        float scale = 1/ (compass_scale); // glDrawingCorrectionRatio *
        glScalef(scale, scale, 1);
    }
    
    // This line seems to make the text darker for some reason
    glColor4f (1.0f, 1.0f, 1.0f, 1.0f);
    
    //--------------
    // Render labels, different rendering methods depending on the platform
    //--------------
    rotation = rotation + model->camera_pos.orientation;
    
    if (rotation < 0)
        rotation = rotation + 360;
    
    if (!wedgeMode){
        glRotatef(model->camera_pos.orientation, 0, 0, 1);
        if ((rotation > 180) && (rotation < 360))
            glTranslatef(-my_texture_info.size.width, 0, 0);
    }
    //--------------------
    //text tilting still needs to be fixed
    glRotatef(-model->tilt, 1, 0, 0);
    //--------------------
    
#ifndef __IPHONE__
    //--------------
    // OSX
    //--------------
    glRotatef(180, 1, 0, 0);
    label_string = [[GLString alloc] initWithAttributedString:
                    my_texture_info.attr_str];
    [label_string drawAtPoint:NSMakePoint (0, 0)];
#else
    //--------------
    // iOS
    //--------------
    glScalef(0.25, 0.25, 0);
    drawiOSText(my_texture_info.attr_str.string,
                4*[model->configurations[@"font_size"] floatValue],
                4*my_texture_info.size.width,
                4*my_texture_info.size.height);
#endif
    glPopMatrix();
}

//--------------
// iOS related tools
//--------------
#ifdef __IPHONE__
void compassRender::drawiOSText(NSString *string, int font_size,
                                CGFloat width, CGFloat height){
    // Use black
    if (mapView.mapType == MKMapTypeStandard){
        glColor4f(0, 0, 0, 1.0);
    }else{
        glColor4f(255.0/255.0, 54.0/255.0, 96.0/255.0, 1.0);
    }

    glEnable(GL_TEXTURE_2D);
    // Set up texture
    Texture2D* statusTexture = [[Texture2D alloc]
                                initWithString:string
                                dimensions:CGSizeMake(width, height)
                                alignment: UITextAlignmentLeft
                                fontName:@"Helvetica-Bold" fontSize:font_size];
    
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
















