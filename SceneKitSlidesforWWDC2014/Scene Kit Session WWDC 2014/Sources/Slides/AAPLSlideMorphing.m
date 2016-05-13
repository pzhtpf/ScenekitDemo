/*
 <codex>
 <abstract>Illustrates how morphing can be used.</abstract>
 </codex>
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideMorphing : AAPLSlide
@end

@implementation AAPLSlideMorphing {
    SCNNode *_mapNode;
    SCNNode *_gaugeANode, *_gaugeAProgressNode;
    SCNNode *_gaugeBNode, *_gaugeBProgressNode;
}

- (NSUInteger)numberOfSteps {
    return 8;
}

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Load the scene
    SCNNode *intermediateNode = [SCNNode node];
    intermediateNode.position = SCNVector3Make(6, 9, 0);
    intermediateNode.scale = SCNVector3Make(1.4, 1, 1);
    [self.groundNode addChildNode:intermediateNode];
    
    _mapNode = [intermediateNode asc_addChildNodeNamed:@"Map" fromSceneNamed:@"Scenes.scnassets/map/foldingMap.dae" withScale:25];
    _mapNode.position = SCNVector3Make(0, 0, 0);
    _mapNode.opacity = 0.0;
    
    // Use a bunch of shader modifiers to simulate ambient occlusion when the map is folded
    NSString *geometryModifier = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mapGeometry" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];
    NSString *fragmentModifier = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mapFragment" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];
    NSString *lightingModifier = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mapLighting" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];
    
    _mapNode.geometry.shaderModifiers = @{ SCNShaderModifierEntryPointGeometry      : geometryModifier,
                                           SCNShaderModifierEntryPointFragment      : fragmentModifier,
                                           SCNShaderModifierEntryPointLightingModel : lightingModifier };
}

- (void)presentStepIndex:(NSUInteger)index withPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    //animate by default
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1.0];
    
    switch (index) {
        case 0:
        {
            [SCNTransaction setAnimationDuration:0.0];
            
            // Set the slide's title and subtitle and add some text
            self.textManager.title = @"Morphing";
            [self.textManager addBullet:@"Linear morph between multiple targets" atLevel:0];
            
            // Initial state, no ambient occlusion
            // This also shows how uniforms from shader modifiers can be set using KVC
            [_mapNode.geometry setValue:@0 forKey:@"ambientOcclusionYFactor"];
            break;
        }
        case 1:
        {
            [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
            
            // Reveal the map and show the gauges
            _mapNode.opacity = 1.0;
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0];
            {
                _gaugeANode = [SCNNode asc_gaugeNodeWithTitle:@"Target A" progressNode:&_gaugeAProgressNode];
                _gaugeANode.position = SCNVector3Make(-10.5, 15, -5);
                [self.contentNode addChildNode:_gaugeANode];
                
                _gaugeBNode = [SCNNode asc_gaugeNodeWithTitle:@"Target B" progressNode:&_gaugeBProgressNode];
                _gaugeBNode.position = SCNVector3Make(-10.5, 13, -5);
                [self.contentNode addChildNode:_gaugeBNode];
            }
            [SCNTransaction commit];
            break;
        }
        case 2:
        {
            // Morph and update the gauges
            _gaugeAProgressNode.scale = SCNVector3Make(1, 1, 1);
            [_mapNode.morpher setWeight:0.65 forTargetAtIndex:0];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.1];
            {
                _gaugeAProgressNode.opacity = 1.0;
            }
            [SCNTransaction commit];
            
            SCNNode *shadowPlane = _mapNode.childNodes[0];
            shadowPlane.scale = SCNVector3Make(0.35, 1, 1);
            
            _mapNode.parentNode.rotation = SCNVector4Make(1, 0, 0, -M_PI_4 * 0.75);
            break;
        }
        case 3:
        {
            // Morph and update the gauges
            _gaugeAProgressNode.scale = SCNVector3Make(1, 0.01, 1);
            [_mapNode.morpher setWeight:0 forTargetAtIndex:0];
            
            SCNNode *shadowPlane = _mapNode.childNodes[0];
            shadowPlane.scale = SCNVector3Make(1, 1, 1);
            
            _mapNode.parentNode.rotation = SCNVector4Make(1, 0, 0, 0);
            
            [SCNTransaction setCompletionBlock:^{
                [SCNTransaction begin];
                [SCNTransaction setAnimationDuration:0.5];
                {
                    _gaugeAProgressNode.opacity = 0.0;
                }
                [SCNTransaction commit];
            }];
            break;
        }
        case 4:
        {
            // Morph and update the gauges
            _gaugeBProgressNode.scale = SCNVector3Make(1, 1, 1);
            [_mapNode.morpher setWeight:0.4 forTargetAtIndex:1];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.1];
            {
                _gaugeBProgressNode.opacity = 1.0;
            }
            [SCNTransaction commit];
            
            SCNNode *shadowPlane = _mapNode.childNodes[0];
            shadowPlane.scale = SCNVector3Make(1, 0.6, 1);
            
            _mapNode.parentNode.rotation = SCNVector4Make(0, 1, 0, -M_PI_4 * 0.5);
            break;
        }
        case 5:
        {
            // Morph and update the gauges
            _gaugeBProgressNode.scale = SCNVector3Make(1, 0.01, 1);
            [_mapNode.morpher setWeight:0 forTargetAtIndex:1];
            
            SCNNode *shadowPlane = _mapNode.childNodes[0];
            shadowPlane.scale = SCNVector3Make(1, 1, 1);
            
            _mapNode.parentNode.rotation = SCNVector4Make(0, 1, 0, 0);
            
            [SCNTransaction setCompletionBlock:^{
                [SCNTransaction begin];
                [SCNTransaction setAnimationDuration:0.5];
                {
                    _gaugeBProgressNode.opacity = 0.0;
                }
                [SCNTransaction commit];
            }];
            break;
        }
        case 6:
        {
            // Morph and update the gauges
            _gaugeAProgressNode.scale = SCNVector3Make(1, 1, 1);
            _gaugeBProgressNode.scale = SCNVector3Make(1, 1, 1);
            
            [_mapNode.morpher setWeight:0.65 forTargetAtIndex:0];
            [_mapNode.morpher setWeight:0.30 forTargetAtIndex:1];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.1];
            {
                _gaugeAProgressNode.opacity = 1.0;
                _gaugeBProgressNode.opacity = 1.0;
            }
            [SCNTransaction commit];
            
            SCNNode *shadowPlane = _mapNode.childNodes[0];
            shadowPlane.scale = SCNVector3Make(0.4, 0.7, 1);
            shadowPlane.opacity = 0.2;
            
            [_mapNode.geometry setValue:@0.35 forKey:@"ambientOcclusionYFactor"];
            _mapNode.position = SCNVector3Make(0, 0, 5);
            _mapNode.parentNode.rotation = SCNVector4Make(0, 1, 0, -M_PI_4 * 0.5);
            _mapNode.rotation = SCNVector4Make(1, 0, 0, M_PI_2 + (-M_PI_4 * 0.75));
            break;
        }
        case 7:
        {
            [SCNTransaction setAnimationDuration:0.5];
            
            // Hide gauges and update the text
            _gaugeANode.opacity = 0.0;
            _gaugeBNode.opacity = 0.0;
            
            self.textManager.subtitle = @"SCNMorpher";
            [self.textManager addBullet:@"Topology must match" atLevel:0];
            [self.textManager addBullet:@"Can be loaded from DAEs" atLevel:0];
            [self.textManager addBullet:@"Can be created programmatically" atLevel:0];
            
            break;
        }
    }
    [SCNTransaction commit];
}

@end
