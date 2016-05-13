/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  AAPLSlideTextManager manages the layout of the different types of text presented in the slides.
  
 */

#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"

static CGFloat const TEXT_SCALE = 0.02;
static CGFloat const TEXT_CHAMFER = 1;
static CGFloat const TEXT_DEPTH = 0.0;
static CGFloat const TEXT_FLATNESS = 0.4;
static CGFloat const TEXT_FOOTPRINT_SCALE = 0.006;

@implementation AAPLSlideTextManager {
    // The containers for each type of text
    SCNNode *_subGroups[AAPLTextTypeCount];
    
    AAPLTextType _previousType;
    CGFloat _currentBaseline;
    CGFloat _titleBaseline;
    CGFloat _subtitleBaseline;
    CGFloat _contentDefaultBaseline;

    float   _baselinePerType[AAPLTextTypeCount];
}

- (id)init {
    if (self = [super init]) {
        self.textNode = [SCNNode node];
        _currentBaseline = 16;
        
        _titleBaseline = 16.5;
        _subtitleBaseline = 16-2;
        _contentDefaultBaseline = 16-2.26-2.23-1;
    }
    
    return self;
}

- (NSColor *)colorForTextType:(AAPLTextType)type level:(NSUInteger)level {
    switch (type) {
        case AAPLTextTypeFootPrint:
        case AAPLTextTypeSubtitle:
            return [NSColor colorWithDeviceRed:142/255.0 green:142/255.0 blue:147/255.0 alpha:1];
        case AAPLTextTypeCode:
            return level == 0 ? [NSColor whiteColor] : [NSColor colorWithDeviceRed:242/255.0 green:173/255.0 blue:24/255.0 alpha:1];
        case AAPLTextTypeBody:
            if (level == 2)
                return [NSColor colorWithDeviceRed:115/255.0 green:170/255.0 blue:230/255.0 alpha:1];
        default:
            return [NSColor whiteColor];
    }
}

- (CGFloat)extrusionDepthForTextType:(AAPLTextType)type {
    return type == AAPLTextTypeChapter ? 10.0 : TEXT_DEPTH;
}

- (CGFloat)fontSizeForTextType:(AAPLTextType)type level:(NSUInteger)level {
    switch (type) {
        case AAPLTextTypeTitle:
            return 88;
        case AAPLTextTypeChapter:
            return 94;
        case AAPLTextTypeCode:
            return 36;
        case AAPLTextTypeFootPrint:
            return 34;
        case AAPLTextTypeSubtitle:
            return 64;
        case AAPLTextTypeBody:
            return level == 0 ? 50 : 40;
        default:
            return 56;
    }
}

- (NSFont *)fontForTextType:(AAPLTextType)type level:(NSUInteger)level {
    CGFloat fontSize = [self fontSizeForTextType:type level:level];
    
    switch (type) {
        case AAPLTextTypeCode:
            return [NSFont fontWithName:@"Menlo" size:fontSize];
        case AAPLTextTypeBullet:
        case AAPLTextTypeFootPrint:
            return [NSFont fontWithName:@"Myriad Set" size:fontSize] ?: [NSFont fontWithName:@"Avenir Medium" size:fontSize];
        case AAPLTextTypeBody:
            if (level != 0)
                return [NSFont fontWithName:@"Myriad Set" size:fontSize] ?: [NSFont fontWithName:@"Avenir Medium" size:fontSize];
        default:
            return [NSFont fontWithName:@"Myriad Set" size:fontSize] ?: [NSFont fontWithName:@"Avenir Medium" size:fontSize];
    }
}

- (CGFloat)lineHeightForTextType:(AAPLTextType)type level:(NSUInteger)level {
    switch (type) {
        case AAPLTextTypeTitle:
            return 2.26;
        case AAPLTextTypeChapter:
            return 3;
        case AAPLTextTypeCode:
            return 1.22;
        case AAPLTextTypeSubtitle:
            return 1.8;
        case AAPLTextTypeBody:
            return level == 0 ? 1.2 : 1.0;
        default:
            return 1.65;
    }
}

