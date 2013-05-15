//
//  GHSkeleton.m
//  cocos2d-ios
//
//  Created by Bogdan Vladu on 4/4/13.
//
//

#import "GHSkeleton.h"
#import "GHSprite.h"
#import "GHBoneSkin.h"
#import "GHSkeletalAnimationCache.h"
#import "GHSkeletalAnimation.h"

@interface GHSkeleton()
-(void)loadSprites:(NSArray*)spritesInfo;
-(void)loadBones:(NSDictionary*)rootBoneInfo;
#ifdef GH_DEBUG
-(void)initShader;
#endif
@end


@interface GHBone(GHSkeletonBonePrivate)
-(void)updateMovement;
@end

@implementation GHBone(GHSkeletonBonePrivate)

-(void)updateMovement{
    if(self.rigid){
        [self setPosition:self.position parent:nil];
    }
    
    for(GHBone* bone in self.children){
        [bone updateMovement];
    }
}
@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation GHSkeleton

-(void)dealloc{
    delegate = nil;
#ifdef GH_DEBUG
    shaderProgram_ = nil;
#endif
    [self unscheduleAllSelectors];
    [self unscheduleUpdate];
    
    [rootBone release];
    [poses release];
    [transitionTime release];
    transitionTime = nil;
    
    [animation release];
    animation = nil;
    
    [super dealloc];
}
-(id)initWithFile:(NSString*)file{
    
    self = [super init];
    if(self){
     
        //maybe the file has or does not have extension given - we do this little trick
        NSString* plistFile = [file stringByDeletingPathExtension];
        plistFile = [plistFile stringByAppendingPathExtension:@"plist"];

        //maye the user has given a suffix - not necessary
        plistFile =  [[CCFileUtils sharedFileUtils] removeSuffixFromFile:plistFile];
        NSString *path = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:plistFile];
        
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        
        NSString* pathToSkeleton = [file stringByDeletingLastPathComponent];
        NSString* pathToSheet = [pathToSkeleton stringByDeletingLastPathComponent];
        
        NSString* sheetName = [dict objectForKey:@"sheet"];
        if(sheetName)
        {
        NSString* sheetFile = [pathToSheet stringByAppendingPathComponent:sheetName];        
            batchNode_ = [CCSpriteBatchNode batchNodeWithFile:sheetFile];
            [self addChild:batchNode_ z:-1];//this way debug drawing will be 0
            [batchNode_ setPosition:ccp(0,0)];
            
            NSString* sheetPlist = [sheetFile stringByDeletingPathExtension];
            sheetPlist = [sheetPlist stringByAppendingPathExtension:@"plist"];
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:sheetPlist];
        }

        [self loadBones:[dict objectForKey:@"root"]];
        [self loadSprites:[dict objectForKey:@"sprites"]];
        [self updateSkins];
        
        
        NSDictionary* posesDict = [dict objectForKey:@"poses"];
        if(posesDict){
            poses = [[NSDictionary alloc] initWithDictionary:posesDict];
        }
        
#ifdef GH_DEBUG
        [self initShader];
#endif
        
    }
    return self;
}

+(id)skeletonWithFile:(NSString*)file{
    return [[[self alloc] initWithFile:file] autorelease];
}


