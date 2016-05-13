/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  This file contains some utilities such as titled box, loading DAE files, loading images etc...
  
 */

#import <GLKit/GLKMath.h>
#import "Utils.h"



NSBitmapImageRep *NSBitmapImageRepFromNSImage(NSImage * image){
    NSSize size = [image size];
    
    if(size.width<=0 || size.height<=0)
        return nil;
    
    [image lockFocus];
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0,0,size.width, size.height)];
    [image unlockFocus];
    
    return bitmap;
}


static void _markBuffer(BOOL *mark, NSInteger pos, int count, NSInteger dx)
{
    for(int i=0; i<count; i++, pos+=dx){
        mark[pos] = 1;
    }
}

static BOOL _sameColor(NSInteger pos, int count, BOOL white, NSInteger dx, unsigned char *data)
{
    for(NSInteger i=0, tdx=0; i<count; i++, tdx+=dx){
        if(data[(pos + tdx)*4 + 3] < 128) return NO;
        unsigned char c = data[(pos + tdx)*4];
        if(white && c < 128) return NO;
        if(!white && c > 128) return NO;
    }
    
    return YES;
}

static int _extend(NSInteger x, NSInteger y, NSInteger w, NSInteger h, unsigned char *data, BOOL isWhite, BOOL *mark)
{
    int c=1;
    BOOL shouldContinue = 1;
    
    do{
        if(x+c < w && y+c < h
           && _sameColor(x+c+y*w, c+1, isWhite, w, data)
           && _sameColor(x+(y+c)*w, c, isWhite, 1, data)){
            //mark
            _markBuffer(mark, x+c+y*w, c+1, w);
            _markBuffer(mark, x+(y+c)*w, c, 1);
            //next
            c++;
        }
        else{
            shouldContinue = 0;
        }
        
        
    }while(shouldContinue);
    
    return c;
}

@implementation SCNNode (AAPLAdditions)


+ (SCNNode *) nodeWithPixelatedImage:(NSImage *) image  pixelSize:(CGFloat) size
{
    NSBitmapImageRep *bitmap = NSBitmapImageRepFromNSImage(image);
    
    NSInteger w = [bitmap pixelsWide];
    NSInteger h = [bitmap pixelsHigh];
    unsigned char *data = [bitmap bitmapData];
    
    BOOL *mark = (BOOL*) calloc(1, w*h);
    
    SCNMaterial *white = [SCNMaterial material];
    SCNMaterial *black = [SCNMaterial material];
    black.diffuse.contents = [NSColor orangeColor];
    //black.reflective.contents = @"envmap.jpg";
    
    SCNNode *group = [SCNNode node];
    
    for(NSInteger y=0, index=0; y<h; y++){
        for(NSInteger x=0; x<w; x++, index++){
            if(mark[index]) continue;
            if(data[index*4+3] < 128) continue;
            
            bool isWhite = (data[index*4] > 128);
            
            int count = _extend(x, y, w, h, data, isWhite, mark);
            float blockSize = size * count;
            
            SCNBox *box = [SCNBox boxWithWidth:blockSize height:blockSize length:5*size chamferRadius:blockSize * 0.0];
            box.firstMaterial = isWhite ? white : black;
            
            SCNNode *node = [SCNNode node];
            node.position = SCNVector3Make((x-(w/2))*size + (count-1)*size*0.5, (h-y)*size - (count-1)*size*0.5, 0);
            node.geometry = box;
            
            [group addChildNode:node];
        }
    }
    
    return group;
}

