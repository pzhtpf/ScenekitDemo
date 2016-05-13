/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  AAPLPresentationViewController controls the presentation, including ordering the slides in and out, updating the position of the camera, the light intensites and more.
  
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlide.h"
#import "AAPLSlideTextManager.h"
#import "AAPLView.h"
#import "Utils.h"


#define AAPL_INITIAL_SLIDE 0

typedef NS_ENUM(NSUInteger, AAPLLightName) {
    AAPLLightMain = 0,
    AAPLLightFront,
    AAPLLightSpot,
    AAPLLightLeft,
    AAPLLightRight,
    AAPLLightAmbient,
    AAPLLightCount
};

@implementation AAPLPresentationViewController {
    // Keeping track of the current slide
    NSInteger _currentSlideIndex;
    NSInteger _currentSlideStep;
    
    // The scene used for this presentation
    SCNScene *_scene;
    
    // Light nodes
    SCNNode *_lights[AAPLLightCount];
    
    // Other useful nodes
    SCNNode *_cameraNode;
    SCNNode *_cameraPitch;
    SCNNode *_cameraHandle;
    
    // Managing the floor
    SCNFloor *_floor;
    NSString *_floorImagePath;
    
    // Presentation settings and slides
    NSDictionary        *_settings;
    NSMutableDictionary *_slideCache;
    
    // Managing the "New" badge
    SCNNode     *_newBadgeNode;
    CAAnimation *_newBadgeAnimation;
}

#pragma mark - View controller

- (SCNView *)presentationView {
    return (SCNView *)[super view];
}

- (id)initWithContentsOfFile:(NSString *)path {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        // Load the presentation settings from the plist file
        NSString *settingsPath = [[NSBundle mainBundle] pathForResource:path ofType:@"plist"];
        _settings = [NSDictionary dictionaryWithContentsOfFile:settingsPath];
        
        _slideCache = [[NSMutableDictionary alloc] init];
        
        // Create a new empty scene
        _scene = [SCNScene scene];
        
        // Create and add a camera to the scene
        // We create three separate nodes to ease the manipulation of the global position, pitch (ie. orientation around the x axis) and relative position
        // - cameraHandle is used to control the global position in world space
        // - cameraPitch  is used to rotate the position around the x axis
        // - cameraNode   is sometimes manipulated by slides to move the camera relatively to the global position (cameraHandle). But this node is supposed to always be repositioned at (0, 0, 0) in the end of a slide.
        
        _cameraHandle = [SCNNode node];
        _cameraHandle.name = @"cameraHandle";
        [_scene.rootNode addChildNode:_cameraHandle];
        
        _cameraPitch = [SCNNode node];
        _cameraPitch.name = @"cameraPitch";
        [_cameraHandle addChildNode:_cameraPitch];
        
        _cameraNode = [SCNNode node];
        _cameraNode.name = @"cameraNode";
        _cameraNode.camera = [SCNCamera camera];
        
        // Set the default field of view to 70 degrees (a relatively strong perspective)
        _cameraNode.camera.xFov = 70.0;
        _cameraNode.camera.yFov = 42.0;
        [_cameraPitch addChildNode:_cameraNode];
        
        // Setup the different lights
        [self initLighting];
        
        // Create and add a reflective floor to the scene
        SCNMaterial *floorMaterial = [SCNMaterial material];
        floorMaterial.ambient.contents = [NSColor blackColor];
        floorMaterial.diffuse.contents = @"floor.png";
        floorMaterial.locksAmbientWithDiffuse = YES;
        floorMaterial.normal.wrapS =
        floorMaterial.normal.wrapT =
        floorMaterial.specular.wrapS =
        floorMaterial.specular.wrapT =
        floorMaterial.diffuse.wrapS  =
        floorMaterial.diffuse.wrapT  = SCNWrapModeMirror;
        floorMaterial.normal.contents = @"floorBump.jpg";
        floorMaterial.normal.mipFilter = SCNFilterModeLinear;
        floorMaterial.diffuse.mipFilter = SCNFilterModeLinear;
        floorMaterial.diffuse.contentsTransform = CATransform3DScale(SCNMatrix4MakeRotation(M_PI / 4, 0, 0, 1), 1.0, 1.0, 1.0);
        floorMaterial.normal.contentsTransform = SCNMatrix4MakeScale(20.0, 20.0, 1.0);
        floorMaterial.normal.intensity = 0.5;

        _floor = [SCNFloor floor];
        _floor.reflectionFalloffEnd = 3.0;
        _floor.firstMaterial = floorMaterial;
        
        SCNNode *floorNode = [SCNNode node];
        floorNode.geometry = _floor;
        [_scene.rootNode addChildNode:floorNode];
        
        floorNode.physicsBody = [SCNPhysicsBody staticBody]; //make floor dynamic for physics slides
        _scene.physicsWorld.speed = 0; //pause physics to avoid continuous drawing
        
        // Use a shader modifier to support a secondary texture for some slides
        NSString *shaderFile = [[NSBundle mainBundle] pathForResource:@"floor" ofType:@"shader"];
        NSString *shaderSource = [NSString stringWithContentsOfFile:shaderFile encoding:NSUTF8StringEncoding error:nil];
        floorMaterial.shaderModifiers = @{ SCNShaderModifierEntryPointSurface : shaderSource };
        
        // Set the scene to the view
        self.view = [[AAPLView alloc] init];
        
        // bg color
        self.presentationView.backgroundColor = [NSColor blackColor];
        
        // black fog
        _scene.fogColor = [NSColor colorWithCalibratedWhite:0 alpha:1.0];
        _scene.fogEndDistance = 45.0;
        _scene.fogStartDistance = 40.0;
        
        // assign the scene to the view
        self.presentationView.scene = _scene;
        
        // Turn on jittering for better anti-aliasing when the scene is still
        self.presentationView.jitteringEnabled = YES;
        
        // Start the presentation
        [self goToSlideAtIndex:AAPL_INITIAL_SLIDE];
    }
    return self;
}

