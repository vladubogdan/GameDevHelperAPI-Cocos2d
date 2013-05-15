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

@protocol GHAnimationDelegate <NSObject>
@optional

-(void)animationDidFinishPlaying:(GHAnimation*)anim onSprite:(GHSprite*)sprite;
-(void)animation:(GHAnimation*)anim didChangeFrameIdx:(NSInteger)frmIdx onSprite:(GHSprite*)sprite;
-(void)animation:(GHAnimation*)anim didFinishRepetition:(NSInteger)repetitionNo onSprite:(GHSprite*)sprite;

@end

@interface GHAnimationFrame : NSObject
{
    CCSpriteFrame* spriteFrame;
    float time;
    NSMutableArray* userInfo;
}
@property (nonatomic, readwrite) float time;

-(id)initWithDictionary:(NSDictionary*)dict;

-(CCSpriteFrame*)spriteFrame;
-(void)setSpriteFrame:(CCSpriteFrame*)val;

-(NSMutableArray*)userInfo;

@end


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
@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readwrite) int repetitions;
@property (nonatomic, readwrite) BOOL loop;
@property (nonatomic, readwrite) BOOL randomFrames;
@property (nonatomic, readwrite) BOOL restoreSprite;

@property (nonatomic, readwrite) BOOL randomReplay;
@property (nonatomic, readwrite) float minRandomTime;
@property (nonatomic, readwrite) float maxRandomTime;


/** creates an animation from a dictionary.
 Make sure that the frames were previously loaded in the CCSpriteFrameCache.
 */
-(id)initWithDictionary:(NSDictionary*)dict name:(NSString*)val;

//changing the total time value will change the time on each frame as needed
-(void)setTotalTime:(float)val;
-(float)totalTime;

-(NSMutableArray*)frames;

//if you remove an animation in one of the delegate methods you should make the delegate nil first
-(void)setDelegate:(id<GHAnimationDelegate>)val;

@end
