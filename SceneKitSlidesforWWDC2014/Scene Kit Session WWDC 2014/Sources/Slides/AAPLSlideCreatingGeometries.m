/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  Presents the different types of geometry that one can create programmatically.
  
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

#import <GLKit/GLKMath.h>
#import <SceneKit/SceneKit.h>

// Data structure representing a vertex that will be used to create custom geometries
typedef struct {
    float x, y, z;    // position
    float nx, ny, nz; // normal
    float s, t;       // texture coordinates
} AAPLVertex;

@interface AAPLSlideCreatingGeometries : AAPLSlide
@end

@implementation AAPLSlideCreatingGeometries {
    SCNNode *_carouselNode;
    SCNNode *_textNode;
    SCNNode *_starOutline;
    SCNNode *_starNode;
    SCNNode *_mobiusHandle;
    SCNNode *_subdivisionGroup;
    NSUInteger _currentStep;
}

- (NSUInteger)numberOfSteps {
    return 6;
}

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Set the slide's title
    self.textManager.title = @"Creating Geometry";

    // Set the slide's subtitle and display the primitves
    self.textManager.subtitle = @"Built-in parametric primitives";
}

- (void)presentStepIndex:(NSUInteger)index withPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    _currentStep = index;
    switch (index) {
        case 0:
            break;
        case 1:
        {
            // Hide the carousel and illustrate SCNText
            [self.textManager flipOutTextOfType:AAPLTextTypeSubtitle];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            [SCNTransaction setCompletionBlock:^{
                [_carouselNode removeFromParentNode];
            }];
            
            [self presentTextNode];
            //[presentationViewController.presentationView prepareObject:_textNode shouldAbortBlock:nil];
            
            _textNode.opacity = 1.0;
            
            _carouselNode.position = SCNVector3Make(0, _carouselNode.position.y, -50);
            [_carouselNode enumerateChildNodesUsingBlock:^(SCNNode *child, BOOL *stop) {
                child.geometry.firstMaterial.emission.contents = [NSColor blackColor];
            }];
            _carouselNode.opacity = 0.0;
            
            [SCNTransaction commit];
            
            self.textManager.subtitle = @"Built-in 3D text";
            [self.textManager addBullet:@"SCNText" atLevel:0];
            [self.textManager flipInTextOfType:AAPLTextTypeSubtitle];
            [self.textManager flipInTextOfType:AAPLTextTypeBullet];
            break;
        }
        case 2:
        {
            
            //Show bezier path
            NSBezierPath *star = [self starPathWithInnerRadius:3 outerRadius:6];
            
            SCNShape *shape = [SCNShape shapeWithPath:star extrusionDepth:1];
            shape.chamferRadius = 0.2;
            shape.chamferProfile = [self chamferProfileForOutline];
            shape.chamferMode = SCNChamferModeFront;
            
            // that way only the outline of the model will be visible
            SCNMaterial *outlineMaterial = [SCNMaterial material];
            outlineMaterial.ambient.contents = outlineMaterial.diffuse.contents = outlineMaterial.specular.contents = [NSColor blackColor];
            outlineMaterial.emission.contents = [NSColor whiteColor];
            outlineMaterial.doubleSided = YES;
            
            SCNMaterial *tranparentMaterial = [SCNMaterial material];
            tranparentMaterial.transparency = 0.0;
            
            shape.materials = @[tranparentMaterial, tranparentMaterial, tranparentMaterial, outlineMaterial, outlineMaterial];
            
            _starOutline = [SCNNode node];
            _starOutline.geometry = shape;
            _starOutline.position = SCNVector3Make(0, 5, 30);
            [_starOutline runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:M_PI*2 z:0 duration:10.0]]];
            
            [self.groundNode addChildNode:_starOutline];
            
            // Hide the 3D text and introduce SCNShape
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            [SCNTransaction setCompletionBlock:^{
                [_textNode removeFromParentNode];
            }];
            
            [self.textManager flipOutTextOfType:AAPLTextTypeSubtitle];
            [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
            
            self.textManager.subtitle = @"3D Shapes";
            
            [self.textManager addBullet:@"SCNShape" atLevel:0];
            
            [self.textManager flipInTextOfType:AAPLTextTypeSubtitle];
            [self.textManager flipInTextOfType:AAPLTextTypeBullet];
            [self.textManager flipInTextOfType:AAPLTextTypeCode];
            
            _starOutline.position = SCNVector3Make(0, 5, 0);
            _textNode.position = SCNVector3Make(_textNode.position.x, _textNode.position.y, -30);
            
            
            [SCNTransaction commit];
            break;
        }
        case 3:
        {
            
            NSBezierPath *star = [self starPathWithInnerRadius:3 outerRadius:6];
            
            SCNShape *shape = [SCNShape shapeWithPath:star extrusionDepth:0];
            shape.chamferRadius = 0.1;
            
            _starNode = [SCNNode node];
            _starNode.geometry = shape;
            SCNMaterial *material = [SCNMaterial material];
            material.reflective.contents = @"color_envmap.png";
            material.diffuse.contents = [NSColor blackColor];
            _starNode.geometry.materials = @[material];
            _starNode.position = SCNVector3Make(0, 5, 0);
            _starNode.pivot = SCNMatrix4MakeTranslation(0, 0, -0.5);
            [_starOutline.parentNode addChildNode:_starNode];
            
            _starNode.eulerAngles = _starOutline.eulerAngles;
            [_starNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:M_PI*2 z:0 duration:10.0]]];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            [SCNTransaction setCompletionBlock:^{
                [_starOutline removeFromParentNode];
            }];

            shape.extrusionDepth = 1;
            _starOutline.opacity = 0.0;
            
            [SCNTransaction commit];
            
            //EXTRUDE
            break;
        }
        case 4:
        {
            //CUSTOM GEOMETRY
            [self.textManager flipOutTextOfType:AAPLTextTypeSubtitle];
            [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
            
            // Example of a custom geometry (Möbius strip)
            self.textManager.subtitle = @"Custom geometry";
            
            [self.textManager addBullet:@"Custom vertices, normals, and texture coordinates" atLevel:0];
            [self.textManager addBullet:@"SCNGeometry" atLevel:0];
            
            [self.textManager flipInTextOfType:AAPLTextTypeSubtitle];
            [self.textManager flipInTextOfType:AAPLTextTypeBullet];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            {
                [SCNTransaction setCompletionBlock:^{
                    [_starNode removeFromParentNode];
                }];
                // move the camera back to its previous position
                presentationViewController.cameraNode.position = SCNVector3Make(0, 0, 0);
                presentationViewController.cameraPitch.rotation = SCNVector4Make(1, 0, 0, self.pitch * M_PI / 180.0);
                
                _starNode.position = SCNVector3Make(_starNode.position.x, _starNode.position.y, _starNode.position.z - 30);
                _starOutline.position = SCNVector3Make(_starOutline.position.x, _starOutline.position.y, _starOutline.position.z - 30);
                
                SCNNode *mobiusNode = [SCNNode node];
                mobiusNode.geometry = [self mobiusStripWithSubdivisionCount:150];
                mobiusNode.rotation = SCNVector4Make(1, 0, 0, -M_PI_4);
                mobiusNode.scale = SCNVector3Make(4.5, 2.8, 2.8);
                
                SCNNode *rotationNode = [SCNNode node];
                [rotationNode addChildNode:mobiusNode];
                
                rotationNode.position = SCNVector3Make(0, 4, 30);
                [self.groundNode addChildNode:rotationNode];
                
                rotationNode.position = SCNVector3Make(0, 4, 3.5);
                
                [rotationNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:M_PI*2 z:0 duration:10.0]]];
                
                _mobiusHandle = rotationNode;
            }
            [SCNTransaction commit];
            
            break;
        case 5:
            {
                //OpenSubdiv
                [self.textManager flipOutTextOfType:AAPLTextTypeSubtitle];
                [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
                
                self.textManager.subtitle = @"Subdivisions";
                
                [self.textManager addBullet:@"OpenSubdiv" atLevel:0];
                [self.textManager addCode:@"aGeometry.#subdivisionLevel# = anInteger;"];
                
                [self.textManager flipInTextOfType:AAPLTextTypeSubtitle];
                [self.textManager flipInTextOfType:AAPLTextTypeBullet];
                [self.textManager flipInTextOfType:AAPLTextTypeCode];
                
                //add boxes
                SCNNode *boxesNode = [SCNNode node];
                
                SCNNode *level0 = [boxesNode asc_addChildNodeNamed:@"rccarBody_LP" fromSceneNamed:@"Scenes.scnassets/car/car_lowpoly.dae" withScale:10];
                level0.position = SCNVector3Make(-6, level0.position.y, 0);
                
                
                SCNNode *label = [SCNNode asc_boxNodeWithTitle:@"0" frame:NSMakeRect(0, 0, 40, 40) color:[NSColor orangeColor] cornerRadius:20.0 centered:YES];
                label.position = SCNVector3Make(0, -35, 10);
                label.scale = SCNVector3Make(0.3, 0.3, 0.001);
                [level0 addChildNode:label];
                
                
                boxesNode.position = SCNVector3Make(0, 0, 30);
                
                SCNNode *level1 = [level0 clone];
                [level1 enumerateChildNodesUsingBlock:^(SCNNode *child, BOOL *stop) {
                    if ([child.name isEqualToString:@"engine_LP"])
                        return;
                    
                    child.geometry = [child.geometry copy];
                    child.geometry.subdivisionLevel = 3;
                }];
                
                level1.position = SCNVector3Make(6, level1.position.y, 0);
                [boxesNode addChildNode:level1];

                label = [SCNNode asc_boxNodeWithTitle:@"2" frame:NSMakeRect(0, 0, 40, 40) color:[NSColor orangeColor] cornerRadius:20.0 centered:YES];
                label.position = SCNVector3Make(0, -35, 10);
                label.scale = SCNVector3Make(0.3, 0.3, 0.001);
                [level1 addChildNode:label];
                
                [level0 runAction:[SCNAction repeatActionForever:[SCNAction rotateByAngle:2.0 * M_PI aroundAxis:SCNVector3Make(0, 1, 0) duration:25.0]]];
                [level1 runAction:[SCNAction repeatActionForever:[SCNAction rotateByAngle:2.0 * M_PI aroundAxis:SCNVector3Make(0, 1, 0) duration:25.0]]];
                
                
                [SCNTransaction begin];
                [SCNTransaction setAnimationDuration:1.0];
                {
                    [SCNTransaction setCompletionBlock:^{
                        [_mobiusHandle removeFromParentNode];
                    }];

                    // move moebius out
                    _mobiusHandle.position = SCNVector3Make(_mobiusHandle.position.x, _mobiusHandle.position.y, _mobiusHandle.position.z - 30);
                    
                    [self.groundNode addChildNode:boxesNode];

                    //move boxes in
                    boxesNode.position = SCNVector3Make(0, 0, 3.5);
                }
                
                [SCNTransaction commit];
                
                _subdivisionGroup = boxesNode;
                
                break;
            }
        }
    }
}

