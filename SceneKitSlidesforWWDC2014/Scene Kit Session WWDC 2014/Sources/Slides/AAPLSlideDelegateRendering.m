/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  Explains what scene delegate rendering is and shows an example.
  
 */

#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"
#import "GLUtils.h"

// OpenGL attribute locations
NS_ENUM(GLuint, AAPLAttrib) {
	AAPL_QUAD_ATTRIB_POS,
	AAPL_QUAD_ATTRIB_UV
};

// A structure used to represent a vertex
typedef struct {
    GLfloat position[4]; // position
    GLfloat uv0[3];      // texture coordinates + vertex index (stored in the last component)
} AAPLVertexUV;

@interface AAPLSlideDelegateRendering : AAPLSlide <SCNSceneRendererDelegate>
@end


AAPLSlideDelegateRendering *retainPointer;


@implementation AAPLSlideDelegateRendering {
    // OpenGL-related ivars
    GLuint _quadVAO;
    GLuint _quadVBO;
    GLuint _program;
    GLuint _timeLocation;
    GLuint _factorLocation;
    GLuint _resolutionLocation;
    
    // Other ivars
    GLfloat _fadeFactor;
    GLfloat _fadeFactorDelta;
    CFAbsoluteTime _startTime;
    CGSize _viewport;
    
    BOOL _active;
}

- (NSUInteger)numberOfSteps {
    return 3;
}

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    // Set the slide's title and subtitle and add some text
    self.textManager.title = @"Custom OpenGL/OpenGL ES";
    
    [self.textManager addBullet:@"Custom code pre/post rendering" atLevel:0];
    [self.textManager addBullet:@"Custom code per node" atLevel:0];
}

- (void)presentStepIndex:(NSUInteger)index withPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    switch (index) {
        case 0:
            break;
        case 1:
        {
            _active = 1;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(),
                           ^{
                               
            if(!_active) return;
                               
            // Create a VBO to render a quad
            [self createQuadGeometryInContext:presentationViewController.presentationView.openGLContext];
            
            // Create the program and retrieve the uniform locations
            AAPLAttribLocation attrib[] = {
                {AAPL_QUAD_ATTRIB_POS, "position"},
                {AAPL_QUAD_ATTRIB_UV, "texcoord0"},
                {0, 0}
            };
            
            _program = AAPLCreateProgramWithNameAndAttributeLocations(@"SceneDelegate", attrib);
            
            _timeLocation = glGetUniformLocation(_program, "time");
            _factorLocation = glGetUniformLocation(_program, "factor");
            _resolutionLocation = glGetUniformLocation( _program, "resolution");
            
            // Initialize time and cache the viewport
            NSSize frameSize = [presentationViewController.presentationView convertSizeToBacking:presentationViewController.presentationView.frame.size];
            _viewport = NSSizeToCGSize(frameSize);
            _startTime = CFAbsoluteTimeGetCurrent();
            
            _fadeFactor = 0; // tunnel is not visible
            _fadeFactorDelta = 0.05; // fade in
            
            // Set self as the scene renderer's delegate and make the view redraw for ever
            presentationViewController.presentationView.delegate = self;
            presentationViewController.presentationView.playing = YES;
            presentationViewController.presentationView.loops = YES;
                           });
            
            retainPointer = self;
        }
            break;
        case 2:
            _fadeFactorDelta *= -1; // fade out
            break;
    }
}

- (void)willOrderOutWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController {
    presentationViewController.presentationView.delegate = nil;
    presentationViewController.presentationView.playing = NO;
    _active = 0;
    retainPointer = nil;
}

// Create a VBO used to render a quad
- (void)createQuadGeometryInContext:(NSOpenGLContext *)context {
    [context makeCurrentContext];
    
	glGenVertexArraysAPPLE(1, &_quadVAO);
	glBindVertexArrayAPPLE(_quadVAO);
    
	glGenBuffers(1, &_quadVBO);
	glBindBuffer(GL_ARRAY_BUFFER, _quadVBO);
	
	AAPLVertexUV vertices[] = {
		{{-1.f, 1.f, 0.f, 1.f}, {0.f, 1.f, 0.f}}, // TL
		{{ 1.f, 1.f, 0.f, 1.f}, {1.f, 1.f, 1.f}}, // TR
		{{-1.f,-1.f, 0.f, 1.f}, {0.f, 0.f, 2.f}}, // BL
		{{-1.f,-1.f, 0.f, 1.f}, {0.f, 0.f, 2.f}}, // BL
		{{ 1.f, 1.f, 0.f, 1.f}, {1.f, 1.f, 1.f}}, // TR
		{{ 1.f,-1.f, 0.f, 1.f}, {1.f, 0.f, 3.f}}, // BR
	};
	
	glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
	
	glVertexAttribPointer(AAPL_QUAD_ATTRIB_POS, 4, GL_FLOAT, GL_FALSE, sizeof(AAPLVertexUV), (void *)offsetof(AAPLVertexUV, position));
	glEnableVertexAttribArray(AAPL_QUAD_ATTRIB_POS);
	glVertexAttribPointer(AAPL_QUAD_ATTRIB_UV, 3, GL_FLOAT, GL_TRUE, sizeof(AAPLVertexUV), (void *)offsetof(AAPLVertexUV, uv0));
	glEnableVertexAttribArray(AAPL_QUAD_ATTRIB_UV);
	
	glBindVertexArrayAPPLE(0);
}

// Invoked by SceneKit before rendering the scene. When this is invoked, SceneKit has already installed the viewport and cleared the background.
- (void)renderer:(id <SCNSceneRenderer>)aRenderer willRenderScene:(SCNScene *)scene atTime:(NSTimeInterval)time {
    // Disable what SceneKit enables by default (and restore upon leaving)
    glDisable(GL_CULL_FACE);
    glDisable(GL_DEPTH_TEST);
    
    // Draw the procedural background
    glBindVertexArrayAPPLE(_quadVAO);
    glUseProgram(_program);
    glUniform1f(_timeLocation, CFAbsoluteTimeGetCurrent() - _startTime);
    glUniform1f(_factorLocation, _fadeFactor);
    glUniform2f(_resolutionLocation, _viewport.width, _viewport.height);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    glBindVertexArrayAPPLE(0);
    
    // Restore SceneKit default states
    glEnable(GL_DEPTH_TEST);
    
    // Update the fade factor
    _fadeFactor = MAX(0, MIN(1, _fadeFactor + _fadeFactorDelta));
}

@end
