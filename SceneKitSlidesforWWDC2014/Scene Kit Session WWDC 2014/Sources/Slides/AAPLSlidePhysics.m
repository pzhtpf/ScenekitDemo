#import <GLKit/GLKMath.h>

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

#define USE_GAME_ICON 0

static CGFloat randFloat(CGFloat min, CGFloat max)
{
    return min + (max - min) * (CGFloat)rand() / RAND_MAX;
}


@interface AAPLSlidePhysics : AAPLSlide
{
    dispatch_source_t _timer;
    NSMutableArray *_dices;
    NSMutableArray *_balls;
    NSMutableArray *_shapes;
    NSMutableArray *_meshes;
    NSMutableArray *_hinges;
    NSMutableArray *_kinematicItems;
    
    NSUInteger _step;
}
@end

@implementation AAPLSlidePhysics {
}

- (NSUInteger)numberOfSteps {
    return 20;
}

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController
{
    _shapes = [NSMutableArray array];
    _dices = [NSMutableArray array];
    _balls = [NSMutableArray array];
    _meshes = [NSMutableArray array];
    _hinges = [NSMutableArray array];
    _kinematicItems = [NSMutableArray array];
    
    // Set the slide's title and subtitle and add some text
    self.textManager.title = @"Physics";
    
    [self.textManager addBullet:@"Nodes are automatically animated by SceneKit" atLevel:0];
    [self.textManager addBullet:@"Same approach as SpriteKit" atLevel:0];
}


/* sequence:
 
- SCNPhysicsBody
  - dynamic objects: cubes (dices?) / spheres in container
  - static objects: stairs + spheres?
  - kinematics objects: cards / roulettes?
  - shapes
  - meshes
- SCNPhysicsBehavior
  - constraints
- SCNPhsyicsWorld
  - contacts
- SCNVehicle
  - demo
 */


- (void)presentStepIndex:(NSUInteger)index withPresentationViewController:(AAPLPresentationViewController *)presentationViewController
{
    _step = index;
    
    switch (index) {
        case 0:
            break;
        case 1:
        {
            [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
            
            self.textManager.subtitle = @"SCNPhysicsBody";
            
            [self.textManager flipInTextOfType:AAPLTextTypeSubtitle];
            
            [self.textManager addBullet:@"Dynamic bodies" atLevel:0];
            
            // Add some code
            [self.textManager addCode:
             @"// Make a node dynamic\n"
             @"aNode.#physicsBody# = [SCNPhysicsBody #dynamicBody#];"];
            
            [self.textManager flipInTextOfType:AAPLTextTypeBullet];
            [self.textManager flipInTextOfType:AAPLTextTypeCode];
        }
            break;
        case 2:
        {
#if USE_GAME_ICON
            SCNNode *node = [SCNNode nodeWithPixelatedImage:[NSImage imageNamed:@"game.png"] pixelSize:0.25];
            SCNVector3 worldPos = [self.groundNode convertPosition:SCNVector3Make(0, 0, 7) toNode:nil];
            node.position = worldPos;
            
            
            [presentationViewController.presentationView.scene.rootNode addChildNode:node];
            
            __block float f = 1;
            //add to scene
            [node enumerateChildNodesUsingBlock:^(SCNNode *child, BOOL *stop) {
                child.transform = child.worldTransform;
                [presentationViewController.presentationView.scene.rootNode addChildNode:child];
                [_dices addObject:child];
                
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
                animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeRotation(f*100.0, f*10, f*20, f*30), CATransform3DMakeTranslation(0, 0, -50))];
                animation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
                animation.additive = YES;
                animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
                animation.duration = 1.0;
                animation.fillMode = kCAFillModeBoth;
                animation.beginTime = CACurrentMediaTime()+f;
                [child addAnimation:animation forKey:nil];
                
                f-=0.01;
            }];
            
            [node removeFromParentNode];
#else
            
            //add a cube
            SCNVector3 worldPos = [self.groundNode convertPosition:SCNVector3Make(0, 12, 2) toNode:nil];
            SCNNode *dice = [self blockAtPosition:worldPos size:SCNVector3Make(1.5, 1.5, 1.5)];
            dice.physicsBody = nil; //wait!
            dice.rotation = SCNVector4Make(0, 0, 1, M_PI_4*0.5);
            dice.scale = SCNVector3Make(0.001, 0.001, 0.001);
            
            [presentationViewController.presentationView.scene.rootNode addChildNode:dice];
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.75];
            dice.scale = SCNVector3Make(2, 2, 2);
            [SCNTransaction commit];
            
            [_dices addObject:dice];
            
#endif
        }
            break;
        case 3:
        {
            float f = 7;
            for(SCNNode *node in _dices){
                [node setPhysicsBody:[SCNPhysicsBody dynamicBody]];
#if USE_GAME_ICON
                [node.physicsBody applyForce:SCNVector3Make(0,f,-f*0.5) atPosition:SCNVector3Zero impulse:YES];
#endif
                f-=0.03;
            }
        }
            break;
        case 4:
