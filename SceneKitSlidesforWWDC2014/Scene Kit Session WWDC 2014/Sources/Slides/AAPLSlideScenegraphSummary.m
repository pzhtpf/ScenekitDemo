/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Recaps the structure of the scene graph with an example.
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideSceneGraphSummary : AAPLSlide {
    SCNNode *_sunNode;
    SCNNode *_sunHaloNode;
    SCNNode *_earthNode;
    SCNNode *_earthGroupNode;
    SCNNode *_moonNode;
    SCNNode *_wireframeBoxNode;
}
@end

@implementation AAPLSlideSceneGraphSummary

- (NSUInteger)numberOfSteps {
    return 6;
}

- (void)presentStepIndex:(NSUInteger)index withPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    switch (index) {
        case 0:
            // Set the slide's title and subtitle
            self.textManager.title = @"Scene Graph";
            self.textManager.subtitle = @"Summary";
            break;
        case 1:
        {
            // A node that will help visualize the position of the stars
            _wireframeBoxNode = [SCNNode node];
            _wireframeBoxNode.rotation = SCNVector4Make(0, 1, 0, M_PI_4);
            _wireframeBoxNode.geometry = [SCNBox boxWithWidth:1 height:1 length:1 chamferRadius:0];
            _wireframeBoxNode.geometry.firstMaterial.diffuse.contents = [NSImage imageNamed:@"box_wireframe"];
            _wireframeBoxNode.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant; // no lighting
            _wireframeBoxNode.geometry.firstMaterial.doubleSided = YES; // double sided
            
            // Sun
            _sunNode = [SCNNode node];
            _sunNode.position = SCNVector3Make(0, 30, 0);
            [self.contentNode addChildNode:_sunNode];
            [_sunNode addChildNode:[_wireframeBoxNode copy]];
            
            // Earth-rotation (center of rotation of the Earth around the Sun)
            SCNNode *earthRotationNode = [SCNNode node];
            [_sunNode addChildNode:earthRotationNode];
            
            // Earth-group (will contain the Earth, and the Moon)
            _earthGroupNode = [SCNNode node];
            _earthGroupNode.position = SCNVector3Make(15, 0, 0);
            [earthRotationNode addChildNode:_earthGroupNode];
            
            // Earth
            _earthNode = [_wireframeBoxNode copy];
            _earthNode.position = SCNVector3Make(0, 0, 0);
            [_earthGroupNode addChildNode:_earthNode];
            
            // Rotate the Earth around the Sun
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
            animation.duration = 10.0;
            animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
            animation.repeatCount = FLT_MAX;
            [earthRotationNode addAnimation:animation forKey:@"earth rotation around sun"];
            
            // Rotate the Earth
            animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
            animation.duration = 1.0;
            animation.fromValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, 0)];
            animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
            animation.repeatCount = FLT_MAX;
            [_earthNode addAnimation:animation forKey:@"earth rotation"];
            break;
        }
        case 2:
        {
            // Moon-rotation (center of rotation of the Moon around the Earth)
            SCNNode *moonRotationNode = [SCNNode node];
            [_earthGroupNode addChildNode:moonRotationNode];
       
            // Moon
            _moonNode = [_wireframeBoxNode copy];
            _moonNode.position = SCNVector3Make(5, 0, 0);
            [moonRotationNode addChildNode:_moonNode];
          
            // Rotate the moon around the Earth
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
            animation.duration = 1.5;
            animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
            animation.repeatCount = FLT_MAX;
            [moonRotationNode addAnimation:animation forKey:@"moon rotation around earth"];
            
            // Rotate the moon
            animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
            animation.duration = 1.5;
            animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
            animation.repeatCount = FLT_MAX;
            [_moonNode addAnimation:animation forKey:@"moon rotation"];
            break;
        }
        case 3:
        {
            // Add geometries (spheres) to represent the stars
            _sunNode.geometry = [SCNSphere sphereWithRadius:2.5];
            _earthNode.geometry = [SCNSphere sphereWithRadius:1.5];
            _moonNode.geometry = [SCNSphere sphereWithRadius:0.75];
            
            // Add a textured plane to represent Earth's orbit
            SCNNode *earthOrbit = [SCNNode node];
            earthOrbit.opacity = 0.4;
            earthOrbit.geometry = [SCNPlane planeWithWidth:31 height:31];
            earthOrbit.geometry.firstMaterial.diffuse.contents = @"Scenes.scnassets/earth/orbit.png";
            earthOrbit.geometry.firstMaterial.diffuse.mipFilter = SCNFilterModeLinear;
            earthOrbit.rotation = SCNVector4Make(1, 0, 0, -M_PI_2);
            earthOrbit.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant; // no lighting
            [_sunNode addChildNode:earthOrbit];
            break;
        }
        case 4:
        {
            // Add a halo to the Sun (a simple textured plane that does not write to depth)
            _sunHaloNode = [SCNNode node];
            _sunHaloNode.geometry = [SCNPlane planeWithWidth:30 height:30];
            _sunHaloNode.rotation = SCNVector4Make(1, 0, 0, self.pitch * M_PI / 180.0);
            _sunHaloNode.geometry.firstMaterial.diffuse.contents = @"Scenes.scnassets/earth/sun-halo.png";
            _sunHaloNode.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant; // no lighting
            _sunHaloNode.geometry.firstMaterial.writesToDepthBuffer = NO; // do not write to depth
            _sunHaloNode.opacity = 0.2;
            [_sunNode addChildNode:_sunHaloNode];
            
            // Add materials to the planets
            _earthNode.geometry.firstMaterial.diffuse.contents = @"Scenes.scnassets/earth/earth-diffuse-mini.jpg";
            _earthNode.geometry.firstMaterial.emission.contents = @"Scenes.scnassets/earth/earth-emissive-mini.jpg";
            _earthNode.geometry.firstMaterial.specular.contents = @"Scenes.scnassets/earth/earth-specular-mini.jpg";
            _moonNode.geometry.firstMaterial.diffuse.contents = @"Scenes.scnassets/earth/moon.jpg";
            _sunNode.geometry.firstMaterial.multiply.contents = @"Scenes.scnassets/earth/sun.jpg";
            _sunNode.geometry.firstMaterial.diffuse.contents = @"Scenes.scnassets/earth/sun.jpg";
            _sunNode.geometry.firstMaterial.multiply.intensity = 0.5;
            _sunNode.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
            
            _sunNode.geometry.firstMaterial.multiply.wrapS =
            _sunNode.geometry.firstMaterial.diffuse.wrapS  =
            _sunNode.geometry.firstMaterial.multiply.wrapT =
            _sunNode.geometry.firstMaterial.diffuse.wrapT  = SCNWrapModeRepeat;
            
            _earthNode.geometry.firstMaterial.locksAmbientWithDiffuse =
            _moonNode.geometry.firstMaterial.locksAmbientWithDiffuse  =
            _sunNode.geometry.firstMaterial.locksAmbientWithDiffuse   = YES;
            
            _earthNode.geometry.firstMaterial.shininess = 0.1;
            _earthNode.geometry.firstMaterial.specular.intensity = 0.5;
            _moonNode.geometry.firstMaterial.specular.contents = [NSColor grayColor];
            
            // Achieve a lava effect by animating textures
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"contentsTransform"];
            animation.duration = 10.0;
            animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DConcat(SCNMatrix4MakeTranslation(0, 0, 0), SCNMatrix4MakeScale(3, 3, 3))];
            animation.toValue = [NSValue valueWithCATransform3D:CATransform3DConcat(SCNMatrix4MakeTranslation(1, 0, 0), SCNMatrix4MakeScale(3, 3, 3))];
            animation.repeatCount = FLT_MAX;
            [_sunNode.geometry.firstMaterial.diffuse addAnimation:animation forKey:@"sun-texture"];
            
            animation = [CABasicAnimation animationWithKeyPath:@"contentsTransform"];
            animation.duration = 30.0;
            animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DConcat(SCNMatrix4MakeTranslation(0, 0, 0), SCNMatrix4MakeScale(5, 5, 5))];
            animation.toValue = [NSValue valueWithCATransform3D:CATransform3DConcat(SCNMatrix4MakeTranslation(1, 0, 0), SCNMatrix4MakeScale(5, 5, 5))];
            animation.repeatCount = FLT_MAX;
            [_sunNode.geometry.firstMaterial.multiply addAnimation:animation forKey:@"sun-texture2"];
            break;
        }
        case 5:
        {
            // We will turn off all the lights in the scene and add a new light
            // to give the impression that the Sun lights the scene
            SCNNode *lightNode = [SCNNode node];
            lightNode.light = [SCNLight light];
            lightNode.light.color = [NSColor blackColor]; // initially switched off
            lightNode.light.type = SCNLightTypeOmni;
            [_sunNode addChildNode:lightNode];
            
            // Configure attenuation distances because we don't want to light the floor
            lightNode.light.attenuationEndDistance = 20.0;
            lightNode.light.attenuationStartDistance = 19.5;
            
            // Animation
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1];
            {
                [presentationViewController updateLightingWithIntensities:@[@0.0]];
                lightNode.light.color = [NSColor whiteColor]; // switch on
                //[presentationViewController updateLightingWithIntensities:@[@0.0]]; //switch off all the other lights
                _sunHaloNode.opacity = 0.5; // make the halo stronger
            }
            [SCNTransaction commit];
            break;
        }
    }
}

@end