- (void) applicationDidFinishLaunching
{
    /* REMOVE FROM SAMPLE CODE */
#if FORCE_RESOLUTION
    //force the resolution
    CGLContextObj ctx = [[self.view openGLContext] CGLContextObj];
    GLint dim[2] = {RESOLUTION_X, RESOLUTION_Y};
    CGLSetParameter(ctx, kCGLCPSurfaceBackingSize, dim);
    CGLEnable (ctx, kCGLCESurfaceBackingSize);
#endif
}

#pragma mark - Presentation outline

- (NSInteger)numberOfSlides {
    return [_settings[@"Slides"] count];
}

- (Class)classOfSlideAtIndex:(NSInteger)slideIndex {
    NSDictionary *info = _settings[@"Slides"][slideIndex];
    NSString *className = info[@"Class"];
    return NSClassFromString(className);
}

#pragma mark - Slide creation and warm up

// This method creates and initializes the slide at the specified index and returns it.
// The new slide is cached in the _slides array.
- (AAPLSlide *)slideAtIndex:(NSInteger)slideIndex loadIfNeeded:(BOOL)loadIfNeeded {
    if (slideIndex < 0 || slideIndex >= [_settings[@"Slides"] count])
        return nil;
    
    // Look into the cache first
    AAPLSlide *slide = _slideCache[@(slideIndex)];
    if (slide) {
        return slide;
    }
    
    if (!loadIfNeeded)
        return nil;
    
    // Create the new slide
    Class slideClass = [self classOfSlideAtIndex:slideIndex];
    slide = [[slideClass alloc] init];
    
    // Update its parameters
    NSDictionary *info = _settings[@"Slides"][slideIndex];
    NSDictionary *parameters = info[@"Parameters"];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [slide setValue:obj forKey:key];
    }];
    
    _slideCache[@(slideIndex)] = slide;
    
    if (!slide)
        return nil;
    
    // Setup the slide
    [slide  setupSlideWithPresentationViewController:self];
    
    return slide;
}

