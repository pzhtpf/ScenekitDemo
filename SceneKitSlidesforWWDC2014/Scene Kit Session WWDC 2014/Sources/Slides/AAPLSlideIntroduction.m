/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Introduction slide.
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideIntroduction : AAPLSlide
{
    NSMutableArray *_boxes;
    SCNNode *_icon1;
    SCNNode *_icon2;
}
@end

@implementation AAPLSlideIntroduction

- (NSUInteger)numberOfSteps {
    return 3;
}

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Set the slide's title and subtitle and add some text.
    self.textManager.title = @"SceneKit";
    self.textManager.subtitle = @"Introduction";
    [self.textManager addBullet:@"High level API for 3D integration" atLevel:0];
    [self.textManager addBullet:@"Data visualization" atLevel:1];
    [self.textManager addBullet:@"User interface" atLevel:1];
    [self.textManager addBullet:@"Casual games" atLevel:1];
    
    // Build the Cocoa graphics stack
    NSColor *redColor    = [NSColor colorWithDeviceRed:168 / 255.0 green:21 / 255.0 blue:1 / 255.0 alpha:1];
    NSColor *grayColor   = [NSColor grayColor];
    NSColor *greenColor  = [NSColor colorWithDeviceRed:105 / 255.0 green:145.0 / 255.0 blue:14.0 / 255.0 alpha:1];
    NSColor *orangeColor = [NSColor orangeColor];
    NSColor *purpleColor = [NSColor colorWithDeviceRed:152 / 255.0 green:57 / 255.0 blue:189 / 255.0 alpha:1];
    
    _boxes = [NSMutableArray array];
    
    [self addBoxWithTitle:@"Cocoa" frame:NSMakeRect(0, 0, 500, 70) level:3 color:grayColor];
    [self addBoxWithTitle:@"Core Image" frame:NSMakeRect(0, 0, 100, 70) level:2 color:greenColor];
    [self addBoxWithTitle:@"Core Animation" frame:NSMakeRect(390, 0, 110, 70) level:2 color:greenColor];
    [self addBoxWithTitle:@"SpriteKit" frame:NSMakeRect(250, 0, 135, 70) level:2 color:greenColor];
    [self addBoxWithTitle:@"SceneKit" frame:NSMakeRect(105, 0, 140, 70) level:2 color:orangeColor];
    [self addBoxWithTitle:@"OpenGL/OpenGL ES" frame:NSMakeRect(0, 0, 500, 70) level:1 color:purpleColor];
    [self addBoxWithTitle:@"Graphics Hardware" frame:NSMakeRect(0, 0, 500, 70) level:0 color:redColor];
}


- (void)presentStepIndex:(NSUInteger)index withPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    float delay = 0;
    
    switch (index) {
        case 0:
            break;
        case 1:
        {
            [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
            [self.textManager addBullet:@"Available on OS X 10.8+ and iOS 8.0" atLevel:0];
            [self.textManager flipInTextOfType:AAPLTextTypeBullet];
            
            //show some nice icons
            _icon1 = [SCNNode asc_planeNodeWithImageNamed:@"Badge_X.png" size:7.5 isLit:NO];
            _icon1.position = SCNVector3Make(-20, 3.5, 5);
            [self.groundNode addChildNode:_icon1];

            _icon2 = [SCNNode asc_planeNodeWithImageNamed:@"Badge_iOS.png" size:7 isLit:NO];
            _icon2.position = SCNVector3Make(20, 3.5, 5);
            [self.groundNode addChildNode:_icon2];

            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.75];
            _icon1.position = SCNVector3Make(-6, 3.5, 5);
            _icon2.position = SCNVector3Make(6, 3.5, 5);
            [SCNTransaction commit];
        }
            break;
        case 2:
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.75];
            _icon1.position = SCNVector3Make(-6, 3.5, -5);
            _icon2.position = SCNVector3Make(6, 3.5, -5);
            _icon1.opacity = 0.0;
            _icon2.opacity = 0.0;
            [SCNTransaction commit];
            
            for (SCNNode *node in _boxes){
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [SCNTransaction begin];
                    [SCNTransaction setAnimationDuration:0.5];
                    
                    node.rotation = SCNVector4Make(1, 0, 0, 0);
                    node.scale = SCNVector3Make(0.02, 0.02, 0.02);
                    node.opacity = 1.0;
                    
                    [SCNTransaction commit];
                });
                
                delay += 0.05;
            }
            
            
            [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
            [self.textManager flipOutTextOfType:AAPLTextTypeSubtitle];
            
            self.textManager.subtitle = @"Graphic Frameworks";
            
            [self.textManager flipInTextOfType:AAPLTextTypeBullet];
            [self.textManager flipInTextOfType:AAPLTextTypeSubtitle];
            
            break;
    }
}

- (void)addBoxWithTitle:(NSString *)title frame:(NSRect)frame level:(NSUInteger)level color:(NSColor *)color {
    SCNNode *node = [SCNNode asc_boxNodeWithTitle:title frame:frame color:color cornerRadius:2.0 centered:YES];
    node.pivot = SCNMatrix4MakeTranslation(0, frame.size.height / 2, 0);
    node.scale = SCNVector3Make(0.02, 0, 0.02);
    node.position = SCNVector3Make(-5, (0.02 * frame.size.height / 2) + (1.5 * level), 10.0);
    node.rotation = SCNVector4Make(1, 0, 0, M_PI_2);
    node.opacity = 0.0;
    [self.contentNode addChildNode:node];
    
    [_boxes addObject:node];
}

@end
