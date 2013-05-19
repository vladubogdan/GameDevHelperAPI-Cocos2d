//
//  GHDebugDraw.h
//  cocos2d-ios
//
//  Created by Bogdan Vladu on 4/29/13.
//
//

#import "ghConfig.h"
#import "cocos2d.h"

#if GH_ENABLE_PHYSICS_INTEGRATION

#import "Box2D.h"

/**
 A debug layer for when using physics in order to draw the physic representation on screen.
 
 This debug layer is more advanced then the one that comes with Cocos2d as the drawing will be made on top of the sprite instead of behind letting you see whats really going on.
 
 The end user will have to use this class like this:
 @code
 ....after initializing the physic world
 
 GHDebugDrawLayer* debugDraw = [GHDebugDrawLayer debugDrawLayerWithWorld:world];
 [self addChild:debugDraw z:1000];
 @endcode
 */
@interface GHDebugDrawLayer : CCLayer
{
    b2World* world;
    
    CCGLProgram* mShaderProgram;
    GLint mColorLocation;
}

/**
 Create an autoreleased object given a Box2d world object.
 */
+(id)debugDrawLayerWithWorld:(b2World*)world;

@end

#endif



