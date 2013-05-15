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

@interface GHDebugDrawLayer : CCLayer
{
    b2World* world;
    
    CCGLProgram* mShaderProgram;
    GLint mColorLocation;
}

+(id)debugDrawLayerWithWorld:(b2World*)world;

@end

#endif



