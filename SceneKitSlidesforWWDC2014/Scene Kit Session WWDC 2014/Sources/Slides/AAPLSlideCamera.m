/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  Camera slide. Illustrates the camera node attribute.
  
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideCamera : AAPLSlide
@end

@implementation AAPLSlideCamera

- (NSUInteger)numberOfSteps {
    return 4;
}

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Create a node to own the "sign" model, make it to be close to the camera, rotate by 90 degree because it's oriented with z as the up axis
    SCNNode *intermediateNode = [SCNNode node];
    intermediateNode.position = SCNVector3Make(0, 0, 7);
    [self.groundNode addChildNode:intermediateNode];
    
    // Load the "sign" model
    SCNNode *signNode = [intermediateNode asc_addChildNodeNamed:@"sign" fromSceneNamed:@"Scenes.scnassets/intersection/intersection" withScale:10];
    signNode.position = SCNVector3Make(4, 0, 0.05);
    
    // Re-parent every node that holds a camera otherwise they would inherit the scale from the "sign" model.
    // This is not a problem except that the scale affects the zRange of cameras and so it would be harder to get the transition from one camera to another right
    NSArray *cameraNodes = [signNode childNodesPassingTest:^BOOL(SCNNode *child, BOOL *stop) {
        return (child.camera != nil);
    }];
    
    for (SCNNode *cameraNode in cameraNodes) {
        CATransform3D previousWorldTransform = cameraNode.worldTransform;
        [intermediateNode addChildNode:cameraNode]; // re-parent
        cameraNode.transform = [intermediateNode convertTransform:previousWorldTransform fromNode:nil];
        cameraNode.scale = SCNVector3Make(1, 1, 1);
    }
    
    // Set the slide's title and subtitle and add some text
    self.textManager.title = @"Node Attributes";
    self.textManager.subtitle = @"SCNCamera";
    [self.textManager addBullet:@"Point of view for renderers" atLevel:0];
    
    [self.textManager addCode:
     @"aNode.#camera# = [#SCNCamera# camera]; \n"
     @"aView.#pointOfView# = aNode;"];
}

- (void)presentStepIndex:(NSUInteger)index withPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    [SCNTransaction begin];
    switch (index) {
        case 0:
        {
            break;
        }
        case 1:
            // Switch to camera1
            [SCNTransaction setAnimationDuration:2.0];
            presentationViewController.presentationView.pointOfView = [self.contentNode childNodeWithName:@"camera1" recursively:YES];
            break;
        case 2:
            // Switch to camera2
            [SCNTransaction setAnimationDuration:2.0];
            presentationViewController.presentationView.pointOfView = [self.contentNode childNodeWithName:@"camera2" recursively:YES];
            break;
        case 3:
        {
            // Switch back to the default camera
            [SCNTransaction setAnimationDuration:1.0];
            presentationViewController.presentationView.pointOfView = presentationViewController.cameraNode;
            break;
        }
    }
    
    [SCNTransaction commit];
}

- (void)willOrderOutWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    [SCNTransaction begin];
    {
        // Restore the default point of view before leaving this slide
        presentationViewController.presentationView.pointOfView = presentationViewController.cameraNode;
    }
    [SCNTransaction commit];
}

@end
