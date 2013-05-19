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

/**
 A GHSprite is an advanced subclass of CCSprite.
  
 This class is used throughout the entire GameDevHelper API because it has friendly methods for almost everything you may want. 
 From physics, to sprite sheet and skeleton animations, almost everything is controlled through objects of this class.
 
 */

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
/**
 Creates an autorelease GHSprite object using the sprite frame name.
 */
+(id)spriteWithSpriteFrameName:(NSString*)spriteFrameName;

/**
 Creates an GHSprite object using the sprite frame name - you have to release this object.
 */
-(id)initWithSpriteFrameName:(NSString*)spriteFrameName;



#pragma mark VARIOUS_PROPERTIES
/**
 Set the name of current sprite object.
 */
-(void)setName:(NSString*)val;
/**
 Get the name of current sprite object.
 */
-(NSString*)name;

/**
 The image file name from where the texture of this sprite was created.
 */
@property (nonatomic, readonly) NSString* imageFile;

/**
 The sprite frame name used to create the texture rectangle of this sprite.
 */
@property (nonatomic, readonly) NSString* spriteFrameName;




#pragma mark ANIMATIONS
/**
 Prepares a sprite sheet animation on this sprite using the animation object.
 */
-(void)prepareAnimation:(GHAnimation*)anim;
/**
 Prepares a sprite sheet animation on this sprite using the animation name.
 Animation has to be previously cache using GHAnimationCache.
 */
-(void)prepareAnimationWithName:(NSString*)animName;
/**
 Returns the current sprite sheet animation assigned to this sprite object.
 */
-(GHAnimation*)animation;

/**
 Play's the currently assigned sprite sheet animation.
 */
-(void)playAnimation;

/**
 Pause the currently assigned sprite sheet animation.
 */
-(void)pauseAnimation;

/**
 Restart the currently assigned sprite sheet animation.
 */
-(void)restartAnimation;

/**
 Stop the currently assigned sprite sheet animation.
 @warning Stoping a sprite sheet animation will also remove the animation from this sprite.
 */
-(void)stopAnimation;

/**
 Stop the currently assigned sprite sheet animation and restore original sprite frame that was assigned to this sprite prior preparing the animation.

 @warning Stoping a sprite sheet animation will also remove the animation from this sprite.
 
 */
-(void)stopAnimationAndRestoreOriginalFrame:(BOOL)restore;



/**
 Sets a sprite sheet animation delegate.
 
 Use the delegate to receive animation notifications.
 
 You should consult GHAnimationDelegate to see what method's you have to implement in your class.
 
 */
-(void)setAnimationDelegate:(id<GHAnimationDelegate>)obj;



#if GH_ENABLE_PHYSICS_INTEGRATION
#pragma mark PHYSICS

//add physics methods here

#endif


@end
