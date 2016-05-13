/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Presents the outline of the presentation.
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"

@interface AAPLSlideOutline : AAPLSlide
@end

@implementation AAPLSlideOutline


- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController
{
    self.textManager.title = @"Outline";
    
    [self.textManager addBullet:@"Scene graph overview" atLevel:0];
    [self.textManager addBullet:@"Getting started" atLevel:0];
    [self.textManager addBullet:@"Animating" atLevel:0];
    [self.textManager addBullet:@"Rendering" atLevel:0];
    [self.textManager addBullet:@"Effects" atLevel:0];
    [self.textManager addBullet:@"Performances" atLevel:0];
}

@end