-(void)loadSprites:(NSArray*)spritesInfo
{
    if(spritesInfo == nil)return;
    
    NSMutableArray* allBones = [NSMutableArray arrayWithArray:[self allBones]];
    
    for(NSDictionary* sprInfo in spritesInfo)
    {
        //name
        //angle
        //localPos
        //visible
        CGPoint localPos = CGPointMake(0, 0);
        
        id sprPos = [sprInfo objectForKey:@"localPos"];
        if(sprPos){
            localPos = CGPointFromString(sprPos);
        }
        localPos.x /=CC_CONTENT_SCALE_FACTOR();
        localPos.y /=CC_CONTENT_SCALE_FACTOR();
        
        
        float angle = 0;
        id sprAngle = [sprInfo objectForKey:@"angle"];
        if(sprAngle){
            angle = [sprAngle floatValue];
        }
        
        bool visible = true;
        id sprVis = [sprInfo objectForKey:@"visible"];
        if(sprVis){
            visible = [sprVis boolValue];
        }
        
        NSString* boneUUID = [sprInfo objectForKey:@"boneUUID"];
        
        NSString* skinName = [sprInfo objectForKey:@"skinName"];
        NSString* skinUUID = [sprInfo objectForKey:@"skinUUID"];
        
        NSString* sprName = [sprInfo objectForKey:@"sprName"];
        if(sprName){
            GHSprite* newSpr = [GHSprite spriteWithSpriteFrameName:sprName];
            [newSpr setName:skinName];
            [newSpr setPosition:localPos];
            [newSpr setRotation:angle];
            [newSpr setColor:ccc3(255, 255, 255)];
            [newSpr setVisible:visible];
            if(batchNode_ != nil){
                [batchNode_ addChild:newSpr];
            }
            
            if(boneUUID){
                for(GHBone* bone in allBones)
                {
                    if([[bone uuid] isEqualToString:boneUUID]){
                        [self addSkin:[GHBoneSkin skinWithSprite:newSpr bone:bone name:skinName uuid:skinUUID]];
                        break;//exit for loop
                    }
                }
            }
            else{
                [self addSkin:[GHBoneSkin skinWithSprite:newSpr bone:nil name:skinName uuid:skinUUID]];
            }
        }
    }
}

-(void)loadBones:(NSDictionary*)rootBoneInfo
{
    if(!rootBoneInfo)return;
    rootBone = [[GHBone alloc] initWithDictionary:rootBoneInfo];
}

-(NSArray*)allBones{
    
    NSMutableArray* array = [NSMutableArray array];
    
    [array addObject:rootBone];
    for(GHBone* bone in [rootBone children])
    {
        [array addObjectsFromArray:[bone allBones]];
    }
    
    return array;
}

-(GHBone*)rootBone{
    return rootBone;
}

-(void)setDelegate:(id<GHSkeletonDelegate>)del{
    delegate = del;
}

-(void)setPosition:(CGPoint)location forBoneNamed:(NSString*)boneName{
    
    GHBone* bone = [rootBone boneWithName:boneName];

    if(bone){
        CGPoint localPoint = ccp(location.x - [self position].x,
                                 location.y - [self position].y);
        [bone setPosition:localPoint parent:nil];
    }
    [rootBone updateMovement];
    [self transformSkins];
}

