/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Explains how to get more information about SceneKit.
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideMoreInfo : AAPLSlide
@end

@implementation AAPLSlideMoreInfo

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    self.textManager.title = @"More Information";

    [self.textManager addText:@"Allan Schaffer" atLevel:0];
    SCNNode *node = [self.textManager addText:@"Graphics and Game Technologies Evangelist" atLevel:1];
    node.opacity = 0.56;
    [self.textManager addText:@"aschaffer@apple.com" atLevel:2];
    [self.textManager addEmptyLine];

    [self.textManager addText:@"Filip Iliescu" atLevel:0];
    node = [self.textManager addText:@"Graphics and Game Technologies Evangelist" atLevel:1];
    node.opacity = 0.56;
    [self.textManager addText:@"filiescu@apple.com" atLevel:2];
    [self.textManager addEmptyLine];

    [self.textManager addText:@"Documentation" atLevel:0];
    node = [self.textManager addText:@"SceneKit Framework Reference" atLevel:1];
    node.opacity = 0.56;
    [self.textManager addText:@"http://developer.apple.com" atLevel:2];
    [self.textManager addEmptyLine];

    [self.textManager addText:@"Apple Developer Forums" atLevel:0];
    [self.textManager addText:@"http://devforums.apple.com" atLevel:2];
}

@end
