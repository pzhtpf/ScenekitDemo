/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Explains what a material is.
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlideSceneGraph.h"
#import "Utils.h"

@interface AAPLSlideMaterials: AAPLSlide
@end

@implementation AAPLSlideMaterials {
    SCNNode *_sceneKitDiagramNode;
}

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Add some text
    self.textManager.title = @"Materials";
   
    [self.textManager addBullet:@"Determines the appearance of the geometry" atLevel:0];
    [self.textManager addBullet:@"SCNMaterial" atLevel:0];
    [self.textManager addBullet:@"Material properties" atLevel:0];
    [self.textManager addBullet:@"SCNMaterialProperty" atLevel:1];
    [self.textManager addBullet:@"Contents is a color or an image" atLevel:1];
    
    // Prepare the diagram but hide it for now
    _sceneKitDiagramNode = [AAPLSlideSceneGraph sharedScenegraphDiagramNode];
    [AAPLSlideSceneGraph scenegraphDiagramGoToStep:0];
    
    _sceneKitDiagramNode.position = SCNVector3Make(3.0, 8.0, 0);
    _sceneKitDiagramNode.opacity = 0.0;
    
    [self.contentNode addChildNode:_sceneKitDiagramNode];
}

- (void)didOrderInWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Reveal and animate
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1.0];
    {
        [AAPLSlideSceneGraph scenegraphDiagramGoToStep:5];
        _sceneKitDiagramNode.opacity = 1.0;
    }
    [SCNTransaction commit];
}

@end
