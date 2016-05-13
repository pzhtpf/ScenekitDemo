#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

#import <SceneKit/SceneKit.h>

@interface AAPLSlideShadows : AAPLSlide
{
    SCNNode *_palmTree;
    SCNNode *_character;
    SCNNode *_lightHandle;
    SCNNode *_projector;
    SCNNode *_staticShadowNode;
    
    SCNVector3 _oldSpotPosition;
    SCNNode *_oldSpotParent;
    CGFloat  _oldSpotZNear;
    id  _oldSpotShadowColor;
    
}
@end

@implementation AAPLSlideShadows


- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Set the slide's title and add some text
    self.textManager.title = @"Shadows";
    
    [self.textManager addBullet:@"Static" atLevel:0];
    [self.textManager addBullet:@"Dynamic" atLevel:0];
    [self.textManager addBullet:@"Projected" atLevel:0];
    
    
    SCNNode *sceneryHolder = [SCNNode node];
    sceneryHolder.name = @"scenery";
    sceneryHolder.position = SCNVector3Make(5, -19, 12);
    
    [self.groundNode addChildNode:sceneryHolder];
    
    //add scenery
    [sceneryHolder asc_addChildNodeNamed:@"scenery" fromSceneNamed:@"Scenes.scnassets/banana/level" withScale:130];
    
    _palmTree = [self.groundNode asc_addChildNodeNamed:@"PalmTree" fromSceneNamed:@"Scenes.scnassets/palmTree/palm_tree" withScale:15];
    
    _palmTree.position = SCNVector3Make(3, -1, 7);
    _palmTree.eulerAngles = SCNVector3Make(0, -M_PI_4*0.2, 0);
    
    [_palmTree enumerateChildNodesUsingBlock:^(SCNNode *child, BOOL *stop) {
        child.castsShadow = NO;
    }];
    
    //add a static shadow
    SCNNode *shadowPlane = [SCNNode nodeWithGeometry:[SCNPlane planeWithWidth:15 height:15]];
    shadowPlane.eulerAngles= SCNVector3Make(-M_PI_2, M_PI_4*0.5, 0);
    shadowPlane.position = SCNVector3Make(0.5, 0.1, 2);
    shadowPlane.geometry.firstMaterial.diffuse.contents = @"staticShadow.tiff";
    [self.groundNode addChildNode:shadowPlane];
    _staticShadowNode = shadowPlane;
    _staticShadowNode.opacity = 0;
    
    SCNNode *character = [self.groundNode asc_addChildNodeNamed:@"explorer" fromSceneNamed:@"Scenes.scnassets/explorer/explorer_skinned" withScale:9];
    
    SCNScene *animScene = [SCNScene sceneNamed:@"idle.dae" inDirectory:@"Scenes.scnassets/explorer" options:nil];
    SCNNode *animatedNode = [animScene.rootNode childNodeWithName:@"Bip001_Pelvis" recursively:YES];
    [character addAnimation:[animatedNode animationForKey:[animatedNode animationKeys][0]] forKey:@"idle"];
    
    character.position = SCNVector3Make(20, 0, 7);
    character.eulerAngles = SCNVector3Make(0, M_PI_2, 0);
    _character = character;
}

- (NSUInteger) numberOfSteps
{
    return 6;
}

