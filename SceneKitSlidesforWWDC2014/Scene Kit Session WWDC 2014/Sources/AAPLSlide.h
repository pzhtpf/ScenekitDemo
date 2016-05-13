/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  The AAPLSlide class represents a slide. A slide owns a node tree, some properties and a text manager.
  
 */

#import <SceneKit/SceneKit.h>

@class AAPLPresentationViewController, AAPLSlideTextManager;
@interface AAPLSlide : NSObject

#pragma mark - Accessing to specific places in the slide

@property (readonly) SCNNode *contentNode; // Top level node of the slide
@property (readonly) SCNNode *groundNode; // A node positioned on the floor

#pragma mark - Managing text inside the slide

@property (readonly) AAPLSlideTextManager *textManager;

#pragma mark - Navigating within the slide

- (NSUInteger)numberOfSteps;
- (void)presentStepIndex:(NSUInteger)index withPresentationViewController:(AAPLPresentationViewController *)presentationViewController;
- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController;
- (void)willOrderOutWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController;
- (void)didOrderInWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController;

#pragma mark - Lighting the scene

@property (copy) NSArray *lightIntensities;
@property SCNVector3 mainLightPosition;

#pragma mark - Customizing the floor

@property (strong) SCNMaterial *floorWarmupMaterial; // used to retain a material to prevent it from being released before the slide is presented. This used for preloading and caching.
@property (copy) NSString *floorImageName;
@property CGFloat floorReflectivity;
@property CGFloat floorFalloff;

#pragma mark - Managing transitions

@property CGFloat transitionDuration;
@property CGFloat transitionOffsetX;
@property CGFloat transitionOffsetZ;
@property CGFloat transitionRotation;

#pragma mark - Placing the slide

@property CGFloat altitude;
@property CGFloat pitch;

#pragma mark - Diplaying the 'New' badge

@property BOOL isNewIn10_10;

@end
