/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  Chapter 7 slide
  
 */


#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"

@interface AAPLSlideChapter7 : AAPLSlide
@end

@implementation AAPLSlideChapter7

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    [self.textManager setChapterTitle:@"Performance"];
}

@end
