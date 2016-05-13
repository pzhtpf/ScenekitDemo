/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  This file contains some OpenGL utilities
  
 */

#import <OpenGL/gl.h>
#import <OpenGL/glext.h>

typedef struct {
	GLuint index;
	const char *name;
} AAPLAttribLocation;

// Load, build and link a GLSL program
GLuint AAPLCreateProgramWithNameAndAttributeLocations(NSString *shaderName, AAPLAttribLocation *attribLocations);

// Bind an OpenGL texture
int AAPLBindSampler(int stage, GLint location, GLuint texture, GLenum target);

// Unbind an OpenGL texture
void AAPLUnbindSampler(int stage, GLenum target);
