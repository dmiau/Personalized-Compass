#import "GLString.h"
#include <iostream>
// The following is a NSBezierPath category to allow
// for rounded corners of the border

#pragma mark -
#pragma mark NSBezierPath Category

#ifndef __IPHONE__
@implementation NSBezierPath (RoundRect)

+ (NSBezierPath *)bezierPathWithRoundedRect:(NSRect)rect cornerRadius:(float)radius {
    NSBezierPath *result = [NSBezierPath bezierPath];
    [result appendBezierPathWithRoundedRect:rect cornerRadius:radius];
    return result;
}

- (void)appendBezierPathWithRoundedRect:(NSRect)rect cornerRadius:(float)radius {
    if (!NSIsEmptyRect(rect)) {
		if (radius > 0.0) {
			// Clamp radius to be no larger than half the rect's width or height.
			float clampedRadius = MIN(radius, 0.5 * MIN(rect.size.width, rect.size.height));
			
			NSPoint topLeft = NSMakePoint(NSMinX(rect), NSMaxY(rect));
			NSPoint topRight = NSMakePoint(NSMaxX(rect), NSMaxY(rect));
			NSPoint bottomRight = NSMakePoint(NSMaxX(rect), NSMinY(rect));
			
			[self moveToPoint:NSMakePoint(NSMidX(rect), NSMaxY(rect))];
			[self appendBezierPathWithArcFromPoint:topLeft     toPoint:rect.origin radius:clampedRadius];
			[self appendBezierPathWithArcFromPoint:rect.origin toPoint:bottomRight radius:clampedRadius];
			[self appendBezierPathWithArcFromPoint:bottomRight toPoint:topRight    radius:clampedRadius];
			[self appendBezierPathWithArcFromPoint:topRight    toPoint:topLeft     radius:clampedRadius];
			[self closePath];
		} else {
			// When radius == 0.0, this degenerates to the simple case of a plain rectangle.
			[self appendBezierPathWithRect:rect];
		}
    }
}

@end
#endif

#pragma mark -
#pragma mark GLString

// GLString follows

@implementation GLString

#pragma mark -
#pragma mark Deallocs

- (void) deleteTexture
{
#ifndef __IPHONE__
	if (texName && cgl_ctx) {
		(*cgl_ctx->disp.delete_textures)(cgl_ctx->rend, 1, &texName);
		texName = 0; // ensure it is zeroed for failure cases
		cgl_ctx = 0;
	}
#endif
}

- (void) dealloc
{
	[self deleteTexture];
    //	[textColor release];
    //	[boxColor release];
    //	[borderColor release];
    //	[string release];
    //	[super dealloc];
}

#pragma mark -
#pragma mark Initializers

// designated initializer
- (id) initWithAttributedString:(NSAttributedString *)attributedString withTextColor:(NSColor *)text withBoxColor:(NSColor *)box withBorderColor:(NSColor *)border
{
	self = [super init];
    if (self){
#ifndef __IPHONE__
        cgl_ctx = NULL;
#endif
        texName = 0;
        texSize.width = 0.0f;
        texSize.height = 0.0f;
        //        [attributedString retain];
        string = attributedString;
        //        [text retain];
        //        [box retain];
        //        [border retain];
        textColor = text;
        boxColor = box;
        borderColor = border;
        staticFrame = NO;
        antialias = YES;
        marginSize.width = 4.0f; // standard margins
        marginSize.height = 2.0f;
        cRadius = 4.0f;
        requiresUpdate = YES;
    }
	// all other variables 0 or NULL
	return self;
}

- (id) initWithString:(NSString *)aString withAttributes:(NSDictionary *)attribs withTextColor:(NSColor *)text withBoxColor:(NSColor *)box withBorderColor:(NSColor *)border
{
	return [self initWithAttributedString:[[NSAttributedString alloc] initWithString:aString attributes:attribs] withTextColor:text withBoxColor:box withBorderColor:border];
}

// basic methods that pick up defaults
- (id) initWithAttributedString:(NSAttributedString *)attributedString;
{
	return [self initWithAttributedString:attributedString withTextColor:[NSColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f] withBoxColor:[NSColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.0f] withBorderColor:[NSColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.0f]];
}

- (id) initWithString:(NSString *)aString withAttributes:(NSDictionary *)attribs
{
	return [self initWithAttributedString:[[NSAttributedString alloc] initWithString:aString attributes:attribs] withTextColor:[NSColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f] withBoxColor:[NSColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.0f] withBorderColor:[NSColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.0f]];
}