- (SCNNode *)textContainerForType:(AAPLTextType)type {
    if (type == AAPLTextTypeChapter)
        return self.textNode.parentNode;
    
    if (_subGroups[type])
        return _subGroups[type];
    
    SCNNode *container = [SCNNode node];
    [self.textNode addChildNode:container];
    
    _subGroups[type] = container;
    _baselinePerType[type] = _currentBaseline;
    
    return container;
}

- (void)addEmptyLine {
    _currentBaseline -= 1.2;
}

- (SCNNode *)nodeWithText:(NSString *)string withType:(AAPLTextType)type level:(NSUInteger)level {
    SCNNode *textNode = [SCNNode node];
    
    // Bullet
    if (type == AAPLTextTypeBullet) {
        if (level == 0) {
            //string = [NSString stringWithFormat:@"• %@", string];
        }
        else {
//            SCNNode *bullet = [SCNNode node];
//            bullet.geometry = [SCNPlane planeWithWidth:10.0 height:10.0];
//            bullet.geometry.firstMaterial.diffuse.contents = [NSColor colorWithDeviceRed:160.0/255 green:182.0/255 blue:203.0/255 alpha:1.0];
//            bullet.position = SCNVector3Make(80, 30, 0);
//            bullet.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
//            bullet.geometry.firstMaterial.writesToDepthBuffer = NO;
//            [textNode addChildNode:bullet];
            string = [NSString stringWithFormat:@"• %@", string];
        }
    }
    
    // Text attributes
    float extrusion = [self extrusionDepthForTextType:type];
    SCNText *text = [SCNText textWithString:string extrusionDepth:extrusion];
    textNode.geometry = text;
    text.flatness = TEXT_FLATNESS;
    text.chamferRadius = extrusion == 0 ? 0 : TEXT_CHAMFER;
    text.font = [self fontForTextType:type level:level];
    
    // Layout
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    CGFloat leading = [layoutManager defaultLineHeightForFont:text.font];
    CGFloat descender = text.font.descender;
    NSUInteger newlineCount = [[text.string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] count];
    textNode.pivot = SCNMatrix4MakeTranslation(0, -descender + newlineCount * leading, 0);
    
    if (type == AAPLTextTypeChapter) {
        SCNVector3 min, max;
        [textNode getBoundingBoxMin:&min max:&max];
        textNode.position = SCNVector3Make(-11, (-min.y + textNode.pivot.m42) * TEXT_SCALE, 7);
        textNode.scale = SCNVector3Make(TEXT_SCALE, TEXT_SCALE, TEXT_SCALE);
        textNode.rotation = SCNVector4Make(0, 1, 0, M_PI/270.0);
    }
    else if(type == AAPLTextTypeFootPrint){
        textNode.position = SCNVector3Make(-5.68, -3.9, -10);
        textNode.scale = SCNVector3Make(TEXT_FOOTPRINT_SCALE, TEXT_FOOTPRINT_SCALE, TEXT_FOOTPRINT_SCALE);
    }
    else {
        textNode.position = SCNVector3Make(-16, _currentBaseline, 0);
        textNode.scale = SCNVector3Make(TEXT_SCALE, TEXT_SCALE, TEXT_SCALE);
    }
    
    // Material
    if (type == AAPLTextTypeChapter) {
        SCNMaterial *frontMaterial = [SCNMaterial material];
        SCNMaterial *sideMaterial = [SCNMaterial material];
        
        frontMaterial.emission.contents = [NSColor lightGrayColor];
        frontMaterial.diffuse.contents = [self colorForTextType:type level:level];
        sideMaterial.diffuse.contents = [NSColor lightGrayColor];
        textNode.geometry.materials = @[frontMaterial, frontMaterial, sideMaterial, frontMaterial, frontMaterial];
    }
    else {
        // Full white emissive material (visible even when there is no light)
        textNode.geometry.firstMaterial = [SCNMaterial material];
        textNode.geometry.firstMaterial.diffuse.contents = [NSColor blackColor];
        textNode.geometry.firstMaterial.emission.contents = [self colorForTextType:type level:level];
    }
    
    if(type == AAPLTextTypeFootPrint) {
        textNode.renderingOrder = 100.0; //render last
        textNode.geometry.firstMaterial.readsFromDepthBuffer = NO;
    }

    return textNode;
}

