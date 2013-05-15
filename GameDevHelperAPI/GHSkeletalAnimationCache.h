//
//  GHSkeletalAnimationCache.h
//  cocos2d-ios
//
//  Created by Bogdan Vladu on 4/8/13.
//
//

#import <Foundation/Foundation.h>

@class GHSkeletalAnimation;

@interface GHSkeletalAnimationCache : NSObject
{
	NSMutableDictionary *skeletalAnimations_;
	NSMutableSet		*loadedFilenames_;
}

/** Retruns ths shared instance of the Skeletal Animation cache */
+ (GHSkeletalAnimationCache *) sharedSkeletalAnimationCache;

/** Purges the cache. It releases all the Skeletal Animations and the retained instance.
 */
+(void)purgeSharedSkeletalAnimationCache;


-(void) addSkeletalAnimationWithFile:(NSString*)plist;


/** Purges the dictionary of loaded skeletal animations.
 * Call this method if you receive the "Memory Warning".
 * In the short term: it will free some resources preventing your app from being killed.
 * In the medium term: it will allocate more resources.
 * In the long term: it will be the same.
 */
-(void) removeSkeletalAnimations;

/** Removes unused skeletal animations.
 * Skeletal Animations that have a retain count of 1 will be deleted.
 * It is convinient to call this method after when starting a new Scene.
 */
-(void) removeUnusedSkeletalAnimations;

/** Deletes an skeletal animation from the the cache.
 */
-(void) removeSkeletalAnimationWithName:(NSString*)name;


/** Returns an Skeletal Animation that was previously added.
 If the name is not found it will return nil.
 You should retain the returned copy if you are going to use it.
 */
-(GHSkeletalAnimation*) skeletalAnimationWithName:(NSString*)name;


@end
