/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  The AAPLSlide class represents a slide. A slide owns a node tree, some properties and a text manager.
  
 */

#import "AAPLSlide.h"
#import "AAPLSlideTextManager.h"

@implementation AAPLSlide

- (id)init {
    if ((self = [super init])) {
        // Node hierarchy :
        // _contentNode
        // |__ _groundNode           : holds the rest of the scene
        // |__ _textManager.textNode : holds the text
        
        _contentNode = [SCNNode node];
        
        _groundNode = [SCNNode node];
        [_contentNode addChildNode:_groundNode];
        
        _textManager = [[AAPLSlideTextManager alloc] init];
        [_contentNode addChildNode:_textManager.textNode];
        
        // Default parameters
        _lightIntensities = @[@0.0, @0.9, @0.7];
        _mainLightPosition = SCNVector3Make(0, 3, -13);
        _floorImageName = nil;
        _floorReflectivity = 0.25;
        _floorFalloff = 3.0;
        _transitionDuration = 1.0;
        _transitionOffsetX = 0.0;
        _transitionOffsetZ = 0.0;
        _transitionRotation = 0.0;
        _altitude = 5.0;
        _pitch = 0.0;
        _isNewIn10_10 = NO;
    }
    return self;
}

#pragma mark - Navigating within the slide

- (NSUInteger)numberOfSteps {
    return 0;
}

- (void)presentStepIndex:(NSUInteger)index withPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
}

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
}

- (void)willOrderOutWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
}

- (void)didOrderInWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
}


@end
