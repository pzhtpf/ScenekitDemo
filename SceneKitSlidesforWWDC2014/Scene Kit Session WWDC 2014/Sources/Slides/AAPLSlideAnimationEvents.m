/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  This slide is about animation events.
  
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

typedef NS_ENUM(NSInteger, AAPLCharacterAnimation) {
	AAPLCharacterAnimationAttack = 0,
	AAPLCharacterAnimationWalk,
	AAPLCharacterAnimationDie,
    AAPLCharacterAnimationCount
};

@interface AAPLSlideAnimationEvents : AAPLSlide
@end

@implementation AAPLSlideAnimationEvents {
    SCNNode *_heroSkeletonNode;
    CAAnimation *_animations[AAPLCharacterAnimationCount];
}

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Load the character and add it to the scene
    SCNNode *heroNode = [self.groundNode asc_addChildNodeNamed:@"bossGroup" fromSceneNamed:@"Scenes.scnassets/boss/boss.dae" withScale:0.0];
    
#define SCALE 0.015
    heroNode.scale = SCNVector3Make(SCALE, SCALE, SCALE);
    heroNode.position = SCNVector3Make(3.0, 0.0, 15.0);
    
    [self.groundNode addChildNode:heroNode];
    
    // Convert sceneTime-based animations into systemTime-based animations.
    // Animations loaded from DAE files will play according to the `currentTime` property of the scene renderer if this one is playing
    // (see the SCNSceneRenderer protocol). Here we don't play a specific DAE so we want the animations to animate as soon as we add
    // them to the scene (i.e have them to play according the time of the system when the animation was added).
    
    _heroSkeletonNode = [heroNode childNodeWithName:@"skeleton" recursively:YES];
    
    for (NSString *animationKey in _heroSkeletonNode.animationKeys) {
        // Find all the animations. Make them system time based and repeat forever.
        // And finally replace the old animation.
        
        CAAnimation *animation = [_heroSkeletonNode animationForKey:animationKey];
        animation.usesSceneTimeBase = NO;
        animation.repeatCount = FLT_MAX;
        
        [_heroSkeletonNode addAnimation:animation forKey:animationKey];
    }
    
    // Load other animations so that we will use them later
    [self setAnimation:AAPLCharacterAnimationAttack withAnimationNamed:@"attackID" fromSceneNamed:@"Scenes.scnassets/boss/boss_attack"];
	[self setAnimation:AAPLCharacterAnimationDie withAnimationNamed:@"DeathID" fromSceneNamed:@"Scenes.scnassets/hero/death"];
	[self setAnimation:AAPLCharacterAnimationWalk withAnimationNamed:@"WalkID" fromSceneNamed:@"Scenes.scnassets/hero/walk"];
}

- (NSUInteger)numberOfSteps {
    return 8;
}

- (void)presentStepIndex:(NSUInteger)index withPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    switch (index) {
        case 0:
        {
            self.textManager.title = @"Animation Extensions";
            [self.textManager addBullet:@"SCNAnimationEvent" atLevel:0];
            [self.textManager addBullet:@"Smooth transitions" atLevel:0];
            
            SCNNode *node = [self.textManager addCode:
             @"#SCNAnimationEvent# *anEvent = \n"
             @"  [SCNAnimationEvent #animationEventWithKeyTime:#0.6 #block:#aBlock]; \n"
             @"anAnimation.#animationEvents# = @[anEvent, anotherEvent];"];
            
            node.position = SCNVector3Make(node.position.x, node.position.y+0.75, node.position.z);
            
            // Warm up NSSound by playing an empty sound.
            // Otherwise the first sound may take some time to start playing and will be desynchronised.
            [[NSSound soundNamed:@"bossaggro"] play];
            break;
        }
        case 1:
        {
            // Trigger the attack animation
            [_heroSkeletonNode addAnimation:_animations[AAPLCharacterAnimationAttack] forKey:@"attack"];
            break;
        }
        case 2:
        {
            [self.textManager fadeOutTextOfType:AAPLTextTypeCode];
            SCNNode * node = [self.textManager addCode:
             @"\n\n\n\n\n\n"
             @"anAnimation.#fadeInDuration# = 0.0;\n"
             @"anAnimation.#fadeOutDuration# = 0.0;"];
            node.position = SCNVector3Make(node.position.x, node.position.y+0.55, node.position.z);
        }
            break;
        case 3:
        case 4:
        {
            _animations[AAPLCharacterAnimationAttack].fadeInDuration = 0;
            _animations[AAPLCharacterAnimationAttack].fadeOutDuration = 0;
            // Trigger the attack animation
			[_heroSkeletonNode addAnimation:_animations[AAPLCharacterAnimationAttack] forKey:@"attack"];
            break;
        }
        case 5:
        {
            {
                [self.textManager fadeOutTextOfType:AAPLTextTypeCode];
                SCNNode * node = [self.textManager addCode:
                 @"\n\n\n\n\n\n"
                 @"anAnimation.fadeInDuration = #0.3#;\n"
                 @"anAnimation.fadeOutDuration = #0.3#;"];
                node.position = SCNVector3Make(node.position.x, node.position.y+0.55, node.position.z);
            }
            break;
        }
        case 6:
        case 7:
        {
            _animations[AAPLCharacterAnimationAttack].fadeInDuration = 0.3;
            _animations[AAPLCharacterAnimationAttack].fadeOutDuration = 0.3;
            // Trigger the attack animation
            [_heroSkeletonNode addAnimation:_animations[AAPLCharacterAnimationAttack] forKey:@"attack"];
            
        }
            break;
    }
}