- (SCNNode *)asc_addChildNodeNamed:(NSString *)name fromSceneNamed:(NSString *)path withScale:(CGFloat)scale {
    // Load the scene from the specified file
    SCNScene *scene = [SCNScene sceneNamed:path inDirectory:nil options:nil];
    
    // Retrieve the root node
    SCNNode *node = scene.rootNode;
    
    // Search for the node named "name"
    if (name) {
        node = [node childNodeWithName:name recursively:YES];
    }
    else {
        // Take the first child if no name is passed
        node = node.childNodes[0];
    }
    
    if (scale != 0) {
        // Rescale based on the current bounding box and the desired scale
        // Align the node to 0 on the Y axis
        SCNVector3 min, max;
        [node getBoundingBoxMin:&min max:&max];
        
        GLKVector3 mid = GLKVector3Add(SCNVector3ToGLKVector3(min), SCNVector3ToGLKVector3(max));
        mid = GLKVector3MultiplyScalar(mid, 0.5);
        mid.y = min.y; // Align on bottom
        
        GLKVector3 size = GLKVector3Subtract(SCNVector3ToGLKVector3(max), SCNVector3ToGLKVector3(min));
        CGFloat maxSize = MAX(MAX(size.x, size.y), size.z);
        
        scale = scale / maxSize;
        mid = GLKVector3MultiplyScalar(mid, scale);
        mid = GLKVector3Negate(mid);
        
        node.scale = SCNVector3Make(scale, scale, scale);
        node.position = SCNVector3FromGLKVector3(mid);
    }
    
    // Add to the container passed in argument
    [self addChildNode:node];
    
    return node;
}

+ (instancetype)asc_boxNodeWithTitle:(NSString *)title frame:(NSRect)frame color:(NSColor *)color cornerRadius:(CGFloat)cornerRadius centered:(BOOL)centered {
    static NSDictionary *titleAttributes = nil;
    static NSDictionary *centeredTitleAttributes = nil;
    
    // create and extrude a bezier path to build the box
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:frame xRadius:cornerRadius yRadius:cornerRadius];
    path.flatness = 0.05;
    
    SCNShape *shape = [SCNShape shapeWithPath:path extrusionDepth:20];
    shape.chamferRadius = 0.0;
    
    SCNNode *node = [SCNNode node];
    node.geometry = shape;
    
    // create an image and fill with the color and text
    NSSize textureSize;
    textureSize.width = ceilf(frame.size.width * 1.5);
    textureSize.height = ceilf(frame.size.height * 1.5);
    
    NSImage *texture = [[NSImage alloc] initWithSize:textureSize];
    
    [texture lockFocus];
    
    NSRect drawFrame = NSMakeRect(0, 0, textureSize.width, textureSize.height);
    
    CGFloat hue, saturation, brightness, alpha;
    [[color colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]] getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    NSColor *lightColor = [NSColor colorWithDeviceHue:hue saturation:saturation - 0.2 brightness:brightness + 0.3 alpha:alpha];
    [lightColor set];
    NSRectFill(drawFrame);
    
    NSBezierPath *fillpath = nil;
    
    if (cornerRadius == 0 && centered == NO) {
        //special case for the "labs" slide
        fillpath = [NSBezierPath bezierPathWithRoundedRect:NSOffsetRect(drawFrame, 0, -2) xRadius:cornerRadius yRadius:cornerRadius];
    }
    else {
        fillpath = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(drawFrame, 3, 3) xRadius:cornerRadius yRadius:cornerRadius];
    }
    
    [color set];
    [fillpath fill];
    
    // draw the title if any
    if (title) {
        if (titleAttributes == nil) {
            NSMutableParagraphStyle *paraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [paraphStyle setAlignment:NSLeftTextAlignment];
            [paraphStyle setMinimumLineHeight:38];
            [paraphStyle setMaximumLineHeight:38];
            
            NSFont *font = [NSFont fontWithName:@"Myriad Set" size:34] ?: [NSFont fontWithName:@"Avenir Medium" size:34];
            
            NSShadow *shadow = [[NSShadow alloc] init];
            [shadow setShadowOffset:NSMakeSize(0, -2)];
            [shadow setShadowBlurRadius:4];
            [shadow setShadowColor:[NSColor colorWithDeviceWhite:0.0 alpha:0.5]];
            
            titleAttributes = @{ NSFontAttributeName            : font,
                                 NSForegroundColorAttributeName : [NSColor whiteColor],
                                 NSShadowAttributeName          : shadow,
                                 NSParagraphStyleAttributeName  : paraphStyle };
            
            
            NSMutableParagraphStyle *centeredParaphStyle = [paraphStyle mutableCopy];
            [centeredParaphStyle setAlignment:NSCenterTextAlignment];
            
            centeredTitleAttributes = @{ NSFontAttributeName            : font,
                                         NSForegroundColorAttributeName : [NSColor whiteColor],
                                         NSShadowAttributeName          : shadow,
                                         NSParagraphStyleAttributeName  : centeredParaphStyle };
        }
        
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:title attributes:centered ? centeredTitleAttributes : titleAttributes];
        NSSize textSize = [attrString size];
        
        //check if we need two lines to draw the text
        BOOL twoLines = [title rangeOfString:@"\n"].length > 0;
        if (!twoLines) {
            twoLines = textSize.width > frame.size.width && [title rangeOfString:@" "].length > 0;
        }
        
        //if so, we need to adjust the size to center vertically
        if (twoLines) {
            textSize.height += 38;
        }
        
        if (!centered)
            drawFrame = NSInsetRect(drawFrame, 15, 0);
        
        //center vertically
        float dy = (drawFrame.size.height - textSize.height) * 0.5;
        drawFrame.size.height -= dy;
        [attrString drawInRect:drawFrame];
    }
    
    [texture unlockFocus];
    
    //set the created image as the diffuse texture of our 3D box
    SCNMaterial *front = [SCNMaterial material];
    front.diffuse.contents = texture;
    front.locksAmbientWithDiffuse = YES;
    
    //use a lighter color for the chamfer and sides
    SCNMaterial *sides = [SCNMaterial material];
    sides.diffuse.contents = lightColor;
    node.geometry.materials = @[front, sides, sides, sides, sides];
    
    return node;
}

