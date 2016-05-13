/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  AAPLView is a subclass of SCNView. The only thing it does is to force a resolution
  
 */

#import "AAPLView.h"

@implementation AAPLView

#if FORCE_RESOLUTION
- (NSRect) bounds
{
    CGFloat backingScaleFactor = [[self window] backingScaleFactor];
    if(backingScaleFactor == 0) backingScaleFactor = 1;
    
    return NSMakeRect(0, 0, floor(RESOLUTION_X / backingScaleFactor), floor(RESOLUTION_Y / backingScaleFactor));
}
#endif

@end
