/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  Presents the Xcode SceneKit editor.
  
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideEditor : AAPLSlide
@end

@implementation AAPLSlideEditor

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Set the slide's title and add some text
    self.textManager.title = @"SceneKit Editor";
    [self.textManager addBullet:@"Built into Xcode" atLevel:0];
    [self.textManager addBullet:@"Scene graph inspection" atLevel:0];
    [self.textManager addBullet:@"Rendering preview" atLevel:0];
    [self.textManager addBullet:@"Adjust lighting and materials" atLevel:0];
}

- (void)didOrderInWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Bring up a screenshot of the editor
    SCNNode *editorScreenshotNode = [SCNNode asc_planeNodeWithImageNamed:@"editor.png" size:14 isLit:YES];
    editorScreenshotNode.position = SCNVector3Make(17, 4.1, 5);
    editorScreenshotNode.rotation = SCNVector4Make(0, 1, 0, -M_PI / 1.5);
    [self.groundNode addChildNode:editorScreenshotNode];
    
    // Animate it (rotate and move)
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1.0];
    {
        editorScreenshotNode.position = SCNVector3Make(7.5, 4.1, 5);
        editorScreenshotNode.rotation = SCNVector4Make(0, 1, 0, -M_PI / 6.0);
    }
    [SCNTransaction commit];
}

@end