+ (instancetype)asc_planeNodeWithImage:(NSImage *)image size:(CGFloat)size isLit:(BOOL)isLit {
    SCNNode *node = [SCNNode node];
    
    float factor = size / (MAX(image.size.width, image.size.height));
    
    node.geometry = [SCNPlane planeWithWidth:image.size.width*factor height:image.size.height*factor];
    node.geometry.firstMaterial.diffuse.contents = image;
    
    //if we don't want the image to be lit, set the lighting model to "constant"
    if (!isLit)
        node.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
    
    return node;
}

+ (instancetype)asc_planeNodeWithImageNamed:(NSString *)imageName size:(CGFloat)size isLit:(BOOL)isLit {
    return [self asc_planeNodeWithImage:[NSImage imageNamed:imageName] size:size isLit:isLit];
}

+ (instancetype)asc_labelNodeWithString:(NSString *)string size:(AAPLLabelSize)size isLit:(BOOL)isLit {
    SCNNode *node = [SCNNode node];
    
    SCNText *text = [SCNText textWithString:string extrusionDepth:0];
    node.geometry = text;
    node.scale = SCNVector3Make(0.01 * size, 0.01 * size, 0.01 * size);
    text.flatness = 0.4;
    
    // Use Myriad it's if available, otherwise Avenir
    if(size == AAPLLabelSizeLarge)
        text.font = [NSFont fontWithName:@"Myriad Set Bold" size:50] ?: [NSFont fontWithName:@"Avenir bold" size:50];
    else
        text.font = [NSFont fontWithName:@"Myriad Set" size:50] ?: [NSFont fontWithName:@"Avenir Medium" size:50];
    
    if (!isLit) {
        text.firstMaterial.lightingModelName = SCNLightingModelConstant;
    }
    
    return node;
}