-(void)setPoseWithName:(NSString*)poseName{
    NSAssert( poses != nil, @"\n\nERROR: Skeleton has no poses or poses were not publish.\n\n");

    NSDictionary* poseInfo = [poses objectForKey:poseName];
    NSAssert( poseInfo != nil, @"\n\nERROR: Skeleton has no pose with the given \"poseName\" argument.\n\n");
        
    NSDictionary* visibility = [poseInfo objectForKey:@"visibility"];
    NSAssert( visibility != nil, @"\n\nERROR: Skeleton pose is in wrong format. Skin visibilities were not found.\n\n");
    
    NSDictionary* zOrder = [poseInfo objectForKey:@"zOrder"];
    NSAssert( visibility != nil, @"\n\nERROR: Skeleton pose is in wrong format. Skin z orders were not found.\n\n");
    
    NSDictionary* skinTex = [poseInfo objectForKey:@"skinTex"];
    NSAssert( skinTex != nil, @"\n\nERROR: Skeleton pose is in wrong format. Skin sprite frame names were not found.\n\n");
    
    NSDictionary* connections = [poseInfo objectForKey:@"connections"];
    NSAssert( connections != nil, @"\n\nERROR: Skeleton pose is in wrong format. Skin connections were not found.\n\n");
    
    NSArray* allBones = [self allBones];
    
    for(GHBoneSkin* skin in skins){
        
        [[skin sprite] setVisible:YES];
        NSNumber* value = [visibility objectForKey:[skin uuid]];
                
        if(value){
            [[skin sprite] setVisible:NO];
        }

        NSNumber* zValue = [zOrder objectForKey:[skin uuid]];
        if(zValue){
            [batchNode_ reorderChild:[skin sprite] z:[zValue integerValue]];
        }
        
        NSString* spriteFrameName = [skinTex objectForKey:[skin uuid]];
        if(spriteFrameName){
            CCSpriteFrame* frame =  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteFrameName];
            if(frame){
                [[skin sprite] setDisplayFrame:frame];
            }
        }
        
        NSDictionary* connectionInfo = [connections objectForKey:[skin uuid]];
        if(connectionInfo){
            //angleOff
            //boneUUID //this may be missing if no connection
            //conAngle
            //posOff
            
            NSString* boneUUID = [connectionInfo objectForKey:@"boneUUID"];
            if(boneUUID)
            {
                //check if the current bone is already our connection bone - if not change it
                if(!([skin bone] && [[[skin bone] uuid] isEqualToString:boneUUID]))
                {
                    for(GHBone* bone in allBones)
                    {
                        if([[bone uuid] isEqualToString:boneUUID]){
                            [skin setBone:bone];
                            break;
                        }
                    }
                }
            }
            else{
                [skin setBone:nil];
            }
                        
            NSNumber* angleOff = [connectionInfo objectForKey:@"angleOff"];
            if(angleOff){
                [skin setAngleOffset:[angleOff floatValue]];
            }
            
            NSString* posOff = [connectionInfo objectForKey:@"posOff"];
            if(posOff)
            {
                CGPoint newPos = CGPointFromString(posOff);
                newPos.x /= CC_CONTENT_SCALE_FACTOR();
                newPos.y /= CC_CONTENT_SCALE_FACTOR();
                [skin setPositionOffset:newPos];
            }
    
            NSNumber* connectionAngle = [connectionInfo objectForKey:@"conAngle"];
            if(connectionAngle){
                [skin setConnectionAngle:[connectionAngle floatValue]];
            }
        }
    }

    
    NSDictionary* positions = [poseInfo objectForKey:@"positions"];
    NSAssert( positions != nil, @"\n\nERROR: Skeleton pose is in wrong format. Bone positions were not found.\n\n");
        
    for(GHBone* bone in allBones)
    {
        NSString* uuid = [bone uuid];
        NSAssert( uuid != nil, @"\n\nERROR: Bone has no UUID.\n\n");
        
        NSString* bonePos = [positions objectForKey:uuid];
        NSAssert( bonePos != nil, @"\n\nERROR: Bone pose does not have a position value. Must be in a wrong format.\n\n");
        
        CGPoint newPos = CGPointFromString(bonePos);
        newPos.x /= CC_CONTENT_SCALE_FACTOR();
        newPos.y /= CC_CONTENT_SCALE_FACTOR();
        bone.position = newPos;
    }
    


    [self transformSkins];
    
    if(delegate){
        if([delegate respondsToSelector:@selector(didLoadPoseWithName:onSkeleton:)])
        {
            [delegate didLoadPoseWithName:poseName onSkeleton:self];
        }
    }
}


-(void)addSkin:(GHBoneSkin*)skin{
    if(nil == skin)return;
    
    if(nil == skins){
        skins = [[NSMutableArray alloc] init];
    }
    [skins addObject:skin];
}
-(void)removeSkin:(GHBoneSkin*)skin{
    [skins removeObject:skin];
}
-(NSArray*)skins{
    return skins;
}


-(void)playAnimation:(GHSkeletalAnimation*)anim{
    if(nil == anim)return;
    
    [self stopAnimation];

    if(transitionTime){[transitionTime release]; transitionTime = nil;}
    currentTranstionTime = 0;
    
    animation = anim;
    [animation retain];
    
    [anim setCurrentTime:0];
    [anim setCurrentLoop:0];
    
    if(delegate){
        if([delegate respondsToSelector:@selector(didStartAnimation:onSkeleton:)])
        {
            [delegate didStartAnimation:anim onSkeleton:self];
        }
    }
    [self scheduleUpdate];
}
-(void)playAnimationWithName:(NSString*)animName{
    GHSkeletalAnimation* anim = [[GHSkeletalAnimationCache sharedSkeletalAnimationCache] skeletalAnimationWithName:animName];
    [self playAnimation:anim];
}

