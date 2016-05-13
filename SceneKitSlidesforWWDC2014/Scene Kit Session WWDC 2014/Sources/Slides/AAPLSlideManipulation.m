
#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideManipulation : AAPLSlide
@end

@implementation AAPLSlideManipulation

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    self.textManager.title = @"Per-Frame Updates";
    self.textManager.subtitle = @"Game loop";
    
    SCNNode *gameLoop = [SCNNode asc_planeNodeWithImageNamed:@"gameLoop" size:20 isLit:NO];
    gameLoop.position = SCNVector3Make(0, 5.5, 10);
    [self.groundNode addChildNode:gameLoop];
}

@end
