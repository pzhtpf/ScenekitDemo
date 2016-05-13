/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:

This is the main controller for the application. It instantiates and runs a presentation.

*/

#import <SceneKit/SceneKit.h>
#import "AAPLPresentationViewController.h"

@interface AAPLAppDelegate : NSObject <NSApplicationDelegate, AAPLPresentationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSMenu *goMenu;

// Go to the previous or next slide
- (IBAction)nextSlide:(id)sender;
- (IBAction)previousSlide:(id)sender;

@end
