/*
 <codex>
 <abstract>Performance tips when dealing with lights.</abstract>
 </codex>
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideLighting : AAPLSlide
@end

@implementation AAPLSlideLighting {
    SCNNode *_roomNode;
}

- (NSUInteger)numberOfSteps {
    return 4;
}

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Set the slide's title and subtitle and add some text
    self.textManager.title = @"Performance";
    self.textManager.subtitle = @"Lighting";
    
    [self.textManager addBullet:@"Minimize the number of lights" atLevel:0];
    [self.textManager addBullet:@"Prefer static than dynamic shadows" atLevel:0];
    [self.textManager addBullet:@"Use material's \"multiply\" property" atLevel:0];
}

- (void)presentStepIndex:(NSUInteger)index withPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    switch (index) {
        case 1:
        {
            // Load the scene
            SCNNode *intermediateNode = [SCNNode node];
            intermediateNode.position = SCNVector3Make(0.0, 0.1, -24.5);
            _roomNode = [intermediateNode asc_addChildNodeNamed:@"Mesh" fromSceneNamed:@"Scenes.scnassets/cornell-box/cornell-box.dae" withScale:15];
            [self.contentNode addChildNode:intermediateNode];
            
            // Hide the light maps for now
            for (SCNMaterial *material in _roomNode.geometry.materials) {
                material.multiply.intensity = 0.0;
                material.lightingModelName = SCNLightingModelBlinn;
            }
            
            // Animate the point of view with an implicit animation.
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:2.0];
            
            [SCNTransaction setCompletionBlock:^{
                
                //animate the object
                [intermediateNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2*M_PI z:0 duration:10]]];
                
            }];
            {
                presentationViewController.cameraHandle.position = [presentationViewController.cameraHandle convertPosition:SCNVector3Make(0, +5, -30) toNode:presentationViewController.cameraHandle.parentNode];
                presentationViewController.cameraPitch.rotation = SCNVector4Make(1, 0, 0, -M_PI_4 * 0.2);
            }
            [SCNTransaction commit];
            break;
        }
        case 2:
        {
            // Remove the lighting by using a constant lighing model (no lighting)
            for (SCNMaterial *material in _roomNode.geometry.materials)
                material.lightingModelName = SCNLightingModelConstant;
            break;
        }
        case 3:
        {
            // Activate the light maps smoothly
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            {
                for (SCNMaterial *material in _roomNode.geometry.materials){
                    material.multiply.intensity = 1.0;
                }
            }
            [SCNTransaction commit];
            break;
        }
    }
}

- (void)willOrderOutWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Remove the animation from the camera and restore (animate) its position before leaving this slide
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:0.0];
    {
        [presentationViewController.cameraNode removeAnimationForKey:@"myAnim"];
        presentationViewController.cameraNode.position = presentationViewController.cameraNode.presentationNode.position;
    }
    [SCNTransaction commit];
    
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1.0];
    {
        presentationViewController.cameraNode.position = SCNVector3Make(0, 0, 0);
    }
    [SCNTransaction commit];
}

@end
