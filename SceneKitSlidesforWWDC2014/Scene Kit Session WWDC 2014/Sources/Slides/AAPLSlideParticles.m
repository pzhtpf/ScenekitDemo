#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

typedef enum {
    Step0,
    StepFire,
    StepFireScreen,
//    StepFireSubtract,
    StepLocal,
    StepGravity,
    StepCollider,
    StepFields,
    StepFieldsVortex,
    StepSubSystems,
    StepConfetti,
    StepEmitterCube,
    StepEmitterSphere,
    StepEmitterTorus,
    StepCount
    
} ParticleSteps;

@interface AAPLSlideParticles : AAPLSlide
{
    SCNNode *_hole;
    SCNNode *_hole2;
    SCNNode *_floorNode;
    SCNNode *_boxNode;
    SCNNode *_particleHolder;
    SCNNode *_fieldOwner;
    SCNNode *_vortexFieldOwner;
    SCNParticleSystem *_snow;
    SCNParticleSystem *_bokeh;
}
@end

SCNVector3 SCNVector3CrossProduct(const SCNVector3 a, const SCNVector3 b){
    //  return a.yzx * b.zxy - a.zxy * b.yzx;
    SCNVector3 out;
    out.x = a.y*b.z - a.z*b.y;
    out.y = a.z*b.x - a.x*b.z;
    out.z = a.x*b.y - a.y*b.x;
    return out;
}

CGFloat SCNVector3Length(const SCNVector3 a){
    return (CGFloat) (sqrt (a.x * a.x + a.y * a.y + a.z * a.z));
}


SCNVector3 SCNVector3Normalize(const SCNVector3 a){
    CGFloat invlen = 1.0 / SCNVector3Length(a);
    SCNVector3 out;
    out.x = a.x * invlen;
    out.y = a.y * invlen;
    out.z = a.z * invlen;
    return out;
}

@implementation AAPLSlideParticles

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Set the slide's title and add some text
    self.textManager.title = @"Particles";
    self.textManager.subtitle = @"SCNParticleSystem";
    [self.textManager addBullet:@"Achieve a large number of effects" atLevel:0];
    [self.textManager addBullet:@"3D particle editor built into Xcode" atLevel:0];
}

/*
 -> emitter shape
 
 fire/reactor  -> color ramp
 smoke -> local/global
 etincelles -> gravity + colliders
 rain -> subsystem
 snow -> fields
 
 bokeh  (multiple images)
 
 xcode editor
 
// explosions
 
  */

- (NSUInteger) numberOfSteps
{
    return StepCount;
}

static inline SCNVector3 __cross(SCNVector3 a, SCNVector3 b)
{
    SCNVector3 c;
    
    c.x = a.y*b.z - a.z*b.y;
    c.y = a.z*b.x - a.x*b.z;
    c.z = a.x*b.y - a.y*b.x;
    
    return c;
}