// Preload the next slide
- (void)prepareSlideAtIndex:(NSInteger)slideIndex {
    //too late?
    if(slideIndex != _currentSlideIndex+1){
        return;
    }
    
    // Retrieve the slide to preload    
    AAPLSlide *slide = [self slideAtIndex:slideIndex loadIfNeeded:YES];
    
    if (slide) {
        [SCNTransaction flush]; // make sure that all pending transactions are flushed otherwise objects not added yet to the scene graph would not be preloaded
        
        // Preload the node tree
        [self.presentationView prepareObject:slide.contentNode shouldAbortBlock:nil];
        
        // Preload the floor image if any
        if ([slide.floorImageName length]) {
            // Create a container for this image to be able to preload it
            SCNMaterial *material = [SCNMaterial material];
            material.diffuse.contents = slide.floorImageName;
            material.diffuse.mipFilter = SCNFilterModeLinear; // we also want to preload mipmaps
            
            [SCNTransaction flush]; //make this material ready before warming up
            
            // Preload
            [self.presentationView prepareObject:material shouldAbortBlock:nil];
            
            // Don't release the material now, otherwise we will loose what we just preloaded
            slide.floorWarmupMaterial = material;
        }
    }
}

#pragma mark - Navigating within a presentation

- (void)goToNextSlideStep {
    AAPLSlide *slide = [self slideAtIndex:_currentSlideIndex loadIfNeeded:NO];
    if (_currentSlideStep + 1 >= [slide numberOfSteps]) {
        [self goToSlideAtIndex:_currentSlideIndex + 1];
    } else {
        [self goToSlideStep:_currentSlideStep + 1];
    }
}

- (void)goToPreviousSlide {
    [self goToSlideAtIndex:_currentSlideIndex - 1];
}

