/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  Last slide.
  
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideEnd : AAPLSlide
@end

@implementation AAPLSlideEnd

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    SCNNode *imageNode = [SCNNode asc_planeNodeWithImageNamed:@"wwdc.png" size:19 isLit:NO];
    imageNode.position = SCNVector3Make(0, 30, 0);
    imageNode.castsShadow = NO;
    [self.contentNode addChildNode:imageNode];
}

@end
