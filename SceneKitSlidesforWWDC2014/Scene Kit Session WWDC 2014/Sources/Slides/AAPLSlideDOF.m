/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  Explains what the depth of field effect is and shows an example.
  
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideDOF : AAPLSlide
{
    SCNNode *_pivot;
    SCNNode *_camera;
}
@end

@implementation AAPLSlideDOF

- (NSUInteger)numberOfSteps {
    return 4;
}

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Set the slide's title and subtitle
    self.textManager.title = @"Depth of Field";
    self.textManager.subtitle = @"SCNCamera";

    // Create a node that will contain the chess board
    SCNNode *intermediateNode = [SCNNode node];
    intermediateNode.scale = SCNVector3Make(35.0, 35.0, 35.0);
    intermediateNode.position = SCNVector3Make(0, 0, 2.1);
    [self.contentNode addChildNode:intermediateNode];
    
    _pivot = [SCNNode node];
    [intermediateNode addChildNode:_pivot];
    
    // Load the chess model and add to "intermediateNode"
    [intermediateNode asc_addChildNodeNamed:@"Line01" fromSceneNamed:@"Scenes.scnassets/chess/chess" withScale:1];
}

- (void)presentStepIndex:(NSUInteger)index withPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1.5];
    
    SCNNode *cameraNode = presentationViewController.cameraNode;
    
    switch (index) {
        case 0:
            break;
        case 1:
            // Add a code snippet
            [self.textManager addCode:
             @"aCamera.#focalDistance# = 16.0; \n"
             @"aCamera.#focalBlurRadius# = 8.0;"];
            break;
        case 2:
        {
            // Turn on DOF to illustrate the code snippet
            cameraNode.camera.focalDistance = 16;
            cameraNode.camera.focalSize = 1.5;
            cameraNode.camera.aperture = 0.3;
            cameraNode.camera.focalBlurRadius = 8;
        }
            break;
        case 3:
            // Focus far away
            cameraNode.camera.focalDistance = 35;
            cameraNode.camera.focalSize = 4;
            cameraNode.camera.aperture = 0.1;
                
            // and update the code snippet
            [self.textManager fadeOutTextOfType:AAPLTextTypeCode];
            [self.textManager addCode:
             @"aCamera.#focalDistance# = #35.0#; \n"
             @"aCamera.#focalBlurRadius# = 8.0;"];
            break;
    }
    
    [SCNTransaction commit];
}

- (void)willOrderOutWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Restore camera settings before leaving this slide
    presentationViewController.presentationView.pointOfView = presentationViewController.cameraNode;
    presentationViewController.presentationView.pointOfView.camera.focalBlurRadius = 0;
}

@end