#if !USE_GAME_ICON
            [self presentDices:presentationViewController];
#endif
            break;
        case 5:
            [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
            [self.textManager flipOutTextOfType:AAPLTextTypeCode];
            
            [self.textManager addBullet:@"Manipulate with forces" atLevel:0];
            
            // Add some code
            [self.textManager addCode:
             @"// Apply an impulse\n"
             @"[aNode.physicsBody #applyForce:#aVector3 #atPosition:#aVector3 #impulse:#YES];"];
            
            [self.textManager flipInTextOfType:AAPLTextTypeBullet];
            [self.textManager flipInTextOfType:AAPLTextTypeCode];
            break;
        case 6:
        {
            // remove dices
            SCNVector3 center = SCNVector3Make(0,-5,20);
            center = [self.groundNode convertPosition:center toNode:nil];
            
            [self explosionAt:center receivers:_dices];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [self.textManager flipOutTextOfType:AAPLTextTypeCode];
                [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
                
                [self.textManager addBullet:@"Static bodies" atLevel:0];
                [self.textManager addCode:
                 @"// Make a node static\n"
                 @"aNode.#physicsBody# = [SCNPhysicsBody #staticBody#];"];
                [self.textManager flipInTextOfType:AAPLTextTypeBullet];
                [self.textManager flipInTextOfType:AAPLTextTypeCode];
            });
            
        }
            break;
        case 7:
            [self presentWalls:presentationViewController];
            break;
        case 8:
            [self presentBalls:presentationViewController];
            break;
        case 9:
        {
            //remove walls
            NSMutableArray *walls = [NSMutableArray array];
            [self.groundNode enumerateChildNodesUsingBlock:^(SCNNode *child, BOOL *stop) {
                if([child.name isEqualToString:@"container-wall"]){
                    [child runAction:[SCNAction sequence:@[[SCNAction moveBy:SCNVector3Make(0, -2, 0) duration:0.5], [SCNAction removeFromParentNode]]]];
                    [walls addObject:child];
                }
            }];
        }
            break;
        case 10:
        {
            // remove balls
            SCNVector3 center = SCNVector3Make(0,-5,5);
            center = [self.groundNode convertPosition:center toNode:nil];
            [self explosionAt:center receivers:_balls];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.textManager flipOutTextOfType:AAPLTextTypeCode];
                [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
                
                [self.textManager addBullet:@"Kinematic bodies" atLevel:0];
                [self.textManager addCode:
                 @"// Make a node kinematic\n"
                 @"aNode.#physicsBody# = [SCNPhysicsBody #kinematicBody#];"];
                [self.textManager flipInTextOfType:AAPLTextTypeBullet];
                [self.textManager flipInTextOfType:AAPLTextTypeCode];
            });
        }
            break;
        
        case 11:
        {
#define MIDDLE_Z 0
            SCNNode *boxNode = [SCNNode node];
            boxNode.geometry = [SCNBox boxWithWidth:10 height:0.2 length:10 chamferRadius:0];
            boxNode.position = SCNVector3Make(0, 5, MIDDLE_Z);
            boxNode.geometry.firstMaterial.emission.contents = [NSColor darkGrayColor];
            boxNode.physicsBody = [SCNPhysicsBody kinematicBody];
            [boxNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:0 z:M_PI * 2 duration:2.0]]];
            [self.groundNode addChildNode:boxNode];
            [_kinematicItems addObject:boxNode];
            
            SCNNode *invisibleWall = [SCNNode node];
            invisibleWall.geometry = [SCNBox boxWithWidth:4 height:40 length:10 chamferRadius:0];
            invisibleWall.position = SCNVector3Make(-7, 0, MIDDLE_Z);
            invisibleWall.geometry.firstMaterial.transparency = 0;
            invisibleWall.physicsBody = [SCNPhysicsBody staticBody];
            [self.groundNode addChildNode:invisibleWall];
            [_kinematicItems addObject:invisibleWall];

            invisibleWall = [invisibleWall copy];
            invisibleWall.position = SCNVector3Make(7, 0, MIDDLE_Z);
            [self.groundNode addChildNode:invisibleWall];
            [_kinematicItems addObject:invisibleWall];

            invisibleWall = [invisibleWall copy];
            invisibleWall.geometry = [SCNBox boxWithWidth:10 height:40 length:4 chamferRadius:0];
            invisibleWall.geometry.firstMaterial.transparency = 0;
            invisibleWall.position = SCNVector3Make(0, 0, MIDDLE_Z-7);
            invisibleWall.physicsBody = [SCNPhysicsBody staticBody];
            [self.groundNode addChildNode:invisibleWall];
            [_kinematicItems addObject:invisibleWall];

            invisibleWall = [invisibleWall copy];
            invisibleWall.position = SCNVector3Make(0, 0, MIDDLE_Z+7);
            [self.groundNode addChildNode:invisibleWall];
            [_kinematicItems addObject:invisibleWall];

            
            for(int i=0; i<100; i++){
                SCNNode *ball = [SCNNode node];
                SCNVector3 worldPos = [boxNode convertPosition:SCNVector3Make(randFloat(-4, 4), randFloat(10, 30), randFloat(-1, 4)) toNode:nil];
                ball.position = worldPos;
                ball.geometry = [SCNSphere sphereWithRadius:0.5];
                ball.geometry.firstMaterial.diffuse.contents = [NSColor cyanColor];
                ball.physicsBody = [SCNPhysicsBody dynamicBody];
                [presentationViewController.presentationView.scene.rootNode addChildNode:ball];
                
                [_kinematicItems addObject:ball];
            }

        }
            break;
        
        case 12:
        {
            [self.textManager flipOutTextOfType:AAPLTextTypeCode];
            [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
            [self.textManager flipOutTextOfType:AAPLTextTypeSubtitle];
            self.textManager.subtitle  = @"SCNPhysicsShape";
            [self.textManager addCode:
             @"// Configure the physics shape\n"
             @"aNode.physicsBody.#physicsShape# = \n\t[#SCNPhysicsShape# shapeWithGeometry:aGeometry options:options];"];
            [self.textManager flipInTextOfType:AAPLTextTypeBullet];
            [self.textManager flipInTextOfType:AAPLTextTypeCode];
            
            [[_kinematicItems objectAtIndex:0] runAction:[SCNAction sequence:@[[SCNAction fadeOutWithDuration:0.5], [SCNAction removeFromParentNode]]]];
            for(int i=1; i<5; i++)
                [[_kinematicItems objectAtIndex:i] removeFromParentNode];

            NSUInteger count = [_kinematicItems count];
            for(NSUInteger i=5; i<count; i++){
                SCNNode *node = [_kinematicItems objectAtIndex:i];

                [node runAction:[SCNAction sequence:@[[SCNAction waitForDuration:5],[SCNAction runBlock:^(SCNNode *owner){
                    owner.transform = owner.presentationNode.transform;
                    owner.physicsBody = nil;
                }],[SCNAction scaleBy:0.001 duration:0.5], [SCNAction removeFromParentNode]]]];
            }
            [_kinematicItems removeAllObjects];
        }
            break;
        case 13:
            //add meshes
            [self presentMeshes:presentationViewController];
            break;
        case 14:
        {
            // remove meshes
            SCNVector3 center = SCNVector3Make(0,-5,20);
            center = [self.groundNode convertPosition:center toNode:nil];
            [self explosionAt:center receivers:_meshes];
        }
            break;
        case 15:
            // add shapes
            [self presentPrimitives:presentationViewController];
            break;
        case 16:
        {
            // remove shapes
            SCNVector3 center = SCNVector3Make(0,-5,20);
            center = [self.groundNode convertPosition:center toNode:nil];
            [self explosionAt:center receivers:_shapes];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.textManager flipOutTextOfType:AAPLTextTypeCode];
                [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
                [self.textManager flipOutTextOfType:AAPLTextTypeSubtitle];
                
                self.textManager.subtitle = @"SCNPhysicsBehavior";
                [self.textManager addCode:
                 @"// setup a physics behavior\n"
                 @"#SCNPhysicsHingeJoint# *joint = [SCNPhysicsHingeJoint\n"
                 @"   jointWithBodyA:#nodeA.physicsBody# axisA:[...] anchorA:[...]\n"
                 @"            bodyB:#nodeB.physicsBody# axisB:[...] anchorB:[...]];\n\n"
                 @"[scene.#physicsWorld# addBehavior:joint];"];
                [self.textManager flipInTextOfType:AAPLTextTypeBullet];
                [self.textManager flipInTextOfType:AAPLTextTypeSubtitle];
                [self.textManager flipInTextOfType:AAPLTextTypeCode];
            });
        }
            break;
        case 17:
            //add meshes
            [self presentHinge:presentationViewController];
            break;
            
        case 18:
            //remove constraints
            [presentationViewController.presentationView.scene.physicsWorld removeAllBehaviors];
            
            for(SCNNode *node in _hinges)
                [node runAction:[SCNAction sequence:@[[SCNAction waitForDuration:3.0], [SCNAction fadeOutWithDuration:0.5], [SCNAction removeFromParentNode]]]];
            
            break;
        case 19:
            [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
            [self.textManager flipOutTextOfType:AAPLTextTypeSubtitle];
            [self.textManager flipOutTextOfType:AAPLTextTypeCode];
            
            self.textManager.subtitle = @"More...";
            
            [self.textManager flipInTextOfType:AAPLTextTypeSubtitle];
            
            [self.textManager addBullet:@"SCNPhysicsField" atLevel:0];
            [self.textManager addBullet:@"SCNPhysicsVehicle" atLevel:0];
            
            [self.textManager flipInTextOfType:AAPLTextTypeBullet];
            [self.textManager flipInTextOfType:AAPLTextTypeCode];
            
    }
}

