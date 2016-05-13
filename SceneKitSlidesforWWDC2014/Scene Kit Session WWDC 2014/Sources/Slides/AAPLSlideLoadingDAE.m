/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Presents what dae documents are.
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideLoadingDae : AAPLSlide
{
    NSMutableArray *_nodesToDim;
    SCNNode *_daeIcon;
    SCNNode *_abcIcon;
}
@end

@implementation AAPLSlideLoadingDae

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Add some text
    self.textManager.title = @"Loading a 3D Scene";
    self.textManager.subtitle = @"Collada documents";
    
    _nodesToDim = [NSMutableArray array];
    
    [self.textManager addBullet:@"Geometries" atLevel:0];
    [self.textManager addBullet:@"Animations" atLevel:0];
    [_nodesToDim addObject:[self.textManager addBullet:@"Textures" atLevel:0]];
    [_nodesToDim addObject:[self.textManager addBullet:@"Lighting" atLevel:0]];
    [_nodesToDim addObject:[self.textManager addBullet:@"Cameras" atLevel:0]];
    [_nodesToDim addObject:[self.textManager addBullet:@"Skinning" atLevel:0]];
    [_nodesToDim addObject:[self.textManager addBullet:@"Morphing" atLevel:0]];
    
    // And an image resting on the ground
    _daeIcon = [SCNNode asc_planeNodeWithImageNamed:@"dae file icon" size:10 isLit:NO];
    _daeIcon.position = SCNVector3Make(6, 4.5, 1);
    
    [self.groundNode addChildNode:_daeIcon];
    
    _abcIcon = [SCNNode asc_planeNodeWithImageNamed:@"abc file icon" size:10 isLit:NO];
    _abcIcon.position = SCNVector3Make(6, 4.5, 30);
    [self.groundNode addChildNode:_abcIcon];
}

- (NSUInteger)numberOfSteps {
    return 2;
}

- (void)presentStepIndex:(NSUInteger)index withPresentationViewController:(AAPLPresentationViewController *)presentationViewController
{
    if(index == 1){
        presentationViewController.showsNewInSceneKitBadge = YES;
        
        [self.textManager flipOutTextOfType:AAPLTextTypeSubtitle];
        
        self.textManager.subtitle = @"Alembic documents";
        
        [self.textManager flipInTextOfType:AAPLTextTypeSubtitle];
        
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:0.5];
        for(SCNNode *node in _nodesToDim){
            node.opacity = 0.5;
        }
        _daeIcon.position = SCNVector3Make(6, 4.5, -30);
        _abcIcon.position = SCNVector3Make(6, 4.5, 1);
        [SCNTransaction commit];
    }
}


@end