- (void)goToSlideAtIndex:(NSInteger)slideIndex {
    NSUInteger oldIndex = _currentSlideIndex;
    
    // Load the slide at the specified index
    AAPLSlide *slide = [self slideAtIndex:slideIndex loadIfNeeded:YES];
    
    if (!slide)
        return;
    
    // Compute the playback direction (did the user select next or previous?)
    float direction = slideIndex >= _currentSlideIndex ? 1 : -1;
    
    // Update badge
    self.showsNewInSceneKitBadge = [slide isNewIn10_10];
    
    // If we are playing backward, we need to use the slide we come from to play the correct transition (backward)
    NSInteger transitionSlideIndex = direction == 1 ? slideIndex : _currentSlideIndex;
    AAPLSlide *transitionSlide = [self slideAtIndex:transitionSlideIndex loadIfNeeded:YES];
    
    // Make sure that the next operations are synchronized by using a transaction
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:0];
    {
        SCNNode *rootNode = slide.contentNode;
        SCNNode *textContainer = slide.textManager.textNode;
        
        SCNVector3 offset = SCNVector3Make(transitionSlide.transitionOffsetX, 0.0, transitionSlide.transitionOffsetZ);
        offset.x *= direction;
        offset.z *= direction;
        
        // Rotate offset based on current yaw
        double cosa = cos(-_cameraHandle.rotation.w);
        double sina = sin(-_cameraHandle.rotation.w);
        
        double tmpX = offset.x * cosa - offset.z * sina;
        offset.z = offset.x * sina + offset.z * cosa;
        offset.x = tmpX;
        
        // If we don't move, fade in
        if (offset.x == 0 && offset.y == 0 && offset.z == 0 && transitionSlide.transitionRotation == 0) {
            rootNode.opacity = 0;
        }
        
        // Don't animate the first slide
        BOOL shouldAnimate = !(slideIndex == 0 && _currentSlideIndex == 0);
        
        // Update current slide index
        _currentSlideIndex = slideIndex;
        
        // Go to step 0
        [self goToSlideStep:0];
        
        // Add the slide to the scene graph
        [self.presentationView.scene.rootNode addChildNode:rootNode];
        
        // Fade in, update paramters and notify on completion
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:shouldAnimate ? slide.transitionDuration : 0];
        [SCNTransaction setCompletionBlock:^{
            [self didOrderInSlideAtIndex:slideIndex];
        }];
        {
            rootNode.opacity = 1;
            
            _cameraHandle.position = SCNVector3Make(_cameraHandle.position.x + offset.x, slide.altitude, _cameraHandle.position.z + offset.z);
            _cameraHandle.rotation = SCNVector4Make(0, 1, 0, _cameraHandle.rotation.w + transitionSlide.transitionRotation * M_PI / 180.0 * direction);
            _cameraPitch.rotation = SCNVector4Make(1, 0, 0, slide.pitch * M_PI / 180.0);
            
            [self updateLightingForSlideAtIndex:slideIndex];
            
            _floor.reflectivity = slide.floorReflectivity;
            _floor.reflectionFalloffEnd = slide.floorFalloff;
        }
        [SCNTransaction commit];
        
        // Compute the position of the text (in world space, relative to the camera)
        CATransform3D textWorldTransform = CATransform3DConcat(SCNMatrix4MakeTranslation(0, -3.3, -28), _cameraNode.worldTransform);
        
        // Place the rest of the slide
        rootNode.transform = textWorldTransform;
        rootNode.position = SCNVector3Make(rootNode.position.x, 0, rootNode.position.z); // clear altitude
        rootNode.rotation = SCNVector4Make(0, 1, 0, _cameraHandle.rotation.w); // use same rotation as the camera to simplify the placement of the elements in slides
        
        // Place the text
        CATransform3D textTransform = [textContainer.parentNode convertTransform:textWorldTransform fromNode:nil];
        textContainer.transform = textTransform;
        
        // Place the ground node
        SCNVector3 localPosition = SCNVector3Make(0, 0, 0);
        SCNVector3 worldPosition = [slide.groundNode.parentNode convertPosition:localPosition toNode:nil];
        worldPosition.y = 0; // make it touch the ground
        
        localPosition = [slide.groundNode.parentNode convertPosition:worldPosition fromNode:nil];
        slide.groundNode.position = localPosition;
        
        // Update the floor image if needed
        [self updateFloorImage:slide.floorImageName forSlide:slide];
    }
    [SCNTransaction commit];
    
    // Preload the next slide after some delay
    double delayInSeconds = 1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [self prepareSlideAtIndex:slideIndex + 1];
    });
    
    // Order out previous slide if any
    if (oldIndex != _currentSlideIndex)
        [self willOrderOutSlideAtIndex:oldIndex];
}

- (void)goToSlideStep:(NSInteger)index {
    _currentSlideStep = index;
    
    AAPLSlide *slide = [self slideAtIndex:_currentSlideIndex loadIfNeeded:YES];
    if (!slide)
        return;
    
    if ([self.delegate respondsToSelector:@selector(presentationViewController:willPresentSlideAtIndex:step:)]) {
        [self.delegate presentationViewController:self willPresentSlideAtIndex:_currentSlideIndex step:_currentSlideStep];
    }
    
    [slide presentStepIndex:_currentSlideStep withPresentationViewController:self];
}

- (void)didOrderInSlideAtIndex:(NSInteger)slideIndex {
    AAPLSlide *slide = [self slideAtIndex:slideIndex loadIfNeeded:NO];
    [slide didOrderInWithPresentationViewController:self];
    //[self clearCachesWithActiveSlideIndex:slideIndex];
}
//
//- (void) clearCachesWithActiveSlideIndex:(NSInteger) slideIndex
//{
//    NSMutableArray *toTrash = [NSMutableArray array];
//    
//    [_slideCache enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//        if(abs((int)([key integerValue] - slideIndex)) > 1){
//            [toTrash addObject:key];
//        }
//    }];
//    
//    for(id key in toTrash){
//        [_slideCache removeObjectForKey:key];
//    }
//}

