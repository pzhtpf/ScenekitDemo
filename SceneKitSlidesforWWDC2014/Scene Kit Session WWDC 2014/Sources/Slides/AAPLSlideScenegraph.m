/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Explains the structure of the scene graph with a diagram.
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlideSceneGraph.h"
#import "Utils.h"

@implementation AAPLSlideSceneGraph

- (NSUInteger)numberOfSteps {
    return 4;
}

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Set the slide's title and subtitle and add some text
    self.textManager.title = @"Scene Graph";
    self.textManager.subtitle = @"Scene";
    [self.textManager addBullet:@"SCNScene" atLevel:0];
    [self.textManager addBullet:@"Starting point" atLevel:0];
    
    // Setup the diagram
    SCNNode *diagramNode = [[self class] sharedScenegraphDiagramNode];
    [self.groundNode addChildNode:diagramNode];
}

- (void)presentStepIndex:(NSUInteger)index withPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    SCNNode *diagramNode = [[self class] sharedScenegraphDiagramNode];
    [[self class] scenegraphDiagramGoToStep:index];
    
    switch (index) {
        case 0:
            diagramNode.opacity = 0.0;
            diagramNode.position = SCNVector3Make(0.0, 5.0, 3.0);
            diagramNode.rotation = SCNVector4Make(1, 0, 0, -M_PI_2);
            break;
        case 1:
        {
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0];
            {
                [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
                [self.textManager flipOutTextOfType:AAPLTextTypeSubtitle];
                
                // Change the slide's subtitle and add some text
                self.textManager.subtitle = @"Node";
                [self.textManager addBullet:@"SCNNode" atLevel:0];
                [self.textManager addBullet:@"A location in 3D space" atLevel:0];
                [self.textManager addBullet:@"Position, rotation, scale" atLevel:1];
                
                [self.textManager flipInTextOfType:AAPLTextTypeSubtitle];
                [self.textManager flipInTextOfType:AAPLTextTypeBullet];
            }
            [SCNTransaction commit];
            break;
        }
        case 2:
            [self.textManager addBullet:@"Hierarchy of nodes" atLevel:0];
            [self.textManager addBullet:@"Relative to the parent node" atLevel:1];
            break;
        case 3:
        {
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0];
            {
                [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
                [self.textManager flipOutTextOfType:AAPLTextTypeSubtitle];
                
                // Change the slide's subtitle and add some text
                self.textManager.subtitle = @"Node attributes";
                [self.textManager addBullet:@"Geometry" atLevel:0];
                [self.textManager addBullet:@"Camera" atLevel:0];
                [self.textManager addBullet:@"Light" atLevel:0];
                [self.textManager addBullet:@"Can be shared" atLevel:0];
                
                [self.textManager flipInTextOfType:AAPLTextTypeSubtitle];
                [self.textManager flipInTextOfType:AAPLTextTypeBullet];
            }
            [SCNTransaction commit];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            {
                // move the diagram up otherwise it would intersect the floor
                diagramNode.position = SCNVector3Make(0.0, diagramNode.position.y + 1.0, 3.0);
            }
            [SCNTransaction commit];
            break;
        }
    }
}

- (void)didOrderInWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    SCNNode *diagramNode = [[self class] sharedScenegraphDiagramNode];
    
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1.0];
    {
        diagramNode.opacity = 1.0;
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:0.0];
        diagramNode.rotation = SCNVector4Make(1, 0, 0, 0);
        [SCNTransaction commit];
        [[self class] showNodesNamed:@[@"scene"]];
    }
    [SCNTransaction commit];
}

