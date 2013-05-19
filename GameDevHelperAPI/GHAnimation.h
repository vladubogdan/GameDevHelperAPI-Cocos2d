//
//  GHAnimation.h
//  cocos2d-ios
//
//  Created by Bogdan Vladu on 5/9/13.
//
//

#import "cocos2d.h"

@class GHAnimation;
@class GHSprite;

/**
 This protocol should be used when you want to receive sprite sheet animations notifications.
 
 Implement this protocol in your class and set your class object as delegate of the animation to get notifications.
 
 Example:
 @code
 [mySprite setAnimationDelegate:self];
 @endcode
 */
@protocol GHAnimationDelegate <NSObject>
@optional

/**
Receive finished playing notification for a sprite sheet animation.
 */
-(void)animationDidFinishPlaying:(GHAnimation*)anim onSprite:(GHSprite*)sprite;

/**
 Receive change frame notification for a sprite sheet animation.
 */
-(void)animation:(GHAnimation*)anim didChangeFrameIdx:(NSInteger)frmIdx onSprite:(GHSprite*)sprite;

/**
 Receive did finish repetition notification for a sprite sheet animation.
 */
-(void)animation:(GHAnimation*)anim didFinishRepetition:(NSInteger)repetitionNo onSprite:(GHSprite*)sprite;

@end


/**
 This class represents a frame of a sprite sheet animation. 
 
 It holds informations such as the Cocos2d sprite frame to be used on the sprite when the animation changes to this object.
 */
@interface GHAnimationFrame : NSObject
{
    CCSpriteFrame* spriteFrame;
    float time;
    NSMutableArray* userInfo;
}
/**
 Get and set the time it takes for this sprite sheet animation frame to play.
 */
@property (nonatomic, readwrite) float time;

/**
 Initialize a sprite sheet animation frame with a dictionary.
 */
-(id)initWithDictionary:(NSDictionary*)dict;

/**
 Get the Cocos2d sprite frame assigned to this sprite sheet animation frame.
 */
-(CCSpriteFrame*)spriteFrame;
/**
 Set the Cocos2d sprite frame assigned to this sprite sheet animation frame.
 */
-(void)setSpriteFrame:(CCSpriteFrame*)val;
/**
 Get the user info as defined in SpriteHelper assigned to this sprite sheet animation frame.
 */
-(NSMutableArray*)userInfo;

@end

/**
 A GHAnimation object is used to play sprite sheet animations on a GHSprite object.
 
 This class contains the properties of a sprite sheet animation as defined in SpriteHelper. You can also change the property as needed.
 
 Use GHAnimationCache to pre-load animations into cache for faster handling.
 
 */
@interface GHAnimation : NSObject
{
    NSString* name;
    NSMutableArray* frames;//contains GHAnimationFrame objects
    
    int repetitions;
    BOOL loop;
    BOOL randomFrames;
    BOOL restoreSprite;

    BOOL randomReplay;
    float minRandomTime;
    float maxRandomTime;
    
    float totalTime;

    bool playing;
    float currentTime;
    int currentFrameIdx;
    float currentRandomRepeatTime;
    int repetitionsPerformed;
    GHAnimationFrame* activeFrame;
    
    id<GHAnimationDelegate> delegate;
    
    __unsafe_unretained GHSprite* sprite;
}
/**
 Get the name of this sprite sheet animation.
 */
@property (nonatomic, readonly) NSString* name;
/**
 Get and set the number of repetitions this sprite sheet animation will play.
 For this property to take effect, loop must be disabled.
 */
@property (nonatomic, readwrite) int repetitions;
/**
 Get and set whether this sprite sheet animation will loop.
 */
@property (nonatomic, readwrite) BOOL loop;
/**
 Get and set whether this sprite sheet animation will change frames randomly and ignore the frames order.
 This is useful for animations such as fire flames.
 */
@property (nonatomic, readwrite) BOOL randomFrames;
/**
 Get and set whether this sprite sheet animation should restore original Cocos2d sprite frame on the assigned sprite when it finishes.
 */
@property (nonatomic, readwrite) BOOL restoreSprite;
/**
 Get and set whether this sprite sheet animation should replay with a random delay time between min and max random time.
 This is useful for animations such as character eyes blinking.
 For this property to take effect, loop must be enabled.
 */
@property (nonatomic, readwrite) BOOL randomReplay;
/**
 Get and set whether this sprite sheet animation minimum random replay time.
 For this property to take effect, randomReplay must be enabled.
 */
@property (nonatomic, readwrite) float minRandomTime;
/**
 Get and set whether this sprite sheet animation maximum random replay time.
 For this property to take effect, randomReplay must be enabled.
 */
@property (nonatomic, readwrite) float maxRandomTime;


/** 
 * Creates an animation from a dictionary.
 * Make sure that the frames were previously loaded in the CCSpriteFrameCache.
 */
-(id)initWithDictionary:(NSDictionary*)dict name:(NSString*)val;
/**
 * Set the total time it will take for this sprite sheet animation to complete a loop.\n
 * Changing the total time value, will change the time on each frame as needed.\n
 */
-(void)setTotalTime:(float)val;
/**
 * Get the total time it takes for this sprite sheet animation to complete a loop.
 */
-(float)totalTime;

/** 
 * Return the frames array. This array contains GHAnimationFrame objects.\n
 */
-(NSMutableArray*)frames;

/**
 * Set the sprite sheet animation delegate.\n
 * Note: If you remove an animation in one of the delegate methods you should make the delegate NULL first.\n
 */
-(void)setDelegate:(id<GHAnimationDelegate>)val;

@end