- (void)willOrderOutSlideAtIndex:(NSInteger)slideIndex {
    AAPLSlide *slide = [self slideAtIndex:slideIndex loadIfNeeded:NO];
    if (slide) {
        SCNNode *node = slide.contentNode;
        
        // Fade out and remove on completion
#if 0
        [node runAction:[SCNAction sequence:@[[SCNAction waitForDuration:2.0], [SCNAction removeFromParentNode]]]];
#else
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:0.75];
        [SCNTransaction setCompletionBlock:^{
            [node removeFromParentNode];
        }];
        {
            node.opacity = 0.0;
        }
        [SCNTransaction commit];
#endif
        [slide willOrderOutWithPresentationViewController:self];
        [_slideCache removeObjectForKey:@(slideIndex)];
//        NSLog(@"remove %d: cached slide count = %d (%@)", (int)slideIndex, (int)[_slideCache count], _slideCache);
    }
}

#pragma mark - Scene decorations

- (void)setShowsNewInSceneKitBadge:(BOOL)showsBadge {
    _showsNewInSceneKitBadge = showsBadge;
    
    if (_newBadgeNode.opacity == 1 && showsBadge)
        return; // already visible
    
    if (_newBadgeNode.opacity == 0 && !showsBadge)
        return; // already invisible
    
    // Load the model and the animation
    if (!_newBadgeNode) {
        _newBadgeNode = [SCNNode node];
        
        SCNNode *badgeNode = [_newBadgeNode asc_addChildNodeNamed:@"newBadge" fromSceneNamed:@"Scenes.scnassets/newBadge" withScale:1];
        _newBadgeNode.scale = SCNVector3Make(0.03, 0.03, 0.03);
        _newBadgeNode.opacity = 0;
        _newBadgeNode.position = SCNVector3Make(50, 20, -10);
        
        SCNNode *imageNode = [_newBadgeNode childNodeWithName:@"badgeImage" recursively:YES];
        imageNode.geometry.firstMaterial.emission.intensity = 0.0;
        
        _newBadgeAnimation = [badgeNode animationForKey:badgeNode.animationKeys[0]];
        [badgeNode removeAllAnimations];
        
        _newBadgeAnimation.speed = 1.5;
        _newBadgeAnimation.fillMode = kCAFillModeBoth;
        _newBadgeAnimation.usesSceneTimeBase = NO;
        _newBadgeAnimation.removedOnCompletion = NO;
        _newBadgeAnimation.repeatCount = 0;
    }
    
    // Play
    if (showsBadge) {
        //reset
        _newBadgeNode.opacity = 1.0;
        SCNNode *ropeNode = [_newBadgeNode childNodeWithName:@"rope02" recursively:YES];
        ropeNode.opacity = 1.0;
        
        [self.cameraPitch addChildNode:_newBadgeNode];
        [_newBadgeNode addAnimation:_newBadgeAnimation forKey:@"animation"];
        
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:2];
        {
            _newBadgeNode.position = SCNVector3Make(14, 8, -20);
            
            [SCNTransaction setCompletionBlock:^{
                [SCNTransaction begin];
                [SCNTransaction setAnimationDuration:3];
                {
                    SCNNode *ropeNode = [_newBadgeNode childNodeWithName:@"rope02" recursively:YES];
                    ropeNode.opacity = 0.0;
                }
                [SCNTransaction commit];
                
            }];
            
            _newBadgeNode.opacity = 1.0;
            SCNNode *imageNode = [_newBadgeNode childNodeWithName:@"badgeImage" recursively:YES];
            imageNode.geometry.firstMaterial.emission.intensity = 0.4;
        }
        [SCNTransaction commit];
    }
    
    // Or hide
    else {
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:1.5];
        {
            [SCNTransaction setCompletionBlock:^{
                [_newBadgeNode removeFromParentNode];
            }];
            _newBadgeNode.position = SCNVector3Make(14, 50, -20);
            _newBadgeNode.opacity = 0.0;
        }
        [SCNTransaction commit];
    }
}

#pragma mark - Lighting the scene