-(GHSkeletalAnimation*)animation{
    return animation;
}

-(void)transitionToAnimation:(GHSkeletalAnimation*)anim inTime:(float)time{
    
    if(nil == anim)return;

    NSArray* allBones = [self allBones];
    for(GHBone* bone in allBones){
        [bone savePosition];
    }
    
    [self playAnimation:anim];//this will also rmeove any previous transition time
    
    transitionTime = [[NSNumber numberWithFloat:time] retain];
    currentTranstionTime = 0;
}

-(void)transitionToAnimationWithName:(NSString*)animName inTime:(float)time{
    GHSkeletalAnimation* anim = [[GHSkeletalAnimationCache sharedSkeletalAnimationCache] skeletalAnimationWithName:animName];
    [self transitionToAnimation:anim inTime:time];
}


-(void)stopAnimation{
    if(animation){
        [animation release];
    }
    animation = nil;
    [self unscheduleUpdate];
}
-(void) update: (ccTime) dt
{
    float time = 0;
    
    if(transitionTime != nil)
    {
        if([transitionTime floatValue] < currentTranstionTime)
        {
            [transitionTime release];
            transitionTime = nil;
            [animation setCurrentTime:dt];
            [animation setCurrentLoop:0];
            currentTranstionTime = 0;
            time = dt;
            
            if(delegate){
                if([delegate respondsToSelector:@selector(didFinishTransitionToAnimation:onSkeleton:)]){
                    [delegate didFinishTransitionToAnimation:animation onSkeleton:self];
                }
            }
        }
        time = currentTranstionTime;
        currentTranstionTime += dt;
    }
    else{
        time = [animation currentTime];
        
        if([animation reversed]){
            [animation setCurrentTime:[animation currentTime] - dt];
        }else{
            [animation setCurrentTime:[animation currentTime] + dt];
        }
    }

    
    if([animation reversed] && transitionTime == nil)
    {
        if(time <= 0){
            
            switch ([animation playMode]) {
                case GH_SKELETAL_ANIM_PLAY_NORMAL:
                case GH_SKELETAL_ANIM_PLAY_LOOP:
                    [animation setCurrentTime:[animation totalTime]];
                    break;
                    
                case GH_SKELETAL_ANIM_PLAY_PINGPONG:
                    [animation setCurrentTime:0];
                    [animation setReversed:NO];
                    break;
                    
                default:
                    break;
            }
            
            if(delegate){
                if([delegate respondsToSelector:@selector(didFinishLoopInAnimation:onSkeleton:)]){
                    [delegate didFinishLoopInAnimation:animation onSkeleton:self];
                }
            }
            [animation setCurrentLoop:[animation currentLoop]+1];
        }
    }
    else{
        if(time >= [animation totalTime]){
            
            switch ([animation playMode]) {
                case GH_SKELETAL_ANIM_PLAY_NORMAL:
                case GH_SKELETAL_ANIM_PLAY_LOOP:
                    [animation setCurrentTime:0];
                    break;

                case GH_SKELETAL_ANIM_PLAY_PINGPONG:
                    [animation setCurrentTime:[animation totalTime]];
                    [animation setReversed:YES];
                    break;

                default:
                    break;
            }
            [animation setCurrentLoop:[animation currentLoop]+1];
            if(delegate){
                if([delegate respondsToSelector:@selector(didFinishLoopInAnimation:onSkeleton:)]){
                    [delegate didFinishLoopInAnimation:animation onSkeleton:self];
                }
            }
        }
    }
    
    if([animation numberOfLoops] != 0 && [animation currentLoop] >= [animation numberOfLoops]){
        [self stopAnimation];
    }
    
    { //handle positions
        GHSkeletalAnimationFrame* beginFrame = nil;
        GHSkeletalAnimationFrame* endFrame = nil;
        
        for(GHSkeletalAnimationFrame* frm in [animation bonePositionFrames]){
                        
            if([frm time] <= time){
                beginFrame = frm;
            }
            
            if([frm time] > time){
                endFrame = frm;
                break;//exit for
            }
        }
        
        if(transitionTime)
        {
            NSArray* positionFrames = [animation bonePositionFrames];
            
            if([positionFrames count] > 0)
                beginFrame = [positionFrames objectAtIndex:0];
            
            
            float beginTime = 0;
            float endTime = [transitionTime floatValue];
            
            float framesTimeDistance = endTime - beginTime;
            float timeUnit = (time-beginTime)/framesTimeDistance; //a value between 0 and 1
                        
            NSMutableDictionary* beginBonesInfo = [beginFrame bonePositions];
            
            if(nil == beginBonesInfo)
                return;
            
            NSArray* allBones = [self allBones];
            
            for(GHBone* bone in allBones)
            {
                NSValue* beginValue = [beginBonesInfo objectForKey:[bone name]];
                
                CGPoint beginPosition = [bone previousPosition];
                CGPoint endPosition = [bone position];
                
                if(beginValue){
                    endPosition = [beginValue CGPointValue];
                }
                
                //lets calculate the position of the bone based on the start - end and unit time
                float newX = beginPosition.x + (endPosition.x - beginPosition.x)*timeUnit;
                float newY = beginPosition.y + (endPosition.y - beginPosition.y)*timeUnit;
                
                CGPoint newPos = CGPointMake(newX, newY);
                bone.position = newPos;
                [self transformSkins];
            }
            [rootBone updateMovement];
        }
        else if(beginFrame && endFrame){
            
            float beginTime = [beginFrame time];
            float endTime = [endFrame time];

            float framesTimeDistance = endTime - beginTime;
            float timeUnit = (time-beginTime)/framesTimeDistance; //a value between 0 and 1

            NSMutableDictionary* beginBonesInfo = [beginFrame bonePositions];
            NSMutableDictionary* endBonesInfo = [endFrame bonePositions];

            if(nil == beginBonesInfo || endBonesInfo == nil)
                return;
            
            NSArray* allBones = [self allBones];
            
            for(GHBone* bone in allBones)
            {                
                NSValue* beginValue = [beginBonesInfo objectForKey:[bone name]];
                NSValue* endValue = [endBonesInfo objectForKey:[bone name]];
                
                
                CGPoint beginPosition = [bone position];
                CGPoint endPosition = [bone position];
                
                if(beginValue){
                    beginPosition = [beginValue CGPointValue];
                }
                
                if(endValue){
                    endPosition = [endValue CGPointValue];
                }
                
                //lets calculate the position of the bone based on the start - end and unit time
                
                float newX = beginPosition.x + (endPosition.x - beginPosition.x)*timeUnit;
                float newY = beginPosition.y + (endPosition.y - beginPosition.y)*timeUnit;
                                
                CGPoint newPos = CGPointMake(newX, newY);
                bone.position = newPos;
            }
            [rootBone updateMovement];
        }
        else if(beginFrame)
        {
            NSMutableDictionary* beginBonesInfo = [beginFrame bonePositions];
            NSArray* allBones = [self allBones];
            
            for(GHBone* bone in allBones)
            {
                NSValue* beginValue = [beginBonesInfo objectForKey:[bone name]];

                CGPoint beginPosition = [bone position];
                if(beginValue){
                    beginPosition = [beginValue CGPointValue];
                }
                bone.position = beginPosition;
            }
            [rootBone updateMovement];
        }
    }
    
    if(transitionTime){
        time = 0;
    }
    
    {//handle sprites z order
        
        GHSkeletalAnimationFrame* beginFrame = nil;
        
        for(GHSkeletalAnimationFrame* frm in [animation spriteZOrderFrames]){
            if([frm time] <= time){
                beginFrame = frm;
            }
        }
        
        //we have the last frame with smaller time
        if(beginFrame){
            
            NSDictionary* zOrderInfo = [beginFrame spritesZOrder];
            
            for(GHSprite* sprite in [batchNode_ children])
            {
                NSString* sprName = [sprite name];
                if(sprName){
                    
                    NSNumber* zNum = [zOrderInfo objectForKey:sprName];
                    if(zNum)
                    {
                        [batchNode_ reorderChild:sprite z:[zNum intValue]];
                    }
                }
            }
        }
    }
    
    

         
    {//handle skin connections        
        GHSkeletalAnimationFrame* beginFrame = nil;
        
        for(GHSkeletalAnimationFrame* frm in [animation skinConnectionFrames]){
            if([frm time] <= time){
                beginFrame = frm;
            }
        }
        
        //we have the last frame with smaller time
        if(beginFrame){
            
            NSDictionary* connections = [beginFrame skinConnections];
            
            for(GHBoneSkin* skin in skins)
            {
                GHSprite* sprite = [skin sprite];
                if(sprite){
                    NSString* sprName = [sprite name];
                    if(sprName){
                        GHSkeletalSkinConnectionInfo* connectionInfo = [connections objectForKey:sprName];
                        
                        if(connectionInfo)
                        {
                            NSString* boneName = [connectionInfo boneName];
                                                    
                            [skin setAngleOffset:[connectionInfo angleOffset]];
                            [skin setPositionOffset:[connectionInfo positionOffset]];
                            [skin setConnectionAngle:[connectionInfo connectionAngle]];
                         
                            
                            if(!boneName)//we may not have a bone
                            {
                                [skin setBone:nil];
                            }
                            else{
                                for(GHBone* bone in [self allBones])
                                {
                                    if([[bone name] isEqualToString:boneName]){
                                        [skin setBone:bone];
                                        break;//exit for loop
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
        
   

    
    {//handle skin sprites
        
        
        GHSkeletalAnimationFrame* beginFrame = nil;
        
        for(GHSkeletalAnimationFrame* frm in [animation skinSpriteFrames]){
            if([frm time] <= time){
                beginFrame = frm;
            }
        }
        
        //we have the last frame with smaller time
        if(beginFrame){
            NSMutableDictionary* info = [beginFrame skinSprites];
            if(info){
                
                for(GHBoneSkin* skin in skins)
                {
                    NSString* newSprFrameName = [info objectForKey:[skin name]];                        
                    if(newSprFrameName){
                        
                        CCSpriteFrame* frame =  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:newSprFrameName];
                        if(frame){
                            [[skin sprite] setDisplayFrame:frame];
                        }
                    }
                }
            }
        }
    }
    
    
    {//handle sprites visibility

        GHSkeletalAnimationFrame* beginFrame = nil;
        
        for(GHSkeletalAnimationFrame* frm in [animation visibilityFrames]){
            if([frm time] <= time){
                beginFrame = frm;
            }
        }
        
        //we have the last frame with smaller time
        if(beginFrame){
            NSMutableDictionary* info = [beginFrame spritesVisibility];
            
            if(info){
                
                for(GHSprite* sprite in [batchNode_ children])
                {
                    NSString* sprFrmName = [sprite name];
                    
                    if(sprFrmName){
                        NSNumber* val = [info objectForKey:sprFrmName];
//                        NSLog(@"SPR FRM NAME %@ %@ ", sprFrmName, val);
                        if(val){
                            [sprite setVisible:[val boolValue]];
                        }
                    }
                }
            }
        }
    }
    
    
    
    { //handle sprites transform
        GHSkeletalAnimationFrame* beginFrame = nil;
        GHSkeletalAnimationFrame* endFrame = nil;
                    
        for(GHSkeletalAnimationFrame* frm in [animation spritesTransformFrames]){
            if([frm time] <= time){
                beginFrame = frm;
            }
            
            if([frm time] > time){
                endFrame = frm;
                break;//exit for
            }
        }
        
        if(beginFrame && endFrame){
            
            float beginTime = [beginFrame time];
            float endTime = [endFrame time];
            
            float framesTimeDistance = endTime - beginTime;
            float timeUnit = (time-beginTime)/framesTimeDistance; //a value between 0 and 1
            
            NSMutableDictionary* beginFrameInfo = [beginFrame spritesTransform];
            NSMutableDictionary* endFrameInfo = [endFrame spritesTransform];
             
            if(beginFrameInfo == nil || endFrameInfo == nil)
                return;
            
            for(GHBoneSkin* skin in skins)
            {
                GHSkeletalSkinConnectionInfo* beginInfo = [beginFrameInfo objectForKey:[skin name]];
                GHSkeletalSkinConnectionInfo* endInfo = [endFrameInfo objectForKey:[skin name]];
            
                
                
                if([skin sprite] && beginInfo && endInfo)
                {
                
                    //set position
                    CGPoint beginPos = [beginInfo position];
                    CGPoint endPos = [endInfo position];
                    float newX = beginPos.x + (endPos.x - beginPos.x)*timeUnit;
                    float newY = beginPos.y + (endPos.y - beginPos.y)*timeUnit;
                    
                    [[skin sprite] setPosition:ccp(newX, newY)];
                   

                    //set angle
                    float beginAngle = [beginInfo angle];
                    float endAngle = [endInfo angle];
                    float newAngle = beginAngle + (endAngle - beginAngle)*timeUnit;
                    [[skin sprite] setRotation:newAngle];
                 
                    
                    //set angle at skin time
                    float beginSkinAngle = [beginInfo connectionAngle];
                    float endSkinAngle = [endInfo connectionAngle];
                    float newSkinAngle = beginSkinAngle + (endSkinAngle - beginSkinAngle)*timeUnit;
                    [skin setConnectionAngle:newSkinAngle];

                    
                    {
                    //set skin angle
                    float beginAngle = [beginInfo angleOffset];
                    float endAngle = [endInfo angleOffset];
                    float newAngle = beginAngle + (endAngle - beginAngle)*timeUnit;
                    [skin setAngleOffset:newAngle];
                    
                    //set skin position offset
                    CGPoint beginPosOff = [beginInfo positionOffset];
                    CGPoint endPosOff = [endInfo positionOffset];
                    
                    float newX = beginPosOff.x + (endPosOff.x - beginPosOff.x)*timeUnit;
                    float newY = beginPosOff.y + (endPosOff.y - beginPosOff.y)*timeUnit;
                    [skin setPositionOffset:ccp(newX, newY)];                        
                    }
                }
            }
        }
    }
        

    [self transformSkins];
    
    currentTranstionTime += dt;
}




-(void)updateSkins{
    for(GHBoneSkin* skin in skins){
        [skin setupTransformations];
    }
}

-(void)transformSkins
{
    for(GHBoneSkin* skin in skins){
        [skin transform];
    }
}


#ifdef GH_DEBUG

-(void)initShader
{
	shaderProgram_ = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_Position_uColor];
	
	colorLocation_ = glGetUniformLocation( shaderProgram_->program_, "u_color");
}

-(void)debugDrawBone:(GHBone*)bone
{
    if([bone rigid]){
        [shaderProgram_ setUniformLocation:colorLocation_ withF1:0 f2:0 f3:1 f4:1];
    }
    else{
        [shaderProgram_ setUniformLocation:colorLocation_ withF1:0 f2:1 f3:0 f4:1];
    }
    
    for(GHBone* child in [bone children])
    {
        GLfloat	vertices[] = {
            bone.position.x, bone.position.y,
            child.position.x, child.position.y
        };
        
        glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, vertices);
        
        glDrawArrays(GL_LINES, 0, 2);
        
        [self debugDrawBone:child];
    }
}

-(void) draw{
    if(!shaderProgram_)return;
    
    [shaderProgram_ use];
	[shaderProgram_ setUniformForModelViewProjectionMatrix];

    [self debugDrawBone:rootBone];
    
    CC_INCREMENT_GL_DRAWS(1);
	CHECK_GL_ERROR_DEBUG();
}

#endif


@end
