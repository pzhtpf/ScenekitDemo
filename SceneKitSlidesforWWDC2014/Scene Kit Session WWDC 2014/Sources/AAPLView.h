/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  AAPLView is a subclass of SCNView. The only thing it does is to force a resolution
  
 */

#import <SceneKit/SceneKit.h>

@interface AAPLView : SCNView

@end

#define FORCE_RESOLUTION 0
#define RESOLUTION_X 1920
#define RESOLUTION_Y 1200
