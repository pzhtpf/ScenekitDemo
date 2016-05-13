/*
 <codex>
 <abstract>Explains what levels of detail are and shows an example of how to use them.</abstract>
 </codex>
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideLOD : AAPLSlide
@end

@implementation AAPLSlideLOD

- (NSUInteger)numberOfSteps {
    return 7;
}

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Set the slide's title
    self.textManager.title = @"Levels of Detail";
    
    // Create a node that will hold the teapots
    SCNNode *intermediateNode = [SCNNode node];
//    intermediateNode.rotation = SCNVector4Make(1, 0, 0, -M_PI_2);
    [self.groundNode addChildNode:intermediateNode];
    
    // Load two resolutions
    [self addTeapotWithResolutionIndex:0 positionX:-5 parent:intermediateNode]; // high res
    [self addTeapotWithResolutionIndex:4 positionX:+5 parent:intermediateNode]; // low res
    
    // Load the other resolutions but hide them
    for (NSUInteger i = 1; i < 4; i++) {
        SCNNode *teapotNode = [self addTeapotWithResolutionIndex:i positionX:5 parent:intermediateNode];
        teapotNode.opacity = 0.0;
    }
}

- (void)presentStepIndex:(NSUInteger)index withPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    switch (index) {
        case 0:
            // Hide everything (in case the user went backward)
            for (NSUInteger i = 1; i < 4; i++) {
                SCNNode *teapot = [self.groundNode childNodeWithName:[NSString stringWithFormat:@"Teapot%ld", i] recursively:YES];
                teapot.opacity = 0.0;
            }
            break;
        case 1:
        {
            // Move the camera and adjust the clipping plane
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:3];
            {
                presentationViewController.cameraNode.position = SCNVector3Make(0, 0, 200);
                presentationViewController.cameraNode.camera.zFar = 500.0;
                presentationViewController.presentationView.scene.fogEndDistance = 600;
                presentationViewController.presentationView.scene.fogStartDistance = 450.0;
            }
            [SCNTransaction commit];
            break;
        }
        case 2:
        {
            // Revert to original position
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            {
                presentationViewController.cameraNode.position = SCNVector3Make(0, 0, 0);
                presentationViewController.cameraNode.camera.zFar = 100.0;
            }
            [SCNTransaction commit];
            break;
        }
        case 3:
        {
            NSArray *numberNodes = @[[self addNodeWithNumber:@"64k" positionX:-17],
                                     [self addNodeWithNumber:@"6k" positionX:-9],
                                     [self addNodeWithNumber:@"3k" positionX:-1],
                                     [self addNodeWithNumber:@"1k" positionX:6.5],
                                     [self addNodeWithNumber:@"256" positionX:14]];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            {
                // Move the camera and the text
                presentationViewController.cameraHandle.position = SCNVector3Make(presentationViewController.cameraHandle.position.x, presentationViewController.cameraHandle.position.y + 6, presentationViewController.cameraHandle.position.z);
                self.textManager.textNode.position = SCNVector3Make(self.textManager.textNode.position.x, self.textManager.textNode.position.y + 6, self.textManager.textNode.position.z);
                
                // Show the remaining resolutions
                for (NSInteger i = 0; i < 5; i++) {
                    SCNNode *numberNode = numberNodes[i];
                    numberNode.position = SCNVector3Make(numberNode.position.x, 7, -5);
                    
                    SCNNode *teapot = [self.groundNode childNodeWithName:[NSString stringWithFormat:@"Teapot%ld", (long)i] recursively:YES];
                    teapot.opacity = 1.0;
                    teapot.rotation = SCNVector4Make(0, 1, 0, M_PI_4);
                    teapot.position = SCNVector3Make((i - 2) * 8, teapot.position.y, -5);
                }
                
                [SCNTransaction commit];
                break;
            }
        }
        case 4:
        {
            presentationViewController.showsNewInSceneKitBadge = YES;
            
            // Remove the numbers
            [self removeNumberNodes];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            {
                // Add some text and code
                self.textManager.subtitle = @"SCNLevelOfDetail";
                
                [self.textManager addCode:
                 @"#SCNLevelOfDetail# *lod1 = [SCNLevelOfDetail #levelOfDetailWithGeometry:#aGeometry \n"
                 @"                                                  #worldSpaceDistance:#aDistance]; \n"
                 @"geometry.#levelsOfDetail# = @[ lod1, lod2, ..., lodn ];"];
                
                // Animation the merge
                for (NSUInteger i = 0; i < 5; i++) {
                    SCNNode *teapot = [self.groundNode childNodeWithName:[NSString stringWithFormat:@"Teapot%lu", (unsigned long)i] recursively:YES];
                    
                    teapot.opacity = i == 0 ? 1.0 : 0.0;
                    teapot.rotation = SCNVector4Make(0, 1, 0, 0);
                    teapot.position = SCNVector3Make(0, teapot.position.y, -5);
                }
                
                // Move the camera and the text
                presentationViewController.cameraHandle.position = SCNVector3Make(presentationViewController.cameraHandle.position.x, presentationViewController.cameraHandle.position.y - 3, presentationViewController.cameraHandle.position.z);
                self.textManager.textNode.position = SCNVector3Make(self.textManager.textNode.position.x, self.textManager.textNode.position.y - 3, self.textManager.textNode.position.z);
            }
            [SCNTransaction commit];
            break;
        }
        case 5:
        {
            presentationViewController.showsNewInSceneKitBadge = NO;
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:3.0];
            {
                // Change the lighting to remove the front light and rise the main light
                [presentationViewController updateLightingWithIntensities:@[@1.0, @0.3, @0.0, @0.0, @0.0, @0.0]];
                [presentationViewController riseMainLight:YES];
                
                // Remove some text
                [self.textManager fadeOutTextOfType:AAPLTextTypeTitle];
                [self.textManager fadeOutTextOfType:AAPLTextTypeSubtitle];
                [self.textManager fadeOutTextOfType:AAPLTextTypeCode];
            }
            [SCNTransaction commit];
            
            // Retrieve the main teapot
            SCNNode *teapot = [self.groundNode childNodeWithName:@"Teapot0" recursively:YES];
            
            // The distances to use for each LOD
            float distances[4] = {30, 50, 90, 150};
            
            // An array of SCNLevelOfDetail instances that we will build
            NSMutableArray *levelsOfDetail = [NSMutableArray array];
            for (NSUInteger i = 1; i < 5; i++) {
                SCNNode *teapotNode = [self.groundNode childNodeWithName:[NSString stringWithFormat:@"Teapot%lu", (unsigned long)i] recursively:YES];
                SCNGeometry *teapot = teapotNode.geometry;
                
                // Unshare the material because we will highlight the different levels of detail with different colors in the next step
                teapot.firstMaterial = [teapot.firstMaterial copy];
                
                // Build the SCNLevelOfDetail instance
                SCNLevelOfDetail *levelOfDetail = [SCNLevelOfDetail levelOfDetailWithGeometry:teapot worldSpaceDistance:distances[i - 1]];
                [levelsOfDetail addObject:levelOfDetail];
            }
            
            teapot.geometry.levelsOfDetail = levelsOfDetail;
            
            // Duplicate and move the teapots
            CFTimeInterval startTime = CACurrentMediaTime();
            CFTimeInterval delay = 0.2;
            
            NSInteger rowCount = 9;
            NSInteger columnCount = 12;
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0];
            {
                // Change the far clipping plane to be able to see far away
                presentationViewController.cameraNode.camera.zFar = 1000.0;
                
                for (NSInteger j = 0; j < columnCount; j++) {
                    for (NSInteger i = 0; i < rowCount; i++) {
                        // Clone
                        SCNNode *clone = [teapot clone];
                        [teapot.parentNode addChildNode:clone];
                        
                        // Animate
                        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
                        animation.additive = YES;
                        animation.duration = 1.0;
                        animation.toValue = [NSValue valueWithSCNVector3:SCNVector3Make((i - rowCount / 2.0) * 12.0, 0, -(5 + (columnCount - j) * 15.0))];
                        animation.fromValue = [NSValue valueWithSCNVector3:SCNVector3Make(0, 0, 0)];
                        animation.beginTime = startTime + delay; // desynchronize
                        
                        // Freeze at the end of the animation
                        animation.removedOnCompletion = NO;
                        animation.fillMode = kCAFillModeForwards;
                        
                        [clone addAnimation:animation forKey:nil];
                        
                        // Animate the hidden property to automatically show the node when the position animation starts
                        animation = [CABasicAnimation animationWithKeyPath:@"hidden"];
                        animation.duration = delay + 0.01;
                        animation.fillMode = kCAFillModeBoth;
                        animation.fromValue = @1;
                        animation.toValue = @0;
                        [clone addAnimation:animation forKey:nil];

                        delay += 0.05;
                    }
                }
            }
            [SCNTransaction commit];
            
            // Animate the camera while we duplicate the nodes
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0 + rowCount * columnCount * 0.05];
            {
                SCNVector3 position = presentationViewController.cameraHandle.position;
                presentationViewController.cameraHandle.position = SCNVector3Make(position.x, position.y + 5, position.z);
                presentationViewController.cameraPitch.rotation = SCNVector4Make(1, 0, 0, presentationViewController.cameraPitch.rotation.w - (M_PI_4 * 0.1));
            }
            [SCNTransaction commit];
            break;
        }
        case 6:
        {
            // Highlight the levels of detail with colors
            SCNNode *teapotNode = [self.groundNode childNodeWithName:@"Teapot0" recursively:YES];
            NSArray *colors = @[[NSColor redColor], [NSColor orangeColor], [NSColor yellowColor], [NSColor greenColor]];

            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1];
            {
                for (NSUInteger i = 0; i < 4; i++) {
                    SCNLevelOfDetail *levelOfDetail = teapotNode.geometry.levelsOfDetail[i];
                    levelOfDetail.geometry.firstMaterial.multiply.contents = colors[i];
                }
            }
            [SCNTransaction commit];
            break;
        }
    }
}

- (void)willOrderOutWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Reset the camera and lights before leaving this slide
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:2.0];
    {
        presentationViewController.cameraNode.camera.zFar = 100.0;
    }
    [SCNTransaction commit];
    
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:0.5];
    {
        [presentationViewController riseMainLight:NO];
     
        //restore fog too
        presentationViewController.presentationView.scene.fogEndDistance = 45;
        presentationViewController.presentationView.scene.fogStartDistance = 40.0;
    }
    [SCNTransaction commit];
}

- (SCNNode *)addTeapotWithResolutionIndex:(NSUInteger)index positionX:(CGFloat)x parent:(SCNNode *)parent {
    
    SCNNode *teapotNode = [parent asc_addChildNodeNamed:[NSString stringWithFormat:@"Teapot%d", (int)index] fromSceneNamed:@"Scenes.scnassets/lod/lod.dae" withScale:11];
    teapotNode.geometry.firstMaterial.reflective.intensity = 0.8;
    teapotNode.geometry.firstMaterial.fresnelExponent = 1.0;
    
    CGFloat yOffset = index == 4 ? 0.0 : index * 20.0;
    teapotNode.position = SCNVector3Make(x, 0.1, 10 + yOffset);
    
    return teapotNode;
}

- (SCNNode *)addNodeWithNumber:(NSString *)numberString positionX:(CGFloat)x {
    SCNNode *numberNode = [SCNNode asc_labelNodeWithString:numberString size:AAPLLabelSizeLarge isLit:YES];
    numberNode.geometry.firstMaterial.diffuse.contents = [NSColor orangeColor];
    numberNode.geometry.firstMaterial.ambient.contents = [NSColor orangeColor];
    numberNode.position = SCNVector3Make(x, 50, 0);
    numberNode.name = @"number";
    
    SCNText *text = (SCNText *)numberNode.geometry;
    text.extrusionDepth = 5;
    
    [self.groundNode addChildNode:numberNode];
    
    return numberNode;
}

- (void)removeNumberNodes {
    // Move, fade and remove on completion
    for (SCNNode *node in self.groundNode.childNodes) {
        if ([node.name isEqualToString:@"number"]) {
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            [SCNTransaction setCompletionBlock:^{
                [node removeFromParentNode];
            }];
            {
                node.opacity = 0.0;
                node.position = SCNVector3Make(node.position.x, node.position.y, node.position.z - 20);
            }
            [SCNTransaction commit];
        }
    }
}

@end