- (void)initLighting {
    // Omni light (main light of the scene)
	_lights[AAPLLightMain] = [SCNNode node];
    _lights[AAPLLightMain].name = @"omni";
    _lights[AAPLLightMain].position = SCNVector3Make(0, 3, -13);
	_lights[AAPLLightMain].light = [SCNLight light];
	_lights[AAPLLightMain].light.type = SCNLightTypeOmni;
    _lights[AAPLLightMain].light.attenuationStartDistance = 10.0;
    _lights[AAPLLightMain].light.attenuationEndDistance = 50.0;
    _lights[AAPLLightMain].light.color = [NSColor blackColor];
	[_cameraHandle addChildNode:_lights[AAPLLightMain]]; //make all lights relative to the camera node
    
    // Front light
	_lights[AAPLLightFront] = [SCNNode node];
    _lights[AAPLLightFront].name = @"front light";
    _lights[AAPLLightFront].position = SCNVector3Make(0, 0, 0);
	_lights[AAPLLightFront].light = [SCNLight light];
    _lights[AAPLLightFront].light.type = SCNLightTypeDirectional;
    _lights[AAPLLightFront].light.color = [NSColor blackColor];
    [_cameraHandle addChildNode:_lights[AAPLLightFront]];
    
    // Spot light
	_lights[AAPLLightSpot] = [SCNNode node];
    _lights[AAPLLightSpot].name = @"spot light";
    _lights[AAPLLightSpot].transform = CATransform3DConcat(SCNMatrix4MakeRotation(-M_PI_2 * 0.8, 1, 0, 0), SCNMatrix4MakeRotation(-0.3, 0, 0, 1));
    _lights[AAPLLightSpot].position = SCNVector3Make(15, 30, -7);
	_lights[AAPLLightSpot].light = [SCNLight light];
    _lights[AAPLLightSpot].light.type = SCNLightTypeSpot;
    _lights[AAPLLightSpot].light.shadowRadius = 3;
    _lights[AAPLLightSpot].light.zNear = 20;
    _lights[AAPLLightSpot].light.zFar = 100;
    _lights[AAPLLightSpot].light.color = [NSColor blackColor];
    //_lights[AAPLLightSpot].light.shadowColor = [NSColor blackColor];
    _lights[AAPLLightSpot].light.castsShadow = YES;
    [self narrowSpotlight:NO];
	[_cameraHandle addChildNode:_lights[AAPLLightSpot]];
    
    // Left light
	_lights[AAPLLightLeft] = [SCNNode node];
    _lights[AAPLLightLeft].name = @"left light";
    _lights[AAPLLightLeft].position = SCNVector3Make(-20, 10, -20);
    _lights[AAPLLightLeft].rotation = SCNVector4Make(0, 1, 0, M_PI_2);
    _lights[AAPLLightLeft].light.attenuationStartDistance = 30.0;
    _lights[AAPLLightLeft].light.attenuationEndDistance = 80.0;
	_lights[AAPLLightLeft].light = [SCNLight light];
	_lights[AAPLLightLeft].light.type = SCNLightTypeOmni;
    _lights[AAPLLightLeft].light.color = [NSColor blackColor];
	[_cameraHandle addChildNode:_lights[AAPLLightLeft]];
    
    // Right light
	_lights[AAPLLightRight] = [SCNNode node];
    _lights[AAPLLightRight].name = @"right light";
    _lights[AAPLLightRight].rotation = SCNVector4Make(0, 1, 0, -M_PI_2);
    _lights[AAPLLightRight].position = SCNVector3Make(20, 10, -20);
    _lights[AAPLLightRight].light.attenuationStartDistance = 30.0;
    _lights[AAPLLightRight].light.attenuationEndDistance = 80.0;
	_lights[AAPLLightRight].light = [SCNLight light];
	_lights[AAPLLightRight].light.type = SCNLightTypeOmni;
    _lights[AAPLLightRight].light.color = [NSColor blackColor];
	[_cameraHandle addChildNode:_lights[AAPLLightRight]];
    
    // Ambient light
	_lights[AAPLLightAmbient] = [SCNNode node];
    _lights[AAPLLightAmbient].name = @"ambient light";
	_lights[AAPLLightAmbient].light = [SCNLight light];
	_lights[AAPLLightAmbient].light.type = SCNLightTypeAmbient;
    _lights[AAPLLightAmbient].light.color = [NSColor colorWithCalibratedWhite:0.0 alpha:1.0];
	[_scene.rootNode addChildNode:_lights[AAPLLightAmbient]];
}

