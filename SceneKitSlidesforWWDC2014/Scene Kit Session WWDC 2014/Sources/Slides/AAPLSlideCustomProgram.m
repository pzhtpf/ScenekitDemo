/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  Shows how Scene Kit allows one to use custom GLSL programs.
  
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

#import <OpenGL/gl3.h>
#import <GLKit/GLKMath.h>

@interface AAPLSlideCustomProgram : AAPLSlide
@end

@implementation AAPLSlideCustomProgram {
    SCNNode *_torusNode;
}

- (NSUInteger)numberOfSteps {
    return 2;
}

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Set the slide's title and subtitle and add some text
    self.textManager.title = @"Custom Program";
    self.textManager.subtitle = @"SCNProgram";
    
    [self.textManager addBullet:@"Custom GLSL code per material" atLevel:0];
    [self.textManager addBullet:@"Replaces SceneKit’s rendering" atLevel:0];
    [self.textManager addBullet:@"Geometry attributes are provided" atLevel:0];
    [self.textManager addBullet:@"Transform uniforms are also provided" atLevel:0];
    
    // Add a torus and animate it
    SCNNode *intermediateNode = [SCNNode node];
    intermediateNode.position = SCNVector3Make(8, 8, 4);
    intermediateNode.rotation = SCNVector4Make(1, 0, 0, -M_PI_2);
    
    [self.groundNode addChildNode:intermediateNode];
    
    _torusNode = [intermediateNode asc_addChildNodeNamed:@"torus" fromSceneNamed:@"Scenes.scnassets/torus/torus" withScale:10];
    _torusNode.name = @"object";
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    rotationAnimation.duration = 10.0;
    rotationAnimation.repeatCount = FLT_MAX;
    rotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 0, 1, M_PI * 2)];
    [_torusNode addAnimation:rotationAnimation forKey:nil];
}

// The following method will create a new SCNGeometry instance by duplicating its vertices in 3 instances and assigning each one of them texture coordinates representing the 3 corners of a triangle, containing entirely a quad of canonical (0..1) coordinates.
// This is usually done by generating the four vertices of the quad but with a triangle we have less 1 less vertex per quad to transform (at the expense of lost fragment bandwith).
//
// v0 (-1.0, -1.0) ---------  v1 (3.0, -1.0)
//                 |===   /
//                 |===  /
//                 |=== /
//                 |   /
//                 |  /
//                 | /
//                 |/
//                 v2 (-1.0, 3.0)
//
// The geometry is created by interleaving vertices data, allowing a more efficient vertex pulling by the graphics card.

typedef struct {
    GLKVector3 morphPositionSrc;
    GLKVector3 morphPositionDst;
    GLKVector2 texCoord;
} AAPLMorphVertex;

- (SCNGeometry *)spriteGeometryWithRadius:(CGFloat)radius sourceGeometry:(SCNGeometry *)geometry {
    SCNGeometrySource *vertexSource = [geometry geometrySourcesForSemantic:SCNGeometrySourceSemanticVertex][0];
    
    NSInteger vectorCount = vertexSource.vectorCount;
    NSInteger vertexCount = vectorCount * 3;
    
    UInt8 *srcVertices = (UInt8 *)vertexSource.data.bytes + vertexSource.dataOffset;
    NSInteger srcStride = vertexSource.dataStride;
    
    AAPLMorphVertex *dstVertices = malloc(sizeof(AAPLMorphVertex) * vertexCount);
    
    for (NSUInteger i = 0; i < vectorCount; ++i) {
        AAPLMorphVertex *v0 = &dstVertices[i * 3];
        AAPLMorphVertex *v1 = &dstVertices[i * 3 + 1];
        AAPLMorphVertex *v2 = &dstVertices[i * 3 + 2];
        
        GLKVector3 position = *(GLKVector3 *)(srcVertices + srcStride * i);
        
        // source position
        v0->morphPositionSrc = position;
        v1->morphPositionSrc = position;
        v2->morphPositionSrc = position;
        
        // compute the destination position, a random point on a sphere of specified radius
        position = GLKVector3Make((2.f * (float)rand() / RAND_MAX - 1.f), (2.f * (float)rand() / RAND_MAX - 1.f), (2.f * (float)rand() / RAND_MAX - 1.f));
        position = GLKVector3MultiplyScalar(GLKVector3Normalize(position), radius);
        
        v0->morphPositionDst = position;
        v1->morphPositionDst = position;
        v2->morphPositionDst = position;
        
        // texture coordinates
        v0->texCoord = GLKVector2Make(-1.f, -1.f);
        v1->texCoord = GLKVector2Make( 3.f, -1.f);
        v2->texCoord = GLKVector2Make(-1.f,  3.f);
    }
    
    // Create three geometry sources : position, normal and texture coordinates
    NSData *interleavedVertexData = [NSData dataWithBytesNoCopy:dstVertices length:vertexCount * sizeof(AAPLMorphVertex) freeWhenDone:YES];
    
    SCNGeometrySource *positionSource = [SCNGeometrySource geometrySourceWithData:interleavedVertexData
                                                                         semantic:SCNGeometrySourceSemanticVertex
                                                                      vectorCount:vectorCount
                                                                  floatComponents:YES
                                                              componentsPerVector:3
                                                                bytesPerComponent:sizeof(float)
                                                                       dataOffset:offsetof(AAPLMorphVertex, morphPositionSrc)
                                                                       dataStride:sizeof(AAPLMorphVertex)];
    
    SCNGeometrySource *normalSource = [SCNGeometrySource geometrySourceWithData:interleavedVertexData
                                                                       semantic:SCNGeometrySourceSemanticNormal
                                                                    vectorCount:vectorCount
                                                                floatComponents:YES
                                                            componentsPerVector:3
                                                              bytesPerComponent:sizeof(float)
                                                                     dataOffset:offsetof(AAPLMorphVertex, morphPositionDst)
                                                                     dataStride:sizeof(AAPLMorphVertex)];
    
    SCNGeometrySource *texCoordSource = [SCNGeometrySource geometrySourceWithData:interleavedVertexData
                                                                         semantic:SCNGeometrySourceSemanticTexcoord
                                                                      vectorCount:vectorCount
                                                                  floatComponents:YES
                                                              componentsPerVector:2
                                                                bytesPerComponent:sizeof(float)
                                                                       dataOffset:offsetof(AAPLMorphVertex, texCoord)
                                                                       dataStride:sizeof(AAPLMorphVertex)];
    
    // Create the indices (each vertex is used only once per triangle)
    GLint *indices = (GLint *)malloc(sizeof(GLint) * vertexCount);
    for (GLint i = 0; i < vertexCount; ++i)
        indices[i] = i;
    
    NSData *indicesData = [NSData dataWithBytesNoCopy:indices length:vertexCount * sizeof(GLint) freeWhenDone:YES];
    
    // Create a geometry element from the indices
    SCNGeometryElement *elements = [SCNGeometryElement geometryElementWithData:indicesData
                                                                 primitiveType:SCNGeometryPrimitiveTypeTriangles
                                                                primitiveCount:vertexCount / 3
                                                                 bytesPerIndex:4];
    
    // Create the geometry from the three geometry sources and the geometry element
    SCNGeometry *newGeometry = [SCNGeometry geometryWithSources:@[positionSource, normalSource, texCoordSource]
                                                       elements:@[elements]];
    
    // Use the same materials
    newGeometry.materials = geometry.materials;
    
    return newGeometry;
}

