/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Shows how to load a scene from a dae file.
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideSampleLoadingDae : AAPLSlide
@end

@implementation AAPLSlideSampleLoadingDae

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    self.textManager.title = @"Loading a DAE";
    self.textManager.subtitle = @"Sample code";

    [self.textManager addCode:
     @"// Load a DAE \n"
     @"SCNScene *scene = [SCNScene #sceneNamed:#@\"dungeon.dae\"];"];
    
    SCNNode *image = [SCNNode asc_planeNodeWithImageNamed:@"daeAsResource" size:9 isLit:NO];
    image.position = SCNVector3Make(0, 3.2, 7);
    [self.groundNode addChildNode:image];
}

@end
