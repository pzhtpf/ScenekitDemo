/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Labs info.
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideLabs : AAPLSlide
@end

@implementation AAPLSlideLabs

- (void)presentStepIndex:(NSUInteger)index withPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Set the slide's title
    self.textManager.title = @"Labs";
    
    SCNNode *relatedImage = [SCNNode asc_planeNodeWithImageNamed:@"labs.png" size:35 isLit:NO];
    relatedImage.position = SCNVector3Make(0, 30, 0);
    relatedImage.castsShadow = NO;
    [self.contentNode addChildNode:relatedImage];
}

@end