- (void)presentStepIndex:(NSUInteger)index withPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    switch (index) {
        case 1:
        {
            // Create the supporting geometry and replace the existing one
            _torusNode = [self.groundNode childNodeWithName:@"object" recursively:YES];
            _torusNode.geometry = [self spriteGeometryWithRadius:8. sourceGeometry:_torusNode.geometry];
            
            // Create a custom program using a vertex and a fragment shader
            NSURL *vertexShaderURL = [[NSBundle mainBundle] URLForResource:@"CustomProgram" withExtension:@"vsh"];
            NSURL *fragmentShaderURL = [[NSBundle mainBundle] URLForResource:@"CustomProgram" withExtension:@"fsh"];
            
            SCNProgram *program = [SCNProgram program];
            program.opaque = NO;
            program.vertexShader = [NSString stringWithContentsOfURL:vertexShaderURL encoding:NSASCIIStringEncoding error:NULL];
            program.fragmentShader = [NSString stringWithContentsOfURL:fragmentShaderURL encoding:NSASCIIStringEncoding error:NULL];
            
            // Bind geometry source semantics to the vertex shader attributes
            [program setSemantic:SCNGeometrySourceSemanticVertex forSymbol:@"a_srcPos" options:nil];
            [program setSemantic:SCNGeometrySourceSemanticNormal forSymbol:@"a_dstPos" options:nil];
            [program setSemantic:SCNGeometrySourceSemanticTexcoord forSymbol:@"a_texcoord" options:nil];
            
            // Bind the uniforms that can benefit from "automatic" values, computed and assigned by SceneKit at each frame
            [program setSemantic:SCNModelViewTransform forSymbol:@"u_mv" options:nil];
            [program setSemantic:SCNProjectionTransform forSymbol:@"u_proj" options:nil];
            
            // Other uniforms will be set using binding blocks
            static float morphFactor = 0.0;
            morphFactor = -M_PI_2;
            [_torusNode.geometry.firstMaterial handleBindingOfSymbol:@"factor" usingBlock:^(unsigned int programID, unsigned int location, SCNNode *renderedNode, SCNRenderer *renderer) {
                // animate the "factor" uniform to morph from the original object to the sphere
                morphFactor += 0.01;
                glUniform1f(location, sin(morphFactor) * 0.5 + 0.5);
            }];
            
            CFTimeInterval startTime = CFAbsoluteTimeGetCurrent();
            [_torusNode.geometry.firstMaterial handleBindingOfSymbol:@"time" usingBlock:^(unsigned int programID, unsigned int location, SCNNode *renderedNode, SCNRenderer *renderer) {
                // animate the "time" uniform to make the particles spin
                glUniform1f(location, CFAbsoluteTimeGetCurrent() - startTime);
            }];
            
            // Use our custom program and make the material not to interact at all with the depth buffer (to provide an additive effect)
            _torusNode.geometry.firstMaterial.program = program;
            _torusNode.geometry.firstMaterial.writesToDepthBuffer = NO;
            _torusNode.geometry.firstMaterial.readsFromDepthBuffer = NO;
            _torusNode.renderingOrder = 100; // as the geometry doesn't interact with the depth buffer, the node needs to be rendered last
            break;
        }
        case 2:
            // Display the related sample code
            [self.textManager fadeOutTextOfType:AAPLTextTypeBullet];
            
            [self.textManager addEmptyLine];
            [self.textManager addCode:
             @"[aMaterial #handleBindingOfSymbol:#@\"myUniform\" \n"
             @"                      #usingBlock:# \n"
             @"       ^(unsigned int programID, \n"
             @"         unsigned int location, \n"
             @"         SCNNode *node, \n"
             @"         SCNRenderer *renderer) { \n"
             @"    glUniform1f(location, aValue); \n"
             @"}];"];
            
            [self.textManager flipInTextOfType:AAPLTextTypeCode];
            break;
    }
}

@end
