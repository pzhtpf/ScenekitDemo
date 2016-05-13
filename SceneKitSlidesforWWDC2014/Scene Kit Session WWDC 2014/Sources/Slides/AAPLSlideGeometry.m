/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Explains how geometries are made.
 */

#import <GLKit/GLKMath.h>

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideGeometry : AAPLSlide
@end

@implementation AAPLSlideGeometry {
    SCNNode *_teapotNodeForPositionsAndNormals;
    SCNNode *_teapotNodeForUVs;
    SCNNode *_teapotNodeForMaterials;
    SCNNode *_positionsVisualizationNode;
    SCNNode *_normalsVisualizationNode;
}

- (NSUInteger)numberOfSteps {
    return 1;
}

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Set the slide's title and subtile and add some text
    self.textManager.title = @"Node Attributes";
    self.textManager.subtitle = @"SCNGeometry";
    
    [self.textManager addBullet:@"Triangles" atLevel:0];
    [self.textManager addBullet:@"Vertices" atLevel:0];
    [self.textManager addBullet:@"Normals" atLevel:0];
    [self.textManager addBullet:@"UVs" atLevel:0];
    [self.textManager addBullet:@"Materials" atLevel:0];
    
    // We create a container for several versions of the teapot model
    // - one teapot to show positions and normals
    // - one teapot to show texture coordinates
    // - one teapot to show materials
    SCNNode *allTeapotsNode = [SCNNode node];
    [self.groundNode addChildNode:allTeapotsNode];
    
    
    _teapotNodeForPositionsAndNormals = [allTeapotsNode asc_addChildNodeNamed:@"TeapotLowRes" fromSceneNamed:@"Scenes.scnassets/teapots/teapotLowRes" withScale:17];
    _teapotNodeForUVs = [allTeapotsNode asc_addChildNodeNamed:@"Teapot" fromSceneNamed:@"Scenes.scnassets/teapots/teapotMaterial" withScale:17];
    _teapotNodeForMaterials = [allTeapotsNode asc_addChildNodeNamed:@"teapotMaterials" fromSceneNamed:@"Scenes.scnassets/teapots/teapotMaterial" withScale:17];
    
    _teapotNodeForPositionsAndNormals.position = SCNVector3Make(4, 0, 0);
    _teapotNodeForUVs.position = SCNVector3Make(4, 0, 0);
    _teapotNodeForMaterials.position = SCNVector3Make(4, 0, 0);
    
    [_teapotNodeForMaterials childNodesPassingTest:^BOOL(SCNNode *child, BOOL *stop) {
        for (SCNMaterial *material in child.geometry.materials) {
            material.multiply.contents = @"Scenes.scnassets/teapots/UVs.png";
            material.multiply.wrapS = SCNWrapModeRepeat;
            material.multiply.wrapT = SCNWrapModeRepeat;
//            material.reflective.contents = [NSColor whiteColor];
//            material.reflective.intensity = 3.0;
//            material.fresnelExponent = 3.0;
        }
        return NO;
    }];
    
    // Animate the teapots (rotate forever)
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    rotationAnimation.duration = 40.0;
    rotationAnimation.repeatCount = FLT_MAX;
    rotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    
    [_teapotNodeForPositionsAndNormals addAnimation:rotationAnimation forKey:nil];
    [_teapotNodeForUVs addAnimation:rotationAnimation forKey:nil];
    [_teapotNodeForMaterials addAnimation:rotationAnimation forKey:nil];
    
    // Load the "explode" shader modifier and add it to the geometry
    NSString *explodeShaderPath = [[NSBundle mainBundle] pathForResource:@"explode" ofType:@"shader"];
    NSString *explodeShaderSource = [NSString stringWithContentsOfFile:explodeShaderPath encoding:NSUTF8StringEncoding error:nil];
    _teapotNodeForPositionsAndNormals.geometry.shaderModifiers = @{ SCNShaderModifierEntryPointGeometry : explodeShaderSource};
    
    // Build nodes that will help visualize the vertices (position and normal)
    [self buildVisualizationsOfNode:_teapotNodeForPositionsAndNormals
                      positionsNode:&_positionsVisualizationNode
                        normalsNode:&_normalsVisualizationNode];
    
    _normalsVisualizationNode.castsShadow = NO;
    
    [_teapotNodeForMaterials addChildNode:_positionsVisualizationNode];
    [_teapotNodeForMaterials addChildNode:_normalsVisualizationNode];
}

