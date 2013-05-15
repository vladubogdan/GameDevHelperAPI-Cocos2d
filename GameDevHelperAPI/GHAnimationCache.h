//
//  GHAnimationCache.h
//  cocos2d-ios
//
//  Created by Bogdan Vladu on 5/9/13.
//
//

#import "cocos2d.h"

@class GHAnimation;
@interface GHAnimationCache : NSObject
{
    NSMutableDictionary* animations_;
}


/** Retruns ths shared instance of the Animation cache */
+ (GHAnimationCache *) sharedAnimationCache;

/** Purges the cache. It releases all the GHAnimation objects and the shared instance.
 */
+(void)purgeSharedAnimationCache;

/** Adds a GHAnimation with a name.
 */
 -(void) addAnimation:(GHAnimation*)animation name:(NSString*)name;

/** Deletes a GHAnimation from the cache.
 */
-(void) removeAnimationByName:(NSString*)name;

/** Returns a GHAnimation that was previously added.
 If the name is not found it will return nil.
 You should retain the returned copy if you are going to use it.
 */
-(GHAnimation*) animationByName:(NSString*)name;

/** Adds an animation from an NSDictionary
 Make sure that the frames were previously loaded in the CCSpriteFrameCache.
 */
-(void)addAnimationsWithDictionary:(NSDictionary *)dictionary;

/** Adds an animation from a plist file.
 Make sure that the frames were previously loaded in the CCSpriteFrameCache.
 */
-(void)addAnimationsWithFile:(NSString *)plist;
@end
