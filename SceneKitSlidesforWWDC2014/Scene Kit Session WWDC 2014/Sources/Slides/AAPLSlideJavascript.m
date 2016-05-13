#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideJS : AAPLSlide
@end

@implementation AAPLSlideJS {
}

- (NSUInteger)numberOfSteps {
    return 3;
}

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Set the slide's title and subtitle and add some code
    self.textManager.title = @"Scriptability";
    
    [self.textManager addBullet:@"Javascript bridge" atLevel:0];
    [self.textManager addCode:@"// setup a JSContext for SceneKit\n#SCNExportJavaScriptModule#(aJSContext);\n\n// reference a SceneKit object from JS\naJSContext.#globalObject#[@\"aNode\"] = aNode;\n\n// execute a script\n[aJSContext #evaluateScript#:@\"aNode.scale = {x:2, y:2, z:2};\";"];
}

- (void)presentStepIndex:(NSUInteger)index withPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    switch (index) {
        case 0:
            break;
        case 1:
            [self.textManager flipOutTextOfType:AAPLTextTypeCode];
            [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
            [self.textManager addEmptyLine];
            [self.textManager addBullet:@"Javascript code example" atLevel:0];
            [self.textManager addCode:@"\n#//allocate a node#\n"
             "var aNode = SCNNode.node();\n\n"
             
             "#//change opacity#\n"
             "aNode.opacity = 0.5;\n\n"
             
             "#//remove from parent#\n"
             "aNode.removeFromParentNode();\n\n"
             
             "#//animate implicitly#\n"
             "SCNTransaction.begin();\n"
             "SCNTransaction.setAnimationDuration(1.0);\n"
             "aNode.scale = {x:2, y:2, z:2};\n"
             "SCNTransaction.commit();"
             ];
            
            [self.textManager flipInTextOfType:AAPLTextTypeBullet];
            [self.textManager flipInTextOfType:AAPLTextTypeCode];
            
            break;
        case 2:
            [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
            [self.textManager flipOutTextOfType:AAPLTextTypeCode];
            [self.textManager addBullet:@"Tools" atLevel:0];
            [self.textManager addBullet:@"Debugging" atLevel:0];
            [self.textManager flipInTextOfType:AAPLTextTypeBullet];
            break;

    }
}

@end
