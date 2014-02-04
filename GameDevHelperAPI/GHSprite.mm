//
//  GHSprite.mm
//  GameDevHelper.com
//
//  Created by Bogdan Vladu.
//  Copyright (c) 2013 Bogdan Vladu. All rights reserved.
//

#import "GHSprite.h"
#import "GHDirector.h"
#import "ghMacros.h"

#import "GHAnimationCache.h"

@interface GHAnimation (GH_ANIMATION_SPRITE_PRIVATE)
-(void)setSprite:(GHSprite*)spr;
-(void)prepare;
-(void)play;
-(void)pause;
-(void)update:(float)dt;
@end


@implementation GHSprite
@synthesize imageFile, spriteFrameName;

+(id)spriteWithSpriteFrameName:(NSString*)spriteFrameName
{
#ifndef GH_ENABLE_ARC
    return [[[self alloc] initWithSpriteFrameName:spriteFrameName] autorelease];
#else
    return [[self alloc] initWithSpriteFrameName:spriteFrameName];
#endif
}

-(id)initWithSpriteFrameName:(NSString*)sprFrameName
{
	self = [super initWithSpriteFrameName:sprFrameName];
    if(self){
    	#if GH_ENABLE_PHYSICS_INTEGRATION
        	body = NULL;
        #endif
        
        spriteFrameName = [[NSString alloc] initWithString:sprFrameName];
        
        NSString* plistFile = [[self imageFile] stringByDeletingPathExtension];
        plistFile = [plistFile stringByAppendingPathExtension:@"plist"];
        plistFile =  [[CCFileUtils sharedFileUtils] removeSuffixFromFile:plistFile];
        NSString *path = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:plistFile];
        
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];

        NSDictionary* frames = [dict objectForKey:@"frames"];
        
        if(frames)
        {
            NSDictionary* frameInfo = [frames objectForKey:sprFrameName];

            if(frameInfo){
                //if its a normal cocos2d plist we wont have this keys
                id tagInfo = [frameInfo objectForKey:@"tag"];
                if(tagInfo){
                    [self setTag:[tagInfo integerValue]];
                }
                
                id tint = [frameInfo objectForKey:@"tint"];
                if(tint){
                    CGRect tintRect = CGRectFromString(tint);
                    [self setColor:ccc3(tintRect.origin.x, tintRect.origin.y, tintRect.size.width)];
                    [self setOpacity:tintRect.size.height];
                }
      
                
#if GH_ENABLE_PHYSICS_INTEGRATION
                NSDictionary* bodyInfo = [frameInfo objectForKey:@"body"];
                if(bodyInfo){
                    physicsInfo = [[NSDictionary alloc] initWithDictionary:bodyInfo];
                    
                    [self createBody];
                }
#endif

            }
        }
    }
    return self;
}

- (id) initWithSpriteFrame:(CCSpriteFrame*)spriteFrame
{
    self = [super initWithSpriteFrame:spriteFrame];
    if(self){
        [self setImageFile:[spriteFrame textureFilename]];
    }
    return self;
}

-(void)dealloc{
    [spriteFrameName release];
    spriteFrameName = nil;
    
    [imageFile release];
    imageFile = nil;
    
    [activeAnimation setSprite:nil];
    [activeAnimation release];
    activeAnimation = nil;
    
    [name release];
    name = nil;
    
#if GH_ENABLE_PHYSICS_INTEGRATION
    [physicsInfo release];
    physicsInfo = nil;
#endif
    
    [super dealloc];
}

-(void)setImageFile:(NSString *)file{
    if(imageFile){[imageFile release]; imageFile = nil;}
    imageFile = [[NSString alloc] initWithString:file];
}

-(NSString*)description{
    return [NSString stringWithFormat:@"GHSprite imageFile: %@ spriteFrameName %@\n", imageFile, spriteFrameName];
}

-(void)setName:(NSString*)val{
    if(val == nil || val == name || [val isEqualToString:name]){
        return;
    }
    
    if(name){[name release]; name = nil;}
    
    name = [[NSString alloc] initWithString:val];
}
-(NSString*)name{
    return name;
}

