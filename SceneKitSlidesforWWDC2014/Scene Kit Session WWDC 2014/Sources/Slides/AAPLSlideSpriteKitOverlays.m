
#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideSpriteKitOverlays : AAPLSlide
@end

@implementation AAPLSlideSpriteKitOverlays

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    self.textManager.title = @"SpriteKit Overlays";
    
    [self.textManager addBullet:@"Game score, gauges, time, menus..." atLevel:0];
    [self.textManager addBullet:@"Event handling" atLevel:0];
    SCNNode *node = [self.textManager addCode:@"scnView.#overlaySKScene# = aSKScene;"];
    node.position = SCNVector3Make(9, 0.7, 0);
    
    SCNNode *gameLoop = [SCNNode asc_planeNodeWithImageNamed:@"overlays" size:10 isLit:NO];
    gameLoop.position = SCNVector3Make(0, 2.9, 13);
    [self.groundNode addChildNode:gameLoop];
}

- (NSUInteger)numberOfSteps
{
    return 2;
}

- (void)presentStepIndex:(NSUInteger)index withPresentationViewController:(AAPLPresentationViewController *)presentationViewController
{
    switch(index){
        case 0:
            break;
        case 1:
            [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
            [self.textManager addEmptyLine];
            [self.textManager addBullet:@"Portability" atLevel:0];
            [self.textManager addBullet:@"Performance" atLevel:0];
            [self.textManager flipInTextOfType:AAPLTextTypeBullet];
            break;
    }
}

@end