- (SCNNode *)nodeWithCode:(NSString *)string {
    // Node hierarchy:
    // codeNode
    // |__ regularCodeNode
    // |__ emphasis-0 (can be highlighted separately)
    // |__ emphasis-1 (can be highlighted separately)
    // |__ emphasis-2 (can be highlighted separately)
    // |__ ...
    
    SCNNode *codeNode = [SCNNode node];
    
    NSUInteger chunk = 0;
    NSString *regularCode = @"";
    NSString *whitespacesCode = @"";
    
    // Automatically highlight the parts of the code that are delimited by '#'
    NSArray *components = [string componentsSeparatedByString:@"#"];
    
    for (NSUInteger i = 0; i < components.count; i++) {
        NSString *component = components[i];
        
        NSString *whitespaces = @"";
        for (NSUInteger j = 0; j < component.length; j++) {
            NSString *character = [component substringWithRange:NSMakeRange(j, 1)];
            if ([character isEqualToString:@"\n"]) {
                whitespaces = [whitespaces stringByAppendingString:@"\n"];
            } else {
                whitespaces = [whitespaces stringByAppendingString:@" "];
            }
        }
        
        if (i % 2) {
            SCNNode *emphasisedCodeNode = [self nodeWithText:[whitespacesCode stringByAppendingString:component] withType:AAPLTextTypeCode level:1];
            emphasisedCodeNode.name = [NSString stringWithFormat:@"emphasis-%ld", chunk++];
            [codeNode addChildNode:emphasisedCodeNode];
            
            regularCode = [regularCode stringByAppendingString:whitespaces];
        } else {
            regularCode = [regularCode stringByAppendingString:component];
        }
        
        whitespacesCode = [whitespacesCode stringByAppendingString:whitespaces];
    }
    
    SCNNode *regularCodeNode = [self nodeWithText:regularCode withType:AAPLTextTypeCode level:0];
    regularCodeNode.name = @"regular";
    [codeNode addChildNode:regularCodeNode];
    
    return codeNode;
}

- (SCNNode *)addText:(NSString *)string withType:(AAPLTextType)type level:(NSUInteger)level {
    SCNNode *parentNode = [self textContainerForType:type];
    
    if(type != AAPLTextTypeFootPrint){
        if(_previousType != type){
            if(type == AAPLTextTypeTitle)
                _currentBaseline = _titleBaseline;
            else if(type == AAPLTextTypeSubtitle)
                _currentBaseline = _subtitleBaseline;
            else{
                if(_previousType <= AAPLTextTypeSubtitle)
                    _currentBaseline = _contentDefaultBaseline;
                else{
                    _currentBaseline -= 1.0;
                }
            }
        }
        
        _currentBaseline -= [self lineHeightForTextType:type level:level];
        
//        if (type > AAPLTextTypeSubtitle) {
//            if (_previousType <= AAPLTextTypeTitle) {
//                _currentBaseline -= 1.0;
//            }
//            if (_previousType <= AAPLTextTypeSubtitle && type > AAPLTextTypeSubtitle) {
//                _currentBaseline -= 1.3;
//            }
//            else if (_previousType != type) {
//                _currentBaseline -= 1.0;
//            }
//        }
    }
    
    SCNNode *textNode = (type == AAPLTextTypeCode) ? [self nodeWithCode:string] : [self nodeWithText:string withType:type level:level];
    [parentNode addChildNode:textNode];
    
    if (self.fadesIn) {
        textNode.opacity = 0;
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:1.0];
        {
            textNode.opacity = 1;
        }
        [SCNTransaction commit];
    }
    
    _previousType = type;
    
    return textNode;
}

#pragma mark - Public API

- (SCNNode *)setTitle:(NSString *)title {
    return [self addText:title withType:AAPLTextTypeTitle level:0];
}

- (SCNNode *)setSubtitle:(NSString *)title {
    return [self addText:title withType:AAPLTextTypeSubtitle level:0];
}

- (SCNNode *)setChapterTitle:(NSString *)title {
    return [self addText:title withType:AAPLTextTypeChapter level:0];
}

- (SCNNode *)addText:(NSString *)text atLevel:(NSUInteger)level {
    return [self addText:text withType:AAPLTextTypeBody level:level];
}

- (SCNNode *)addBullet:(NSString *)text atLevel:(NSUInteger)level {
    return [self addText:text withType:AAPLTextTypeBullet level:level];
}