-(void)prepareAnimation:(GHAnimation*)anim{
    if(activeAnimation){
        [activeAnimation setSprite:nil];
        [activeAnimation release];
        activeAnimation = nil;
    }
    if(anim){
        activeAnimation = [anim copy];
        [activeAnimation setSprite:self];
        [activeAnimation prepare];
    }
}
-(void)prepareAnimationWithName:(NSString*)animName{
    GHAnimation* anim = [[GHAnimationCache sharedAnimationCache] animationByName:animName];
    if(anim){
        [self prepareAnimation:anim];
    }
    else{
        CCLOG(@"GameDevHelperAPI WARNING: Animation with name %@ was could not be prepared because it was not found.", animName);
    }
}
-(GHAnimation*)animation{
    return activeAnimation;
}

-(void)playAnimation{
    if(activeAnimation)[activeAnimation play];
}
-(void)pauseAnimation{
    if(activeAnimation)[activeAnimation pause];
}
-(void)restartAnimation{
    
}
-(void)stopAnimation{
    
}
-(void)stopAnimationAndRestoreOriginalFrame:(BOOL)restore{
    
}

-(void)setAnimationDelegate:(id<GHAnimationDelegate>)obj{
    if(activeAnimation){[activeAnimation setDelegate:obj];}
}




-(void)update:(ccTime)dt{
    if(activeAnimation){
        [activeAnimation update:dt];
    }
}



#if GH_ENABLE_PHYSICS_INTEGRATION
-(void)destroyBody{
    if(body){
        b2World* bWorld = body->GetWorld();
        bWorld->DestroyBody(body);
        body = NULL;
    }
}
-(void)createBody{
    
    if(physicsInfo == nil)return;
    
    [self destroyBody];
    
    b2World* world = [[GHDirector sharedDirector] physicalWorld];

    if(world == nil)return;
    
    int type = [[physicsInfo objectForKey:@"type"] intValue];
    if(type == 3)//NO PHYSICS
        return;
    
    b2BodyDef bodyDef;
	bodyDef.type = (b2BodyType)type;
	   
	bodyDef.position = GH_POINT_TO_METERS([self position]);
    
	bodyDef.angle = CC_DEGREES_TO_RADIANS(-1*self.rotation);;
    bodyDef.userData = self;

    body = world->CreateBody(&bodyDef);
    
	body->SetFixedRotation([[physicsInfo objectForKey:@"fixed"] boolValue]);
    body->SetGravityScale([[physicsInfo objectForKey:@"gravityScale"] floatValue]);
	body->SetSleepingAllowed([[physicsInfo objectForKey:@"sleep"] boolValue]);
    body->SetBullet([[physicsInfo objectForKey:@"bullet"] boolValue]);
    body->SetAwake([[physicsInfo objectForKey:@"awake"] boolValue]);
    body->SetActive([[physicsInfo objectForKey:@"active"] boolValue]);

    NSArray* shapesInfo = [physicsInfo objectForKey:@"shapes"];
    for(NSDictionary* shInfo in shapesInfo)
    {
        float density = [[shInfo objectForKey:@"density"]floatValue];
        float friction = [[shInfo objectForKey:@"friction"]floatValue];
        float restitution = [[shInfo objectForKey:@"restitution"]floatValue];
        bool sensor = [[shInfo objectForKey:@"sensor"]boolValue];
//        <key>name</key>
//        <string>backpackShape</string>
//        <key>sensor</key>
//        <false/>
//        <key>shapeID</key>
//        <integer>0</integer>
//        
        
        int type = [[shInfo objectForKey:@"type"] intValue];

        if(type == 2) //CIRCLE
        {
            b2FixtureDef fixture;
            b2CircleShape circle;
            
            float circleRadius = [[shInfo objectForKey:@"radius"] floatValue];
            NSString* offsetStr = [shInfo objectForKey:@"circleOffset"];
            CGPoint offset = CGPointFromString(offsetStr);
            
            circle.m_radius = GH_VALUE_TO_METERS(circleRadius)/2.0f/CC_CONTENT_SCALE_FACTOR();
            
            circle.m_p = GH_POINT_TO_METERS(offset);
            circle.m_p.x /= CC_CONTENT_SCALE_FACTOR();
            circle.m_p.y /= CC_CONTENT_SCALE_FACTOR();
            
            fixture.shape = &circle;
            
            fixture.density = density;
            fixture.friction = friction;
            fixture.restitution = restitution;
            fixture.isSensor = sensor;
            
            NSNumber* cat = [shInfo objectForKey:@"category"];
            NSNumber* mask = [shInfo objectForKey:@"mask"];
            
            if(cat && mask)
            {
                fixture.filter.categoryBits = [cat intValue];
                fixture.filter.maskBits = [mask intValue];
            }
                        
            body->CreateFixture(&fixture);
        }
        else{//create using points
            NSArray* fixtures = [shInfo objectForKey:@"fixtures"];
            for(NSArray* fixPoints in fixtures)
            {
                int count = (int)[fixPoints count];
                b2Vec2 *verts = new b2Vec2[count];
                b2PolygonShape shapeDef;
                
                
                int i = count - 1;
                for(int j = 0; j< count; ++j)
                {
                    NSString* pointStr = [fixPoints objectAtIndex:(NSUInteger)j];
                    CGPoint point = CGPointFromString(pointStr);

                    point.x /= CC_CONTENT_SCALE_FACTOR();
                    point.y /= CC_CONTENT_SCALE_FACTOR();
                    
                    //flip y for cocos2d coordinate system
                    point.y =  [self textureRect].size.height - point.y;
                    point.y = point.y - [self textureRect].size.height;
                    
                    verts[i] = GH_POINT_TO_METERS(point);                    
                    i = i-1;
                }
                
                shapeDef.Set(verts, count);
                
                b2FixtureDef fixture;
                //------------------------------------------------------------------
                fixture.density = density;
                fixture.friction = friction;
                fixture.restitution = restitution;
                fixture.isSensor = sensor;
                
                NSNumber* cat = [shInfo objectForKey:@"category"];
                NSNumber* mask = [shInfo objectForKey:@"mask"];
                
                if(cat && mask)
                {
                    fixture.filter.categoryBits = [cat intValue];
                    fixture.filter.maskBits = [mask intValue];
                }
                
                fixture.shape = &shapeDef;
                body->CreateFixture(&fixture);
                delete[] verts;
            }

            
        }
    }
}

