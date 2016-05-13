/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Explains how you can animate objects.
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideManipulation4 : AAPLSlide
@end

@implementation AAPLSlideManipulation4

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    self.textManager.title = @"Scene Manipulation";
    self.textManager.subtitle = @"Animations";
    
    [self.textManager addBullet:@"Properties are animatable" atLevel:0];
    [self.textManager addBullet:@"Implicit and explicit animations" atLevel:0];
    [self.textManager addBullet:@"Same programming model as Core Animation" atLevel:0];
}

@end
