//
//  GHSkeletalAnimation.h
//  cocos2d-ios
//
//  Created by Bogdan Vladu on 4/8/13.
//
//

#import "cocos2d.h"
@interface GHSkeletalSkinConnectionInfo :NSObject
{
    //used with skin connections
    NSString* boneName;//may be nil;
    
    //used with sprites transform and skin connections
    float angleOffset;
    float connectionAngle;
    CGPoint positionOffset;
    
    //used with sprites transform
    CGPoint position;
    float angle;
}
@property (nonatomic, readonly) NSString* boneName;
@property (nonatomic, readwrite) float angleOffset;
@property (nonatomic, readwrite) float connectionAngle;
@property (nonatomic, readwrite) CGPoint positionOffset;

@property (nonatomic, readwrite) CGPoint position;
@property (nonatomic, readwrite) float angle;

+(id)skinConnectionInfoWithBoneName:(NSString*)name;
@end

@interface GHSkeletalAnimationFrame : NSObject
{
    float time_;
    
    NSMutableDictionary* bonePositions_;//key bone name / value - NSValue with point
    NSMutableDictionary* spritesZOrder_;//key sprite name/ value - NSNumber with int
    NSMutableDictionary* skinConnections_;//key sprite name/ value - GHSkeletalSkinConnectionInfo
    NSMutableDictionary* skinSprites_;//key skin name/ value sprite name
    NSMutableDictionary* spritesVisibility_;//key sprite name / value NO (sprite only available if its invisible)
    NSMutableDictionary* spritesTransform_;//key sprite name / value GHSkeletalSkinConnectionInfo
}
@property (nonatomic, readwrite) float time;

-(id) initWithTime:(float)tm;
+(id) frameWithTime:(float)tm;

-(NSMutableDictionary*)bonePositions;
-(NSMutableDictionary*)spritesZOrder;
-(NSMutableDictionary*)skinConnections;
-(NSMutableDictionary*)skinSprites;
-(NSMutableDictionary*)spritesVisibility;
-(NSMutableDictionary*)spritesTransform;
@end



typedef enum GHSkeletalAnimationPlayMode_ {
	GH_SKELETAL_ANIM_PLAY_NORMAL,
	GH_SKELETAL_ANIM_PLAY_LOOP,
	GH_SKELETAL_ANIM_PLAY_PINGPONG,
    
} GHSkeletalAnimationPlayMode;


@interface GHSkeletalAnimation : NSObject <NSCopying>
{
    NSString* name_;
    float totalTime_;
    float currentTime_;
    GHSkeletalAnimationPlayMode playMode_;
    
    NSMutableArray* bonePositionFrames_;
    NSMutableArray* spriteZOrderFrames_;
    NSMutableArray* skinConnectionFrames_;
    NSMutableArray* skinSpriteFrames_;
    NSMutableArray* visibilityFrames_;
    NSMutableArray* spritesTransformFrames_;
    
    int numberOfLoops_; //0 loops forever;
    int currentLoop_;
    bool reversed_;
    
    bool paused_;
}
@property (nonatomic,readwrite) int numberOfLoops;
@property (nonatomic,readwrite) int currentLoop;
@property (nonatomic,readwrite) GHSkeletalAnimationPlayMode playMode;
@property (nonatomic,readwrite) bool reversed;
@property (nonatomic,readwrite) bool paused;

@property (nonatomic,readonly) NSString* name;

-(id) initWithDictionary:(NSDictionary*)dict;
+(id) animationWithDictionary:(NSDictionary*)dict;

//this will scale frame times in order to match the new time
-(void)setTotalTime:(float)totalTime;
-(float)totalTime;

//this method has no effect if the animation is paused
-(void)setCurrentTime:(float)val;
-(float)currentTime;

-(NSMutableArray*)bonePositionFrames;
-(NSMutableArray*)spriteZOrderFrames;
-(NSMutableArray*)skinConnectionFrames;
-(NSMutableArray*)skinSpriteFrames;
-(NSMutableArray*)visibilityFrames;
-(NSMutableArray*)spritesTransformFrames;

-(int)goToNextBonePositionFrame;
-(int)goToPreviousBonePositionFrame;

-(int)goToNextSpriteZOrderFrame;
-(int)goToPreviousSpriteZOrderFrame;

-(int)goToNextSkinConnectionFrame;
-(int)goToPreviousSkinConnectionFrame;

-(int)goToNextSkiSpriteFrame;
-(int)goToPreviousSkinSpriteFrame;

-(int)goToNextVisibilityFrame;
-(int)goToPreviousVisibilityFrameFrame;

-(int)goToNextSpriteTransformFrame;
-(int)goToPreviousSpriteTransformFrame;

@end
