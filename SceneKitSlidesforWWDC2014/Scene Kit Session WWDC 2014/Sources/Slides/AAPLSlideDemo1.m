/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  Chapter 2 slide : Scene Graph
  
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"

@interface AAPLSlideDemo1 : AAPLSlide
{
    SCNNode *_chapterNode;
}
@end

@implementation AAPLSlideDemo1

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    _chapterNode = [self.textManager setChapterTitle:@"Car Toy Demo"];
}


- (void)willOrderOutWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:0.75];
    _chapterNode.position = SCNVector3Make(_chapterNode.position.x-30, _chapterNode.position.y, _chapterNode.position.z);
    [SCNTransaction commit];
}


@end
