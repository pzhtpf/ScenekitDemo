/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Explains how implicit animations work and shows an example.
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideImplicitAnimations : AAPLSlide
@end

@implementation AAPLSlideImplicitAnimations {
    SCNNode *_animatedNode;
}

- (NSUInteger)numberOfSteps {
    return 4;
}

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Set the slide's title and subtitle and add some text
    self.textManager.title = @"Animations";
    self.textManager.subtitle = @"Implicit animations";
    
    [self.textManager addCode:
     @"// Begin a transaction \n"
     @"[#SCNTransaction# begin]; \n"
     @"[#SCNTransaction# setAnimationDuration:2.0]; \n\n"
     @"// Change properties \n"
     @"aNode.#opacity# = 1.0; \n"
     @"aNode.#rotation# = SCNVector4(0, 1, 0, M_PI*4); \n\n"
     @"// Commit the transaction \n"
     @"[SCNTransaction #commit#];"];
    
    // A simple torus that we will animate to illustrate the code
    _animatedNode = [SCNNode node];
    _animatedNode.position = SCNVector3Make(10, 7, 0);
    
    // Use an extra node that we can tilt it and cumulate that with the animation
    SCNNode *torusNode = [SCNNode node];
    torusNode.geometry = [SCNTorus torusWithRingRadius:4.0 pipeRadius:1.5];
    torusNode.rotation = SCNVector4Make(1, 0, 0, -M_PI * 0.7);
    torusNode.geometry.firstMaterial.diffuse.contents = [NSColor redColor];
    torusNode.geometry.firstMaterial.specular.contents = [NSColor whiteColor];
    torusNode.geometry.firstMaterial.reflective.contents = [NSImage imageNamed:@"envmap"];
    torusNode.geometry.firstMaterial.fresnelExponent = 0.7;
    
    [_animatedNode addChildNode:torusNode];
    [self.contentNode addChildNode:_animatedNode];
}

- (void)presentStepIndex:(NSUInteger)index withPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Animate by default
    [SCNTransaction begin];
    
    switch (index) {
        case 0:
            // Disable animations for first step
            [SCNTransaction setAnimationDuration:0];
            
            // Initially dim the torus
            _animatedNode.opacity = 0.25;
            
            [self.textManager highlightCodeChunks:nil];
            break;
        case 1:
            [self.textManager highlightCodeChunks:@[@0, @1]];
            break;
        case 2:
            [self.textManager highlightCodeChunks:@[@2, @3]];
            break;
        case 3:
            [self.textManager highlightCodeChunks:@[@4]];
            
            // Animate implicitly
            [SCNTransaction setAnimationDuration:2.0];
            _animatedNode.opacity = 1.0;
            _animatedNode.rotation = SCNVector4Make(0, 1, 0, M_PI * 4);
            break;
    }
    
    [SCNTransaction commit];
}

@end
