/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  AAPLPresentationViewController controls the presentation, including ordering the slides in and out, updating the position of the camera, the light intensites and more.
  
 */

#import <SceneKit/SceneKit.h>

@class AAPLSlide;
@protocol AAPLPresentationDelegate;

@interface AAPLPresentationViewController : NSViewController

@property (weak) id <AAPLPresentationDelegate> delegate;

// Main view
- (SCNView *) presentationView;

- (id)initWithContentsOfFile:(NSString *)path;
- (void)applicationDidFinishLaunching;

// Presentation outline
- (NSInteger)numberOfSlides;
- (Class)classOfSlideAtIndex:(NSInteger)slideIndex;

// Navigation within the presentation
- (void)goToNextSlideStep;
- (void)goToPreviousSlide;
- (void)goToSlideAtIndex:(NSInteger)slideIndex;

// Nodes used to control the position and orientation of the main camera
@property (readonly) SCNNode *cameraHandle;
@property (readonly) SCNNode *cameraPitch; // child of 'cameraHandle'
@property (readonly) SCNNode *cameraNode;  // child of 'cameraPitch'

// Scene decorations
@property (nonatomic) BOOL showsNewInSceneKitBadge;

// Lighting the scene
- (void)updateLightingWithIntensities:(NSArray *)intensities; //[ omni, front, top spot, left, right, ambient]
- (void)narrowSpotlight:(BOOL)narrow;
- (void)riseMainLight:(BOOL)rise;

// Nodes used to control the lighting
- (SCNNode *)spotLight;
- (SCNNode *)mainLight;

// actions
- (IBAction) exportSlidesToImages:(id) sender;
- (IBAction) exportSlidesToSCN:(id) sender;
- (IBAction) autoPlay:(id) sender;

@end

@protocol AAPLPresentationDelegate <NSObject>
@optional

- (void)presentationViewController:(AAPLPresentationViewController *)presentationViewController willPresentSlideAtIndex:(NSUInteger)slideIndex step:(NSUInteger)step;

@end
