#include "commonInclude.h"
#include <math.h>
#include <algorithm>
#include "compassRender.h"

#ifdef __IPHONE__
typedef UIFont NSFont;
typedef UIColor NSColor;
#import "Texture2D.h"
#endif

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
    glColor4f (1.0f, 1.0f, 1.0f, 1.0f);
    glPushMatrix();
    
    //--------------
    // Font generation
    //--------------
    // Set font size
//#ifndef __IPHONE__
	NSFont * font =[NSFont fontWithName:@"Helvetica"
                                   size:
                    [model->configurations[@"font_size"] floatValue]];
//#else
//	UIFont *font = [UIFont fontWithName:@"Helvetica"
//                                   size:[model->configurations[@"ios_font_size"] floatValue]];
//#endif
    NSString * string = [NSString stringWithFormat:@"%@\n",
                         [NSString stringWithUTF8String:name.c_str()]];
    
	stringAttrib = [NSMutableDictionary dictionary];
	[stringAttrib setObject:font forKey:NSFontAttributeName];

    
    
    //--------------
    // Render labels, different rendering methods depending on the platform
    //--------------
#ifndef __IPHONE__
    //--------------
    // OSX
    //--------------
    [label_string setString:string withAttributes:stringAttrib];
    glRotatef(180, 1, 0, 0);
    
    [label_string drawAtPoint:NSMakePoint (0, 0)];
#else
    //--------------
    // iOS
    //--------------
    NSAttributedString *attr_str =
    [[NSAttributedString alloc] initWithString:string attributes:stringAttrib];
    
    CGSize str_size = makeGLFrameSize(attr_str);
    
    glRotatef(model->current_pos.orientation, 0, 0, 1);
    
    rotation = rotation + model->current_pos.orientation;
    
    if (rotation < 0)
        rotation = rotation + 360;
    
    if ((rotation > 180) && (rotation < 360))
        glTranslatef(-str_size.width, 0, 0);
    
    glScalef(0.25, 0.25, 0);
    drawiOSText(string, 4*[model->configurations[@"font_size"] floatValue],
                4*str_size.width,
                4*str_size.height);
#endif
    glPopMatrix();
    
    glPopMatrix();
}

//--------------
// iOS related tools
//--------------
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
