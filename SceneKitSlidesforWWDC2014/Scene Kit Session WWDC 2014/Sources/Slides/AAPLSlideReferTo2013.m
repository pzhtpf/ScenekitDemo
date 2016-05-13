/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Chapter 2 slide : Scene Graph
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideReferTo2013 : AAPLSlide
@end

@implementation AAPLSlideReferTo2013

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    self.textManager.title = @"Related Sessions";
    
    // load the "related.png" image and show it mapped on a plane
    SCNNode *relatedImage = [SCNNode asc_planeNodeWithImageNamed:@"related.png" size:35 isLit:NO];
    relatedImage.position = SCNVector3Make(0, 10, 0);
    relatedImage.castsShadow = NO;
    [self.groundNode addChildNode:relatedImage];
}

@end
