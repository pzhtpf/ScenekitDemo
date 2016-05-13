/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Illustrates how instances of CALayer can be used with material properties.
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"
#import <GLKit/GLKMath.h>
#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>

#define USE_SPRITEKIT 0

@interface AAPLSlideMaterialLayer : AAPLSlide
@end

//AAPLSlideMaterialLayer *materialLayerSlideReference;

@implementation AAPLSlideMaterialLayer {
    SKVideoNode *_videoNode;
    AVPlayerLayer *_playerLayer1;
    AVPlayerLayer *_playerLayer2;
    SCNMaterial *_material;
    SCNNode *_object;
}

- (NSUInteger)numberOfSteps {
    return 5;
}

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController
{
    // Set the slide's title and subtitle and add some text
    self.textManager.title = @"Materials";
    self.textManager.subtitle = @"Property contents";
    
    [self.textManager addBullet:@"Color" atLevel:0];
    [self.textManager addBullet:@"CGColorRef, NSColor, UIColor" atLevel:1];
    
    SCNNode *code = [self.textManager addCode:@"material.diffuse.contents = #[UIColor redColor]#;"];
    
    code.position = SCNVector3Make(code.position.x+5, code.position.y - 9.5, code.position.z);
    
#define W 8
    SCNNode *node = [SCNNode node];
    node.name = @"material-cube";
    node.geometry = [SCNBox boxWithWidth:W height:W length:W chamferRadius:W*0.02];
    
    _material = node.geometry.firstMaterial;
    _material.diffuse.contents = [NSColor redColor];
    
    _object = node;
    
    node.position = SCNVector3Make(8, 11, 0);
    [self.contentNode addChildNode:node];
    [node runAction:[SCNAction repeatActionForever:[SCNAction rotateByAngle:M_PI*2 aroundAxis:SCNVector3Make(0.4, 1, 0) duration:4]]];

    //materialLayerSlideReference = self;
}

