//
//  GHAnimation.m
//  cocos2d-ios
//
//  Created by Bogdan Vladu on 5/9/13.
//
//

#import "GHAnimation.h"
#import "GHSprite.h"

@implementation GHAnimationFrame
@synthesize time;

-(id)initWithDictionary:(NSDictionary*)dict{
    self = [super init];
    if(self){
        
        NSArray* notifsInfo = [dict objectForKey:@"notification"];
//        CGPoint point = [dict objectForKey:@"offset"];//currently not used
        
        NSString* spriteFrameName = [dict objectForKey:@"spriteframe"];
        
        if(spriteFrameName){
            spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteFrameName];
            
            NSAssert1(spriteFrame, @"SpriteFrame %@ was not found. Use CCSpriteFrameCache to load spriteFrames before loading an animation.", spriteFrameName);
            [spriteFrame retain];
        }
    
        if([notifsInfo count] > 0){
            userInfo = [[NSMutableArray alloc] initWithArray:notifsInfo];
        }
    }
    return self;
}
-(void)dealloc{
    [spriteFrame release];
    spriteFrame = nil;
    
    [userInfo release];
    userInfo = nil;
    
    [super dealloc];
}

-(CCSpriteFrame*)spriteFrame{
    return spriteFrame;
}
-(void)setSpriteFrame:(CCSpriteFrame*)val{
    if(!val)return;
    if(spriteFrame){
        [spriteFrame release]; spriteFrame = nil;
    }
    spriteFrame = [val retain];
}

-(NSMutableArray*)userInfo{
    return userInfo;
}
@end


@implementation GHAnimation (GH_ANIMATION_SPRITE_PRIVATE)
-(void)setSprite:(GHSprite *)spr{
    sprite = spr;
}
@end


@implementation GHAnimation

@synthesize name;

@synthesize repetitions;
@synthesize loop;
@synthesize randomFrames;
@synthesize restoreSprite;

@synthesize randomReplay;
@synthesize minRandomTime;
@synthesize maxRandomTime;


/** creates an animation from a plist file.
 Make sure that the frames were previously loaded in the CCSpriteFrameCache.
 */


-(id)initWithDictionary:(NSDictionary*)dict name:(NSString*)val{

    self = [super init];
    if(self){
        sprite = nil;
        name = [[NSString alloc] initWithString:val];
        frames = [[NSMutableArray alloc] initWithCapacity:10];
        [self loadAnimationFromDictionary:dict];
    }
    return self;
}

