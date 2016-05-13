/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  Chapter 3 slide
  
 */


#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"

@interface AAPLSlideChapter3 : AAPLSlide
@end

@implementation AAPLSlideChapter3

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    [self.textManager setChapterTitle:@"Getting Started"];
}

@end
