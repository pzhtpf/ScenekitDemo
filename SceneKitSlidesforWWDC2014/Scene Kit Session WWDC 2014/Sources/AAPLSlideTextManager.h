/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  AAPLSlideTextManager manages the layout of the different types of text presented in the slides.
  
 */

#import <SceneKit/SceneKit.h>

typedef NS_ENUM(NSInteger, AAPLTextType) {
    AAPLTextTypeNone,
    AAPLTextTypeChapter,
    AAPLTextTypeTitle,
    AAPLTextTypeSubtitle,
    AAPLTextTypeBullet,
    AAPLTextTypeBody,
    AAPLTextTypeCode,
    AAPLTextTypeFootPrint,
    AAPLTextTypeCount
};

@interface AAPLSlideTextManager : NSObject

#pragma mark - Add text content to the slide

- (SCNNode *)setTitle:(NSString *)title;
- (SCNNode *)setSubtitle:(NSString *)title;
- (SCNNode *)setChapterTitle:(NSString *)title;
- (SCNNode *)addBullet:(NSString *)text atLevel:(NSUInteger)level;
- (SCNNode *)addCode:(NSString *)text;
- (SCNNode *)addText:(NSString *)text atLevel:(NSUInteger)level;
- (SCNNode *)addFootPrint:(NSString *)text;
- (void)addEmptyLine;

#pragma mark - Animations

- (void)highlightBulletAtIndex:(NSUInteger)index;
- (void)highlightCodeChunks:(NSArray *)chunks;
- (void)flipOutTextOfType:(AAPLTextType)type;
- (void)flipInTextOfType:(AAPLTextType)type;
- (void)fadeOutTextOfType:(AAPLTextType)type;

#pragma mark - Properties

@property (strong) SCNNode *textNode;
@property BOOL fadesIn;

@end
