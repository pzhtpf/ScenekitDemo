/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  Introduces the constraints API and shows severals examples.
  
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideConstraints : AAPLSlide
@end

@implementation AAPLSlideConstraints {
    SCNNode *_ballNode;
}

- (NSUInteger)numberOfSteps {
    return 8;
}

- (void)presentStepIndex:(NSUInteger)index withPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    switch (index) {
        case 0:
            // Set the slide's title and subtitle and add some text
            self.textManager.title = @"Constraints";
            self.textManager.subtitle = @"SCNConstraint";
            
            [self.textManager addBullet:@"Applied sequentially at render time" atLevel:0];
            [self.textManager addBullet:@"Only affect presentation values" atLevel:0];
            
            [self.textManager addCode:@"aNode.#constraints# = @[aConstraint, anotherConstraint, ...];"];
            
            // Tweak the near clipping plane of the spot light to get a precise shadow map
            [presentationViewController.spotLight.light setAttribute:@(10) forKey:SCNLightShadowNearClippingKey];
            break;
        case 1:
        {
            // Remove previous text
            [self.textManager flipOutTextOfType:AAPLTextTypeSubtitle];
            [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
            [self.textManager flipOutTextOfType:AAPLTextTypeCode];
            
//            SCNTransformConstraint *aConstraint = [SCNTransformConstraint transformConstraintInWorldSpace:YES withBlock:
//                           ^SCNMatrix4(SCNNode *node, SCNMatrix4 transform) {
//                               transform.m43 = 0.0;
//                               return transform;
//                           }];
            
            // Add new text
            self.textManager.subtitle = @"SCNTransformConstraint";
            [self.textManager addBullet:@"Custom constraint on a node's transform" atLevel:0];
            [self.textManager addCode:@"aConstraint = [SCNTransformConstraint #transformConstraintInWorldSpace:#YES \n"
             @"                                                            #withBlock:# \n"
             @"               ^SCNMatrix4(SCNNode *node, SCNMatrix4 transform) { \n"
             @"                   transform.m43 = 0.0; \n"
             @"                   return transform; \n"
             @"               }];"];
            
            [self.textManager flipInTextOfType:AAPLTextTypeSubtitle];
            [self.textManager flipInTextOfType:AAPLTextTypeBullet];
            [self.textManager flipInTextOfType:AAPLTextTypeCode];
            break;
        }
        case 2:
        {
            // Remove previous text
            [self.textManager flipOutTextOfType:AAPLTextTypeSubtitle];
            [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
            [self.textManager flipOutTextOfType:AAPLTextTypeCode];
            
            // Add new text
            self.textManager.subtitle = @"SCNLookAtConstraint";
            [self.textManager addBullet:@"Makes a node to look at another node" atLevel:0];
            [self.textManager addCode:@"nodeA.constraints = @[SCNLookAtConstraint #lookAtConstraintWithTarget#:nodeB];"];
            
            [self.textManager flipInTextOfType:AAPLTextTypeSubtitle];
            [self.textManager flipInTextOfType:AAPLTextTypeBullet];
            [self.textManager flipInTextOfType:AAPLTextTypeCode];
            break;
        }
        case 3:
        {
            // Setup the scene
            [self setupLookAtScene];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            {
                // Dim the text and move back a little bit
                self.textManager.textNode.opacity = 0.5;
                presentationViewController.cameraHandle.position = [presentationViewController.cameraNode convertPosition:SCNVector3Make(0, 0, 5.0) toNode:presentationViewController.cameraHandle.parentNode];
            }
            [SCNTransaction commit];
            break;
        }
        case 4:
        {
            // Add constraints to the arrows
            SCNNode *container = [self.contentNode childNodeWithName:@"arrowContainer" recursively:YES];
            
            // "Look at" constraint
            SCNLookAtConstraint *constraint = [SCNLookAtConstraint lookAtConstraintWithTarget:_ballNode];
            
            NSUInteger i = 0;
            for (SCNNode *arrow in container.childNodes) {
                double delayInSeconds = 0.1 * i++; // desynchronize the different animations
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                    [SCNTransaction begin];
                    [SCNTransaction setAnimationDuration:1.0];
                    {
                        // Animate to the result of applying the constraint
                        ((SCNNode *)arrow.childNodes[0]).rotation = SCNVector4Make(0, 1, 0, M_PI_2);
                        [arrow setConstraints:@[constraint]];
                    }
                    [SCNTransaction commit];
                });
            }
            break;
        }
        case 5:
        {
            // Create a keyframe animation to move the ball
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
            animation.keyTimes = @[@0.0, @(1/8.0), @(2/8.0), @(3/8.0), @(4/8.0), @(5/8.0), @(6/8.0), @(7/8.0), @1.0];
            animation.values = @[[NSValue valueWithSCNVector3:SCNVector3Make(0, 0.0, 0)],
                                 [NSValue valueWithSCNVector3:SCNVector3Make(20.0, 0.0, 20.0)],
                                 [NSValue valueWithSCNVector3:SCNVector3Make(40.0, 0.0, 0)],
                                 [NSValue valueWithSCNVector3:SCNVector3Make(20.0, 0.0, -20.0)],
                                 [NSValue valueWithSCNVector3:SCNVector3Make(0, 0.0, 0)],
                                 [NSValue valueWithSCNVector3:SCNVector3Make(-20.0, 0.0, 20.0)],
                                 [NSValue valueWithSCNVector3:SCNVector3Make(-40.0, 0.0, 0)],
                                 [NSValue valueWithSCNVector3:SCNVector3Make(-20.0, 0.0, -20.0)],
                                 [NSValue valueWithSCNVector3:SCNVector3Make(0, 0.0, 0)]];
            animation.calculationMode = kCAAnimationCubicPaced; // smooth the movement between keyframes
            animation.repeatCount = FLT_MAX;
            animation.duration = 10.0;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            [_ballNode addAnimation:animation forKey:nil];
            
            // Rotate the ball to give the illusion of a rolling ball
            // We need two animations to do that:
            // - one rotation to orient the ball in the right direction
            // - one rotation to spin the ball
            animation = [CAKeyframeAnimation animationWithKeyPath:@"rotation"];
            animation.keyTimes = @[@0.0, @(0.7/8.0), @(1/8.0), @(2/8.0), @(3/8.0), @(3.3/8.0), @(4.7/8.0), @(5/8.0), @(6/8.0), @(7/8.0),@(7.3/8.0), @1.0];
            animation.values = @[[NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI_4)],
                                 [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI_4)],
                                 [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI_2)],
                                 [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI)],
                                 [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI + M_PI_2)],
                                 [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2 - M_PI_4)],
                                 [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2 - M_PI_4)],
                                 [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2 - M_PI_2)],
                                 [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI)],
                                 [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI - M_PI_2)],
                                 [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI_4)],
                                 [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI_4)]];
            animation.repeatCount = FLT_MAX;
            animation.duration = 10.0;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            [_ballNode addAnimation:animation forKey:nil];
            
            CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
            rotationAnimation.duration = 1.0;
            rotationAnimation.repeatCount = FLT_MAX;
            rotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(1, 0, 0, M_PI * 2)];
            [_ballNode.childNodes[1] addAnimation:rotationAnimation forKey:nil];
            break;
        }
        case 6:
        {
            // Add a constraint to the camera
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            {
                SCNLookAtConstraint *constraint = [SCNLookAtConstraint lookAtConstraintWithTarget:_ballNode];
                constraint.gimbalLockEnabled = YES;
                presentationViewController.cameraNode.constraints = @[constraint];
            }
            [SCNTransaction commit];
            break;
        }
        case 7:
        {
            // Add a constraint to the light
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            {
                SCNNode *cameraTarget = [self.contentNode childNodeWithName:@"cameraTarget" recursively:YES];
                SCNLookAtConstraint *constraint = [SCNLookAtConstraint lookAtConstraintWithTarget:cameraTarget];
             
                presentationViewController.spotLight.constraints = @[constraint];
            }
            [SCNTransaction commit];
            break;
        }
    }
}

