/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  Creating a Scene slide, part 1.
  
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideCreateAScene : AAPLSlide
@end

@implementation AAPLSlideCreateAScene

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    self.textManager.title = @"Creating a Scene";
  
    [self.textManager addBullet:@"Creating programmatically" atLevel:0];
    [self.textManager addBullet:@"Loading a scene from a file" atLevel:0];
}

@end
