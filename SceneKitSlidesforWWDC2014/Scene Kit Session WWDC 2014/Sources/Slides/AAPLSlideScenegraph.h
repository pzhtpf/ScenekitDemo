/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  Explains the structure of the scene graph with a diagram.
  
 */

#import "AAPLSlide.h"

@interface AAPLSlideSceneGraph : AAPLSlide

+ (SCNNode *)sharedScenegraphDiagramNode;
+ (void)scenegraphDiagramGoToStep:(NSUInteger)step;

@end
