/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  Chapter 6 slide
  
 */


#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"

@interface AAPLSlideChapter6 : AAPLSlide
@end

@implementation AAPLSlideChapter6

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    [self.textManager setChapterTitle:@"Effects"];
}

@end
