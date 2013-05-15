//
//  GHSkeletalAnimationCache.m
//  cocos2d-ios
//
//  Created by Bogdan Vladu on 4/8/13.
//
//

#import "GHSkeletalAnimationCache.h"
#import "cocos2d.h"
#import "GHSkeletalAnimation.h"

@interface GHSkeletalAnimationCache ()
- (void) addSkeletalAnimationWithDictionary:(NSDictionary*)dictionary;
@end


@implementation GHSkeletalAnimationCache


#pragma mark GHSkeletalAnimationCache - Alloc, Init & Dealloc

static GHSkeletalAnimationCache *sharedSkeletalAnimationCache_=nil;

+ (GHSkeletalAnimationCache *)sharedSkeletalAnimationCache
{
	if (!sharedSkeletalAnimationCache_)
		sharedSkeletalAnimationCache_ = [[GHSkeletalAnimationCache alloc] init];
    
	return sharedSkeletalAnimationCache_;
}

+(id)alloc
{
	NSAssert(sharedSkeletalAnimationCache_ == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

+(void)purgeSharedSkeletalAnimationCache
{
	[sharedSkeletalAnimationCache_ release];
	sharedSkeletalAnimationCache_ = nil;
}

-(id) init
{
	if( (self=[super init]) ) {
		skeletalAnimations_ = [[NSMutableDictionary alloc] initWithCapacity: 10];
		loadedFilenames_ = [[NSMutableSet alloc] initWithCapacity:30];
	}
    
	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | num of sprite frames =  %lu>", [self class], self, (unsigned long)[skeletalAnimations_ count]];
}

-(void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);
    
	[skeletalAnimations_ release];
	[loadedFilenames_ release];
    
	[super dealloc];
}


-(void) addSkeletalAnimationWithFile:(NSString*)plist{

    NSAssert(plist, @"plist filename should not be nil");
	
	if( ! [loadedFilenames_ member:plist] ) {
        
		NSString *path = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:plist];
		NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];

        [self addSkeletalAnimationWithDictionary:dict];
		
		[loadedFilenames_ addObject:plist];
	}
	else
		CCLOGINFO(@"GameDevHelper: GHSkeletalAnimationCache: file already loaded: %@", plist);

}

- (void) addSkeletalAnimationWithDictionary:(NSDictionary*)dictionary{
    if(nil == dictionary)return;
    GHSkeletalAnimation* anim = [GHSkeletalAnimation animationWithDictionary:dictionary];
    [skeletalAnimations_ setObject:anim forKey:anim.name];
}

-(void) removeSkeletalAnimations{
    
    [skeletalAnimations_ removeAllObjects];
	[loadedFilenames_ removeAllObjects];
}

-(void) removeUnusedSkeletalAnimations{
    
	NSArray *keys = [skeletalAnimations_ allKeys];
	for( id key in keys ) {
		id value = [skeletalAnimations_ objectForKey:key];
		if( [value retainCount] == 1 ) {
			CCLOG(@"GameDevHelper: GHSkeletalAnimationCache: removing unused frame: %@", key);
            
//            [loadedFilenames_ removeObject:<#(id)#>
			[skeletalAnimations_ removeObjectForKey:key];
		}
	}
}

-(void) removeSkeletalAnimationWithName:(NSString*)name{
    
    // explicit nil handling
	if( ! name )
		return;
    
    [skeletalAnimations_ removeObjectForKey:name];
	
	// XXX. Since we don't know the .plist file that originated the frame, we must remove all .plist from the cache
	[loadedFilenames_ removeAllObjects];
}

-(GHSkeletalAnimation*) skeletalAnimationWithName:(NSString*)name{
    
    GHSkeletalAnimation *anim = [skeletalAnimations_ objectForKey:name];
	if( ! anim ) {
			CCLOG(@"GameDevHelper: GHSkeletalAnimationCache: Animation '%@' not found", name);
	}
    
	return anim;
}

@end
