/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Explains how to use SCNView within Interface Builder.
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideInterfaceBuilder : AAPLSlide
@end

@implementation AAPLSlideInterfaceBuilder

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Add some text
    self.textManager.title = @"Displaying the Scene";
    self.textManager.subtitle = @"Game template";
   
    [self.textManager addBullet:@"Start with the Xcode game template" atLevel:0];
    [self.textManager addBullet:@"Or drag an SCNView from the library" atLevel:0];
    
    // And an image
    SCNNode *imageNode = [SCNNode asc_planeNodeWithImageNamed:@"Interface Builder" size:8.3 isLit:NO];
    imageNode.position = SCNVector3Make(-4.0, 3.2, 11.0);
    [self.contentNode addChildNode:imageNode];
    
    imageNode = [SCNNode asc_planeNodeWithImageNamed:@"game_big" size:7 isLit:NO];
    imageNode.position = SCNVector3Make(5.0, 3.5, 11.0);
    imageNode.geometry.firstMaterial.diffuse.magnificationFilter = SCNFilterModeNearest;
    [self.contentNode addChildNode:imageNode];
}

@end
