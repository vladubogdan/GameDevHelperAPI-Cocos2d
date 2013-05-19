//
//  GHSkeletalAnimationCache.h
//  cocos2d-ios
//
//  Created by Bogdan Vladu on 4/8/13.
//
//

#import <Foundation/Foundation.h>

@class GHSkeletalAnimation;

/** Singleton that manages the GHSkeletalAnimation objects.
 It saves in a cache the animations. You should use this class if you want to save your animations in a cache.
 
 */
@interface GHSkeletalAnimationCache : NSObject
{
	NSMutableDictionary *skeletalAnimations_;
	NSMutableSet		*loadedFilenames_;
}

/** Returns ths shared instance of the Skeletal Animation cache */
+ (GHSkeletalAnimationCache *) sharedSkeletalAnimationCache;

/** Purges the cache. It releases all the Skeletal Animations and the retained instance.*/
+(void)purgeSharedSkeletalAnimationCache;

/** Adds a skeleton animation in cache given the file name.*/
-(void) addSkeletalAnimationWithFile:(NSString*)plist;


/** Purges the dictionary of loaded skeletal animations.*/
-(void) removeSkeletalAnimations;

/** Removes unused skeletal animations.
 * Skeletal Animations that have a retain count of 1 will be deleted.
 * It is convinient to call this method when starting a new Scene.
 */
-(void) removeUnusedSkeletalAnimations;

/** Deletes a skeleton animation from the the cache.*/
-(void) removeSkeletalAnimationWithName:(NSString*)name;


/** Returns a Skeleton Animation that was previously added.
 If the name is not found it will return nil.
 You should retain the returned copy if you are going to use it.
 */
-(GHSkeletalAnimation*) skeletalAnimationWithName:(NSString*)name;

@end
