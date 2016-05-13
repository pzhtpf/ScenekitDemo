/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  Chapter 1 slide
  
 */


#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"

@interface AAPLSlideChapter1 : AAPLSlide
{
    SCNNode *footPrintNode;
}
@end

@implementation AAPLSlideChapter1

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    [self.textManager setChapterTitle:@"What's New in SceneKit"];
    
    //add footprint
    footPrintNode = [SCNNode node];
    
    SCNNode *sessionID = [self.textManager addText:@"Session 609" atLevel:0];
    SCNNode *presenter = [self.textManager addText:@"Thomas Goossens" atLevel:0];
    SCNNode *title = [self.textManager addFootPrint:@"Software Engineer"];
    SCNNode *footPrint = [self.textManager addFootPrint:@"© 2014 Apple Inc. All rights reserved. Redistribution or public display not permitted without written permission from Apple."];
    
    sessionID.renderingOrder = 100;
    presenter.renderingOrder = 100;
    title.renderingOrder = 100;
    sessionID.geometry.firstMaterial = footPrint.geometry.firstMaterial;
    title.geometry.firstMaterial = footPrint.geometry.firstMaterial;
    presenter.geometry.firstMaterial.readsFromDepthBuffer = NO;
    title.geometry.firstMaterial.readsFromDepthBuffer = NO;
    
    sessionID.position = SCNVector3Make(footPrint.position.x, footPrint.position.y+1.78, footPrint.position.z);
    presenter.position = SCNVector3Make(footPrint.position.x, footPrint.position.y+1.38, footPrint.position.z);
    title.position = SCNVector3Make(footPrint.position.x, footPrint.position.y+0.93, footPrint.position.z);
    
#define SCALE 0.007
    SCNVector3 scale = SCNVector3Make(SCALE, SCALE, SCALE);
    sessionID.scale = scale;
    presenter.scale = scale;
    title.scale = scale;
    
    [footPrintNode addChildNode:sessionID];
    [footPrintNode addChildNode:presenter];
    [footPrintNode addChildNode:footPrint];
    [footPrintNode addChildNode:title];
    
    [presentationViewController.cameraNode addChildNode:footPrintNode];
}

- (void) willOrderOutWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController
{
    [footPrintNode removeFromParentNode];
}

@end
