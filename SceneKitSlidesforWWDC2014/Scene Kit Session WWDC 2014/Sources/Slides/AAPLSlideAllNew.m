/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  This slide displays a word cloud introducing the new features added to Scene Kit.
  
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideAllNew : AAPLSlide
@end

@implementation AAPLSlideAllNew {
    NSArray *_materials;
    NSFont  *_font;
}

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Create the font and the materials that will be shared among the features in the word cloud
    _font = [NSFont fontWithName:@"Myriad Set BoldItalic" size:50] ?: [NSFont fontWithName:@"Avenir Heavy Oblique" size:50];
    
    SCNMaterial *frontAndBackMaterial = [SCNMaterial material];
    SCNMaterial *sideMaterial = [SCNMaterial material];
    sideMaterial.diffuse.contents = [NSColor darkGrayColor];
    
    _materials = @[frontAndBackMaterial, sideMaterial, frontAndBackMaterial];
    
    // Add different features to the word cloud
    [self placeFeature:@"Techniques" atPoint:NSMakePoint(10,-8) timeOffset:0];
    [self placeFeature:@"SpriteKit materials" atPoint:NSMakePoint(-16,-7) timeOffset:0.05];
    [self placeFeature:@"Inverse kinematics" atPoint:NSMakePoint(-12,-6) timeOffset:0.1];
    [self placeFeature:@"Actions" atPoint:NSMakePoint(-10,6) timeOffset:0.15];
    [self placeFeature:@"SKTexture" atPoint:NSMakePoint(4,9) timeOffset:0.2];
    [self placeFeature:@"JavaScript" atPoint:NSMakePoint(-4,8) timeOffset:0.25];
    [self placeFeature:@"Alembic" atPoint:NSMakePoint(-3,-8) timeOffset:0.3];
    [self placeFeature:@"OpenSubdiv" atPoint:NSMakePoint(-1,6) timeOffset:0.35];
    [self placeFeature:@"Assets catalog" atPoint:NSMakePoint(1,5) timeOffset:0.85];
    [self placeFeature:@"SIMD bridge" atPoint:NSMakePoint(3,-6) timeOffset:0.45];
    [self placeFeature:@"Physics" atPoint:NSMakePoint(-0.5,0) timeOffset:0.47];
    [self placeFeature:@"Vehicle" atPoint:NSMakePoint(5,3) timeOffset:0.50];
    [self placeFeature:@"Fog" atPoint:NSMakePoint(7,2) timeOffset:0.95];
    [self placeFeature:@"SpriteKit overlays" atPoint:NSMakePoint(-10,1) timeOffset:0.60];
    [self placeFeature:@"Particles" atPoint:NSMakePoint(-13,-1) timeOffset:0.65];
    [self placeFeature:@"Forward shadows" atPoint:NSMakePoint(8,-1) timeOffset:0.7];
    [self placeFeature:@"Snapshot" atPoint:NSMakePoint(6,-2) timeOffset:0.75];
    [self placeFeature:@"Physics fields" atPoint:NSMakePoint(-6,-3) timeOffset:0.8];
    [self placeFeature:@"Archiving" atPoint:NSMakePoint(-11,3) timeOffset:0.9];
    [self placeFeature:@"Performance tools" atPoint:NSMakePoint(-2,-5) timeOffset:1];
}

- (void)placeFeature:(NSString *)string atPoint:(NSPoint)p timeOffset:(CGFloat)offset {
    // Create and configure a node with a text geometry, and add it to the scene
    SCNText *text = [SCNText textWithString:string extrusionDepth:5];
    text.font = _font;
    text.flatness = 0.4;
    text.materials = _materials;
    
    SCNNode *textNode = [SCNNode node];
    textNode.geometry = text;
    textNode.position = SCNVector3Make(p.x, p.y + self.altitude, 0);
    textNode.scale = SCNVector3Make(0.02, 0.02, 0.02);
    
    [self.contentNode addChildNode:textNode];
    
    // Animation the node's position and opacity
    CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position.z"];
    positionAnimation.fromValue = @(-10);
    positionAnimation.toValue = @14;
    positionAnimation.duration = 7.0;
    positionAnimation.timeOffset = -offset * positionAnimation.duration;
    positionAnimation.repeatCount = FLT_MAX;
    [textNode addAnimation:positionAnimation forKey:nil];
    
    CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.keyTimes = @[@0.0, @0.2, @0.9, @1.0];
    opacityAnimation.values = @[@0.0, @1.0, @1.0, @0.0];
    opacityAnimation.duration = positionAnimation.duration;
    opacityAnimation.timeOffset = positionAnimation.timeOffset;
    opacityAnimation.repeatCount = FLT_MAX;
    [textNode addAnimation:opacityAnimation forKey:nil];
}

@end
