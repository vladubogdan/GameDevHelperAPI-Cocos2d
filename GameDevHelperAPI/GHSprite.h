//
//  GHSprite.h
//  GameDevHelper.com
//
//  Created by Bogdan Vladu.
//  Copyright (c) 2013 Bogdan Vladu. All rights reserved.
//

#import "cocos2d.h"
#import "ghConfig.h"

#if GH_ENABLE_PHYSICS_INTEGRATION
#import "Box2D.h"
#endif

#import "GHAnimation.h"

@interface GHSprite : CCSprite
{
    NSString* imageFile;
    NSString* spriteFrameName;
    NSString* name;//name may be the same as spriteFrameName, different or nil
    
    
#if GH_ENABLE_PHYSICS_INTEGRATION
    
    NSDictionary* physicsInfo;//may be nil - contains all physical information
    b2Body* body;//may be null if sprite has no physical representation
#endif
    
    GHAnimation* activeAnimation;//may be nil
}
#pragma mark INIT
+(id)spriteWithSpriteFrameName:(NSString*)spriteFrameName;
-(id)initWithSpriteFrameName:(NSString*)spriteFrameName;



#pragma mark VARIOUS_PROPERTIES
-(void)setName:(NSString*)val;
-(NSString*)name;

@property (nonatomic, readonly) NSString* imageFile;
@property (nonatomic, readonly) NSString* spriteFrameName;




#pragma mark ANIMATIONS
-(void)prepareAnimation:(GHAnimation*)anim;
-(void)prepareAnimationWithName:(NSString*)animName;
-(GHAnimation*)animation;

-(void)playAnimation;
-(void)pauseAnimation;
-(void)restartAnimation;
-(void)stopAnimation; //removes the animation entirely
-(void)stopAnimationAndRestoreOriginalFrame:(BOOL)restore;

-(void)setAnimationDelegate:(id<GHAnimationDelegate>)obj;



#if GH_ENABLE_PHYSICS_INTEGRATION
#pragma mark PHYSICS

//add physics methods here

#endif


@end
