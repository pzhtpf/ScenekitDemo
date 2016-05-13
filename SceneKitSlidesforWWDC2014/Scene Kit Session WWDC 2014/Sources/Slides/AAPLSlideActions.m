/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  Present actions.
  
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideActions : AAPLSlide
@end

@implementation AAPLSlideActions {
    SCNNode *_animatedNode;
}

- (NSUInteger)numberOfSteps {
    return 5;
}

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Set the slide's title and subtitle and add some code
    self.textManager.title = @"Actions";
    self.textManager.subtitle = @"SCNAction";
    
    [self.textManager addBullet:@"Easy to sequence, group, and repeat" atLevel:0];
    [self.textManager addBullet:@"Limited to SCNNode" atLevel:0];
    [self.textManager addBullet:@"Same programming model as SpriteKit" atLevel:0];
}

- (void)presentStepIndex:(NSUInteger)index withPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Animate by default
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:0];
    
    switch (index) {
        case 0:
            // Initially hide the torus
            _animatedNode.opacity = 0.0;
            break;
        case 1:
            [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
            [self.textManager addEmptyLine];
            [self.textManager addCode:@"// Rotate forever\n"
             @"[aNode #runAction:#\n"
             @"  [SCNAction repeatActionForever:\n"
             @"  [SCNAction rotateByX:0 y:M_PI*2 z:0 duration:5.0]]];"];
            
            [self.textManager flipInTextOfType:AAPLTextTypeCode];
            
            break;
        case 2:
            [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
            [self.textManager flipOutTextOfType:AAPLTextTypeCode];
            
            [self.textManager addBullet:@"Move" atLevel:0];
            [self.textManager addBullet:@"Rotate" atLevel:0];
            [self.textManager addBullet:@"Scale" atLevel:0];
            [self.textManager addBullet:@"Opacity" atLevel:0];
            [self.textManager addBullet:@"Remove" atLevel:0];
            [self.textManager addBullet:@"Wait" atLevel:0];
            [self.textManager addBullet:@"Custom block" atLevel:0];
            
            [self.textManager flipInTextOfType:AAPLTextTypeBullet];
            break;
        case 3:
            [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
            [self.textManager addBullet:@"Directly updates the presentation tree" atLevel:0];
            [self.textManager flipInTextOfType:AAPLTextTypeBullet];
            break;
        case 4:
        {
            [self.textManager addBullet:@"node.position ≠ node.presentationNode.position" atLevel:0];
            
            //labels
            SCNNode *label1 = [self.textManager addText:@"Action" atLevel:0];
            label1.position = SCNVector3Make(-15, 3, 0);
            SCNNode *label2 = [self.textManager addText:@"Animation" atLevel:0];
            label2.position = SCNVector3Make(-15, -2, 0);
            
            //animation
            SCNNode *animNode = [SCNNode node];
            CGFloat cubeSize = 4;
            animNode.position = SCNVector3Make(-5, cubeSize/2, 0);
    
            SCNGeometry *cube = [SCNBox boxWithWidth:cubeSize height:cubeSize length:cubeSize chamferRadius:0.05 * cubeSize];
                
            cube.firstMaterial.diffuse.contents = @"texture.png";
            cube.firstMaterial.diffuse.mipFilter = YES;
            cube.firstMaterial.diffuse.wrapS = SCNWrapModeRepeat;
            cube.firstMaterial.diffuse.wrapT = SCNWrapModeRepeat;
            animNode.geometry = cube;
            [[self contentNode] addChildNode:animNode];
            
            [SCNTransaction begin];

            
            __block SCNNode *animPosIndicator = nil;
            SCNAnimationEvent *startEvt = [SCNAnimationEvent animationEventWithKeyTime:0 block:^(CAAnimation *animation, id animatedObject, BOOL playingBackward) {
                [SCNTransaction begin];
                [SCNTransaction setAnimationDuration:0];
                animPosIndicator.position = SCNVector3Make(10, animPosIndicator.position.y, animPosIndicator.position.z);
                [SCNTransaction commit];
            }];
            SCNAnimationEvent *endEvt = [SCNAnimationEvent animationEventWithKeyTime:1 block:^(CAAnimation *animation, id animatedObject, BOOL playingBackward) {
                [SCNTransaction begin];
                [SCNTransaction setAnimationDuration:0];
                animPosIndicator.position = SCNVector3Make(-5, animPosIndicator.position.y, animPosIndicator.position.z);
                [SCNTransaction commit];
            }];
            
            CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"position.x"];
            anim.duration = 3;
            anim.fromValue = @0.0;
            anim.toValue = @15.0;
            anim.additive = YES;
            anim.autoreverses = YES;
            anim.animationEvents = @[startEvt, endEvt];
            anim.repeatCount = MAXFLOAT;
            [animNode addAnimation:anim forKey:nil];
            
            //action
            SCNNode *actionNode = [SCNNode node];
            actionNode.position = SCNVector3Make(-5, cubeSize*1.5 + 1, 0);
            actionNode.geometry = cube;
            
            [[self contentNode] addChildNode:actionNode];
            
            SCNAction *mv = [SCNAction moveByX:15 y:0 z:0 duration:3];
            
            [actionNode runAction:[SCNAction repeatActionForever:[SCNAction sequence:@[mv, [mv reversedAction]]]]];

            //position indicator
            SCNNode *positionIndicator = [SCNNode node];
            positionIndicator.geometry = [SCNCylinder cylinderWithRadius:0.5 height:0.01];
            positionIndicator.geometry.firstMaterial.diffuse.contents = [NSColor redColor];
            positionIndicator.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
            positionIndicator.eulerAngles = SCNVector3Make(M_PI_2, 0, 0);
            positionIndicator.position = SCNVector3Make(0, 0, cubeSize*0.5);
            [actionNode addChildNode:positionIndicator];
            
            //anim pos indicator
            animPosIndicator = [positionIndicator clone];
            animPosIndicator.position = SCNVector3Make(5, cubeSize/2,cubeSize*0.5);
            [[self contentNode] addChildNode:animPosIndicator];
            
            [SCNTransaction commit];
            
            break;
        }
    }

    [SCNTransaction commit];
}

@end
