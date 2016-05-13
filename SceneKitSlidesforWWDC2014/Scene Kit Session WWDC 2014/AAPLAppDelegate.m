/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  This is the main controller for the application. It instantiates and runs a presentation.
  
 */

#import "AAPLAppDelegate.h"
#import <IOKit/pwr_mgt/IOPMLib.h>

@implementation AAPLAppDelegate {
    AAPLPresentationViewController *_presentationViewController;
    IOPMAssertionID _assertionID;
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    [self disableDisplaySleeping];
    
    // Create a presentation from a plist file
    _presentationViewController = [[AAPLPresentationViewController alloc] initWithContentsOfFile:@"Scene Kit Presentation"];
    _presentationViewController.delegate = self;
    
    // Populate the 'Go' menu for direct access to slides
    [self populateGoMenu];
    
    // Start the presentation
    [self.window.contentView addSubview:_presentationViewController.presentationView];
    _presentationViewController.presentationView.frame = [self.window.contentView bounds];
    _presentationViewController.presentationView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
}

- (void) applicationDidFinishLaunching:(NSNotification *)notification
{
    [_presentationViewController applicationDidFinishLaunching];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    //restore default display settings
    [self enableDisplaySleeping];
}

#pragma mark - Presentation delegate

- (void)presentationViewController:(AAPLPresentationViewController *)presentationViewController willPresentSlideAtIndex:(NSUInteger)slideIndex step:(NSUInteger)step {
    // Update the window's title depending on the current slide
    if (step == 0) {
        self.window.title = [NSString stringWithFormat:@"SceneKit slide %ld", slideIndex];
    } else {
        self.window.title = [NSString stringWithFormat:@"SceneKit slide %ld step %ld", slideIndex, step];
    }
}

#pragma mark - 'Go' menu

- (void)populateGoMenu {
    for (NSUInteger i = 0; i < _presentationViewController.numberOfSlides; i++) {
        NSString *slideName = NSStringFromClass([_presentationViewController classOfSlideAtIndex:i]);
        NSRange prefixRange = NSMakeRange(0, @"AAPLSlide".length);
        NSString *title = [slideName stringByReplacingCharactersInRange:prefixRange withString:[NSString stringWithFormat:@"%lu ", (unsigned long)i]];
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:@selector(goTo:) keyEquivalent:@""];
        item.representedObject = @(i);
        [_goMenu addItem:item];
    }
}

#pragma mark - Actions

- (IBAction)nextSlide:(id)sender {
    [_presentationViewController goToNextSlideStep];
}

- (IBAction)previousSlide:(id)sender {
    [_presentationViewController goToPreviousSlide];
}

- (IBAction)goTo:(NSMenuItem *)sender {
    NSInteger index = [sender.representedObject integerValue];
    [_presentationViewController goToSlideAtIndex:index];
}

- (IBAction)exportSlidesToImages:(NSMenuItem *)sender {
    [_presentationViewController exportSlidesToImages:sender];
}

- (IBAction)exportSlidesToSCN:(NSMenuItem *)sender {
    [_presentationViewController exportSlidesToSCN:sender];
}

- (IBAction) autoPlay:(id) sender{
    [_presentationViewController autoPlay:sender];
}

- (IBAction)toggleCursor:(id)sender {
    static BOOL hidden = NO;
    if (hidden) {
        [NSCursor unhide];
        hidden = NO;
    } else {
        [NSCursor hide];
        hidden = YES;
    }
}

#pragma mark - NSApplicationDelegate

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

#pragma mark - Sleep

- (void)disableDisplaySleeping {
    CFStringRef reasonForActivity = CFSTR("Scene Kit Presentation");
    IOPMAssertionCreateWithName(kIOPMAssertionTypeNoDisplaySleep, kIOPMAssertionLevelOn, reasonForActivity, &_assertionID);
}

- (void)enableDisplaySleeping {
    if (_assertionID)
        IOPMAssertionRelease(_assertionID);
}

@end