- (void)didOrderInWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
}

- (void)willOrderOutWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1.0];
    {
        presentationViewController.cameraNode.constraints = nil;
        presentationViewController.spotLight.constraints = nil;
    }
    [SCNTransaction commit];
}

- (void)setupLookAtScene {
    SCNNode *intermediateNode = [SCNNode node];
    intermediateNode.scale = SCNVector3Make(0.5, 0.5, 0.5);
    intermediateNode.position = SCNVector3Make(0, 0, 10);
    [self.contentNode addChildNode:intermediateNode];
    
    SCNMaterial *ballMaterial = [SCNMaterial material];
    ballMaterial.diffuse.contents = @"Scenes.scnassets/pool/pool_8.png";
    ballMaterial.specular.contents = [NSColor whiteColor];
    ballMaterial.shininess = 0.9; // shinny
    ballMaterial.reflective.contents = @"color_envmap";
    ballMaterial.reflective.intensity = 0.5;
    
    // Node hierarchy for the ball :
    //   _ballNode
    //  |__ cameraTarget      : the target for the "look at" constraint
    //  |__ ballRotationNode  : will rotate to animate the rolling ball
    //      |__ ballPivotNode : will own the geometry and will be rotated so that the "8" faces the camera at the beginning
    
    _ballNode = [SCNNode node];
    _ballNode.rotation = SCNVector4Make(0, 1, 0, M_PI_4);
    [intermediateNode addChildNode:_ballNode];
    
    SCNNode *cameraTarget = [SCNNode node];
    cameraTarget.name = @"cameraTarget";
    cameraTarget.position = SCNVector3Make(0, 6, 0);
    [_ballNode addChildNode:cameraTarget];
    
    SCNNode *ballRotationNode = [SCNNode node];
    ballRotationNode.position = SCNVector3Make(0, 4, 0);
    [_ballNode addChildNode:ballRotationNode];
    
    SCNNode *ballPivotNode = [SCNNode node];
    ballPivotNode.geometry = [SCNSphere sphereWithRadius:4.0];
    ballPivotNode.geometry.firstMaterial = ballMaterial;
    ballPivotNode.rotation = SCNVector4Make(0, 1, 0, M_PI_2);
    [ballRotationNode addChildNode:ballPivotNode];
    
    SCNMaterial *arrowMaterial = [SCNMaterial material];
    arrowMaterial.diffuse.contents = [NSColor whiteColor];
    arrowMaterial.reflective.contents = [NSImage imageNamed:@"chrome"];
    
    SCNNode *arrowContainer = [SCNNode node];
    arrowContainer.name = @"arrowContainer";
    [intermediateNode addChildNode:arrowContainer];
    
    NSBezierPath *arrowPath = [NSBezierPath asc_arrowBezierPathWithBaseSize:NSMakeSize(6,2)
                                                                    tipSize:NSMakeSize(3, 5)
                                                                     hollow:0.5
                                                                   twoSides:NO];
    // Create the arrows
    for (NSUInteger i = 0; i < 11; i++) {
        SCNNode *arrowNode = [SCNNode node];
        arrowNode.position = SCNVector3Make(cos(M_PI * i / 10.0) * 20.0, 3 + 18.5 * sin(M_PI * i / 10.0), 0);
        
        SCNShape *arrowGeometry = [SCNShape shapeWithPath:arrowPath extrusionDepth:1];
        arrowGeometry.chamferRadius = 0.2;
        
        SCNNode *arrowSubNode = [SCNNode node];
        arrowSubNode.geometry = arrowGeometry;
        arrowSubNode.geometry.firstMaterial = arrowMaterial;
        arrowSubNode.pivot = SCNMatrix4MakeTranslation(0, 2.5, 0); // place the pivot (center of rotation) at the middle of the arrow
        arrowSubNode.rotation = SCNVector4Make(0, 0, 1, M_PI_2);
        
        [arrowNode addChildNode:arrowSubNode];
        [arrowContainer addChildNode:arrowNode];
    }
}

@end
