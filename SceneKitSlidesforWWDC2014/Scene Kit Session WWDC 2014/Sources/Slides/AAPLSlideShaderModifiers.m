/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Illustrates how shader modifiers work with several examples.
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideShaderModifiers : AAPLSlide
@end

@implementation AAPLSlideShaderModifiers {
    SCNNode *_planeNode;
    SCNNode *_sphereNode;
    SCNNode *_torusNode;
    SCNNode *_xRayNode;
    SCNNode *_virusNode;
}

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Set the slide's title and subtitle and add some text
    self.textManager.title = @"Shader Modifiers";
    
    [self.textManager addBullet:@"Inject custom GLSL code at specific stages" atLevel:0];
    [self.textManager addBullet:@"Combines with SceneKit’s shaders" atLevel:0];
    [self.textManager addBullet:@"Refer to WWDC 2013 presentation" atLevel:0];
    
    [self.textManager addEmptyLine];
    [self.textManager addCode:@"aMaterial.#shaderModifiers# = @{ <Entry Point> : <GLSL Code> };"];
}

- (NSUInteger)numberOfSteps {
    return 2;
}

- (NSArray *) lightIntensities
{
    return @[@0.0,@0.3,@1.0];
}

- (void)presentStepIndex:(NSUInteger)index withPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    [SCNTransaction begin];
    
    switch (index) {
        case 1:
        {
            [self.textManager flipOutTextOfType:AAPLTextTypeCode];
            [self.textManager flipOutTextOfType:AAPLTextTypeSubtitle];
            [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
            
            self.textManager.subtitle = @"Entry points";
            
            SCNNode *textNode = [SCNNode asc_labelNodeWithString:@"Geometry" size:AAPLLabelSizeNormal isLit:NO];
            textNode.position = SCNVector3Make(-13.5, 9, 0);
            [self.contentNode addChildNode:textNode];
            textNode = [SCNNode asc_labelNodeWithString:@"Surface" size:AAPLLabelSizeNormal isLit:NO];
            textNode.position = SCNVector3Make(-5.3, 9, 0);
            [self.contentNode addChildNode:textNode];
            textNode = [SCNNode asc_labelNodeWithString:@"Lighting" size:AAPLLabelSizeNormal isLit:NO];
            textNode.position = SCNVector3Make(2, 9, 0);
            [self.contentNode addChildNode:textNode];
            textNode = [SCNNode asc_labelNodeWithString:@"Fragment" size:AAPLLabelSizeNormal isLit:NO];
            textNode.position = SCNVector3Make(9.5, 9, 0);
            [self.contentNode addChildNode:textNode];
            
            [self.textManager flipInTextOfType:AAPLTextTypeSubtitle];
            
            
            //add spheres
            SCNSphere *sphere = [SCNSphere sphereWithRadius:3];
            sphere.firstMaterial.diffuse.contents = [NSColor redColor];
            sphere.firstMaterial.specular.contents = [NSColor whiteColor];
            sphere.firstMaterial.specular.intensity = 1.0;
            
            sphere.firstMaterial.shininess = 0.1;
            sphere.firstMaterial.reflective.contents = @"envmap.jpg";
            sphere.firstMaterial.fresnelExponent = 2;
            
            //GEOMETRY
            SCNNode *node = [SCNNode node];
            node.geometry = [sphere copy];
            node.position = SCNVector3Make(-12,3,0);
            node.geometry.shaderModifiers = @{SCNShaderModifierEntryPointGeometry : @"// Waves Modifier\n"
                                              "uniform float Amplitude = 0.2;\n"
                                              "uniform float Frequency = 5.0;\n"
                                              "vec2 nrm = _geometry.position.xz;\n"
                                              "float len = length(nrm)+0.0001; // for robustness\n"
                                              "nrm /= len;\n"
                                              "float a = len + Amplitude*sin(Frequency * _geometry.position.y + u_time * 10.0);\n"
                                              "_geometry.position.xz = nrm * a;\n"};
            
            [self.groundNode addChildNode:node];
            
            // SURFACE
            node = [SCNNode node];
            node.geometry = [sphere copy];
            node.position = SCNVector3Make(-4,3,0);
            

            NSString *surfaceModifier = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sm_surf" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];
            
            node.rotation = SCNVector4Make(1, 0, 0, -M_PI_4);
            node.geometry.firstMaterial = [node.geometry.firstMaterial copy];
            node.geometry.firstMaterial.lightingModelName = SCNLightingModelLambert;
            node.geometry.shaderModifiers = @{SCNShaderModifierEntryPointSurface : surfaceModifier};
            [self.groundNode addChildNode:node];
            
            // LIGHTING
            node = [SCNNode node];
            node.geometry = [sphere copy];
            node.position = SCNVector3Make(4,3,0);
            
            NSString *lightingModifier = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sm_light" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];
            node.geometry.shaderModifiers = @{ SCNShaderModifierEntryPointLightingModel : lightingModifier };
            
            [self.groundNode addChildNode:node];
            
            // FRAGMENT
            node = [SCNNode node];
            node.geometry = [sphere copy];
            node.position = SCNVector3Make(12,3,0);
            
            node.geometry.firstMaterial = [node.geometry.firstMaterial copy];
            node.geometry.firstMaterial.diffuse.contents = [NSColor greenColor];
            
            
            NSString *modifier = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sm_frag" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];
            node.geometry.shaderModifiers = @{ SCNShaderModifierEntryPointFragment: modifier };
            
            [self.groundNode addChildNode:node];
            
            
            //redraw forever
            presentationViewController.presentationView.playing = YES;
            presentationViewController.presentationView.loops = YES;
        }
            break;
    }
    
    [SCNTransaction commit];
}

- (void)willOrderOutWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    presentationViewController.presentationView.playing = NO;
    presentationViewController.cameraNode.position = SCNVector3Make(0, 0, 0);
}

@end
