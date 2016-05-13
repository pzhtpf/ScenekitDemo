/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  Chapter 4 slide
  
 */


#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"

@interface AAPLSlideChapter4 : AAPLSlide
@end

@implementation AAPLSlideChapter4

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    [self.textManager setChapterTitle:@"Animating a Scene"];
}

@end
