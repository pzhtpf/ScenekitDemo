/*
 <codex>
 <abstract>Explains how flattening nodes can help with performance.</abstract>
 </codex>
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideFlattening : AAPLSlide
@end

@implementation AAPLSlideFlattening

- (NSUInteger)numberOfSteps {
    return 2;
}

- (void)presentStepIndex:(NSUInteger)index withPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    switch (index) {
        case 0:
        {
            // Set the slide's title and subtitle and add some text.
            self.textManager.title = @"Performance";
            self.textManager.subtitle = @"Flattening";
            
            [self.textManager addBullet:@"Flatten node tree into single node" atLevel:0];
            [self.textManager addBullet:@"Minimize draw calls" atLevel:0];
            
            [self.textManager addCode:
             @"// Flatten node hierarchy \n"
             @"SCNNode *flattenedNode = [aNode #flattenedClone#];"];
            
            break;
        }
        case 1:
        {
            // Discard the text and show a 2D image.
            // Animate the image's position when it appears.
            
            [self.textManager flipOutTextOfType:AAPLTextTypeCode];
            [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
            
            SCNNode *imageNode = [SCNNode asc_planeNodeWithImageNamed:@"flattening" size:20 isLit:NO];
            imageNode.position = SCNVector3Make(0, 4.8, 16);
            [self.groundNode addChildNode:imageNode];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            {
                imageNode.position = SCNVector3Make(0, 4.8, 8);
            }
            [SCNTransaction commit];
        }
    }
}

@end