- (void)updateLightingForSlideAtIndex:(NSInteger)slideIndex {
    AAPLSlide *slide = [self slideAtIndex:slideIndex loadIfNeeded:YES];
    
    _lights[AAPLLightMain].position = slide.mainLightPosition;
    
    [self updateLightingWithIntensities:slide.lightIntensities];
}

- (void)updateLightingWithIntensities:(NSArray *)intensities {
    for (NSInteger i = 0; i < AAPLLightCount; i++) {
        
        CGFloat intensity = [intensities count] > i ? [intensities[i] floatValue] : 0;
        
        _lights[i].light.color = [NSColor colorWithDeviceWhite:intensity alpha:1];
    }
}

- (void)narrowSpotlight:(BOOL)narrow {
    if (narrow) {
        _lights[AAPLLightSpot].light.spotInnerAngle = 20;
        _lights[AAPLLightSpot].light.spotOuterAngle = 30;
    } else {
        _lights[AAPLLightSpot].light.spotInnerAngle = 10;
        _lights[AAPLLightSpot].light.spotOuterAngle = 50;
    }
}

- (void)riseMainLight:(BOOL)rise {
    if (rise) {
        _lights[AAPLLightMain].light.attenuationStartDistance = 90;
        _lights[AAPLLightMain].light.attenuationEndDistance = 250;
        
        _lights[AAPLLightMain].position = SCNVector3Make(0, 10, -10);
    } else {
        _lights[AAPLLightMain].light.attenuationStartDistance = 10;
        _lights[AAPLLightMain].light.attenuationEndDistance = 50;
        _lights[AAPLLightMain].position = SCNVector3Make(0, 3, -13);
    }
}

- (SCNNode *)spotLight {
    return _lights[AAPLLightSpot];
}

- (SCNNode *)mainLight {
    return _lights[AAPLLightMain];
}

#pragma mark - Updating the floor

// Updates the secondary image of the floor if needed
- (void)updateFloorImage:(NSString *)imagePath forSlide:(AAPLSlide *)slide {
    // We don't want to animate if we replace the secondary image by a new one
    // Otherwise we want to translate the secondary image to the new location
    BOOL disableAction = NO;
    
    if ([_floorImagePath isEqualToString:imagePath] == NO && (imagePath!=_floorImagePath)) {
        _floorImagePath = imagePath;
        disableAction = YES;
        
        if (imagePath) {
            // Set a new material property with this image to the "floorMap" custom property of the floor
            SCNMaterialProperty *property = [SCNMaterialProperty materialPropertyWithContents:imagePath];
            property.wrapS = SCNWrapModeRepeat;
            property.wrapT = SCNWrapModeRepeat;
            property.mipFilter = SCNFilterModeLinear;
            
            [_floor.firstMaterial setValue:property forKey:@"floorMap"];
        }
    }
    
    if (imagePath) {
        SCNVector3 slidePosition = [slide.groundNode convertPosition:SCNVector3Make(0, 0, 10) toNode:nil];
        
        if (disableAction) {
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0];
            {
                [_floor.firstMaterial setValue:[NSValue valueWithSCNVector3:slidePosition] forKey:@"floorImageNamePosition"];
            }
            [SCNTransaction commit];
        } else {
            [_floor.firstMaterial setValue:[NSValue valueWithSCNVector3:slidePosition] forKey:@"floorImageNamePosition"];
        }
    }
}


#pragma -
#pragma export slides

