/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  Creating a Scene slide, part 2.
  
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideCreateAScene2 : AAPLSlide
@end

@implementation AAPLSlideCreateAScene2

- (void)presentStepIndex:(NSUInteger)index withPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    self.textManager.title = @"Creating a Scene";
    
    [self.textManager addBullet:@"Creating programmatically" atLevel:0];
    [self.textManager addBullet:@"Loading a scene from a file" atLevel:0];
    
    // Automatically highlight the second bullet after one second
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [self.textManager highlightBulletAtIndex:1];
    });
}

@end
