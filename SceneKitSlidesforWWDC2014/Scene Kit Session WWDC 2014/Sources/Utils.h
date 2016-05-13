/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  This file contains some utilities such as titled box, loading DAE files, loading images etc...
  
 */

#import <SceneKit/SceneKit.h>

typedef NS_ENUM(NSInteger, AAPLLabelSize) {
    AAPLLabelSizeSmall = 1,
    AAPLLabelSizeNormal = 2,
    AAPLLabelSizeLarge = 4
};

@interface SCNNode (AAPLAdditions)

// create a node tree from an image
+ (SCNNode *) nodeWithPixelatedImage:(NSImage *) image pixelSize:(CGFloat) size;

// Add the node named 'name' found in the DAE document located at 'path' as a child of the receiver
- (instancetype)asc_addChildNodeNamed:(NSString *)name fromSceneNamed:(NSString *)path withScale:(CGFloat)scale;

// Setup a 3D box with a title
+ (instancetype)asc_boxNodeWithTitle:(NSString *)title frame:(NSRect)frame color:(NSColor *)color cornerRadius:(CGFloat)cornerRadius centered:(BOOL)centered;

// Create a 3D plan with the specified image mapped on it
+ (instancetype)asc_planeNodeWithImage:(NSImage *)image size:(CGFloat)size isLit:(BOOL)isLit;
+ (instancetype)asc_planeNodeWithImageNamed:(NSString *)imageName size:(CGFloat)size isLit:(BOOL)isLit;

// Create a 3D text node
+ (instancetype)asc_labelNodeWithString:(NSString *)text size:(AAPLLabelSize)size isLit:(BOOL)isLit;

// Create a 3D gauge
+ (instancetype)asc_gaugeNodeWithTitle:(NSString *)title progressNode:(SCNNode * __strong *)progressNode;

@end

@interface NSBezierPath (AAPLAdditions)

// Create an arrow
+ (instancetype)asc_arrowBezierPathWithBaseSize:(NSSize)baseSize tipSize:(NSSize)tipSize hollow:(CGFloat)hollow twoSides:(BOOL)twoSides;

@end

@interface NSImage (AAPLAdditions)

// Load an image that represents the application named
+ (instancetype)asc_imageForApplicationNamed:(NSString *)name;

// Create and return an image with the closest resolution to "size"
- (instancetype)asc_copyWithResolution:(CGFloat)size;

@end


@interface SCNAction (AAPLAddition)

+ (SCNAction *) removeFromParentNodeOnMainThread:(SCNNode *) node;

@end
