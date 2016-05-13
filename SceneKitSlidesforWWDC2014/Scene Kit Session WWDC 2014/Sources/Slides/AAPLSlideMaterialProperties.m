/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Illustrates how the different material properties affect the appearance of an object.
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideMaterialProperties : AAPLSlide
@end

@implementation AAPLSlideMaterialProperties {
    SCNNode *_earthNode;
    SCNNode *_cloudsNode;
    
    SCNVector3 _cameraOriginalPosition;
}

- (NSUInteger)numberOfSteps {
    return 1;
}

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController
{
    // Set the slide's title and add some code
    self.textManager.title = @"Material Properties";
    
    [self.textManager addBullet:@"Diffuse" atLevel:0];
    [self.textManager addBullet:@"Ambient" atLevel:0];
    [self.textManager addBullet:@"Specular" atLevel:0];
    [self.textManager addBullet:@"Normal" atLevel:0];
    [self.textManager addBullet:@"Reflective" atLevel:0];
    [self.textManager addBullet:@"Emission" atLevel:0];
    [self.textManager addBullet:@"Transparent" atLevel:0];
    [self.textManager addBullet:@"Multiply" atLevel:0];
    
    
    SCNNode *imageNode = [SCNNode asc_planeNodeWithImageNamed:@"earth-diffuse-mini.jpg" size:3.0 isLit:NO];
    imageNode.position = SCNVector3Make(-7, 12.7, 0);
    imageNode.castsShadow = NO;
    [self.contentNode addChildNode:imageNode];
    
    imageNode = [SCNNode asc_planeNodeWithImageNamed:@"earth-specular-mini.jpg" size:3.0 isLit:NO];
    imageNode.position = SCNVector3Make(-7, 9.4, 0);
    imageNode.castsShadow = NO;
    [self.contentNode addChildNode:imageNode];
    
    imageNode = [SCNNode asc_planeNodeWithImageNamed:@"earth-bump-mini.png" size:3.0 isLit:NO];
    imageNode.position = SCNVector3Make(-7, 7.5, 0);
    imageNode.castsShadow = NO;
    [self.contentNode addChildNode:imageNode];
    
    imageNode = [SCNNode asc_planeNodeWithImageNamed:@"earth-emissive-mini.jpg" size:3.0 isLit:NO];
    imageNode.position = SCNVector3Make(-7, 4.5, 0);
    imageNode.castsShadow = NO;
    [self.contentNode addChildNode:imageNode];
    
    imageNode = [SCNNode asc_planeNodeWithImageNamed:@"cloudsTransparency-mini.png" size:3.0 isLit:NO];
    imageNode.position = SCNVector3Make(-7, 2.8, 0);
    imageNode.castsShadow = NO;
    [self.contentNode addChildNode:imageNode];
    
    // Create a node for Earth and another node to display clouds
    _earthNode = [SCNNode node];
    _earthNode.position = SCNVector3Make(6, 7.2, -2);
    _earthNode.geometry = [SCNSphere sphereWithRadius:7.2];
    
    _cloudsNode = [SCNNode node];
    _cloudsNode.geometry = [SCNSphere sphereWithRadius:7.9];
    
    [self.groundNode addChildNode:_earthNode];
    [_earthNode addChildNode:_cloudsNode];
    
    // Initially hide everything
    _earthNode.opacity = 1.0;
    _cloudsNode.opacity = 0.5;
    
    _earthNode.geometry.firstMaterial.ambient.intensity = 1;
    _earthNode.geometry.firstMaterial.normal.intensity = 1;
    _earthNode.geometry.firstMaterial.reflective.intensity = 0.2;
    _earthNode.geometry.firstMaterial.reflective.contents = [NSColor whiteColor];
    _earthNode.geometry.firstMaterial.fresnelExponent = 3.0;
    
    
    
    _earthNode.geometry.firstMaterial.emission.intensity = 1;
    _earthNode.geometry.firstMaterial.diffuse.contents = @"Scenes.scnassets/earth/earth-diffuse.jpg";
    
    _earthNode.geometry.firstMaterial.shininess = 0.1;
    _earthNode.geometry.firstMaterial.specular.contents = @"Scenes.scnassets/earth/earth-specular.jpg";
    _earthNode.geometry.firstMaterial.specular.intensity = 0.8;
    
    _earthNode.geometry.firstMaterial.normal.contents = @"Scenes.scnassets/earth/earth-bump.png";
    _earthNode.geometry.firstMaterial.normal.intensity = 1.3;
    
    _earthNode.geometry.firstMaterial.emission.contents = @"Scenes.scnassets/earth/earth-emissive.jpg";
    //_earthNode.geometry.firstMaterial.reflective.intensity = 0.3;
    _earthNode.geometry.firstMaterial.emission.intensity = 1.0;
    
    
    // This effect can also be achieved with an image with some transparency set as the contents of the 'diffuse' property
    _cloudsNode.geometry.firstMaterial.transparent.contents = @"Scenes.scnassets/earth/cloudsTransparency.png";
    _cloudsNode.geometry.firstMaterial.transparencyMode = SCNTransparencyModeRGBZero;
    
    
    // Use a shader modifier to display an environment map independently of the lighting model used
    _earthNode.geometry.shaderModifiers = @{ SCNShaderModifierEntryPointFragment :
                                                 @" _output.color.rgb -= _surface.reflective.rgb * _lightingContribution.diffuse;"
                                             @"_output.color.rgb += _surface.reflective.rgb;" };
    
    // Add animations
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    rotationAnimation.duration = 40.0;
    rotationAnimation.repeatCount = FLT_MAX;
    rotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    [_earthNode addAnimation:rotationAnimation forKey:nil];
    
    rotationAnimation.duration = 100.0;
    [_cloudsNode addAnimation:rotationAnimation forKey:nil];
    
    
    //animate light
    SCNNode *lightHandleNode = [SCNNode node];
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeDirectional;
    lightNode.light.castsShadow = YES;
    [lightHandleNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:-M_PI*2 z:0 duration:12]]];
    [lightHandleNode addChildNode:lightNode];
    
    [_earthNode addChildNode:lightHandleNode];
}

- (void)presentStepIndex:(NSUInteger)index withPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1.0];
    
    switch (index) {
        case 0:
            break;
    }
    [SCNTransaction commit];
}

@end
