/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  Explains how explicit animations work and shows an example.
  
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideExplicitAnimations : AAPLSlide
@end

@implementation AAPLSlideExplicitAnimations {
    SCNNode *_animatedNode;
}

- (NSUInteger)numberOfSteps {
    return 5;
}

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Set the slide's title and subtitle and add some code
    self.textManager.title = @"Animations";
    self.textManager.subtitle = @"Explicit animations";
    
    [self.textManager addCode:
     @"// Create an animation \n"
     @"animation = [#CABasicAnimation# animationWithKeyPath:@\"rotation\"]; \n\n"
     @"// Configure the animation \n"
     @"animation.#duration# = 2.0; \n"
     @"animation.#toValue# = [NSValue valueWithSCNVector4:SCNVector4Make(0,1,0,M_PI*2)]; \n"
     @"animation.#repeatCount# = MAXFLOAT; \n\n"
     @"// Play the animation \n"
     @"[aNode #addAnimation:#animation #forKey:#@\"myAnimation\"];"];
    
    // A simple torus that we will animate to illustrate the code
    _animatedNode = [SCNNode node];
    _animatedNode.position = SCNVector3Make(9, 5.7, 20);
    
    // Use an extra node that we can tilt it and cumulate that with the animation
    SCNNode *torusNode = [SCNNode node];
    torusNode.geometry = [SCNTorus torusWithRingRadius:4.0 pipeRadius:1.5];
    torusNode.rotation = SCNVector4Make(1, 0, 0, -M_PI * 0.5);
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
            
            // Initially hide the torus
            _animatedNode.opacity = 0.0;
            
            [self.textManager highlightCodeChunks:nil];
            break;
        case 1:
            [self.textManager highlightCodeChunks:@[@0]];
            break;
        case 2:
            [self.textManager highlightCodeChunks:@[@1, @2, @3]];
            break;
        case 3:
            [self.textManager highlightCodeChunks:@[@4, @5]];
            break;
        case 4:
        {
            [SCNTransaction setAnimationDuration:0];
            
            // Show the torus
            _animatedNode.opacity = 1.0;
            
            // Animate explicitly
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
            animation.duration = 2.0;
            animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
            animation.repeatCount = FLT_MAX;
            [_animatedNode addAnimation:animation forKey:@"myAnimation"];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            {
                // Dim the text
                self.textManager.textNode.opacity = 0.75;
                
                presentationViewController.cameraHandle.position = [presentationViewController.cameraHandle convertPosition:SCNVector3Make(9, 8, 20) toNode:presentationViewController.cameraHandle.parentNode];
                presentationViewController.cameraPitch.rotation = SCNVector4Make(1, 0, 0, -M_PI / 10);
            }
            [SCNTransaction commit];
            break;
        }
    }
    
    [SCNTransaction commit];
}

@end