- (void)didOrderInWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController
{
    presentationViewController.presentationView.scene.physicsWorld.speed = 2;
}

- (void)willOrderOutWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController
{
    presentationViewController.presentationView.scene.physicsWorld.speed = 0;
    
    for(SCNNode *node in _dices){
        [node removeFromParentNode];
    }
    for(SCNNode *node in _balls){
        [node removeFromParentNode];
    }
    for(SCNNode *node in _shapes){
        [node removeFromParentNode];
    }
    for(SCNNode *node in _meshes){
        [node removeFromParentNode];
    }
    for(SCNNode *node in _hinges){
        [node removeFromParentNode];
    }
    
    [presentationViewController.presentationView.scene.physicsWorld removeAllBehaviors];
}

- (void) explosionAt:(SCNVector3) center receivers:(NSArray *)nodes
{
    GLKVector3 c = SCNVector3ToGLKVector3(center);
    
    for(SCNNode *node in nodes){
        GLKVector3 p = SCNVector3ToGLKVector3(node.presentationNode.position);
        GLKVector3 dir = GLKVector3Subtract(p, c);
        
        float force = 25;
        float distance = GLKVector3Length(dir);
        
        dir = GLKVector3MultiplyScalar(dir, force / MAX(0.01, distance));
        
        [node.physicsBody applyForce:SCNVector3FromGLKVector3(dir) atPosition:SCNVector3Make(randFloat(-0.2, 0.2), randFloat(-0.2, 0.2), randFloat(-0.2, 0.2)) impulse:YES];
        
        [node runAction:[SCNAction sequence:@[[SCNAction waitForDuration:2], [SCNAction fadeOutWithDuration:0.5], [SCNAction removeFromParentNode]]]];
    }
}