- (void)presentStepIndex:(NSUInteger)index withPresentationViewController:(AAPLPresentationViewController *)presentationViewController
{
#define HOLE_Z 10
    switch(index)
    {
        case StepFire:
        {
            [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
            
            [self.textManager addEmptyLine];
            [self.textManager addBullet:@"Particle image" atLevel:0];
            [self.textManager addBullet:@"Color over life duration" atLevel:0];
            [self.textManager addBullet:@"Size over life duration" atLevel:0];
            [self.textManager addBullet:@"Several blend modes" atLevel:0];
            
            [self.textManager flipInTextOfType:AAPLTextTypeBullet];
            
            SCNNode *hole = [SCNNode node];
            hole.geometry = [SCNTube tubeWithInnerRadius:1.7 outerRadius:1.9 height:1.5];
            hole.position = SCNVector3Make(0, 0, HOLE_Z);
            hole.scale = SCNVector3Make(1, 0, 1);
            
            [self.groundNode addChildNode:hole];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            
            hole.scale = SCNVector3Make(1,1,1);
            
            [SCNTransaction commit];
            
            SCNParticleSystem *ps = [SCNParticleSystem particleSystemNamed:@"fire" inDirectory:nil];
            [hole addParticleSystem:ps];
            
            _hole = hole;
        }
            break;
        case StepFireScreen:
        {
            SCNParticleSystem *ps = [[_hole particleSystems] firstObject];
            ps.blendMode = SCNParticleBlendModeScreen;
        } break;
/*
        case StepFireSubtract:
        {
            NSColor *col = [NSColor colorWithCalibratedWhite:0.7 alpha:1.0];

            [CATransaction begin];
            [CATransaction setAnimationDuration:5.5];
            presentationViewController.presentationView.backgroundColor = col;
            [CATransaction commit];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:5.5];
            presentationViewController.presentationView.scene.fogColor = col;
            [SCNTransaction commit];
            
            SCNParticleSystem *ps = [[_hole particleSystems] firstObject];
            ps.blackPassEnabled = NO;
            ps.blendMode = SCNParticleBlendModeSubtract;
        } break;
 */
        case StepLocal:
        {
            [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
            
            [self.textManager addBullet:@"Local or global" atLevel:0];
            [self.textManager flipInTextOfType:AAPLTextTypeBullet];
            
            [_hole removeAllParticleSystems];
            _hole2 = [_hole clone];
            _hole2.geometry = [_hole.geometry copy];
            _hole2.position = SCNVector3Make(0, -2, HOLE_Z-4);
            [self.groundNode addChildNode:_hole2];
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            _hole2.position = SCNVector3Make(0, 0, HOLE_Z-4);
            [SCNTransaction commit];
            
            SCNParticleSystem *ps = [SCNParticleSystem particleSystemNamed:@"smoke" inDirectory:nil];
            ps.particleColorVariation = SCNVector4Make(0, 0, 0.5, 0);
            [_hole addParticleSystem:ps];

            SCNParticleSystem *localPs = [ps copy];
            localPs.particleImage = ps.particleImage; // FIXME: remove when <rdar://problem/16957114> ParticleSystems does not copy its image
            localPs.local = YES;
            [_hole2 addParticleSystem:localPs];
            
            {
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
                animation.fromValue = [NSValue valueWithSCNVector3:SCNVector3Make(7, 0, HOLE_Z)];
                animation.toValue = [NSValue valueWithSCNVector3:SCNVector3Make(-7, 0, HOLE_Z)];
                animation.beginTime = CACurrentMediaTime() + 0.75;
                animation.duration = 8;
                animation.autoreverses = YES;
                animation.repeatCount = MAXFLOAT;
                animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                animation.timeOffset = animation.duration/2;
                [_hole addAnimation:animation forKey:@"animateHole"];
            }
            {
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
                animation.fromValue = [NSValue valueWithSCNVector3:SCNVector3Make(-7, 0, HOLE_Z-4)];
                animation.toValue = [NSValue valueWithSCNVector3:SCNVector3Make(7, 0, HOLE_Z-4)];
                animation.beginTime = CACurrentMediaTime() + 0.75;
                animation.duration = 8;
                animation.autoreverses = YES;
                animation.repeatCount = MAXFLOAT;
                animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                animation.timeOffset = animation.duration/2;
                [_hole2 addAnimation:animation forKey:@"animateHole"];
            }
        }
            break;
            
        case StepGravity:
        {
            [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
            
            [self.textManager addBullet:@"Affected by gravity" atLevel:0];
            [self.textManager flipInTextOfType:AAPLTextTypeBullet];
         
            [_hole2 removeAllParticleSystems];
            [_hole2 runAction:[SCNAction sequence:@[[SCNAction scaleTo:0 duration:0.5], [SCNAction removeFromParentNode]]]];
            [_hole removeAllParticleSystems];
            [_hole removeAnimationForKey:@"animateHole" fadeOutDuration:0.5];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            
            SCNTube *tube = (SCNTube*) _hole.geometry;
            tube.innerRadius = 0.3;
            tube.outerRadius = 0.4;
            tube.height = 1.0;
            
            [SCNTransaction commit];
            
            
            
            SCNParticleSystem *ps = [SCNParticleSystem particleSystemNamed:@"sparks" inDirectory:nil];
            [_hole removeAllParticleSystems];
            [_hole addParticleSystem:ps];
            
            _floorNode = [presentationViewController.presentationView.scene.rootNode childNodesPassingTest:^BOOL(SCNNode *child, BOOL *stop) {
                return [child.geometry isKindOfClass:[SCNFloor class]];
            }][0];
            
            ps.colliderNodes = @[_floorNode];
            
            break;
        }
            
        case StepCollider:
        {
            
            [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
            
            [self.textManager addBullet:@"Affected by colliders" atLevel:0];
            [self.textManager flipInTextOfType:AAPLTextTypeBullet];
            
            SCNNode *boxNode = [SCNNode node];
            boxNode.geometry = [SCNBox boxWithWidth:5 height:0.2 length:5 chamferRadius:0];
            boxNode.position = SCNVector3Make(0, 7, HOLE_Z);
            boxNode.geometry.firstMaterial.emission.contents = [NSColor darkGrayColor];
            
            [self.groundNode addChildNode:boxNode];
            
            SCNParticleSystem*ps = [_hole particleSystems][0];
            ps.colliderNodes = @[_floorNode, boxNode];
            
            
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"eulerAngles"];
            animation.fromValue = [NSValue valueWithSCNVector3:SCNVector3Make(0, 0, M_PI_4*1.7)];
            animation.toValue = [NSValue valueWithSCNVector3:SCNVector3Make(0, 0, -M_PI_4*1.7)];
            animation.beginTime = CACurrentMediaTime() + 0.5;
            animation.duration = 2;
            animation.autoreverses = YES;
            animation.repeatCount = MAXFLOAT;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            animation.timeOffset = animation.duration/2;
            [boxNode addAnimation:animation forKey:@"animateHole"];
            
            _boxNode = boxNode;
        }
            break;
        case StepFields:
        {
            [_hole removeAllParticleSystems];

            [_hole runAction:[SCNAction sequence:@[[SCNAction scaleTo:0 duration:0.75], [SCNAction removeFromParentNode]]]];
            
            [_boxNode runAction:[SCNAction sequence:@[[SCNAction moveByX:0 y:15 z:0 duration:1.0], [SCNAction removeFromParentNode]]]];
            
            SCNNode *particleHolder = [SCNNode node];
            particleHolder.position = SCNVector3Make(0, 20, HOLE_Z);
            [self.groundNode addChildNode:particleHolder];
            
            _particleHolder = particleHolder;

            
            [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
            [self.textManager addBullet:@"Affected by physics fields" atLevel:0];
            [self.textManager flipInTextOfType:AAPLTextTypeBullet];
            
            SCNParticleSystem *ps = [SCNParticleSystem particleSystemNamed:@"snow" inDirectory:nil];
            ps.affectedByPhysicsFields = YES;
            [_particleHolder addParticleSystem:ps];
            _snow = ps;
            
            //physics field
            SCNPhysicsField *field = [SCNPhysicsField turbulenceFieldWithSmoothness:50 animationSpeed:1];
            field.halfExtent = SCNVector3Make(20, 20, 20);
            field.strength = 4.0;
            
            SCNNode *fieldOwner = [SCNNode node];
            fieldOwner.position = SCNVector3Make(0, 5, HOLE_Z);
            
            [self.groundNode addChildNode:fieldOwner];
            fieldOwner.physicsField = field;
            _fieldOwner = fieldOwner;
            
            ps.colliderNodes = @[_floorNode];
        }
            break;
        case StepFieldsVortex:
        {
            _vortexFieldOwner = [SCNNode node];
            _vortexFieldOwner.position = SCNVector3Make(0, 5, HOLE_Z);
            
            [self.groundNode addChildNode:_vortexFieldOwner];

            //tornado
            __block SCNVector3 _worldOrigin = SCNVector3Make(_fieldOwner.worldTransform.m41,_fieldOwner.worldTransform.m42,_fieldOwner.worldTransform.m43);
            __block SCNVector3 _worldAxis = (SCNVector3) {0,1,0};
            
#define VS 20.0
#define VW 10.0

            SCNPhysicsField *vortex = [SCNPhysicsField customFieldWithEvaluationBlock:^SCNVector3(SCNVector3 position, SCNVector3 velocity, float mass, float charge, NSTimeInterval time) {
                SCNVector3 l;
                l.x = _worldOrigin.x - position.x;
                l.z = _worldOrigin.z - position.z;
                SCNVector3 t = __cross(_worldAxis, l);
                float d2 = (l.x*l.x + l.z*l.z);
                float vs = VS / sqrt(d2);
                float fy = 1.0 - (MIN(1.0,(position.y/ 15.0)));
                return SCNVector3Make(t.x * vs + l.x * VW * fy, 0, t.z * vs + l.z * VW * fy);
            }];
            vortex.halfExtent = SCNVector3Make(100, 100, 100);
            _vortexFieldOwner.physicsField = vortex;
        }
            break;
        case StepSubSystems:
        {
            [_fieldOwner removeFromParentNode];
            [_particleHolder removeAllParticleSystems];
            _snow.dampingFactor = -1;
            
            [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
            [self.textManager addBullet:@"Sub-particle system on collision" atLevel:0];
            [self.textManager flipInTextOfType:AAPLTextTypeBullet];
            
            SCNParticleSystem *ps = [SCNParticleSystem particleSystemNamed:@"rain" inDirectory:nil];
            SCNParticleSystem *pss = [SCNParticleSystem particleSystemNamed:@"plok" inDirectory:nil];
            pss.idleDuration = 0;
            pss.loops = NO;
            
            [ps setSystemSpawnedOnCollision:pss];
            
            [_particleHolder addParticleSystem:ps];
            ps.colliderNodes = @[_floorNode];
        }
            break;
        case StepConfetti:
        {
            [_particleHolder removeAllParticleSystems];
            
            [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
            [self.textManager addBullet:@"Custom blocks" atLevel:0];
            [self.textManager flipInTextOfType:AAPLTextTypeBullet];
            
            {
                SCNParticleSystem *ps = [SCNParticleSystem particleSystem];
                ps.emitterShape = [SCNBox boxWithWidth:20 height:0 length:5 chamferRadius:0];
                ps.birthRate = 100;
                ps.particleLifeSpan = 5;
                ps.particleLifeSpanVariation = 0;
                ps.spreadingAngle = 20;
                ps.particleSize = 0.25;
                ps.particleVelocity = 5;
                ps.particleVelocityVariation = 2;
                ps.birthDirection = SCNParticleBirthDirectionConstant;
                ps.emittingDirection = SCNVector3Make(0, -1, 0);
                ps.birthLocation = SCNParticleBirthLocationVolume;
                ps.particleImage = @"confetti.png";
                ps.lightingEnabled = YES;
                ps.orientationMode = SCNParticleOrientationModeFree;
                ps.sortingMode = SCNParticleSortingModeDistance;
                ps.particleAngleVariation = 180;
                ps.particleAngularVelocity = 200;
                ps.particleAngularVelocityVariation = 400;
                ps.particleColor = [NSColor greenColor];
                ps.particleColorVariation = SCNVector4Make(0.2, 0.1, 0.1, 0);
                ps.particleBounce = 0;
                ps.particleFriction = 0.6;
                ps.colliderNodes = @[_floorNode];
                ps.blendMode = SCNParticleBlendModeAlpha;
                
                CAKeyframeAnimation *floatAnimation = [CAKeyframeAnimation animationWithKeyPath:nil];
                floatAnimation.values = @[@1, @1, @0];
                floatAnimation.keyTimes = @[@0, @0.9, @1];
                floatAnimation.duration = 1.0;
                floatAnimation.additive = NO;
                
                ps.propertyControllers = @{ SCNParticlePropertyOpacity: [SCNParticlePropertyController controllerWithAnimation:floatAnimation] };
                
                [ps handleEvent:SCNParticleEventBirth forProperties:@[SCNParticlePropertyColor] withBlock:^(void **data, size_t *dataStride, uint32_t *indices , NSInteger count) {
                    
                    for (NSInteger i = 0; i < count; ++i) {
                        float *col = (float *)((char *)data[0] + dataStride[0] * i);
                        if (rand() & 0x1) { // swith green for red
                            col[0] = col[1];
                            col[1] = 0;
                        }
                        
                    }
                }];
                
                [ps handleEvent:SCNParticleEventCollision forProperties:@[SCNParticlePropertyAngle, SCNParticlePropertyRotationAxis, SCNParticlePropertyAngularVelocity, SCNParticlePropertyVelocity, SCNParticlePropertyContactNormal] withBlock:^(void **data, size_t *dataStride, uint32_t *indices , NSInteger count) {
                    
                    for (NSInteger i = 0; i < count; ++i) {
                        // fix orientation
                        float *angle = (float *)((char *)data[0] + dataStride[0] * indices[i]);
                        float *axis = (float *)((char *)data[1] + dataStride[1] * indices[i]);
                        
                        float *colNrm = (float *)((char *)data[4] + dataStride[4] * indices[i]);
                        SCNVector3 collisionNormal = {colNrm[0], colNrm[1], colNrm[2]};
                        SCNVector3 cp = SCNVector3CrossProduct(collisionNormal, SCNVector3Make(0, 0, 1));
                        CGFloat cpLen = SCNVector3Length(cp);
                        angle[0] = asin(cpLen);
                        
                        axis[0] = cp.x / cpLen;
                        axis[1] = cp.y / cpLen;
                        axis[2] = cp.z / cpLen;
                        
                        // kill angular rotation
                        float *angVel = (float *)((char *)data[2] + dataStride[2] * indices[i]);
                        angVel[0] = 0;
                        
                        if (colNrm[1] > 0.4) {
                            float *vel = (float *)((char *)data[3] + dataStride[3] * indices[i]);
                            vel[0] = 0;
                            vel[1] = 0;
                            vel[2] = 0;
                        }
                    }
                }];
                
                [_particleHolder addParticleSystem:ps];
                _particleHolder.position = SCNVector3Make(0, 15, HOLE_Z);

            }
        }
            break;

        case StepEmitterCube:
        {
            [_particleHolder removeAllParticleSystems];
            
            [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
            [self.textManager addBullet:@"Emitter shape" atLevel:0];
            [self.textManager flipInTextOfType:AAPLTextTypeBullet];
            
            [_particleHolder removeFromParentNode];
            
            SCNParticleSystem *ps = [SCNParticleSystem particleSystemNamed:@"emitters" inDirectory:nil];
            ps.local = YES;
            [_particleHolder addParticleSystem:ps];
            
            SCNNode *node = [SCNNode node];
            node.position = SCNVector3Make(3, 6, HOLE_Z);
            [node runAction:[SCNAction repeatActionForever:[SCNAction rotateByAngle:M_PI * 2 aroundAxis:SCNVector3Make(0.3, 1, 0) duration:8]]];
            [self.groundNode addChildNode:node];
            _bokeh = ps;
            
            [node addParticleSystem:ps];
        }
            break;
        case StepEmitterSphere:
        {
            _bokeh.emitterShape = [SCNSphere sphereWithRadius:5];
        }
            break;
        case StepEmitterTorus:
        {
            _bokeh.emitterShape = [SCNTorus torusWithRingRadius:5 pipeRadius:1];
        }
            break;
    }
    
}

- (void)willOrderOutWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    [presentationViewController.presentationView.scene removeAllParticleSystems];
}

@end