- (void) genTexture; // generates the texture without drawing texture to current context
{
	NSSize previousSize = texSize;
	
	if ((NO == staticFrame) && (0.0f == frameSize.width) && (0.0f == frameSize.height)) { // find frame size if we have not already found it
		frameSize = [string size]; // current string size
        
        // round to the nearest power of 2
        frameSize.width = 2*round(frameSize.width/2);
        frameSize.height= 2*round(frameSize.height/2);
        
		frameSize.width += marginSize.width * 2.0f; // add padding
		frameSize.height += marginSize.height * 2.0f;
	}
    
#ifndef __IPHONE__
    NSImage * image;
	image = [[NSImage alloc] initWithSize:frameSize];
	
	[image lockFocus];
	[[NSGraphicsContext currentContext] setShouldAntialias:antialias];
    
    
    if ([boxColor alphaComponent]) { // this should be == 0.0f but need to make sure
		[boxColor set];
		NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(NSMakeRect (0.0f, 0.0f, frameSize.width, frameSize.height) , 0.5, 0.5)
														cornerRadius:cRadius];
		[path fill];
	}
    
	if ([borderColor alphaComponent]) {
		[borderColor set];
		NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(NSMakeRect (0.0f, 0.0f, frameSize.width, frameSize.height), 0.5, 0.5)
														cornerRadius:cRadius];
		[path setLineWidth:1.0f];
		[path stroke];
	}
    
	[textColor set];
    
    
    //    // Flip the text here?
    //    // Need to flip the image
    //    //http://stackoverflow.com/questions/10936590/flip-nsimage-on-both-axes
    //    NSAffineTransform *t = [NSAffineTransform transform];
    //    [t translateXBy:0 yBy:frameSize.height];
    //    [t scaleXBy:1 yBy:-1];
    //    [t concat];
    
	[string drawAtPoint:CGPointMake(marginSize.width, marginSize.height)]; // draw at offset position
    
    
	NSBitmapImageRep * bitmap;
	bitmap = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect (0.0f, 0.0f, frameSize.width, frameSize.height)];
	[image unlockFocus];
    
    
	texSize.width = [bitmap pixelsWide];
	texSize.height = [bitmap pixelsHigh];
	
	if (cgl_ctx = CGLGetCurrentContext ()) { // if we successfully retrieve a current context (required)
		glPushAttrib(GL_TEXTURE_BIT);
		if (0 == texName) glGenTextures (1, &texName);
		glBindTexture (GL_TEXTURE_2D, texName);
		if (NSEqualSizes(previousSize, texSize)) {
			glTexSubImage2D(GL_TEXTURE_2D,0,0,0,texSize.width,texSize.height,[bitmap hasAlpha] ? GL_RGBA : GL_RGB,GL_UNSIGNED_BYTE,[bitmap bitmapData]);
		} else {
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texSize.width, texSize.height, 0, [bitmap hasAlpha] ? GL_RGBA : GL_RGB, GL_UNSIGNED_BYTE, [bitmap bitmapData]);
		}
		glPopAttrib();
	} else
		NSLog (@"StringTexture -genTexture: Failure to get current OpenGL context\n");
    
#else
    //http://liam.flookes.com/wp/2011/09/27/rendering-text-on-iphone-with-opengl/
    
    const int bitsPerElement = 8;
    int sizeInBytes = frameSize.height*frameSize.width*4;
    int texturePitch = frameSize.width*4;
    uint8_t *data = new uint8_t[sizeInBytes];
    memset(data, 0x00, sizeInBytes);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(data, frameSize.width, frameSize.height, bitsPerElement, texturePitch, colorSpace, kCGImageAlphaPremultipliedLast);
    
//    CGContextSetTextDrawingMode(context, kCGTextFillStroke);
//    
//    const CGFloat components[4] = { 1.0f, 0.0f, 0.0f, 1.0f };
//    CGColorRef color = CGColorCreate(colorSpace, components);
//    
//    CGContextSetStrokeColorWithColor(context, color);
//    CGContextSetFillColorWithColor(context, color);
//    CGColorRelease(color);
//    CGContextTranslateCTM(context, 0.0f, frameSize.height);
//    CGContextScaleCTM(context, 1.0f, -1.0f);
    
    UIGraphicsPushContext(context);

	[string drawAtPoint:CGPointMake(marginSize.width, marginSize.height)]; // draw at offset position
    
//    [string drawInRect:CGRectMake(0, 0, frameSize.width, frameSize.height) withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *result = [UIImage imageWithCGImage:imageRef];
    CFDataRef rawData = CGDataProviderCopyData(CGImageGetDataProvider(imageRef));
    
    UIGraphicsPopContext();
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    texSize.width = [result size].width;
	texSize.height = [result size].height;

    [EAGLContext setCurrentContext:_gl_context];
    
    glEnable (GL_TEXTURE_2D);
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texSize.width, texSize.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, rawData);
    

    delete [] data;

    //---------------------
#endif
	requiresUpdate = NO;
}


#pragma mark -
#pragma mark Accessors

- (GLuint) texName
{
	return texName;
}

- (NSSize) texSize
{
	return texSize;
}

#pragma mark Text Color

- (void) setTextColor:(NSColor *)color // set default text color
{
    //	[color retain];
    //	[textColor release];
	textColor = color;
	requiresUpdate = YES;
}

- (NSColor *) textColor
{
	return textColor;
}

#pragma mark Box Color

- (void) setBoxColor:(NSColor *)color // set default text color
{
    //	[color retain];
    //	[boxColor release];
	boxColor = color;
	requiresUpdate = YES;
}

- (NSColor *) boxColor
{
	return boxColor;
}

#pragma mark Border Color