- (SCNNode *)poolBallWithPosition:(SCNVector3)position
{
    SCNNode *model = [SCNNode node];
    model.position = position;
    model.geometry = [SCNSphere sphereWithRadius:0.7];
    model.geometry.firstMaterial.diffuse.contents = @"Scenes.scnassets/pool/pool_8.png";
    model.physicsBody = [SCNPhysicsBody dynamicBody];
    return model;
}

- (SCNGeometry *) blockMeshWithSize:(SCNVector3) size
{
    SCNBox *diceMesh = [SCNBox boxWithWidth:size.x height:size.y length:size.z chamferRadius:0.05 * size.x];
    
    diceMesh.firstMaterial.diffuse.contents = @"texture.png";
    diceMesh.firstMaterial.diffuse.mipFilter = YES;
    diceMesh.firstMaterial.diffuse.wrapS = SCNWrapModeRepeat;
    diceMesh.firstMaterial.diffuse.wrapT = SCNWrapModeRepeat;
    
    return diceMesh;
}

- (SCNNode *)blockAtPosition:(SCNVector3)position size:(SCNVector3) size
{
    static SCNGeometry *diceMesh = NULL;
    
    if (!diceMesh) {
        diceMesh = [self blockMeshWithSize:size];
    }
    
    SCNNode *model = [SCNNode node];
    model.position = position;
    model.geometry = diceMesh;
    model.physicsBody =  [SCNPhysicsBody dynamicBody];
    
    return model;
}

