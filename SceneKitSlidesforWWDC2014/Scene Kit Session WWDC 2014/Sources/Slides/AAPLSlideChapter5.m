/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  Chapter 5 slide
  
 */


#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"

@interface AAPLSlideChapter5 : AAPLSlide
{
    SCNNode *footPrintNode;
}
@end

@implementation AAPLSlideChapter5

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController
{
    [self.textManager setChapterTitle:@"Rendering"];
}

- (void) didOrderInWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController
{
    
    //add footprint
    footPrintNode = [SCNNode node];
    
    SCNNode *presenter = [self.textManager addText:@"Aymeric Bard" atLevel:0];
    SCNNode *title = [self.textManager addFootPrint:@"Software Engineer"];
    SCNNode *footPrint = [self.textManager addFootPrint:@""];
    
    presenter.renderingOrder = 100;
    title.renderingOrder = 100;
    title.geometry.firstMaterial = footPrint.geometry.firstMaterial;
    presenter.geometry.firstMaterial.readsFromDepthBuffer = NO;
    title.geometry.firstMaterial.readsFromDepthBuffer = NO;
    
    presenter.position = SCNVector3Make(footPrint.position.x, footPrint.position.y+1.38, footPrint.position.z);
    title.position = SCNVector3Make(footPrint.position.x, footPrint.position.y+0.93, footPrint.position.z);
    
#define SCALE 0.007
    SCNVector3 scale = SCNVector3Make(SCALE, SCALE, SCALE);
    presenter.scale = scale;
    title.scale = scale;
    
    
    [footPrintNode addChildNode:presenter];
    [footPrintNode addChildNode:footPrint];
    [footPrintNode addChildNode:title];
    
    footPrintNode.opacity = 0;
    
    [presentationViewController.cameraNode addChildNode:footPrintNode];
    
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1.0];
    footPrintNode.opacity = 1.0;
    [SCNTransaction commit];
}

- (void) willOrderOutWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController
{
    [footPrintNode removeFromParentNode];
}


@end