+ (SCNNode *)sharedScenegraphDiagramNode {
    static SCNNode *diagramNode = nil;
    
    if (diagramNode == nil) {
        diagramNode = [SCNNode node];
        diagramNode.opacity = 0.0;
        
        // "Scene"
        NSColor* blue = [NSColor colorWithDeviceRed:44.0/255 green:137.0/255 blue:214/255.0 alpha:1];
        SCNNode *box = [SCNNode asc_boxNodeWithTitle:@"Scene" frame:NSMakeRect(-53.5, -25, 107, 50) color:blue cornerRadius:2 centered:YES];
        box.name = @"scene";
        box.scale = SCNVector3Make(0.03, 0.03, 0.03);
        box.position = SCNVector3Make(5.4, 4.8, 0);
        [diagramNode addChildNode:box];
        
        // Arrow from "Scene" to "Root Node"
        SCNNode *arrowNode = [SCNNode node];
        arrowNode.name = @"sceneArrow";
        arrowNode.geometry = [SCNShape shapeWithPath:[NSBezierPath asc_arrowBezierPathWithBaseSize:NSMakeSize(3,0.2) tipSize:NSMakeSize(0.5, 0.7) hollow:0.2 twoSides:NO] extrusionDepth:0];
        arrowNode.scale = SCNVector3Make(20, 20, 1);
        arrowNode.position = SCNVector3Make(-5, 0, 8);
        arrowNode.rotation = SCNVector4Make(0, 0, 1, -M_PI_2);
        arrowNode.geometry.firstMaterial.diffuse.contents = blue;
        [box addChildNode:arrowNode];
        
        // "Root Node"
        NSColor *green = [NSColor colorWithDeviceRed:58.0/255 green:166.0/255 blue:76.0/255 alpha:1];
        box = [SCNNode asc_boxNodeWithTitle:@"Root Node" frame:NSMakeRect(-40, -36, 80, 72) color:green cornerRadius:2 centered:YES];
        box.name = @"rootNode";
        box.scale = SCNVector3Make(0.03, 0.03, 0.03);
        box.position = SCNVector3Make(5.405, 1.8, 0);
        [diagramNode addChildNode:box];
        
        // Arrows from "Root Node" to child nodes
        arrowNode = [arrowNode clone];
        arrowNode.name = @"nodeArrow1";
        
        arrowNode.geometry = [SCNShape shapeWithPath:[NSBezierPath asc_arrowBezierPathWithBaseSize:NSMakeSize(5.8,0.15) tipSize:NSMakeSize(0.5, 0.7) hollow:0.2 twoSides:YES] extrusionDepth:0];
        arrowNode.position = SCNVector3Make(0, -30, 8);
        arrowNode.rotation = SCNVector4Make(0, 0, 1, -(M_PI * 0.85));
        arrowNode.geometry.firstMaterial.diffuse.contents = green;
        [box addChildNode:arrowNode];
        
        arrowNode = [arrowNode clone];
        arrowNode.name = @"nodeArrow2";
        arrowNode.position = SCNVector3Make(0, -43, 8);
        arrowNode.rotation = SCNVector4Make(0, 0, 1, -(M_PI * (1-0.85)));
        [box addChildNode:arrowNode];
        
        arrowNode = [arrowNode clone];
        arrowNode.name = @"nodeArrow3";
        arrowNode.geometry = [SCNShape shapeWithPath:[NSBezierPath asc_arrowBezierPathWithBaseSize:NSMakeSize(2.6,0.15) tipSize:NSMakeSize(0.5, 0.7) hollow:0.2 twoSides:YES] extrusionDepth:0];
        arrowNode.position = SCNVector3Make(-4, -38, 8);
        arrowNode.rotation = SCNVector4Make(0, 0, 1, -(M_PI * 0.5));
        arrowNode.geometry.firstMaterial.diffuse.contents = green;
        [box addChildNode:arrowNode];
        
        // Multiple "Child Node"
        box = [SCNNode asc_boxNodeWithTitle:@"Child Node" frame:NSMakeRect(-40, -36, 80, 72) color:green cornerRadius:2 centered:YES];
        box.name = @"child1";
        box.scale = SCNVector3Make(0.03, 0.03, 0.03);
        box.position = SCNVector3Make(2.405, -2, 0);
        [diagramNode addChildNode:box];
        
        box = [box clone];
        box.name = @"child2";
        box.position = SCNVector3Make(5.405, -2, 0);
        [diagramNode addChildNode:box];
        
        box = [box clone];
        box.name = @"child3";
        box.position = SCNVector3Make(8.405, -2, 0);
        [diagramNode addChildNode:box];
        
        // "Light"
        NSColor *purple = [NSColor colorWithDeviceRed:255.0/255 green:45.0/255 blue:85.0/255 alpha:1];
        box = [SCNNode asc_boxNodeWithTitle:@"Light" frame:NSMakeRect(-40, -20, 80, 40) color:purple cornerRadius:2 centered:YES];
        box.name = @"light";
        box.scale = SCNVector3Make(0.03, 0.03, 0.03);
        box.position = SCNVector3Make(2.405, -4.8, 0);
        [diagramNode addChildNode:box];
        
        // Arrow to "Light"
        arrowNode = [SCNNode node];
        arrowNode.name = @"lightArrow";
        arrowNode.geometry = [SCNShape shapeWithPath:[NSBezierPath asc_arrowBezierPathWithBaseSize:NSMakeSize(2.0,0.15) tipSize:NSMakeSize(0.5, 0.7) hollow:0.2 twoSides:NO] extrusionDepth:0];
        arrowNode.position = SCNVector3Make(-5, 60, 8);
        arrowNode.scale = SCNVector3Make(20, 20, 1);
        arrowNode.rotation = SCNVector4Make(0, 0, 1, -M_PI_2);
        arrowNode.geometry.firstMaterial.diffuse.contents = purple;
        [box addChildNode:arrowNode];
        
        // "Camera"
        box = [SCNNode asc_boxNodeWithTitle:@"Camera" frame:NSMakeRect(-45, -20, 90, 40) color:purple cornerRadius:2 centered:YES];
        box.name = @"camera";
        box.scale = SCNVector3Make(0.03, 0.03, 0.03);
        box.position = SCNVector3Make(5.25, -4.8, 0);
        [diagramNode addChildNode:box];
        
        // Arrow to "Camera"
        arrowNode = [arrowNode clone];
        arrowNode.name = @"cameraArrow";
        arrowNode.position = SCNVector3Make(0, 60, 8);
        [box addChildNode:arrowNode];
        
        // "Geometry"
        box = [SCNNode asc_boxNodeWithTitle:@"Geometry" frame:NSMakeRect(-55, -20, 110, 40) color:purple cornerRadius:2 centered:YES];
        box.name = @"geometry";
        box.scale = SCNVector3Make(0.03, 0.03, 0.03);
        box.position = SCNVector3Make(8.6, -4.8, 0);
        [diagramNode addChildNode:box];
        
        // Arrows to "Geometry"
        arrowNode = [arrowNode clone];
        arrowNode.name = @"geometryArrow";
        arrowNode.position = SCNVector3Make(-10, 60, 8);
        [box addChildNode:arrowNode];
        
        arrowNode = [arrowNode clone];
        arrowNode.name = @"geometryArrow2";
        arrowNode.geometry = [SCNShape shapeWithPath:[NSBezierPath asc_arrowBezierPathWithBaseSize:NSMakeSize(5.0,0.15) tipSize:NSMakeSize(0.5, 0.7) hollow:0.2 twoSides:NO] extrusionDepth:0];
        arrowNode.geometry.firstMaterial.diffuse.contents = purple;
        arrowNode.position = SCNVector3Make(-105, 53, 8);
        arrowNode.rotation = SCNVector4Make(0, 0, 1, -M_PI / 8);
        [box addChildNode:arrowNode];
        
        // Multiple "Material"
        NSColor *redColor = [NSColor colorWithDeviceRed:255.0/255 green:149.0/255 blue:0.0/255 alpha:1];
        
        SCNNode *materialsBox = [SCNNode asc_boxNodeWithTitle:nil frame:NSMakeRect(-151, -25, 302, 50) color:[NSColor grayColor] cornerRadius:2 centered:YES];
        materialsBox.scale = SCNVector3Make(0.03, 0.03, 0.03);
        materialsBox.name = @"materials";
        materialsBox.position = SCNVector3Make(8.7, -7.1, -0.2);
        [diagramNode addChildNode:materialsBox];
        
        box = [SCNNode asc_boxNodeWithTitle:@"Material" frame:NSMakeRect(-45, -20, 90, 40) color:redColor cornerRadius:0 centered:YES];
        box.position = SCNVector3Make(-100, 0, 0.2);
        [materialsBox addChildNode:box];
        
        box = [box clone];
        box.position = SCNVector3Make(100, 0, 0.2);
        [materialsBox addChildNode:box];
        
        box = [box clone];
        box.position = SCNVector3Make(0, 0, 0.2);
        [materialsBox addChildNode:box];
        
        // Arrow from "Geometry" to the materials
        arrowNode = [SCNNode node];
        arrowNode.geometry = [SCNShape shapeWithPath:[NSBezierPath asc_arrowBezierPathWithBaseSize:NSMakeSize(2.0,0.15) tipSize:NSMakeSize(0.5, 0.7) hollow:0.2 twoSides:NO] extrusionDepth:0];
        arrowNode.position = SCNVector3Make(-6, 65, 8);
        arrowNode.scale = SCNVector3Make(20, 20, 1);
        arrowNode.rotation = SCNVector4Make(0, 0, 1, -M_PI_2);
        arrowNode.geometry.firstMaterial.diffuse.contents = redColor;
        [box addChildNode:arrowNode];
        
        [materialsBox.parentNode replaceChildNode:materialsBox with:[materialsBox flattenedClone]];
    }
    
    return diagramNode;
}