- (void)presentStepIndex:(NSUInteger)index withPresentationViewController:(AAPLPresentationViewController *)presentationViewController
{
    switch(index){
        case 0:
        {
        } break;
        case 1:
        {
            [self.textManager highlightBulletAtIndex:0];
            
            _staticShadowNode.opacity = 1;

            SCNNode *node = [self.textManager addCode:@"aMaterial.#multiply#.contents = aShadowMap;"];
            node.position = SCNVector3Make(node.position.x, node.position.y-4, node.position.z);
            [node enumerateChildNodesUsingBlock:^(SCNNode *child, BOOL *stop) {
                child.renderingOrder = 1;
                for(SCNMaterial *m in child.geometry.materials)
                    m.readsFromDepthBuffer = NO;
            }];
        }
            break;
        case 2:
            //move the tree
            [_palmTree runAction:[SCNAction rotateByX:0 y:M_PI*4 z:0 duration:8]];
            break;
        case 3:
        {
            self.textManager.fadesIn = YES;
            [self.textManager fadeOutTextOfType:AAPLTextTypeCode];
            
            SCNNode *node = [self.textManager addCode:@"aLight.#castsShadow# = YES;"];
            [node enumerateChildNodesUsingBlock:^(SCNNode *child, BOOL *stop) {
                child.renderingOrder = 1;
                for(SCNMaterial *m in child.geometry.materials){
                    m.readsFromDepthBuffer = NO;
                    m.writesToDepthBuffer = NO;
                }
            }];
            
            node.position = SCNVector3Make(node.position.x, node.position.y-11.5, node.position.z);
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.75];
            
            SCNNode *spot = presentationViewController.spotLight;
            _oldSpotShadowColor = spot.light.shadowColor;
            spot.light.shadowColor = [NSColor blackColor];
            spot.light.shadowRadius = 3;
            
            SCNVector3 tp = self.textManager.textNode.position;
            
            SCNNode *superNode = presentationViewController.cameraNode.parentNode.parentNode;
            
            SCNVector3 p0 = [self.groundNode convertPosition:SCNVector3Zero toNode:nil];
            SCNVector3 p1 = [self.groundNode convertPosition:SCNVector3Make(20, 0, 0) toNode:nil];
            SCNVector3 tr = SCNVector3Make(p1.x-p0.x, p1.y-p0.y, p1.z-p0.z);
            
            
            SCNVector3 p = superNode.position;
            p.x += tr.x;
            p.y += tr.y;
            p.z += tr.z;
            tp.x += 20;
            tp.y += 0;
            tp.z += 0;
            superNode.position = p;
            self.textManager.textNode.position = tp;
            [SCNTransaction commit];
            
            [self.textManager highlightBulletAtIndex:1];
        }
            
            break;
        case 4:
        {
            //move the light
            SCNNode *lightPivot = [SCNNode node];
            lightPivot.position = _character.position;
            [self.groundNode addChildNode:lightPivot];
            
            SCNNode *spot = presentationViewController.spotLight;
            _oldSpotPosition = spot.position;
            _oldSpotParent = spot.parentNode;
            _oldSpotZNear = spot.light.zNear;
            
            spot.light.zNear = 20;
            spot.position = [lightPivot convertPosition:spot.position fromNode:spot.parentNode];
            [lightPivot addChildNode:spot];
            
            //add an object to represent the light
            SCNNode *lightModel = [SCNNode node];
            SCNNode *lightHandle = [SCNNode node];
            SCNCone *cone = [SCNCone coneWithTopRadius:0 bottomRadius:0.5 height:1];
            cone.radialSegmentCount = 10;
            cone.heightSegmentCount = 5;
            lightModel.geometry = cone;
            lightModel.geometry.firstMaterial.emission.contents = [NSColor yellowColor];
#define DIST 0.3
            lightHandle.position = SCNVector3Make(spot.position.x * DIST, spot.position.y * DIST, spot.position.z * DIST);
            lightModel.castsShadow = NO;
            lightModel.eulerAngles = SCNVector3Make(M_PI_2, 0, 0);
            [lightHandle addChildNode:lightModel];
            lightHandle.constraints = @[[SCNLookAtConstraint lookAtConstraintWithTarget:_character]];
            [lightPivot addChildNode:lightHandle];
            _lightHandle = lightHandle;
            
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"eulerAngles.z"];
            animation.fromValue = @(M_PI_4*1.7);
            animation.toValue = @(-M_PI_4*0.3);
            animation.duration = 4;
            animation.autoreverses = YES;
            animation.repeatCount = MAXFLOAT;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            animation.timeOffset = animation.duration/2;
            [lightPivot addAnimation:animation forKey:@"lightAnim"];
        }
            break;
        case 5:
            [self.textManager fadeOutTextOfType:AAPLTextTypeCode];
            SCNNode *text = [self.textManager addCode:@"aLight.#shadowMode# =\n       #SCNShadowModeModulated#;\naLight.#gobo# = anImage;"];
            text.position = SCNVector3Make(text.position.x, text.position.y-11.5, text.position.z);
            [text enumerateChildNodesUsingBlock:^(SCNNode *child, BOOL *stop) {
                child.renderingOrder = 1;
                for(SCNMaterial *m in child.geometry.materials){
                    m.readsFromDepthBuffer = NO;
                    m.writesToDepthBuffer = NO;
                }
            }];

            
            [_lightHandle removeFromParentNode];
            
            [self restoreSpotPosition:presentationViewController];
            [self.textManager highlightBulletAtIndex:2];
            
            
            SCNNode *spot = presentationViewController.spotLight;
            spot.light.castsShadow = NO;
            
            SCNNode *head = [_character childNodeWithName:@"Bip001_Pelvis" recursively:YES];
            
            SCNNode *node = [SCNNode node];
            node.light = [SCNLight light];
            node.light.type = SCNLightTypeSpot;
            node.light.spotOuterAngle = 30.;
            [node setConstraints:@[[SCNLookAtConstraint lookAtConstraintWithTarget:head]]];
            node.position = SCNVector3Make(0, 220, 0);
            node.light.zNear = 10;
            node.light.zFar = 1000;
            node.light.gobo.contents = [NSImage imageNamed:@"blobShadow"];
            node.light.gobo.intensity = 0.65;
            node.light.shadowMode = SCNShadowModeModulated;
            
            //exclude character from shadow
            node.light.categoryBitMask = 0x1;
            [_character enumerateChildNodesUsingBlock:^(SCNNode *child, BOOL *stop) {
                child.categoryBitMask = 0x2;
            }];
            
            _projector = node;
            [_character addChildNode:node];
            
            break;
    }
}

- (void) restoreSpotPosition:(AAPLPresentationViewController *)presentationViewController
{
    SCNNode *spot = presentationViewController.spotLight;
    spot.light.castsShadow = YES;
    [_oldSpotParent addChildNode:spot];
    spot.position = _oldSpotPosition;
    spot.light.zNear = _oldSpotZNear;
    spot.light.shadowColor = _oldSpotShadowColor;
}

- (void)didOrderInWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
}

- (void) willOrderOutWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController
{
    [_projector removeFromParentNode];
    if(_oldSpotParent){
        [self restoreSpotPosition:presentationViewController];
    }
    
    if(_oldSpotShadowColor){
        SCNNode *spot = presentationViewController.spotLight;
        spot.light.shadowColor = _oldSpotShadowColor;
    }
}

@end
