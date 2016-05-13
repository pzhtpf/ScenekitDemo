/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Presents the Xcode SceneKit editor.
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideTechniques : AAPLSlide
{
    SCNNode *_plistGroup;
    SCNNode *_pass3;
    SCNNode *_pass2;
    SCNNode *_pass1;
}

@end

typedef enum {
    StepIntro,
    Step1Pass,
    Step3Passes,
    Step3PassesConnected,
    StepFiles,
    StepFilesPlist,
    StepCode,
    StepSample,
    StepCount
    
} TechniqueSteps;

@implementation AAPLSlideTechniques

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Set the slide's title and add some text
    self.textManager.title = @"Multi-Pass Effects";
    self.textManager.subtitle = @"SCNTechnique";
    
    [self.textManager addBullet:@"Multi-pass effects" atLevel:0];
    [self.textManager addBullet:@"Post processing" atLevel:0];

    [self.textManager addBullet:@"Chain passes" atLevel:0];
    [self.textManager addBullet:@"Set and animate shader uniforms in Objective-C" atLevel:0];
}

- (NSUInteger)numberOfSteps{
    return StepCount;
}

- (void)presentStepIndex:(NSUInteger)index withPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    switch (index) {
        case StepIntro:
            break;
        case StepCode:
            [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
            [_plistGroup removeFromParentNode];

            [self.textManager addEmptyLine];
            [self.textManager addCode:@"// Load a technique\nSCNTechnique *technique = [SCNTechnique #techniqueWithDictionary#:aDictionary];\n\n"
             "// Chain techniques\ntechnique = [SCNTechnique #techniqueBySequencingTechniques#:@[t1, t2 ...];\n\n"
             "// Set a technique\naSCNView.#technique# = technique;"];
            [self.textManager flipInTextOfType:AAPLTextTypeBullet];
            [self.textManager flipInTextOfType:AAPLTextTypeCode];
            break;
        case StepFiles:
        {
            [_pass2 removeFromParentNode];

            [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
            [self.textManager addBullet:@"Load from Plist" atLevel:0];
            [self.textManager flipInTextOfType:AAPLTextTypeCode];
            
            _plistGroup = [SCNNode node];
            [self.contentNode addChildNode:_plistGroup];
            
            //add plist icon
            SCNNode *node = [SCNNode asc_planeNodeWithImageNamed:@"plist.png" size:8 isLit:YES];
            node.position = SCNVector3Make(0, 3.7, 10);
            [_plistGroup addChildNode:node];
            
            //add plist icon
            node = [SCNNode asc_planeNodeWithImageNamed:@"vsh.png" size:3 isLit:YES];
            for(int i = 0; i<5; i++){
                node = [node clone];
                node.position = SCNVector3Make(6, 1.4, 10 - i);
                [_plistGroup addChildNode:node];
            }
            
            node = [SCNNode asc_planeNodeWithImageNamed:@"fsh.png" size:3 isLit:YES];
            for(int i = 0; i<5; i++){
                node = [node clone];
                node.position = SCNVector3Make(9, 1.4, 10 - i);
                [_plistGroup addChildNode:node];
            }
        }
            break;
        case StepFilesPlist:
        {
            //add plist icon
            SCNNode *node = [SCNNode asc_planeNodeWithImageNamed:@"technique.png" size:9 isLit:YES];
            node.position = SCNVector3Make(0, 3.5, 10.1);
            node.opacity = 0.0;
            [_plistGroup addChildNode:node];
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.75];
            node.position = SCNVector3Make(0, 3.5, 11);
            node.opacity = 1.0;
            [SCNTransaction commit];
        }
            break;
        case Step1Pass:
        {
            [self.textManager flipOutTextOfType:AAPLTextTypeBullet];

            SCNNode *node = [SCNNode asc_planeNodeWithImageNamed:@"pass1.png" size:15 isLit:YES];
            node.position = SCNVector3Make(0, 3.5, 10.1);
            node.opacity = 0.0;
            [self.contentNode addChildNode:node];
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.75];
            node.position = SCNVector3Make(0, 3.5, 11);
            node.opacity = 1.0;
            [SCNTransaction commit];
            _pass1 = node;
        }
            break;
        case Step3Passes:
        {
            [_pass1 removeFromParentNode];
            _pass2 = [SCNNode node];
            _pass2.opacity = 0.0;
            _pass2.position = SCNVector3Make(0, 3.5, 6);
            
            SCNNode *node = [SCNNode asc_planeNodeWithImageNamed:@"pass2.png" size:8 isLit:YES];
            node.position = SCNVector3Make(-8, 0, 0);
            [_pass2 addChildNode:node];
            
            node = [SCNNode asc_planeNodeWithImageNamed:@"pass3.png" size:8 isLit:YES];
            node.position = SCNVector3Make(0, 0, 0);
            [_pass2 addChildNode:node];
            
            node = [SCNNode asc_planeNodeWithImageNamed:@"pass4.png" size:8 isLit:YES];
            node.position = SCNVector3Make(8, 0, 0);
            [_pass2 addChildNode:node];
            
            [self.contentNode addChildNode:_pass2];
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.75];
            _pass2.position = SCNVector3Make(0, 3.5, 9);
            _pass2.opacity = 1.0;
            [SCNTransaction commit];
        }
            break;
        case Step3PassesConnected:
        {
            [self.textManager addEmptyLine];
            [self.textManager addBullet:@"Connect pass inputs/outputs" atLevel:0];
            
            
            SCNNode *node = [SCNNode asc_planeNodeWithImageNamed:@"link.png" size:8.75 isLit:YES];
            node.position = SCNVector3Make(0.01, -2, 0);
            node.opacity = 0;
            [_pass2 addChildNode:node];
            
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.75];
            SCNNode *n = _pass2.childNodes[0];
            n.position = SCNVector3Make(-7.5, -0.015, 0);

            n = _pass2.childNodes[2];
            n.position = SCNVector3Make(7.5, 0.02, 0);

            node.opacity = 1;

            [SCNTransaction commit];
        }
            break;
        case StepSample:
        {
            [self.textManager flipOutTextOfType:AAPLTextTypeCode];
            [self.textManager flipOutTextOfType:AAPLTextTypeSubtitle];
            [self.textManager setSubtitle:@"Example—simple depth of field"];
            [self.textManager flipInTextOfType:AAPLTextTypeCode];
            
            _pass3 = [SCNNode node];
            
            SCNNode *node = [SCNNode asc_planeNodeWithImageNamed:@"pass5.png" size:15 isLit:YES];
            node.position = SCNVector3Make(-3, 5, 10.1);
            node.opacity = 0.0;
            [_pass3 addChildNode:node];

            SCNNode *t0 = [SCNNode asc_planeNodeWithImageNamed:@"technique0.png" size:4 isLit:NO];
            t0.position = SCNVector3Make(-8.5, 1.5, 10.1);
            t0.opacity = 0.0;
            [_pass3 addChildNode:t0];
            
            SCNNode *t1 = [SCNNode asc_planeNodeWithImageNamed:@"technique1.png" size:4 isLit:NO];
            t1.position = SCNVector3Make(-3.6, 1.5, 10.1);
            t1.opacity = 0.0;
            [_pass3 addChildNode:t1];
            
            SCNNode *t2 = [SCNNode asc_planeNodeWithImageNamed:@"technique2.png" size:4 isLit:NO];
            t2.position = SCNVector3Make(1.4, 1.5, 10.1);
            t2.opacity = 0.0;
            [_pass3 addChildNode:t2];
        
            SCNNode *t3 = [SCNNode asc_planeNodeWithImageNamed:@"technique3.png" size:8 isLit:NO];
            t3.position = SCNVector3Make(8, 5, 10.1);
            t3.opacity = 0.0;
            [_pass3 addChildNode:t3];
            
            [[self contentNode] addChildNode:_pass3];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.75];
            node.opacity = 1.0;
            t0.opacity = 1.0;
            t1.opacity = 1.0;
            t2.opacity = 1.0;
            t3.opacity = 1.0;
            [SCNTransaction commit];
        }
            break;
    }
}
@end