+ (instancetype)asc_gaugeNodeWithTitle:(NSString *)title progressNode:(SCNNode * __strong *)progressNode {
    SCNNode *gaugeGroup = [SCNNode node];
    
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:0];
    {
        SCNNode *gauge = [SCNNode node];
        gauge.geometry = [SCNCapsule capsuleWithCapRadius:0.4 height:8];
        gauge.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
        gauge.rotation = SCNVector4Make(0, 0, 1, M_PI_2);
        gauge.geometry.firstMaterial.diffuse.contents = [NSColor whiteColor];
        gauge.geometry.firstMaterial.cullMode = SCNCullFront;
        
        SCNNode *gaugeValue = [SCNNode node];
        gaugeValue.geometry = [SCNCapsule capsuleWithCapRadius:0.3 height:7.8];
        gaugeValue.pivot = SCNMatrix4MakeTranslation(0, 3.8, 0);
        gaugeValue.position = SCNVector3Make(0, 3.8, 0);
        gaugeValue.scale = SCNVector3Make(1, 0.01, 1);
        gaugeValue.opacity = 0.0;
        gaugeValue.geometry.firstMaterial.diffuse.contents = [NSColor colorWithDeviceRed:0 green:1 blue:0 alpha:1];
        gaugeValue.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
        [gauge addChildNode:gaugeValue];
        
        if (progressNode) {
            *progressNode = gaugeValue;
        }
        
        SCNNode *titleNode = [SCNNode asc_labelNodeWithString:title  size:AAPLLabelSizeNormal isLit:NO];
        titleNode.position = SCNVector3Make(-8, -0.55, 0);
        
        [gaugeGroup addChildNode:titleNode];
        [gaugeGroup addChildNode:gauge];
    }
    [SCNTransaction commit];
    
    return gaugeGroup;
}

@end

@implementation NSBezierPath (AAPLAdditions)

+ (instancetype)asc_arrowBezierPathWithBaseSize:(NSSize)baseSize tipSize:(NSSize)tipSize hollow:(CGFloat)hollow twoSides:(BOOL)twoSides {
    NSBezierPath *arrow = [NSBezierPath bezierPath];
    
    float h[5];
    float w[4];
    
    w[0] = 0;
    w[1] = baseSize.width - tipSize.width - hollow;
    w[2] = baseSize.width - tipSize.width;
    w[3] = baseSize.width;
    
    h[0] = 0;
    h[1] = (tipSize.height - baseSize.height) * 0.5;
    h[2] = (tipSize.height) * 0.5;
    h[3] = (tipSize.height + baseSize.height) * 0.5;
    h[4] = tipSize.height;
    
    if (twoSides) {
        [arrow moveToPoint:NSMakePoint(tipSize.width, h[1])];
        [arrow lineToPoint:NSMakePoint(tipSize.width + hollow, h[0])];
        [arrow lineToPoint:NSMakePoint(0, h[2])];
        [arrow lineToPoint:NSMakePoint(tipSize.width + hollow, h[4])];
        [arrow lineToPoint:NSMakePoint(tipSize.width, h[3])];
    }
    else {
        [arrow moveToPoint:NSMakePoint(0, h[1])];
        [arrow lineToPoint:NSMakePoint(0, h[3])];
    }
    
    [arrow lineToPoint:NSMakePoint(w[2], h[3])];
    [arrow lineToPoint:NSMakePoint(w[1], h[4])];
    [arrow lineToPoint:NSMakePoint(w[3], h[2])];
    [arrow lineToPoint:NSMakePoint(w[1], h[0])];
    [arrow lineToPoint:NSMakePoint(w[2], h[1])];
    
    [arrow closePath];
    
    return arrow;
}



@end

@implementation NSImage (AAPLAdditions)

+ (instancetype)asc_imageForApplicationNamed:(NSString *)name {
    NSImage *image = nil;
    
    NSString *path = [[NSWorkspace sharedWorkspace] fullPathForApplication:name];
    if (path) {
        image = [[NSWorkspace sharedWorkspace] iconForFile:path];
        image = [image asc_copyWithResolution:512];
    }
    
    if (image == nil) {
        image = [NSImage imageNamed:NSImageNameCaution];
    }
    
    return image;
}

- (instancetype)asc_copyWithResolution:(CGFloat)size {
    NSImageRep *imageRep = [self bestRepresentationForRect:NSMakeRect(0, 0, size, size) context:nil hints:nil];
    if (imageRep) {
        return [[NSImage alloc] initWithCGImage:[imageRep CGImageForProposedRect:nil context:nil hints:nil] size:imageRep.size];
    }
    return self;
}

@end



@implementation SCNAction (AAPLAddition)

+ (SCNAction *) removeFromParentNodeOnMainThread:(SCNNode *) node
{
    return [SCNAction runBlock:^(SCNNode *owner){
        [owner removeFromParentNode];
    } queue:dispatch_get_main_queue()];
}

@end