- (void) didOrderInWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController
{
    if(_currentStep == 0)
        [self presentPrimitives];
}

- (void)willOrderOutWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Make sure the camera is back to its default location before leaving the slide
    presentationViewController.cameraNode.position = SCNVector3Make(0, 0, 0);
    
    // Move bananas out
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:0.75];
    _subdivisionGroup.position = SCNVector3Make(_subdivisionGroup.position.x, _subdivisionGroup.position.y, _subdivisionGroup.position.z-30);
    [SCNTransaction commit];
}

#pragma mark - Primitives

// Create a carousel of 3D primitives
- (void)presentPrimitives {
    
    // Create the carousel node. It will host all the primitives as child nodes.
    _carouselNode = [SCNNode node];
    _carouselNode.position = SCNVector3Make(0, 0.1, -5);
    _carouselNode.scale = SCNVector3Make(0, 0, 0); // start infinitely small
    [self.groundNode addChildNode:_carouselNode];
    
    // Animate the scale to achieve a "grow" effect
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1.0];
    {
        _carouselNode.scale = SCNVector3Make(1, 1, 1);
    }
    [SCNTransaction commit];
    
    // Rotate the carousel forever
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    rotationAnimation.duration = 40.0;
    rotationAnimation.repeatCount = FLT_MAX;
    rotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    [_carouselNode addAnimation:rotationAnimation forKey:nil];
    
    // A material shared by all the primitives
    SCNMaterial *sharedMaterial = [SCNMaterial material];
    sharedMaterial.reflective.contents = [NSImage imageNamed:@"envmap"];
    sharedMaterial.reflective.intensity = 0.2;
    sharedMaterial.doubleSided = YES;
    
    __block int primitiveIndex = 0;
    void (^addPrimitive)(SCNGeometry *, CGFloat) = ^(SCNGeometry *geometry, CGFloat yPos) {
        CGFloat xPos = 13.0 * sin(M_PI * 2 * primitiveIndex / 9.0);
        CGFloat zPos = 13.0 * cos(M_PI * 2 * primitiveIndex / 9.0);
        
        SCNNode *node = [SCNNode node];
        node.position = SCNVector3Make(xPos, yPos, zPos);
        node.geometry = geometry;
        node.geometry.firstMaterial = sharedMaterial;
        [_carouselNode addChildNode:node];
        
        primitiveIndex++;
        rotationAnimation.timeOffset = -primitiveIndex;
        [node addAnimation:rotationAnimation forKey:nil];
    };
    
    // SCNBox
    SCNBox *box = [SCNBox boxWithWidth:5.0 height:5.0 length:5.0 chamferRadius:5.0 * 0.05];
    box.widthSegmentCount = 4;
    box.heightSegmentCount = 4;
    box.lengthSegmentCount = 4;
    box.chamferSegmentCount = 4;
    addPrimitive(box, 5.0 / 2);
    
    // SCNPyramid
    SCNPyramid *pyramid = [SCNPyramid pyramidWithWidth:5.0 * 0.8 height:5.0 length:5.0 * 0.8];
    pyramid.widthSegmentCount = 4;
    pyramid.heightSegmentCount = 10;
    pyramid.lengthSegmentCount = 4;
    addPrimitive(pyramid, 0);
    
    // SCNCone
    SCNCone *cone = [SCNCone coneWithTopRadius:0 bottomRadius:5.0 / 2 height:5.0];
    cone.radialSegmentCount = 20;
    cone.heightSegmentCount = 4;
    addPrimitive(cone, 5.0 / 2);
    
    // SCNTube
    SCNTube *tube = [SCNTube tubeWithInnerRadius:5.0 * 0.25 outerRadius:5.0 * 0.5 height:5.0];
    tube.heightSegmentCount = 5;
    tube.radialSegmentCount = 40;
    addPrimitive(tube, 5.0 / 2);
    
    // SCNCapsule
    SCNCapsule *capsule = [SCNCapsule capsuleWithCapRadius:5.0 * 0.4 height:5.0 * 1.4];
    capsule.heightSegmentCount = 5;
    capsule.radialSegmentCount = 20;
    addPrimitive(capsule, 5.0 * 0.7);
    
    // SCNCylinder
    SCNCylinder *cylinder = [SCNCylinder cylinderWithRadius:5.0 * 0.5 height:5.0];
    cylinder.heightSegmentCount = 5;
    cylinder.radialSegmentCount = 40;
    addPrimitive(cylinder, 5.0 / 2);
    
    // SCNSphere
    SCNSphere *sphere = [SCNSphere sphereWithRadius:5.0 * 0.5];
    sphere.segmentCount = 20;
    addPrimitive(sphere, 5.0 / 2);
    
    // SCNTorus
    SCNTorus *torus = [SCNTorus torusWithRingRadius:5.0 * 0.5 pipeRadius:5.0 * 0.25];
    torus.ringSegmentCount = 40;
    torus.pipeSegmentCount = 20;
    addPrimitive(torus, 5.0 / 4);
    
    // SCNPlane
    SCNPlane *plane = [SCNPlane planeWithWidth:5.0 height:5.0];
    plane.widthSegmentCount = 5;
    plane.heightSegmentCount = 5;
    plane.cornerRadius = 5.0 * 0.1;
    addPrimitive(plane, 5.0 / 2);
}