-(id)initWithName:(NSString*)val{
    self = [super init];
    if(self){
        sprite = nil;
        name = [[NSString alloc] initWithString:val];
        frames = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	GHAnimation *animation  = [[[self class] allocWithZone: zone] initWithName:name];

    [animation setRepetitions:[self repetitions]];
    [animation setLoop:[self loop]];
    [animation setRandomFrames:[self randomFrames]];
    [animation setRestoreSprite:[self restoreSprite]];
    [animation setRandomReplay:[self randomReplay]];
    [animation setMinRandomTime:[self minRandomTime]];
    [animation setMaxRandomTime:[self maxRandomTime]];
    [animation setTotalTime:[self totalTime]];
    [[animation frames] addObjectsFromArray:[self frames]];
    
    return animation;
}


-(void)dealloc{
    delegate = nil;
    [name release];
    [frames release];
    [super dealloc];
}

-(void)loadAnimationFromDictionary:(NSDictionary*)dict{
    
    float delayPerUnit = [[dict objectForKey:@"delayPerUnit"] floatValue];
    loop = [[dict objectForKey:@"loop"] boolValue];
    randomFrames = [[dict objectForKey:@"randomFrames"] boolValue];
    repetitions = [[dict objectForKey:@"loops"] intValue];

    maxRandomTime = [[dict objectForKey:@"maxRandomTime"] floatValue];
    minRandomTime = [[dict objectForKey:@"minRandomTime"] floatValue];
    randomReplay  = [[dict objectForKey:@"randomReplay"] boolValue];
    
    restoreSprite = [[dict objectForKey:@"restoreOriginalFrame"] boolValue];
    
    NSArray* framesInfo = [dict objectForKey:@"frames"];

    totalTime = 0;
    for(NSDictionary* frmInfo in framesInfo)
    {
        float delay = [[frmInfo objectForKey:@"delayUnits"] floatValue];
        
        float frameTime = delay*delayPerUnit;
        totalTime += frameTime;
        
        GHAnimationFrame* newFrm = [[GHAnimationFrame alloc] initWithDictionary:frmInfo];
        if(newFrm){
            [frames addObject:newFrm];
            [newFrm setTime:frameTime];
            [newFrm release];
        }
    }    
}

//changing the total time value will change the time on each frame as needed
-(void)setTotalTime:(float)val{
    
    float newTime = val;
    if(newTime < 0.1)
        newTime = 0.1;
    
    float currentTotalTime = totalTime;
    totalTime = 0;
    for(GHAnimationFrame* frame in frames)
    {
        float frameUnit = [frame time]/currentTotalTime;
        //gives a value between 0 and 1 for the frame time
        //multiplying this unit value with the new total time gives the new frame time
        float newFrameTime = frameUnit*newTime;
        totalTime += newFrameTime;
        [frame setTime:newFrameTime];
    }
}
-(float)totalTime{
    return totalTime;
}

-(NSMutableArray*)frames{
    return frames;
}

//if you remove an animation in one of the delegate methods you should make the delegate nil first
-(void)setDelegate:(id<GHAnimationDelegate>)val{
    delegate = val;
}

- (float)calculatedRandomReplayTime
{
    float diff = maxRandomTime - minRandomTime;
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + minRandomTime;
}

-(int)randomFrame
{
    int from = 0;
    int to = (int)[frames count];
    return (int)from + arc4random() % (to-from+1);
}

-(void)update:(ccTime)dt
{
    if(!playing)
        return;
    
    currentTime += dt;
    
    BOOL endedAllRep = false;
    BOOL endedRep = false;    
    if([activeFrame time] <= currentTime)
    {
        BOOL resetCurrentTime = true;
        int nextFrame = currentFrameIdx+1;

        if(randomFrames){
            nextFrame = [self randomFrame];
            while (nextFrame == currentFrameIdx) {
                nextFrame = [self randomFrame];
                //in case the random number returns the same frame
            }
        }
        
        if(nextFrame >= (int)[frames count]){
            
            if(loop){
                if([activeFrame time] + currentRandomRepeatTime <= currentTime)
                {
                    nextFrame = 0;
                    currentRandomRepeatTime = [self calculatedRandomReplayTime];
                    ++repetitionsPerformed;
                    endedRep = true;
                }
                else{
                    nextFrame = (int)[frames count] - 1;
                    resetCurrentTime = false;
                }
            }
            else
            {
                ++repetitionsPerformed;
                if(repetitionsPerformed >= repetitions)
                {
                    nextFrame = (int)[frames count] -1;
                    endedAllRep = true;
                    playing = false;
                }
                else {
                    if(restoreSprite || repetitionsPerformed < repetitions)
                    {
                        nextFrame = 0;
                        endedRep = true;
                    }
                    else {
                        nextFrame = (int)[frames count] -1;
                    }
                }
            }
        }
        if(resetCurrentTime)
            currentTime = 0.0f;
        
        [self setActiveFrameWithIndex:nextFrame];
    }
    
    if(endedAllRep){
        playing = false;
    }
    if(delegate)
    {
        if(endedRep){
            
            if(delegate && [delegate respondsToSelector:@selector(animation:didFinishRepetition:onSprite:)])
            {
                [delegate animation:self didFinishRepetition:repetitionsPerformed onSprite:sprite];
            }
        }
        
        if(endedAllRep){
            
            if(delegate && [delegate respondsToSelector:@selector(animationDidFinishPlaying:onSprite:)])
            {
                [delegate animationDidFinishPlaying:self onSprite:sprite];
            }
        }
    }
}


-(void)moveToFirstFrame{
    [self setActiveFrameWithIndex:0];
}

-(void)moveToPreviousFrame{
    [self setActiveFrameWithIndex:currentFrameIdx-1];
}

-(void)moveToNextFrame{
    [self setActiveFrameWithIndex:currentFrameIdx+1];
}

-(int)currentFrameIndex{
    return currentFrameIdx;
}

-(void)setRandomReplay:(BOOL)val{
    randomReplay = val;
    currentRandomRepeatTime = 0;
}

-(void)prepare
{
    NSAssert( sprite, @"Animation is not assigned on a sprite. Use [sprite setAnimation:anim] before calling \"prepare\".");
    
    [sprite unscheduleUpdate];
    [sprite scheduleUpdate];
    
    currentRandomRepeatTime = 0;
    if(randomReplay){
        currentRandomRepeatTime = [self calculatedRandomReplayTime];
    }
    
    playing = false;
    repetitionsPerformed = 0;
    if(currentFrameIdx == [[self frames] count] - 1){
        [self moveToFirstFrame];
    }
}

-(void)play{
    playing = true;
}
-(void)pause{
    playing = false;
}


-(void)setActiveFrameWithIndex:(int)frmIdx{
    if(frmIdx < 0){
        frmIdx = 0;
    }
    if(frmIdx >= [frames count]){
        frmIdx = (int)[frames count] - 1;
    }

    if(frmIdx == currentFrameIdx && activeFrame != nil)
        return;
    
    if(frmIdx >= 0 && frmIdx < (int)[frames count]){
        currentFrameIdx = frmIdx;
        activeFrame = [frames objectAtIndex:(NSUInteger)currentFrameIdx];
        [sprite setDisplayFrame:[activeFrame spriteFrame]];
        
        if(delegate && [delegate respondsToSelector:@selector(animation:didChangeFrameIdx:onSprite:)])
        {
            [delegate animation:self didChangeFrameIdx:currentFrameIdx onSprite:sprite];
        }

    }
}

-(void)setActiveFrame:(GHAnimationFrame*)frm{
    
    NSUInteger frmIdx = [frames indexOfObject:frm];
    if(frm)
    {
        activeFrame = frm;
        currentFrameIdx = (int)frmIdx;
    }
}

@end
