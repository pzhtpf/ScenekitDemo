/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Shows how to set a scene to a renderer.
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideRenderAScene : AAPLSlide
@end

@implementation AAPLSlideRenderAScene

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    self.textManager.title = @"Displaying the Scene";
    
    [self.textManager addBullet:@"Assign the scene to the renderer" atLevel:0];
    [self.textManager addBullet:@"Modifications of the scene graph are automatically reflected" atLevel:0];
    
    [self.textManager addCode:
     @"// Assign the scene \n"
     @"aSCNView.#scene# = aScene;"];
}

@end
