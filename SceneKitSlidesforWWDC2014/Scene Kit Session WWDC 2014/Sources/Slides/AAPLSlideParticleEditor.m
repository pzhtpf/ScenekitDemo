
#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideParticleEditor : AAPLSlide
@end

@implementation AAPLSlideParticleEditor

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Add some text
    self.textManager.title = @"3D Particle Editor";
    
    [self.textManager addBullet:@"Integrated into Xcode" atLevel:0];
    [self.textManager addBullet:@"Edit .scnp files" atLevel:0];
    [self.textManager addBullet:@"Particle templates available" atLevel:0];
}


- (void)didOrderInWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Bring up a screenshot of the editor
    SCNNode *editorScreenshotNode = [SCNNode asc_planeNodeWithImageNamed:@"particleEditor" size:14 isLit:YES];
//    editorScreenshotNode.geometry.firstMaterial.diffuse.mipFilter = SCNLinearFiltering;
    editorScreenshotNode.position = SCNVector3Make(17, 3.8, 5);
    editorScreenshotNode.rotation = SCNVector4Make(0, 1, 0, -M_PI / 1.5);
    [self.groundNode addChildNode:editorScreenshotNode];
    
    // Animate it (rotate and move)
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1.0];
    {
        editorScreenshotNode.position = SCNVector3Make(7, 3.8, 5);
        editorScreenshotNode.rotation = SCNVector4Make(0, 1, 0, -M_PI / 7.0);
    }
    [SCNTransaction commit];
}


@end
