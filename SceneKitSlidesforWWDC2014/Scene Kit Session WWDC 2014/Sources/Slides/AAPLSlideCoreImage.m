/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  Shows an example of how Core Image filters can be used to achieve screen-space effects.
  
 */

#import <GLKit/GLKMath.h>

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

#pragma mark - Core Image slide

@interface AAPLSlideCoreImage : AAPLSlide
@end

@implementation AAPLSlideCoreImage {
    CGSize _viewportSize;
}

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Setup the image grid here to benefit from the preloading mechanism
    _viewportSize = [presentationViewController.presentationView convertSizeToBacking:presentationViewController.presentationView.frame.size];
}

- (NSUInteger)numberOfSteps {
    return 1;
}

- (void)didOrderInWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    SCNNode *banana = [self.contentNode asc_addChildNodeNamed:@"banana" fromSceneNamed:@"Scenes.scnassets/banana/banana" withScale:5];
    
    [banana runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:M_PI*2 z:0 duration:1.5]]];
    banana.position = SCNVector3Make(2.5, 5, 10);
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setDefaults];
    [filter setValue:@10 forKey:kCIInputRadiusKey];
    banana.filters = @[filter];
    
    banana = [banana copy];
    [self.contentNode addChildNode:banana];
    banana.position = SCNVector3Make(6, 5, 10);
    filter = [CIFilter filterWithName:@"CIPixellate"];
    [filter setDefaults];
    banana.filters = @[filter];
    
    
    banana = [banana copy];
    [self.contentNode addChildNode:banana];
    banana.position = SCNVector3Make(9.5, 5, 10);
    filter = [CIFilter filterWithName:@"CIEdgeWork"];
    [filter setDefaults];
    banana.filters = @[filter];
}

- (void)presentStepIndex:(NSUInteger)index withPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    switch (index) {
        case 0:
            // Set the slide's title and subtitle and add some text
            self.textManager.title = @"Core Image";
            self.textManager.subtitle = @"CI Filters";
            
            [self.textManager addBullet:@"Screen-space effects" atLevel:0];
            [self.textManager addBullet:@"Applies to a node hierarchy" atLevel:0];
            [self.textManager addBullet:@"Filter parameters are animatable" atLevel:0];
            [self.textManager addCode:@"aNode.#filters# = @[filter1, filter2];"];
            break;
    }
}

@end

