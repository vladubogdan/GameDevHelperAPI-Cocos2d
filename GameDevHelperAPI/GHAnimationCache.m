//
//  GHAnimationCache.m
//  cocos2d-ios
//
//  Created by Bogdan Vladu on 5/9/13.
//
//

#import "GHAnimationCache.h"
#import "GHAnimation.h"

@interface GHAnimationCache (PRIVATE)

-(void) parseAnimationDictionary:(NSDictionary*)animations;

@end

@implementation GHAnimationCache


#pragma mark CCAnimationCache - Alloc, Init & Dealloc

static GHAnimationCache *sharedAnimationCache_=nil;

+ (GHAnimationCache *)sharedAnimationCache
{
	if (!sharedAnimationCache_)
		sharedAnimationCache_ = [[GHAnimationCache alloc] init];
    
	return sharedAnimationCache_;
}

+(id)alloc
{
	NSAssert(sharedAnimationCache_ == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

+(void)purgeSharedAnimationCache
{
	[sharedAnimationCache_ release];
	sharedAnimationCache_ = nil;
}

-(id) init
{
	if( (self=[super init]) ) {
		animations_ = [[NSMutableDictionary alloc] initWithCapacity: 20];
	}
    
	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | num of animations =  %lu>", [self class], self, (unsigned long)[animations_ count]];
}

-(void) dealloc
{
	CCLOGINFO(@"GameDevHelperAPI: deallocing %@", self);
	[animations_ release];
	[super dealloc];
}

#pragma mark GHAnimationCache - load/get/del

-(void) addAnimation:(GHAnimationCache*)animation name:(NSString*)name
{
	[animations_ setObject:animation forKey:name];
}

-(void) removeAnimationByName:(NSString*)name
{
	if( ! name )
		return;
    
	[animations_ removeObjectForKey:name];
}

-(GHAnimationCache*) animationByName:(NSString*)name
{
	return [animations_ objectForKey:name];
}

#pragma mark GHAnimationCache - from file

-(void) parseAnimationDictionary:(NSDictionary*)animations
{
	NSArray* animationNames = [animations allKeys];
	for( NSString *name in animationNames )
	{
		NSDictionary* animationDict = [animations objectForKey:name];
        
        NSArray* frames = [animationDict objectForKey:@"frames"];
        if([frames count] > 0)
        {
            NSDictionary* firstFrameInfo = [frames objectAtIndex:0];
            if(firstFrameInfo){
                NSString* spriteFrameName = [firstFrameInfo objectForKey:@"spriteframe"];
                
                if(spriteFrameName){
                    CCSpriteFrame* spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteFrameName];

                    if(spriteFrame){
                    
                        GHAnimation* newAnimation = [[GHAnimation alloc] initWithDictionary:animationDict name:name];
                        if(newAnimation){
                            [[GHAnimationCache sharedAnimationCache] addAnimation:newAnimation
                                                                             name:name];
                            [newAnimation release];
                        }
                    }
                    else{
                        CCLOG(@"GameDevHelperAPI WARNING: Sprite frames for animation %@ were not found. Animation will not be loaded.", name);
                    }
                }
            }
        }
	}
}

-(void)addAnimationsWithDictionary:(NSDictionary *)dictionary
{
	NSDictionary *animations = [dictionary objectForKey:@"animations"];
    
	if ( animations == nil ) {
		CCLOG(@"GameDevHelperAPI: GHAnimationCache: No animations were found in provided dictionary.");
		return;
	}
	
	NSUInteger version = 2;
	NSDictionary *properties = [dictionary objectForKey:@"properties"];
	if( properties )
		version = [[properties objectForKey:@"format"] intValue];
	
	NSArray *spritesheets = [properties objectForKey:@"spritesheets"];
	for( NSString *name in spritesheets )
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:name];
    
	switch (version) {
		case 2:
			[self parseAnimationDictionary:animations];
			break;
		default:
			NSAssert(NO, @"Invalid animation format");
	}
}


/** Read an NSDictionary from a plist file and parse it automatically for animations */
-(void)addAnimationsWithFile:(NSString *)plist
{
	NSAssert( plist, @"Invalid animation file name");
    
    NSString *path = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:plist];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    
	NSAssert1( dict, @"GHAnimationCache: File could not be found: %@", plist);
    
    
	[self addAnimationsWithDictionary:dict];
}

@end