- (void) presentDices:(AAPLPresentationViewController *)presentationViewController
{
    int count = 200;
    float spread = 6;
    
    // drop rigid bodies cubes
    uint64_t intervalTime = NSEC_PER_SEC * 5.0 / count;
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), intervalTime, 0); // every ms
    
    __block NSInteger remainingCount = count;
    dispatch_source_set_event_handler(_timer, ^{
        
        if(_step > 4){
            dispatch_source_cancel(_timer);
            return;
        }
        
        [SCNTransaction begin];
        
        SCNVector3 worldPos = [self.groundNode convertPosition:SCNVector3Make(0, 30, 0) toNode:nil];
        
        SCNNode *dice = [self blockAtPosition:worldPos size:SCNVector3Make(1.5, 1.5, 1.5)];
        
        //add to scene
        [presentationViewController.presentationView.scene.rootNode addChildNode:dice];
        
        [dice.physicsBody setVelocity:SCNVector3Make(randFloat(-spread, spread), -10, randFloat(-spread, spread))];
        [dice.physicsBody setAngularVelocity:SCNVector4Make(randFloat(-1, 1),randFloat(-1, 1),randFloat(-1, 1),randFloat(-3, 3))];
        [SCNTransaction commit];
        
        [_dices addObject:dice];
        
        // ensure we stop firing
        if (--remainingCount < 0)
            dispatch_source_cancel(_timer);
    });
    
    dispatch_resume(_timer);
}

