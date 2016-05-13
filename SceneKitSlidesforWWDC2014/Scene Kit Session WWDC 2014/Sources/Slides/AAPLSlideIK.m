/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Introduces the inverse kinematic API and shows an example.
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideIK : AAPLSlide <SCNSceneRendererDelegate>
{
    SCNIKConstraint *_ik;
    SCNLookAtConstraint *_lookAt;
    CAAnimation *_attack;
    SCNNode *_hero;
    SCNNode *_target;
    BOOL _ikActive;
    
    CFTimeInterval _animationStartTime;
    CFTimeInterval _animationDuration;
}
@end

@implementation AAPLSlideIK {
}

- (NSUInteger)numberOfSteps {
    return 9;
}

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController
{
    // Set the slide's title and subtitle and add some text
    self.textManager.title = @"Constraints";
    self.textManager.subtitle = @"SCNIKConstraint";
    
    [self.textManager addBullet:@"Inverse kinematics" atLevel:0];
    [self.textManager addBullet:@"Node chain" atLevel:0];
    [self.textManager addBullet:@"Target" atLevel:0];
    
    //load the hero
    _hero = [[self groundNode] asc_addChildNodeNamed:@"heroGroup" fromSceneNamed:@"Scenes.scnassets/hero/hero" withScale:12];
    _hero.position = SCNVector3Make(0, 0, 5);
    
    //hide the sword
    SCNNode *sword = [_hero childNodeWithName:@"sword" recursively:YES];
    sword.hidden = YES;

    //load attack animation
    NSString *path = [[NSBundle mainBundle] pathForResource:@"attack" ofType:@"dae" inDirectory:@"Scenes.scnassets/hero"];
    SCNSceneSource *source = [SCNSceneSource sceneSourceWithURL:[NSURL fileURLWithPath:path] options:nil];
    _attack = [source entryWithIdentifier:@"attackID" withClass:[CAAnimation class]];
    _attack.repeatCount = 0;
    _attack.fadeInDuration = 0.1;
    _attack.fadeOutDuration = 0.3;
    _attack.speed = 0.75;
    
    _attack.animationEvents = @[[SCNAnimationEvent animationEventWithKeyTime:0.55 block:^(CAAnimation *animation, id animatedObject, BOOL playingBackward) {
        if(_ikActive)
            [self destroyTarget];
    }]];
    
    _animationDuration = _attack.duration;
    
    //setup IK
    SCNNode *hand = [_hero childNodeWithName:@"Bip01_R_Hand" recursively:YES];
    SCNNode *clavicle = [_hero childNodeWithName:@"Bip01_R_Clavicle" recursively:YES];
    SCNNode *head = [_hero childNodeWithName:@"Bip01_Head" recursively:YES];
    
    
    _ik = [SCNIKConstraint inverseKinematicsConstraintWithChainRootNode:clavicle];
    hand.constraints = @[_ik];
    _ik.influenceFactor = 0.0;
    
    //add target
    _target = [SCNNode node];
    _target.position = SCNVector3Make(-4, 7, 10);
    _target.opacity = 0;
    _target.geometry = [SCNPlane planeWithWidth:2 height:2];
    _target.geometry.firstMaterial.diffuse.contents = @"target.png";
    [[self groundNode] addChildNode:_target];

    //look at
    _lookAt = [SCNLookAtConstraint lookAtConstraintWithTarget:_target];
    _lookAt.influenceFactor = 0;
    head.constraints = @[_lookAt];

    presentationViewController.presentationView.delegate = self;
}

- (void)renderer:(id <SCNSceneRenderer>)aRenderer didApplyAnimationsAtTime:(NSTimeInterval)time
{
    if (_ikActive)
    {
        // update the influence factor of the IK constraint based on the animation progress
        CGFloat currProgress = _attack.speed * (time - _animationStartTime) / _animationDuration;
        
        //clamp
        currProgress = MAX(0,currProgress);
        currProgress = MIN(1,currProgress);
        
        if(currProgress >= 1){
            _ikActive = NO;
        }
        
        float middle = 0.5f;
        float f;
        
        // smoothly increate from 0% to 50% then smoothly decrease from 50% to 100%
        if(currProgress > middle){
            f = (1.0-currProgress)/(1.0-middle);
        }
        else{
            f = currProgress/middle;
        }
        
        _ik.influenceFactor = f;
        _lookAt.influenceFactor = 1-f;
    }
}

- (void) moveTarget:(int) step
{
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:0.75];
    switch(step){
        case 0:
            _ik.targetPosition = [[self groundNode] convertPosition:SCNVector3Make(-70, 2, 50) toNode:nil];
            break;
        case 1:
            _target.position = SCNVector3Make(-1, 4, 10);
            _ik.targetPosition = [[self groundNode] convertPosition:SCNVector3Make(-30, -50, 50) toNode:nil];
            break;
        case 2:
            _target.position = SCNVector3Make(-5, 5, 10);
            _ik.targetPosition = [[self groundNode] convertPosition:SCNVector3Make(-70, 2, 50) toNode:nil];
            break;
    }
    _target.opacity = 1;
    [SCNTransaction commit];
}

- (void) destroyTarget
{
    _target.opacity = 0;
    SCNParticleSystem *ps = [SCNParticleSystem particleSystemNamed:@"explosion.scnp" inDirectory:nil];
    [_target addParticleSystem:ps];
}

- (void)presentStepIndex:(NSUInteger)index withPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    switch (index) {
        case 0:
            break;
        case 1://punch
            [_hero addAnimation:_attack forKey:@"attack"];
            _animationStartTime = CACurrentMediaTime();
            break;
        case 2://add target
            [self moveTarget:0];
            break;
        case 3://punch
            [_hero addAnimation:_attack forKey:@"attack"];
            _animationStartTime = CACurrentMediaTime();
            break;
        case 4://punch + IK
            _ikActive = YES;
            _lookAt.influenceFactor = 1;
            [_hero addAnimation:_attack forKey:@"attack"];
            _animationStartTime = CACurrentMediaTime();
            break;
        case 5://punch
            [self moveTarget:1];
            break;
        case 6://punch
            _ikActive = YES;
            [_hero addAnimation:_attack forKey:@"attack"];
            _animationStartTime = CACurrentMediaTime();
            break;
        case 7://punch
            [self moveTarget:2];
            break;
        case 8://punch
            _ikActive = YES;
            [_hero addAnimation:_attack forKey:@"attack"];
            _animationStartTime = CACurrentMediaTime();
            break;
    }
}

- (void)willOrderOutWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController
{
    //clear delegate
    presentationViewController.presentationView.delegate = nil;
}


@end
