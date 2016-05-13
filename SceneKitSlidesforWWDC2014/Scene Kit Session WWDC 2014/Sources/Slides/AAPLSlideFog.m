#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

#import <SceneKit/SceneKit.h>

@interface AAPLSlideFog : AAPLSlide
{
    SCNNode *backgroundNode;
}
@end

@implementation AAPLSlideFog


- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Set the slide's title and add some text
    self.textManager.title = @"Fog";
    self.textManager.subtitle = @"SCNScene";
    
    [self.textManager addEmptyLine];
    [self.textManager addCode:@"// set some fog\n"
     @"aScene.#fogColor# = aColor;\n"
     @"aScene.#fogStartDistance# = 50;\n"
     @"aScene.#fogEndDistance# = 100;"
     ];
    
    //add palm trees
    SCNNode *palmTree = [self.groundNode asc_addChildNodeNamed:@"PalmTree" fromSceneNamed:@"Scenes.scnassets/palmTree/palm_tree" withScale:15];
    palmTree.position = SCNVector3Make(4, -1, 0);
    
    palmTree = [palmTree clone];
    [self.groundNode addChildNode:palmTree];
    palmTree.position = SCNVector3Make(0, -1, 7);

    palmTree = [palmTree clone];
    [self.groundNode addChildNode:palmTree];
    palmTree.position = SCNVector3Make(8, -1, 13);

    palmTree = [palmTree clone];
    [self.groundNode addChildNode:palmTree];
    palmTree.position = SCNVector3Make(13, -1, -7);
    
    palmTree = [palmTree clone];
    [self.groundNode addChildNode:palmTree];
    palmTree.position = SCNVector3Make(-13, -1, -14);

    palmTree = [palmTree clone];
    [self.groundNode addChildNode:palmTree];
    palmTree.position = SCNVector3Make(3, -1, -14);
}

- (NSUInteger) numberOfSteps
{
    return 3;
}

- (void)presentStepIndex:(NSUInteger)index withPresentationViewController:(AAPLPresentationViewController *)presentationViewController
{
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1.0];

    switch(index){
        case 0:
            break;
        case 1:
            //add a plan in the background
        {
            [self.textManager fadeOutTextOfType:AAPLTextTypeCode];
            [self.textManager fadeOutTextOfType:AAPLTextTypeSubtitle];
            
            SCNNode *bg = [SCNNode node];
            SCNPlane *plane = [SCNPlane planeWithWidth:100 height:100];
            bg.geometry = plane;
            bg.position = SCNVector3Make(0, 0, -60);
            [presentationViewController.cameraNode addChildNode:bg];
            
            backgroundNode = bg;
            
            presentationViewController.presentationView.scene.fogColor = [NSColor whiteColor];
            presentationViewController.presentationView.scene.fogStartDistance = 10;
            presentationViewController.presentationView.scene.fogEndDistance = 50;
        }
            break;
        case 2:
            presentationViewController.presentationView.scene.fogDensityExponent = 0.3;
            break;
    }

    [SCNTransaction commit];
}

- (void) willOrderOutWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController
{
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:0.5];
    [SCNTransaction setCompletionBlock:^{
        [backgroundNode removeFromParentNode];
    }];
    presentationViewController.presentationView.scene.fogColor = [NSColor blackColor];
    presentationViewController.presentationView.scene.fogEndDistance = 45.0;
    presentationViewController.presentationView.scene.fogDensityExponent = 1.0;
    presentationViewController.presentationView.scene.fogStartDistance = 40.0;
    [SCNTransaction commit];
}

@end