// export the current slide to an NSImage
- (void) exportCurrentSlide
{
    NSSize size = NSMakeSize(RESOLUTION_X, RESOLUTION_Y);
    
    id view = self.view;
    NSImage* image = [view snapshot];
    
    if(image){
        NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithCGImage:[image CGImageForProposedRect:NULL context:NULL hints:NULL]];
        
        size.width /= 2;
        size.height /= 2;
        
        NSImage *composite = [[NSImage alloc] initWithSize:size];
        [composite lockFocus];
        [[NSColor blackColor] set];
        
        NSRect rect = NSMakeRect(0, 0, size.width, size.height);
        NSRectFill(rect);
        
        [bitmap drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1 respectFlipped:YES hints:nil];
        [composite unlockFocus];
        
        [[composite TIFFRepresentation] writeToFile:[[NSString stringWithFormat:@"~/Desktop/SceneKit-WWDC13/SceneKit_slide_%d_%d.tiff", (int)_currentSlideIndex, (int)_currentSlideIndex] stringByExpandingTildeInPath] atomically:YES];
    }
}

- (void) exportCurrentSlideToSCN
{
    SCNScene *scene = self.presentationView.scene;
    
    NSString *file = [[NSString stringWithFormat:@"~/Desktop/wwdc2014-archive/wwdc14_slide_%d_%d.scn", (int)_currentSlideIndex, (int)_currentSlideStep] stringByExpandingTildeInPath];
    
    [[NSFileManager defaultManager] removeItemAtPath:file error:NULL];
    [NSKeyedArchiver archiveRootObject:scene toFile:file];
}

// Export as SCN archive
- (IBAction) exportSlidesToSCN:(id) sender
{
    [[NSFileManager defaultManager] createDirectoryAtPath:[@"~/Desktop/wwdc2014-archive" stringByExpandingTildeInPath] withIntermediateDirectories:YES attributes:nil error:nil];
    
    [SCNTransaction begin];
    [SCNTransaction setDisableActions:YES];
    
    [self exportCurrentSlideToSCN];
    
    [SCNTransaction commit];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSUInteger slideIndex = 0;
        NSUInteger stepIndex = 0;
        
        while(1){
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self goToNextSlideStep];
            });
            
            if(_currentSlideIndex == slideIndex && stepIndex == _currentSlideStep){
                //finish !
                return;
            }
            
            sleep(1.0); //let the slide stabilize
            
            slideIndex = _currentSlideIndex;
            stepIndex = _currentSlideStep;
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self exportCurrentSlideToSCN];
            });
        }
    });

}


// Export the slides to PDF
- (IBAction) exportSlidesToImages:(id) sender
{
    [SCNTransaction begin];
    [SCNTransaction setDisableActions:YES];
    
    [self exportCurrentSlide];
    
    [SCNTransaction commit];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSUInteger slideIndex = 0;
        NSUInteger stepIndex = 0;
        
        while(1){
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self goToNextSlideStep];
            });
            
            if(_currentSlideIndex == slideIndex && stepIndex == _currentSlideStep){
                //finish !
                return;
            }
            
            sleep(1.0); //let the slide stabilize
            
            slideIndex = _currentSlideIndex;
            stepIndex = _currentSlideStep;
            
            [SCNTransaction begin];
            [SCNTransaction setDisableActions:YES];
            [self exportCurrentSlide];
            [SCNTransaction commit];
        }
    });
}


// Play the slides automatically
- (IBAction) autoPlay:(id) sender
{
    static BOOL demoRunning = NO;
    static BOOL demoShouldStop = NO;
    
    if(demoRunning == YES){
        demoShouldStop = YES;
        return;
    }
    demoRunning = YES;
    demoShouldStop = NO;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUInteger lastSlide=0;
        NSUInteger lastStep=0;
        
        sleep(4);
        
        while(demoShouldStop==NO){
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self goToNextSlideStep];
            });
            
            if(lastSlide == _currentSlideIndex && lastStep == _currentSlideStep){
                [self goToSlideAtIndex:0];
            }
            
            lastSlide = _currentSlideIndex;
            lastStep = _currentSlideStep;
            
            sleep(4);
        }
    });
}


@end
