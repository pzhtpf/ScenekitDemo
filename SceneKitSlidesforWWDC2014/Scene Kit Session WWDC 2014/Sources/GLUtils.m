/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  This file contains some OpenGL utilities
  
 */

#import "GLUtils.h"

// Compile a GLSL shader
static bool AAPLCompileShader(GLuint *shader, GLenum type, NSString *file) {
	const GLchar *source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
	if (!source) {
		NSLog(@"Failed to load vertex shader");
		return false;
	}
	
	*shader = glCreateShader(type);
	glShaderSource(*shader, 1, &source, NULL);
	glCompileShader(*shader);
    
    GLint status;
	glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
	if (status == 0) {
        GLsizei length = 0;
        GLcharARB logs[1000];
        logs[0] = '\0';
        glGetShaderInfoLog(*shader, 1000, &length, logs);
        NSLog(@"gl Compile Status: %s", logs);
		glDeleteShader(*shader);
		return false;
	}
	
	return true;
}

// Link a GLSL program
static BOOL AAPLLinkProgram(GLuint program) {
	glLinkProgram(program);
    
	GLint status;
	glGetProgramiv(program, GL_LINK_STATUS, &status);
	if (status == 0) {
        GLsizei length = 0;
        GLcharARB logs[1000];
        logs[0] = '\0';
        glGetShaderInfoLog(program, 1000, &length, logs);
        NSLog(@"gl Link Status: %s", logs);
        
		return NO;
	}
	
	return YES;
}

GLuint AAPLCreateProgramWithNameAndAttributeLocations(NSString *shaderName, AAPLAttribLocation *attribLocations) {
	// Create and compile vertex shader.
	NSString *vertShaderPathName = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"vsh"];
	GLuint vertShader = 0;
    if (!AAPLCompileShader(&vertShader, GL_VERTEX_SHADER, vertShaderPathName)) {
		NSLog(@"Failed to compile vertex shader");
		return NO;
	}
	
	// Create and compile fragment shader.
	NSString *fragShaderPathName = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"fsh"];
	GLuint fragShader = 0;
    if (!AAPLCompileShader(&fragShader, GL_FRAGMENT_SHADER, fragShaderPathName)) {
		NSLog(@"Failed to compile fragment shader");
		return NO;
	}
    
    // Create and compile fragment shader.
    GLuint geomShader = 0;
	NSString *geomShaderPathName = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"gsh"];
	if (geomShaderPathName && !AAPLCompileShader(&geomShader, GL_GEOMETRY_SHADER_EXT, geomShaderPathName)) {
		NSLog(@"Failed to compile geometry shader");
	}
    
	GLuint program = glCreateProgram();
	
	// Attach vertex shader to program.
	glAttachShader(program, vertShader);
	
	// Attach fragment shader to program.
	glAttachShader(program, fragShader);
	
    if (geomShader) {
        glAttachShader(program, geomShader);
    }
    
	// Bind attribute locations.
	// This needs to be done prior to linking.
	int i = 0;
	while (true) {
		if (attribLocations[i].name == NULL)
			break; // last attrib
		
		glBindAttribLocation(program, attribLocations[i].index, attribLocations[i].name);
		++i;
	}
    
	if (geomShader) {
        // configure the geometry shader
        glProgramParameteriEXT(program, GL_GEOMETRY_INPUT_TYPE_EXT, GL_TRIANGLES);
        glProgramParameteriEXT(program, GL_GEOMETRY_OUTPUT_TYPE_EXT, GL_TRIANGLE_STRIP);
        glProgramParameteriEXT(program, GL_GEOMETRY_VERTICES_OUT_EXT, 4);
    }
    
	// Link program.
	if (!AAPLLinkProgram(program)) {
		NSLog(@"Failed to link program: %d", program);
		
		if (vertShader) {
			glDeleteShader(vertShader);
			vertShader = 0;
		}
        
		if (fragShader) {
			glDeleteShader(fragShader);
			fragShader = 0;
		}
		
        if (geomShader) {
			glDeleteShader(geomShader);
			geomShader = 0;
		}
		
        if (program) {
			glDeleteProgram(program);
			program = 0;
		}
		
		return 0;
	}
	
	// Release vertex, fragment and geometry shaders.
	if (vertShader) {
		glDetachShader(program, vertShader);
		glDeleteShader(vertShader);
	}
    
	if (fragShader) {
		glDetachShader(program, fragShader);
		glDeleteShader(fragShader);
	}

	if (geomShader) {
		glDetachShader(program, geomShader);
		glDeleteShader(geomShader);
	}
	
	return program;
}

int AAPLBindSampler(int stage, GLint location, GLuint texture, GLenum target) {
	if (location != -1) {
		glActiveTexture(GL_TEXTURE0 + stage);
        glEnable(target);
		glBindTexture(target, texture);
		glUniform1i(location, stage);
		return stage + 1;
	}
	return stage;
}

void AAPLUnbindSampler(int stage, GLenum target) {
    glActiveTexture(GL_TEXTURE0 + stage);
    glBindTexture(target, 0);
    glDisable(target);
}
