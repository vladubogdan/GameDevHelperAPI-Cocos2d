//
//  GHSkeleton.h
//  cocos2d-ios
//
//  Created by Bogdan Vladu on 4/4/13.
//
//

#import "cocos2d.h"
#import "ghConfig.h"

#import "GHBone.h"

@class GHSkeletalAnimation;
@class GHSkeleton;

/**
 This protocol is used when the end user wants to receive skeleton animation notifications.

 Example:
 @code
 [mySkeleton setDelegate:self];
 @endcode
 */
@protocol GHSkeletonDelegate <NSObject>
@optional

/**
 Receive load pose notification. Returns the skeleton on which the new pose was loaded and the pose name.
 */
-(void)didLoadPoseWithName:(NSString*)poseName onSkeleton:(GHSkeleton*)skeleton;

/**
 Called when a skeleton animation just started. Returns the skeleton on which the animation started and the skeletal animation object.
 */
-(void)didStartAnimation:(GHSkeletalAnimation*)animation onSkeleton:(GHSkeleton*)skeleton;

/**
 Called when a skeleton transitioned to a new animaton. Returns the skeleton and the skeletal animation object.
 */
-(void)didFinishTransitionToAnimation:(GHSkeletalAnimation*)animation onSkeleton:(GHSkeleton*)skeleton;

/**
 Called when a skeleton animation just stoped. Returns the skeleton and the skeletal animation object.
 */
-(void)didStopAnimation:(GHSkeletalAnimation*)animation onSkeleton:(GHSkeleton*)skeleton;

/**
 Called when a skeleton animation just finished a loop. Returns the skeleton and the skeletal animation object.
 */
-(void)didFinishLoopInAnimation:(GHSkeletalAnimation*)animation onSkeleton:(GHSkeleton*)skeleton;
@end



/**
 This class is used to create skeletons as defined in SpriteHelper.

 Example of loading a published skeleton file:
 @code
 skeleton = [GHSkeleton skeletonWithFile:@"resourceFolderWhereItWasPublished/skeletons/DocName_SkeletonName.plist"];
 @endcode
 */
@interface GHSkeleton : CCNode
{
    GHBone* rootBone;
    CCSpriteBatchNode* batchNode_;//sprites are kept in this batchNode
    
    NSDictionary* poses;//may be nil depending on publish settings
    
    NSMutableArray* skins;//contains GHBoneSkin objects
#ifdef GH_DEBUG
    //debug drawing
    GLint		colorLocation_;
#endif
    
    GHSkeletalAnimation* animation;//combined animations currently not supported
    
    NSNumber* transitionTime;//not nil only when transtioning to a new animation
    float currentTranstionTime;
    id<GHSkeletonDelegate> delegate;
}
/**
 Creates a skeleton object given a file name.
 */
-(id)initWithFile:(NSString*)file;
/**
 Creates an autoreleased skeleton object given a file name.
 */
+(id)skeletonWithFile:(NSString*)file;

/**
 Sets the delegate object to be used by this skeleton.
 
 You should read GHSkeletonDelegate documentation for what methods you have to implement.
 */
-(void)setDelegate:(id<GHSkeletonDelegate>)del;

/**
 Finds a bone in the skeleton structure and set its position.
 */
-(void)setPosition:(CGPoint)position forBoneNamed:(NSString*)boneName;

/**
 Loads a pose onto the skeleton given the pose name.
 */
-(void)setPoseWithName:(NSString*)poseName;

/**
 Returns an array containing all the bone objects (GHBone) in the skeleton.
 */
-(NSArray*)allBones;
/**
 Returns an array containing all the skin objects (GHBoneSkin) in the skeleton.
 */
-(NSArray*)skins;
/**
 Returns the root bone.
 */
-(GHBone*)rootBone;

/**
 Adds a skin to the skeleton.
 */
-(void)addSkin:(GHBoneSkin*)skin;
/**
 Removes a skin from the skeleton.
 */
-(void)removeSkin:(GHBoneSkin*)skin;

/**
 Start an animation on the skeleton given the animation object.
 */
-(void)playAnimation:(GHSkeletalAnimation*)anim;
/**
 Start an animation on the skeleton given the animation name.
 @warning
 Animation has to be previously cache using GHSkeletalAnimationCache.
 */
-(void)playAnimationWithName:(NSString*)animName;
/**
 Returns the current animation active on this skeleton.
*/
 -(GHSkeletalAnimation*)animation;
/**
This will change or set an animation by transitioning each bone position
 to the new animation bone positions in the period of time specified.
 */
-(void)transitionToAnimation:(GHSkeletalAnimation*)anim inTime:(float)time;
/**
 This will change or set an animation given its name, by transitioning each bone position
 to the new animation bone positions in the period of time specified.
 @warning
 Animation has to be previously cache using GHSkeletalAnimationCache.
 */
-(void)transitionToAnimationWithName:(NSString*)animName inTime:(float)time;

/**
 Stops the active skeleton animation.
 */
-(void)stopAnimation;

@end