- (SCNNode *)addCode:(NSString *)string {
    return [self addText:string withType:AAPLTextTypeCode level:0];
}

- (SCNNode *)addFootPrint:(NSString *)text
{
    return [self addText:text withType:AAPLTextTypeFootPrint level:0];
}


#pragma mark - Animations

static CGFloat const PIVOT_X = 16;
static CGFloat const FLIP_ANGLE = M_PI_2;
static CGFloat const FLIP_DURATION = 1.0;

// Animate (fade out) to remove the text of specified type
- (void)fadeOutTextOfType:(AAPLTextType)type {
    _previousType = AAPLTextTypeNone;
    
    SCNNode *node = _subGroups[type];
    _subGroups[type] = nil;
    if (node) {
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:FLIP_DURATION];
        [SCNTransaction setCompletionBlock:^{
            [node removeFromParentNode];
        }];
        {
            node.opacity = 0;
        }
        [SCNTransaction commit];
        
        // Reset the baseline to what it was before adding this text
        _currentBaseline = MAX(_currentBaseline, _baselinePerType[type]);
    }
}

// Animate (flip) to remove the text of specified type
- (void)flipOutTextOfType:(AAPLTextType)type {
    _previousType = AAPLTextTypeNone;
    
    SCNNode *node = _subGroups[type];
    _subGroups[type] = nil;
    if (node) {
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:0];
        {
            node.position = SCNVector3Make(-PIVOT_X, 0, 0);
            node.pivot = SCNMatrix4MakeTranslation(-PIVOT_X, 0, 0);
        }
        [SCNTransaction commit];
        
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:FLIP_DURATION];
        [SCNTransaction setCompletionBlock:^{
            [node removeFromParentNode];
        }];
        {
            node.rotation = SCNVector4Make(0, 1, 0, FLIP_ANGLE);
            node.opacity = 0;
        }
        [SCNTransaction commit];
        
        // Reset the baseline to what it was before adding this text
        _currentBaseline = MAX(_currentBaseline, _baselinePerType[type]);
    }
}

// Animate to reveal the text of specified type
- (void)flipInTextOfType:(AAPLTextType)type {
    SCNNode *node = _subGroups[type];
    if (node) {
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:0];
        {
            node.position = SCNVector3Make(-PIVOT_X, 0, 0);
            node.pivot = SCNMatrix4MakeTranslation(-PIVOT_X, 0, 0);
            node.rotation = SCNVector4Make(0, 1, 0, -FLIP_ANGLE);
            node.opacity = 0;
        }
        [SCNTransaction commit];
        
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:FLIP_DURATION];
        {
            node.rotation = SCNVector4Make(0, 1, 0, 0);
            node.opacity = 1;
        }
        [SCNTransaction commit];
    }
}

#pragma mark - Highlighting text

- (void)highlightBulletAtIndex:(NSUInteger)index {
    // Highlight is done by changing the emission color
    SCNNode *node = _subGroups[AAPLTextTypeBullet];
    if (node) {
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:0.75];
        {
            // Reset all
            for (SCNNode *child in node.childNodes) {
                child.geometry.firstMaterial.emission.contents = [NSColor whiteColor];
            }
            
            // Unhighlight everything but index
            if (index != NSNotFound) {
                NSUInteger i = 0;
                for (SCNNode *child in node.childNodes) {
                    if (i != index)
                        child.geometry.firstMaterial.emission.contents = [NSColor darkGrayColor];
                    i++;
                }
            }
        }
        [SCNTransaction commit];
    }
}

- (void)highlightCodeChunks:(NSArray *)chunks {
    SCNNode *node = _subGroups[AAPLTextTypeCode];
    
    // Unhighlight everything
    [node childNodesPassingTest:^BOOL(SCNNode *child, BOOL *stop) {
        child.geometry.firstMaterial.emission.contents = [self colorForTextType:AAPLTextTypeCode level:0];
        return NO;
    }];
    
    // Highlight text inside range
    for (NSNumber *i in chunks) {
        SCNNode *chunkNode = [node childNodeWithName:[NSString stringWithFormat:@"emphasis-%ld", [i unsignedIntegerValue]] recursively:YES];
        chunkNode.geometry.firstMaterial.emission.contents = [self colorForTextType:AAPLTextTypeCode level:1];
    }
}

@end