// this method will only get called if the sprite is batched.
// return YES if the physics values (angles, position ) changed
// If you return NO, then nodeToParentTransform won't be called.
-(BOOL) dirty
{
	return YES;
}

// returns the transform matrix according the Chipmunk Body values
-(CGAffineTransform) nodeToParentTransform
{
    if(body){
        CGPoint pos = GH_METERS_TO_POINT(body->GetPosition());
	
        if ( ignoreAnchorPointForPosition_ ) {
            pos.x += anchorPointInPoints_.x;
            pos.y += anchorPointInPoints_.y;
        }
        
        // Make matrix
        float radians = body->GetAngle();
        float c = cosf(radians);
        float s = sinf(radians);
        
        if( ! CGPointEqualToPoint(anchorPointInPoints_, CGPointZero) ){
            pos.x += c*-anchorPointInPoints_.x + -s*-anchorPointInPoints_.y;
            pos.y += s*-anchorPointInPoints_.x + c*-anchorPointInPoints_.y;
        }
        
        // Rot, Translate Matrix
        transform_ = CGAffineTransformMake( c,  s,
                                           -s,	c,
                                           pos.x,	pos.y);
        
        return transform_;
    }
    
    return [super nodeToParentTransform];
}

-(void)setPosition:(CGPoint)pos
{
    [super setPosition:pos];
    if(body){
        body->SetTransform(GH_POINT_TO_METERS(pos), CC_DEGREES_TO_RADIANS(-1*super.rotation));
    }
}

-(void)setRotation:(float)rot{
    [super setRotation:rot];
    if(body){
        body->SetTransform(GH_POINT_TO_METERS(self.position), CC_DEGREES_TO_RADIANS(-1*rot));
    }
}

#endif //GH_ENABLE_PHYSICS_INTEGRATION




@end