- (void)presentStepIndex:(NSUInteger)index withPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    switch (index) {
        case 0:
        {
            break;
        }
        case 1:
        {
            [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
            [self.textManager fadeOutTextOfType:AAPLTextTypeCode];
            
            [self.textManager addBullet:@"Image" atLevel:0];
            [self.textManager addBullet:@"Name, path, URL" atLevel:1];
            [self.textManager addBullet:@"NSImage, UIImage, NSData" atLevel:1];
            [self.textManager addBullet:@"SKTexture" atLevel:1];
            
            [self.textManager flipInTextOfType:AAPLTextTypeBullet];
            
            
            SCNNode *code = [self.textManager addCode:@"material.diffuse.contents = #@\"slate.jpg\"#;"];
            code.position = SCNVector3Make(code.position.x+6, code.position.y - 6.5, code.position.z);
            
            _material.diffuse.contents = @"slate.jpg";
            _material.normal.contents = @"slate-bump.png";
            _material.normal.intensity = 0;
        }
            break;
            
        case 2:
        {
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            _material.normal.intensity = 5.0;
            _material.specular.contents = [NSColor grayColor];
            [SCNTransaction commit];
            
            SCNNode *code = [self.textManager addCode:@"material.normal.contents = #[SKTexture textureByGeneratingNormalMap]#;"];
            code.position = SCNVector3Make(code.position.x+2, code.position.y - 6.5, code.position.z);
            
        }
            break;
        case 3:
        {
            [self.textManager fadeOutTextOfType:AAPLTextTypeCode];
            [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
            [self.textManager addBullet:@"Live contents" atLevel:0];
            [self.textManager addBullet:@"CALayer tree" atLevel:1];
            [self.textManager addBullet:@"SKScene (new)" atLevel:1];
            [self.textManager flipInTextOfType:AAPLTextTypeBullet];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            _material.normal.intensity = 2.0;
            [SCNTransaction commit];
            
            // Load movies and display movie layers
            AVPlayerLayer * (^configurePlayer)(NSURL *, NSString *) = ^(NSURL *movieURL, NSString *hostingNodeName) {
                AVPlayer *player = [AVPlayer playerWithURL:movieURL];
                player.actionAtItemEnd = AVPlayerActionAtItemEndNone; // loop
                
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(playerItemDidReachEnd:)
                                                                             name:AVPlayerItemDidPlayToEndTimeNotification
                                                                           object:player.currentItem];
                
                                [player play];
                
                // Set an arbitrary frame. This frame will be the size of our movie texture so if it is too small it will appear scaled up and blurry, and if it is too big it will be slow
                AVPlayerLayer *playerLayer = [[AVPlayerLayer alloc] init];
                playerLayer.player = player;
                playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                playerLayer.frame = CGRectMake(0,0,600,800);
                
                // Use a parent layer with a background color set to black
                // That way if the movie is stil loading and the frame is transparent, we won't see holes in the model
                CALayer *backgroundLayer = [CALayer layer];
                backgroundLayer.backgroundColor = CGColorGetConstantColor(kCGColorBlack);
                backgroundLayer.frame = CGRectMake(0, 0, 600, 800);
                [backgroundLayer addSublayer:playerLayer];
                
                SCNNode *frameNode = [self.contentNode childNodeWithName:hostingNodeName recursively:YES];
                SCNMaterial *material = frameNode.geometry.firstMaterial;
                material.diffuse.contents = backgroundLayer;
                
                return playerLayer;
            };
            
            _playerLayer1 = configurePlayer([[NSBundle mainBundle] URLForResource:@"movie1" withExtension:@"mov"], @"material-cube");
        }
            break;
        case 4:
        {
            [_videoNode pause];
            
            [self.textManager flipOutTextOfType:AAPLTextTypeBullet];
            [self.textManager addEmptyLine];
            
            [self.textManager addBullet:@"Cube map" atLevel:0];
            [self.textManager addBullet:@"NSArray of 6 items" atLevel:1];
            [self.textManager flipInTextOfType:AAPLTextTypeBullet];
            
            SCNNode *code = [self.textManager addCode:@"material.reflective.contents = #@[@\"right.png\", @\"left.png\" ... @\"front.png\"]#;"];
            code.position = SCNVector3Make(code.position.x, code.position.y - 9.5, code.position.z);
            
            
            SCNNode *image = [SCNNode asc_planeNodeWithImageNamed:@"cubemap.png" size:12 isLit:NO];
            image.position = SCNVector3Make(-10, 9, 0);
            image.opacity = 0;
            [self.contentNode addChildNode:image];
            
            
            
            _object.geometry = [SCNTorus torusWithRingRadius:W*0.5 pipeRadius:W*0.2];
            _material = _object.geometry.firstMaterial;
            _object.rotation = SCNVector4Make(1, 0, 0, M_PI_2);
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            _material.reflective.contents = @[@"right.tga", @"left.tga", @"top.tga", @"bottom.tga", @"back.tga", @"front.tga"];
            _material.diffuse.contents = [NSColor redColor];
            image.opacity = 1.0;
            [SCNTransaction commit];
        }
            
            break;
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *playerItem = notification.object;
    [playerItem seekToTime:kCMTimeZero];
}

- (void)willOrderOutWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
#if !USE_SPRITEKIT
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerLayer1.player.currentItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerLayer2.player.currentItem];
    
    [_playerLayer1.player pause];
    [_playerLayer2.player pause];
    
    _playerLayer1.player = nil;
    _playerLayer2.player = nil;
#else
    [_videoNode pause];
#endif
    
    // Stop playing scene animations, restore the original point of view and restore the default spot light mode
    presentationViewController.presentationView.playing = NO;
    presentationViewController.presentationView.pointOfView = presentationViewController.cameraNode;
    [presentationViewController narrowSpotlight:NO];
}

@end