- (void)setAnimation:(AAPLCharacterAnimation)index withAnimationNamed:(NSString *)animationName fromSceneNamed:(NSString *)sceneName {
    // Load the DAE using SCNSceneSource in order to be able to retrieve the animation by its identifier
	NSURL *url = [[NSBundle mainBundle] URLForResource:sceneName withExtension:@"dae"];
    SCNSceneSource *sceneSource = [SCNSceneSource sceneSourceWithURL:url options:@{SCNSceneSourceAnimationImportPolicyKey : SCNSceneSourceAnimationImportPolicyPlay}];
    
	CAAnimation *animation = [sceneSource entryWithIdentifier:animationName withClass:[CAAnimation class]];
    _animations[index] = animation;
    
    // Blend animations for smoother transitions
    [animation setFadeInDuration:0.3];
    [animation setFadeOutDuration:0.3];
    
    if (index == AAPLCharacterAnimationDie) {
        // We want the "death" animation to remain at its final state at the end of the animation
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeBoth;
        
        // Create animation events and set them to the animation
        SCNAnimationEventBlock swipeSoundEventBlock = ^(CAAnimation *animation, id animatedObject, BOOL playingBackward) {
            [[NSSound soundNamed:@"swipe"] play];
        };
        
        SCNAnimationEventBlock deathSoundEventBlock = ^(CAAnimation *animation, id animatedObject, BOOL playingBackward) {
            [[NSSound soundNamed:@"death"] play];
        };
        
        animation.animationEvents = @[[SCNAnimationEvent animationEventWithKeyTime:0.0 block:swipeSoundEventBlock],
                                      [SCNAnimationEvent animationEventWithKeyTime:0.3 block:deathSoundEventBlock]];
    }
    
    if (index == AAPLCharacterAnimationAttack) {
        // Create an animation event and set it to the animation
        SCNAnimationEventBlock swordSoundEventBlock = ^(CAAnimation *animation, id animatedObject, BOOL playingBackward) {
            [[NSSound soundNamed:@"attack4"] play];
        };
        
        animation.animationEvents = @[[SCNAnimationEvent animationEventWithKeyTime:0.4 block:swordSoundEventBlock]];
    }
    
    if (index == AAPLCharacterAnimationWalk) {
        // Repeat the walk animation 3 times
        animation.repeatCount = 3;
        
        // Create an animation event and set it to the animation
        SCNAnimationEventBlock stepSoundEventBlock = ^(CAAnimation *animation, id animatedObject, BOOL playingBackward) {
            [[NSSound soundNamed:@"walk"] play];
        };
        
        animation.animationEvents = @[[SCNAnimationEvent animationEventWithKeyTime:0.2 block:stepSoundEventBlock],
                                      [SCNAnimationEvent animationEventWithKeyTime:0.7 block:stepSoundEventBlock]];
    }
}

@end