#pragma mark - Custom geometry

- (SCNGeometry *)mobiusStripWithSubdivisionCount:(NSInteger)subdivisionCount {
    NSInteger hSub = subdivisionCount;
    NSInteger vSub = subdivisionCount / 2;
    NSInteger vcount = (hSub + 1) * (vSub + 1);
    NSInteger icount = (hSub * vSub) * 6;
    
    AAPLVertex *vertices = malloc(sizeof(AAPLVertex) * vcount);
    unsigned short *indices = malloc(sizeof(unsigned short) * icount);
    
    // Vertices
    float sStep = 2.f * M_PI / hSub;
    float tStep = 2.f / vSub;
    AAPLVertex *v = vertices;
    float s = 0.f;
    float cosu, cosu2, sinu, sinu2;
    
    for (NSInteger i = 0; i <= hSub; ++i, s += sStep) {
        float t = -1.f;
        for (NSInteger j = 0; j <= vSub; ++j, t += tStep, ++v) {
            sinu = sin(s);
            cosu = cos(s);
            sinu2 = sin(s/2);
            cosu2 = cos(s/2);
            
            v->x = cosu * (1 + 0.5 * t * cosu2);
            v->y = sinu * (1 + 0.5 * t * cosu2);
            v->z = 0.5 * t * sinu2;
            
            v->nx = -0.125 * t * sinu  + 0.5  * cosu  * sinu2 + 0.25 * t * cosu2 * sinu2 * cosu;
            v->ny =  0.125 * t * cosu  + 0.5  * sinu2 * sinu  + 0.25 * t * cosu2 * sinu2 * sinu;
            v->nz = -0.5       * cosu2 - 0.25 * cosu2 * cosu2 * t;
            
            // normalize
            float invLen = 1. / sqrtf(v->nx * v->nx + v->ny * v->ny + v->nz * v->nz);
            v->nx *= invLen;
            v->ny *= invLen;
            v->nz *= invLen;
            
            
            v->s = 3.125 * s / M_PI;
            v->t = t * 0.5 + 0.5;
        }
    }
    
    // Indices
    unsigned short *ind = indices;
    unsigned short stripStart = 0;
    for (NSInteger i = 0; i < hSub; ++i, stripStart += (vSub + 1)) {
        for (NSInteger j = 0; j < vSub; ++j) {
			unsigned short v1	= stripStart + j;
			unsigned short v2	= stripStart + j + 1;
			unsigned short v3	= stripStart + (vSub+1) + j;
			unsigned short v4	= stripStart + (vSub+1) + j + 1;
			
			*ind++	= v1; *ind++	= v3; *ind++	= v2;
			*ind++	= v2; *ind++	= v3; *ind++	= v4;
        }
    }
    
    NSData *data = [NSData dataWithBytes:vertices length:vcount * sizeof(AAPLVertex)];
    free(vertices);
    
    // Vertex source
    SCNGeometrySource *vertexSource = [SCNGeometrySource geometrySourceWithData:data
                                                                       semantic:SCNGeometrySourceSemanticVertex
                                                                    vectorCount:vcount
                                                                floatComponents:YES
                                                            componentsPerVector:3
                                                              bytesPerComponent:sizeof(float)
                                                                     dataOffset:0
                                                                     dataStride:sizeof(AAPLVertex)];
    
    // Normal source
    SCNGeometrySource *normalSource = [SCNGeometrySource geometrySourceWithData:data
                                                                       semantic:SCNGeometrySourceSemanticNormal
                                                                    vectorCount:vcount
                                                                floatComponents:YES
                                                            componentsPerVector:3
                                                              bytesPerComponent:sizeof(float)
                                                                     dataOffset:offsetof(AAPLVertex, nx)
                                                                     dataStride:sizeof(AAPLVertex)];
    
    
    // Texture coordinates source
    SCNGeometrySource *texcoordSource = [SCNGeometrySource geometrySourceWithData:data
                                                                         semantic:SCNGeometrySourceSemanticTexcoord
                                                                      vectorCount:vcount
                                                                  floatComponents:YES
                                                              componentsPerVector:2
                                                                bytesPerComponent:sizeof(float)
                                                                       dataOffset:offsetof(AAPLVertex, s)
                                                                       dataStride:sizeof(AAPLVertex)];
    
    
    // Geometry element
    NSData *indicesData = [NSData dataWithBytes:indices length:icount * sizeof(unsigned short)];
    free(indices);
    
    SCNGeometryElement *element = [SCNGeometryElement geometryElementWithData:indicesData
                                                                primitiveType:SCNGeometryPrimitiveTypeTriangles
                                                               primitiveCount:icount/3
                                                                bytesPerIndex:sizeof(unsigned short)];
    
    // Create the geometry
    SCNGeometry *geometry = [SCNGeometry geometryWithSources:@[vertexSource, normalSource, texcoordSource] elements:@[element]];
    
    // Add textures
    geometry.firstMaterial = [SCNMaterial material];
    geometry.firstMaterial.diffuse.contents = [NSImage imageNamed:@"moebius"];
    geometry.firstMaterial.diffuse.wrapS = SCNWrapModeRepeat;
    geometry.firstMaterial.diffuse.wrapT = SCNWrapModeRepeat;
    geometry.firstMaterial.doubleSided = YES;
    geometry.firstMaterial.reflective.contents = [NSImage imageNamed:@"envmap"];
    geometry.firstMaterial.reflective.intensity = 0.3;
    
    return geometry;
}