+ (void)highlightNodesNamed:(NSArray *)names inNodeTree:(SCNNode *)node {
    for (SCNNode *child in node.childNodes) {
        if ([names containsObject:child.name]) {
            child.opacity = 1;
            [self highlightNodesNamed:names inNodeTree:child];
        }
        else {
            if (child.opacity == 1.0)
                child.opacity = 0.3;
        }
    }
}

+ (void)showNodesNamed:(NSArray *)names {
    SCNNode *diagramNode = [self sharedScenegraphDiagramNode];
    
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1.0];
    {
        for (NSString *nodeName in names) {
            SCNNode *node = [diagramNode childNodeWithName:nodeName recursively:YES];
            node.opacity = 1.0;
            if (node.rotation.z == 0.0)
                node.rotation = SCNVector4Make(0, 1, 0, 0);
        }
    }
    [SCNTransaction commit];
}

+ (void)scenegraphDiagramGoToStep:(NSUInteger)step {
    SCNNode *diagramNode = [[self class] sharedScenegraphDiagramNode];
    
    switch (step) {
        case 0:
            // Restore the initial state (hidden and rotated)
            [diagramNode childNodesPassingTest:^BOOL(SCNNode *child, BOOL *stop) {
                child.opacity = 0.0;
                if (child.rotation.z == 0) // don't touch nodes that already have a rotation set
                    child.rotation = SCNVector4Make(0, 1, 0, M_PI_2);
                return NO;
            }];
            break;
        case 1:
            [self showNodesNamed:@[@"sceneArrow", @"rootNode"]];
            break;
        case 2:
            [self showNodesNamed:@[@"child1", @"child2", @"child3", @"nodeArrow1", @"nodeArrow2", @"nodeArrow3"]];
            break;
        case 3:
            [self showNodesNamed:@[@"light", @"camera", @"geometry", @"lightArrow", @"cameraArrow", @"geometryArrow", @"geometryArrow2"]];
            break;
        case 4:
            [self showNodesNamed:@[@"scene", @"sceneArrow", @"rootNode", @"light", @"camera", @"cameraArrow", @"child1", @"child2", @"child3", @"nodeArrow1", @"nodeArrow2", @"nodeArrow3", @"geometry", @"lightArrow", @"geometryArrow", @"geometryArrow2"]];
            [self highlightNodesNamed:@[@"scene", @"sceneArrow", @"rootNode", @"light", @"camera", @"cameraArrow", @"child1", @"child2", @"child3", @"nodeArrow1", @"nodeArrow2", @"nodeArrow3", @"geometry", @"lightArrow", @"geometryArrow", @"geometryArrow2"] inNodeTree:diagramNode];
            break;
        case 5:
            [self showNodesNamed:@[@"scene", @"sceneArrow", @"rootNode", @"light", @"camera", @"cameraArrow", @"child1", @"child2", @"child3", @"nodeArrow1", @"nodeArrow2", @"nodeArrow3", @"geometry", @"lightArrow", @"geometryArrow", @"geometryArrow2", @"materials"]];
            [self highlightNodesNamed:@[@"scene", @"sceneArrow", @"rootNode", @"child2", @"child3", @"nodeArrow2", @"nodeArrow3", @"geometry", @"geometryArrow", @"geometryArrow2", @"materials"] inNodeTree:diagramNode];
            break;
        case 6:
            [self highlightNodesNamed:@[@"child3", @"geometryArrow", @"geometry"] inNodeTree:diagramNode];
            break;
        case 7:
            [self showNodesNamed:@[@"scene", @"sceneArrow", @"rootNode", @"light", @"camera", @"cameraArrow", @"child1", @"child2", @"child3", @"nodeArrow1", @"nodeArrow2", @"nodeArrow3", @"geometry", @"lightArrow", @"geometryArrow", @"geometryArrow2", @"materials"]];
            break;
    }
}

@end