- (void) presentWalls:(AAPLPresentationViewController *)presentationViewController
{
    //add spheres and container
    CGFloat height = 2;
    CGFloat width = 1.0;
    
    int count = 3;
    CGFloat margin = 2;
    
    CGFloat totalWidth = count * (margin + width);
    
    SCNGeometry *blockMesh = [self blockMeshWithSize:SCNVector3Make(width, height, width)];
    
    for( int i=0 ;i<count; i++){
        //create a static block
        SCNNode * wall = [SCNNode node];
        wall.position = SCNVector3Make((i-(count/2)) *(width + margin), -height/2, totalWidth/2);
        wall.geometry = blockMesh;
        wall.name = @"container-wall";
        wall.physicsBody = [SCNPhysicsBody staticBody];
        
        [self.groundNode addChildNode:wall];
        [wall runAction:[SCNAction moveBy:SCNVector3Make(0, height, 0) duration:0.5]];
        
        //one more
        wall = [wall copy];
        wall.position = SCNVector3Make((i-(count/2)) *(width + margin), -height/2, -totalWidth/2);
        [self.groundNode addChildNode:wall];

        // one more
        wall = [wall copy];
        wall.position = SCNVector3Make(totalWidth/2, -height/2, (i-(count/2)) *(width + margin));
        [self.groundNode addChildNode:wall];
        
        //one more
        wall = [wall copy];
        wall.position = SCNVector3Make(-totalWidth/2, -height/2, (i-(count/2)) *(width + margin));
        [self.groundNode addChildNode:wall];
    }
}

- (void) presentBalls:(AAPLPresentationViewController *)presentationViewController
{
    int count = 150;
    
    for (int i = 0; i < count; ++i) {
        SCNVector3 worldPos = [self.groundNode convertPosition:SCNVector3Make(randFloat(-5, 5), randFloat(25, 30), randFloat(-5, 5)) toNode:nil];
        
        SCNNode *ball = [self poolBallWithPosition:worldPos];
        
        [presentationViewController.presentationView.scene.rootNode addChildNode:ball];
        [_balls addObject:ball];
    }
}

- (void) presentPrimitives:(AAPLPresentationViewController *) presentationViewController
{
    int count = 100;
    float spread = 0;
    
    // create a cube with a sphere shape
    for (int i = 0; i < count; ++i) {
        SCNNode *model = [SCNNode node];
        model.position = [self.groundNode convertPosition:SCNVector3Make(randFloat(-1, 1), randFloat(30, 50), randFloat(-1, 1)) toNode:nil];
        model.eulerAngles = SCNVector3Make(randFloat(0, M_PI * 2), randFloat(0, M_PI * 2), randFloat(0, M_PI * 2));
        
        SCNVector3 size = SCNVector3Make(randFloat(1.0, 1.5), randFloat(1.0, 1.5), randFloat(1.0, 1.5));
        int geometryIndex = rand() % 8;
        switch (geometryIndex) {
            case 0: // Box
                model.geometry = [SCNBox boxWithWidth:size.x height:size.y length:size.z chamferRadius:0];
                break;
            case 1: // Pyramid
                model.geometry = [SCNPyramid pyramidWithWidth:size.x height:size.y length:size.z];
                break;
            case 2: // Sphere
                model.geometry = [SCNSphere sphereWithRadius:size.x];
                break;
            case 3: // Cylinder
                model.geometry = [SCNCylinder cylinderWithRadius:size.x height:size.y];
                break;
            case 4: // Cone
                //model.geometry = [SCNCone coneWithTopRadius:0 bottomRadius:size.x height:size.y];
                break;
            case 5: // Tube
                model.geometry = [SCNTube tubeWithInnerRadius:size.x outerRadius:(size.x+size.z) height:size.y];
                break;
            case 6: // Capsule
                model.geometry = [SCNCapsule capsuleWithCapRadius:size.x height:(size.y + 2 * size.x)];
                break;
            case 7: // Torus
                model.geometry = [SCNTorus torusWithRingRadius:size.x pipeRadius:fmin(size.x, size.y) / 2];
                break;
            default:
                break;
        }
        
        //        model.geometry.firstMaterial.diffuse.contents = [NSColor colorWithCalibratedHue:randFloat(0, 1) saturation:1.0 brightness:1.0 alpha:1.0];
        model.geometry.firstMaterial.multiply.contents = @"texture.png";
        
        model.physicsBody = [SCNPhysicsBody dynamicBody];
        [model.physicsBody setVelocity:SCNVector3Make(randFloat(-spread, spread), -10, randFloat(-spread, spread))];
        [model.physicsBody setAngularVelocity:SCNVector4Make(randFloat(-1, 1),randFloat(-1, 1),randFloat(-1, 1),randFloat(-3, 3))];
        
        [_shapes addObject:model];
        
        [presentationViewController.presentationView.scene.rootNode addChildNode:model];
    }
}