#pragma mark - Stylized 3D text

- (NSAttributedString *)attributedStringWithString:(NSString *)string {
    NSFont *font = [NSFont fontWithName:@"Avenir Next Heavy" size:288];
    NSDictionary *attributes = @{ NSFontAttributeName : font };
    return [[NSMutableAttributedString alloc] initWithString:string attributes:attributes];
}

- (SCNMaterial *)textFrontMaterial {
    SCNMaterial *material = [SCNMaterial material];
    material.diffuse.contents = [NSColor blackColor];
    material.reflective.contents = [NSImage imageNamed:@"envmap"];
    material.reflective.intensity = 0.5;
    material.multiply.contents = [NSImage imageNamed:@"gradient2"];
    return material;
}

- (SCNMaterial *)textSideAndChamferMaterial {
    SCNMaterial *material = [SCNMaterial material];
    material.diffuse.contents = [NSColor whiteColor];
    material.reflective.contents = [NSImage imageNamed:@"envmap"];
    material.reflective.intensity = 0.4;
    return material;
}

- (NSBezierPath *)textChamferProfile {
    NSBezierPath *profile = [NSBezierPath bezierPath];
    [profile moveToPoint:NSMakePoint(0, 1)];
    [profile lineToPoint:NSMakePoint(1.5, 1)];
    [profile lineToPoint:NSMakePoint(1.5, 0)];
    [profile lineToPoint:NSMakePoint(1, 0)];
    return profile;
}