- (void)presentStepIndex:(NSUInteger)index withPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    switch (index) {
        case 0:
        {
            // Show what needs to be shown, hide what needs to be hidden
            _positionsVisualizationNode.opacity = 1.0;
            _normalsVisualizationNode.opacity = 1.0;
            _teapotNodeForUVs.opacity = 0.0;
            _teapotNodeForMaterials.opacity = 1.0;
            
            _teapotNodeForPositionsAndNormals.opacity = 0.0;
            
            // Don't highlight bullets (this is useful when we go back from the next slide)
            [self.textManager highlightBulletAtIndex:NSNotFound];
            break;
        }
        case 1:
        {
            [self.textManager highlightBulletAtIndex:0];
            
            // Animate the "explodeValue" parameter (uniform) of the shader modifier
            CABasicAnimation *explodeAnimation = [CABasicAnimation animationWithKeyPath:@"explodeValue"];
            explodeAnimation.duration = 2.0;
            explodeAnimation.repeatCount = FLT_MAX;
            explodeAnimation.autoreverses = YES;
            explodeAnimation.toValue = @20.0;
            explodeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [_teapotNodeForPositionsAndNormals.geometry addAnimation:explodeAnimation forKey:@"explode"];
            break;
        }
        case 2:
        {
            [self.textManager highlightBulletAtIndex:1];
            
            // Remove the "explode" animation and freeze the "explodeValue" parameter to the current value
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.0];
            {
                NSNumber *explodeValue = [_teapotNodeForPositionsAndNormals.presentationNode.geometry valueForKey:@"explodeValue"];
                [_teapotNodeForPositionsAndNormals.geometry setValue:explodeValue forKey:@"explodeValue"];
                [_teapotNodeForPositionsAndNormals.geometry removeAnimationForKey:@"explode"];
            }
            [SCNTransaction commit];
            
            // Animate to a "no explosion" state and show the positions on completion
            void (^showPositions)(void) = ^{
                [SCNTransaction begin];
                [SCNTransaction setAnimationDuration:1.0];
                {
                    _positionsVisualizationNode.opacity = 1.0;
                }
                [SCNTransaction commit];
            };
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            [SCNTransaction setCompletionBlock:showPositions];
            {
                [_teapotNodeForPositionsAndNormals.geometry setValue:@0.0 forKey:@"explodeValue"];
            }
            [SCNTransaction commit];
            break;
        }
        case 3:
        {
            [self.textManager highlightBulletAtIndex:2];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            {
                _positionsVisualizationNode.opacity = 0.0;
                _normalsVisualizationNode.opacity = 1.0;
            }
            [SCNTransaction commit];
            break;
        }
        case 4:
        {
            [self.textManager highlightBulletAtIndex:3];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0];
            {
                _normalsVisualizationNode.hidden = YES;
                _teapotNodeForUVs.opacity = 1.0;
                _teapotNodeForPositionsAndNormals.opacity = 0.0;
            }
            [SCNTransaction commit];
            break;
        }
        case 5:
        {
            [self.textManager highlightBulletAtIndex:4];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0];
            {
                _teapotNodeForUVs.hidden = YES;
                _teapotNodeForMaterials.opacity = 1.0;
            }
            [SCNTransaction commit];
            break;
        }
    }
}

- (void)buildVisualizationsOfNode:(SCNNode *)node positionsNode:(SCNNode * __strong *)verticesNode normalsNode:(SCNNode * __strong *)normalsNode {
    // A material that will prevent the nodes from being lit
    SCNMaterial *noLightingMaterial = [SCNMaterial material];
    noLightingMaterial.lightingModelName = SCNLightingModelConstant;
    
    SCNMaterial *normalMaterial = [SCNMaterial material];
    normalMaterial.lightingModelName = SCNLightingModelConstant;
    normalMaterial.diffuse.contents = [NSColor redColor];
    
    // Create nodes to represent the vertex and normals
    SCNNode *positionVisualizationNode = [SCNNode node];
    SCNNode *normalsVisualizationNode = [SCNNode node];
    
    // Retrieve the vertices and normals from the model
    SCNGeometrySource *positionSource = [node.geometry geometrySourcesForSemantic:SCNGeometrySourceSemanticVertex][0];
    SCNGeometrySource *normalSource = [node.geometry geometrySourcesForSemantic:SCNGeometrySourceSemanticNormal][0];
    
    // Get vertex and normal bytes
    float *vertexBuffer = (float *)positionSource.data.bytes;
    float *normalBuffer = (float *)normalSource.data.bytes;
    
    NSInteger stride = [positionSource dataStride] / sizeof(float);
    NSInteger normalOffset = [normalSource dataOffset] / sizeof(float);
    
    // Iterate and create geometries to represent the positions and normals
    for (NSUInteger i = 0; i < positionSource.vectorCount; i++) {
        // One new node per normal/vertex
        SCNNode *vertexNode = [SCNNode node];
        SCNNode *normalNode = [SCNNode node];
        
        // Attach one sphere per vertex
        SCNSphere *sphere = [SCNSphere sphereWithRadius:0.5];
        sphere.geodesic = YES;
        sphere.segmentCount = 0; // use a small segment count for better performances
        sphere.firstMaterial = noLightingMaterial;
        vertexNode.geometry = sphere;
        
        // And one pyramid per normal
        SCNPyramid *pyramid = [SCNPyramid pyramidWithWidth:0.1 height:0.1 length:8];
        pyramid.firstMaterial = normalMaterial;
        normalNode.geometry = pyramid;
        
        // Place the position node
        vertexNode.position = SCNVector3Make(vertexBuffer[i * stride], vertexBuffer[i * stride + 1], vertexBuffer[i * stride + 2]);
        
        // Place the normal node
        normalNode.position = vertexNode.position;
        
        // Orientate the normal
        GLKVector3 up = GLKVector3Make(0, 0, 1);
        GLKVector3 normalVec = GLKVector3Make(normalBuffer[i * stride+normalOffset], normalBuffer[i * stride + 1+normalOffset], normalBuffer[i * stride + 2+normalOffset]);
        GLKVector3 axis = GLKVector3Normalize(GLKVector3CrossProduct(up, normalVec));
        float dotProduct = GLKVector3DotProduct(up, normalVec);
        normalNode.rotation = SCNVector4Make(axis.x, axis.y, axis.z, acos(dotProduct));
        
        // Add the nodes to their parent
        [positionVisualizationNode addChildNode:vertexNode];
        [normalsVisualizationNode addChildNode:normalNode];
    }
    
    // We must flush the transaction in order to make sure that the parametric geometries (sphere and pyramid)
    // are up-to-date before flattening the nodes
    [SCNTransaction flush];
    
    // Flatten the visualization nodes so that they can be rendered with 1 draw call
    *verticesNode = [positionVisualizationNode flattenedClone];
    *normalsNode = [normalsVisualizationNode flattenedClone];
}

@end