- (void) presentMeshes:(AAPLPresentationViewController *) presentationViewController
{
    // add meshes
    SCNNode *container = [SCNNode node];
    SCNNode *black = [container asc_addChildNodeNamed:@"teapot" fromSceneNamed:@"Scenes.scnassets/lod/midResTeapot.dae" withScale:5];
    //SCNNode *white = [container asc_addChildNodeNamed:@"white" fromSceneNamed:@"pawn.dae" withScale:2];
    
    //    black.physicsBody = [SCNPhysicsBody dynamicBody];
    //    white.physicsBody = [SCNPhysicsBody dynamicBody];
    
    //    SCNVector3 min, max;
    //    [black getBoundingBoxMin:&min max:&max];
    //    black.pivot = SCNMatrix4MakeTranslation((min.x+max.x) * 0.5, (min.y+max.y) * 0.5, (min.z+max.z) * 0.5);
    //    white.pivot = black.pivot;
    
    int count = 100;
    for (int i = 0; i < count; ++i) {
        SCNVector3 worldPos = [self.groundNode convertPosition:SCNVector3Make(randFloat(-1, 1), randFloat(30, 50), randFloat(-1, 1)) toNode:nil];
        
        //        SCNNode *object = (i&1) ? [black copy] : [white copy];
        SCNNode *object = [black copy];
        object.position = worldPos;
        object.physicsBody = [SCNPhysicsBody dynamicBody]; //FIX ME!
        object.physicsBody.friction = 0.5;
        
        [presentationViewController.presentationView.scene.rootNode addChildNode:object];
        [_meshes addObject:object];
    }
}

- (void) presentHinge:(AAPLPresentationViewController *) presentationViewController
{
    int count = 10;
    
    SCNMaterial *material = [SCNMaterial material];
    material.diffuse.contents = [NSColor whiteColor];
    material.specular.contents = [NSColor whiteColor];
    material.locksAmbientWithDiffuse = YES;
    
    CGFloat cubeWidth = 10./count;
    CGFloat cubeHeight = 0.2;
    CGFloat cubeLength = 5.0;
    CGFloat offset = 0;
    CGFloat height = 5 + count * cubeWidth;
    
    SCNNode *oldModel = nil;
    for (int i = 0; i < count; ++i) {
        SCNNode *model = [SCNNode node];
        
        SCNMatrix4 worldtr = [self.groundNode convertTransform:SCNMatrix4MakeTranslation(-offset + cubeWidth * i, height, 5) toNode:nil];
        
        model.transform = worldtr;
        
        model.geometry = [SCNBox boxWithWidth:cubeWidth height:cubeHeight length:cubeLength chamferRadius:0];
        model.geometry.firstMaterial = material;
        
        SCNPhysicsBody *body = [SCNPhysicsBody dynamicBody];
        body.restitution = 0.6;
        model.physicsBody = body;
        
        [presentationViewController.presentationView.scene.rootNode addChildNode:model];
        
        SCNPhysicsHingeJoint *joint = [SCNPhysicsHingeJoint jointWithBodyA:model.physicsBody axisA:SCNVector3Make(0, 0, 1) anchorA:SCNVector3Make(-cubeWidth*0.5, 0, 0) bodyB:oldModel.physicsBody axisB:SCNVector3Make(0, 0, 1) anchorB:SCNVector3Make(cubeWidth*0.5, 0, 0)];
        [presentationViewController.presentationView.scene.physicsWorld addBehavior:joint];
        
        [_hinges addObject:model];
        
        oldModel = model;
    }
}


@end