// Takes a string an creates a node hierarchy where each letter is an independent geometry that is animated
- (SCNNode *)splittedStylizedTextWithString:(NSString *)string {

    SCNNode *textNode = [SCNNode node];
    SCNMaterial *frontMaterial = [self textFrontMaterial];
    SCNMaterial *border = [self textSideAndChamferMaterial];
    
    // Current x position of the next letter to add
    CGFloat positionX = 0;
    
    // For each letter
    for (NSUInteger i = 0; i < [string length]; i++) {
      
        SCNNode *letterNode = [SCNNode node];
        NSString *letterString = [string substringWithRange:NSMakeRange(i, 1)];
        SCNText *text = [SCNText textWithString:[self attributedStringWithString:letterString] extrusionDepth:50.0];
        
        text.chamferRadius = 3.0;
        text.chamferProfile = [self textChamferProfile];
        
        // use a different material for the "heart" character
        SCNMaterial *finalFrontMaterial = frontMaterial;
        if (i == 1) {
            finalFrontMaterial = [finalFrontMaterial copy];
            finalFrontMaterial.diffuse.contents = [NSColor redColor];
            finalFrontMaterial.reflective.contents = [NSColor blackColor];
            letterNode.scale = SCNVector3Make(1.1, 1.1, 1.0);
        }
        
        text.materials = @[finalFrontMaterial, finalFrontMaterial, border, border, border];
        
        letterNode.geometry = text;
        [textNode addChildNode:letterNode];
        
        // measure the letter we just added to update the position
        SCNVector3 min, max;
        max = SCNVector3Make(0, 0, 0);
        min = SCNVector3Make(0, 0, 0);
        if ([letterNode getBoundingBoxMin:&min max:&max]) {
            letterNode.position = SCNVector3Make(positionX - min.x + ( max.x + min.x) * 0.5, -min.y, 0);
            positionX += max.x;
        }
        else{
            // if we have no bounding box, it is probably because of the "space" character. In that case, move to the right a little bit.
            positionX += 50.0;
        }
        
        // Place the pivot at the center of the letter so that the rotation animation looks good
        letterNode.pivot = SCNMatrix4MakeTranslation((max.x + min.x) * 0.5, 0, 0);
        
        // Animate the letter
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"rotation"];
        animation.duration = 4.0;
        animation.keyTimes = @[@0.0, @0.3, @1.0];
        animation.values = @[[NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, 0)],
                             [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)],
                             [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)]];
        CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.timingFunctions = @[timingFunction, timingFunction, timingFunction];
        animation.repeatCount = FLT_MAX;
        animation.beginTime = CACurrentMediaTime() + 1.0 + i * 0.2; // desynchronize animations
        [letterNode addAnimation:animation forKey:nil];
    }
    
    return textNode;
}

