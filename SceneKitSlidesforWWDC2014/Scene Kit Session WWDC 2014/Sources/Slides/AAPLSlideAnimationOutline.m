/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  The different ways to manipulate objects.
  
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideAnimationOutline : AAPLSlide
@end

@implementation AAPLSlideAnimationOutline

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    self.textManager.title = @"Animating a Scene";
    self.textManager.subtitle = @"Outline";
    
    [self.textManager addBullet:@"Per-frame updates" atLevel:0];
    [self.textManager addBullet:@"Animations" atLevel:0];
    [self.textManager addBullet:@"Actions" atLevel:0];
    [self.textManager addBullet:@"Physics" atLevel:0];
    [self.textManager addBullet:@"Constraints" atLevel:0];
    [self.textManager addBullet:@"Morphing" atLevel:0];
    [self.textManager addBullet:@"Skinning" atLevel:0];
}

@end
