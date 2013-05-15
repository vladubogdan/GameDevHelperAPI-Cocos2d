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

@protocol GHSkeletonDelegate <NSObject>
@optional

-(void)didLoadPoseWithName:(NSString*)poseName onSkeleton:(GHSkeleton*)skeleton;
-(void)didStartAnimation:(GHSkeletalAnimation*)animation onSkeleton:(GHSkeleton*)skeleton;
-(void)didFinishTransitionToAnimation:(GHSkeletalAnimation*)animation onSkeleton:(GHSkeleton*)skeleton;
-(void)didStopAnimation:(GHSkeletalAnimation*)animation onSkeleton:(GHSkeleton*)skeleton;
-(void)didFinishLoopInAnimation:(GHSkeletalAnimation*)animation onSkeleton:(GHSkeleton*)skeleton;
@end




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

-(id)initWithFile:(NSString*)file;
+(id)skeletonWithFile:(NSString*)file;

-(void)setDelegate:(id<GHSkeletonDelegate>)del;

-(void)setPosition:(CGPoint)position forBoneNamed:(NSString*)boneName;

-(void)setPoseWithName:(NSString*)poseName;

-(NSArray*)allBones;
-(NSArray*)skins;
-(GHBone*)rootBone;

-(void)addSkin:(GHBoneSkin*)skin;
-(void)removeSkin:(GHBoneSkin*)skin;

-(void)playAnimation:(GHSkeletalAnimation*)anim;
-(void)playAnimationWithName:(NSString*)animName;

-(GHSkeletalAnimation*)animation;

//this will change or set an animation by transitioning each bone position
//to the new animation bone positions in the period of time specified
-(void)transitionToAnimation:(GHSkeletalAnimation*)anim inTime:(float)time;
-(void)transitionToAnimationWithName:(NSString*)animName inTime:(float)time;


-(void)stopAnimation;

@end