- (void)presentTextNode {
    _textNode = [self splittedStylizedTextWithString:@"I❤︎SceneKit"];
    _textNode.scale = SCNVector3Make(0.017, 0.0187, 0.017);
    _textNode.opacity = 0.0;
    
    _textNode.position = SCNVector3Make(-14, 0, 30);
    
    [self.groundNode addChildNode:_textNode];
    
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1.0];
    _textNode.position = SCNVector3Make(-14, 0, 0);
    [SCNTransaction commit];
}

#pragma mark - SCNShape

- (NSBezierPath *)outlineChamferProfilePath {
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(1, 1)];
    [path lineToPoint:NSMakePoint(1, 0)];
    return path;
}

- (NSBezierPath *)starPathWithInnerRadius:(CGFloat)innerRadius outerRadius:(CGFloat)outerRadius {
    NSUInteger raysCount = 5;
    CGFloat delta = 2.0 * M_PI / raysCount;
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    for (NSUInteger i = 0; i < raysCount; ++i) {
        CGFloat alpha = i * delta + M_PI_2;
        
        if (i == 0)
            [path moveToPoint:NSMakePoint(outerRadius * cos(alpha), outerRadius * sin(alpha))];
        else
            [path lineToPoint:NSMakePoint(outerRadius * cos(alpha), outerRadius * sin(alpha))];
        
        alpha += 0.5 * delta;
        [path lineToPoint:NSMakePoint(innerRadius * cos(alpha), innerRadius * sin(alpha))];
    }
    
    return path;
}
// the curve to use to extrude the shape
- (NSBezierPath *)chamferProfileForOutline {
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(1, 1)];
    [path lineToPoint:NSMakePoint(1, 0)];
    return path;
}

@end
