/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  Presents how dae files are supported on OS X.
  
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideDaeOnOSX : AAPLSlide
@end

@implementation AAPLSlideDaeOnOSX

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Slide's title and subtitle
    self.textManager.title = @"Working with DAE Files";
    self.textManager.subtitle = @"DAE files on OS X";
    
    // DAE icon
    SCNNode *daeIconNode = [SCNNode asc_planeNodeWithImageNamed:@"dae file icon" size:5 isLit:NO];
    daeIconNode.position = SCNVector3Make(0, 2.3, 0);
    [self.groundNode addChildNode:daeIconNode];

    // Preview icon and text
    SCNNode *previewIconNode = [SCNNode asc_planeNodeWithImageNamed:@"Preview.tiff" size:3 isLit:NO];
    previewIconNode.position = SCNVector3Make(-5, 1.3, 11);
    [self.groundNode addChildNode:previewIconNode];
    
    SCNNode *previewTextNode = [SCNNode asc_labelNodeWithString:@"Preview" size:AAPLLabelSizeSmall isLit:NO];
    previewTextNode.position = SCNVector3Make(-5.5, 0, 13);
    [self.groundNode addChildNode:previewTextNode];
    
    // Quicklook icon and text
    SCNNode *qlIconNode = [SCNNode asc_planeNodeWithImageNamed:@"Finder.tiff" size:3 isLit:NO];
    qlIconNode.position = SCNVector3Make(0, 1.3, 11);
    [self.groundNode addChildNode:qlIconNode];
    
    SCNNode *qlTextNode = [SCNNode asc_labelNodeWithString:@"QuickLook" size:AAPLLabelSizeSmall isLit:NO];
    qlTextNode.position = SCNVector3Make(-1.11, 0, 13);
    [self.groundNode addChildNode:qlTextNode];

    // Xcode icon and text
    SCNNode *xcodeIconNode = [SCNNode asc_planeNodeWithImageNamed:@"Xcode.tiff" size:3 isLit:NO];
    xcodeIconNode.position = SCNVector3Make(5, 1.3, 11);
    [self.groundNode addChildNode:xcodeIconNode];
    
    SCNNode *xcodeTextNode = [SCNNode asc_labelNodeWithString:@"Xcode" size:AAPLLabelSizeSmall isLit:NO];
    xcodeTextNode.position = SCNVector3Make(3.8, 0, 13);
    [self.groundNode addChildNode:xcodeTextNode];
}

@end