- (void) setBorderColor:(NSColor *)color // set default text color
{
    //	[color retain];
    //	[borderColor release];
	borderColor = color;
	requiresUpdate = YES;
}

- (NSColor *) borderColor
{
	return borderColor;
}

#pragma mark Margin Size

// these will force the texture to be regenerated at the next draw
- (void) setMargins:(NSSize)size // set offset size and size to fit with offset
{
	marginSize = size;
	if (NO == staticFrame) { // ensure dynamic frame sizes will be recalculated
		frameSize.width = 0.0f;
		frameSize.height = 0.0f;
	}
	requiresUpdate = YES;
}

- (NSSize) marginSize
{
	return marginSize;
}

#pragma mark Antialiasing
- (BOOL) antialias
{
	return antialias;
}

- (void) setAntialias:(bool)request
{
	antialias = request;
	requiresUpdate = YES;
}


#pragma mark Frame

- (NSSize) frameSize
{
	if ((NO == staticFrame) && (0.0f == frameSize.width) && (0.0f == frameSize.height)) { // find frame size if we have not already found it
		frameSize = [string size]; // current string size
        
        // round to the nearest power of 2
        frameSize.width = 2*round(frameSize.width/2);
        frameSize.height= 2*round(frameSize.height/2);
        
		frameSize.width += marginSize.width * 2.0f; // add padding
		frameSize.height += marginSize.height * 2.0f;
	}
	return frameSize;
}

- (BOOL) staticFrame
{
	return staticFrame;
}

- (void) useStaticFrame:(NSSize)size // set static frame size and size to frame
{
	frameSize = size;
	staticFrame = YES;
	requiresUpdate = YES;
}

- (void) useDynamicFrame
{
	if (staticFrame) { // set to dynamic frame and set to regen texture
		staticFrame = NO;
		frameSize.width = 0.0f; // ensure frame sizes will be recalculated
		frameSize.height = 0.0f;
		requiresUpdate = YES;
	}
}

#pragma mark String

- (void) setString:(NSAttributedString *)attributedString // set string after initial creation
{
    //	[attributedString retain];
    //	[string release];
	string = attributedString;
	if (NO == staticFrame) { // ensure dynamic frame sizes will be recalculated
		frameSize.width = 0.0f;
		frameSize.height = 0.0f;
	}
	requiresUpdate = YES;
}

- (void) setString:(NSString *)aString withAttributes:(NSDictionary *)attribs; // set string after initial creation
{
	[self setString:[[NSAttributedString alloc] initWithString:aString attributes:attribs]];
}


#pragma mark -
#pragma mark Drawing

- (void) drawWithBounds:(NSRect)bounds
{
	if (requiresUpdate)
		[self genTexture];
	if (texName) {
        
#ifndef __IPHONE__
		glPushAttrib(GL_ENABLE_BIT | GL_TEXTURE_BIT | GL_COLOR_BUFFER_BIT); // GL_COLOR_BUFFER_BIT for glBlendFunc, GL_ENABLE_BIT for glEnable / glDisable

#endif
		glDisable (GL_DEPTH_TEST); // ensure text is not remove by depth buffer test.
        glEnable (GL_BLEND); // for text fading
		glBlendFunc (GL_ONE, GL_ONE_MINUS_SRC_ALPHA); // ditto
//        glBlendFunc(GL_ONE, GL_SRC_COLOR);

		glEnable (GL_TEXTURE_2D);		
		glBindTexture (GL_TEXTURE_2D, texName);
        Vertex2D texCoords[] = {
            {0.0f, 0.0f},
            {0.0f, 1.0f},
            {1.0f, 0.0f},
            {1.0f, 1.0f}
            
        };
            
        Vertex2D vertices[] = {
            {static_cast<float> (bounds.origin.x), static_cast<float> (bounds.origin.y)},
            {static_cast<float> (bounds.origin.x), static_cast<float>(bounds.origin.y + bounds.size.height)},
            {static_cast<float>(bounds.origin.x + bounds.size.width),
                static_cast<float>(bounds.origin.y)},
            {static_cast<float>(bounds.origin.x + bounds.size.width),
                static_cast<float>(bounds.origin.y + bounds.size.height)}
            
        };
        
//        EAGLContext *curContext = [EAGLContext currentContext];
        
        glEnableClientState(GL_VERTEX_ARRAY);
//        glEnableClientState(GL_NORMAL_ARRAY);
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        
        
        glVertexPointer(2, GL_FLOAT, 0, vertices);
        glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        
        glDisableClientState(GL_VERTEX_ARRAY);
//        glDisableClientState(GL_NORMAL_ARRAY);
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);

#ifndef __IPHONE__
		glPopAttrib();
#endif
	}
}

- (void) drawAtPoint:(NSPoint)point
{
	if (requiresUpdate)
		[self genTexture]; // ensure size is calculated for bounds
	if (texName){ // if successful
#ifndef __IPHONE__
		[self drawWithBounds:NSMakeRect (point.x, point.y, texSize.width, texSize.height)];
#else
		[self drawWithBounds:CGRectMake(point.x, point.y, texSize.width, texSize.height)];
#endif
    }
}

@end
