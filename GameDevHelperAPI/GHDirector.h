//
//  GHDirector.h
//  cocos2d-ios
//
//  Created by Bogdan Vladu on 4/29/13.
//
//

#import "ghConfig.h"

#if GH_ENABLE_PHYSICS_INTEGRATION
#import "Box2D.h"
#endif


/**
 This singleton is used to control the entire API. 
 
 Right now, not much is handled here, but more will be added soon.
 
 Since the GHDirector is a singleton, the standard way to use it is by calling:
 @code
    [[GHDirector sharedDirector] physicalWorld];
 @endcode
 */
@interface GHDirector : NSObject
{

#if GH_ENABLE_PHYSICS_INTEGRATION
    b2World* physicalWorld;
    float ptm;
#endif
}

/**
 Returns the singleton shared instance.
*/
+ (GHDirector*)sharedDirector;

#if GH_ENABLE_PHYSICS_INTEGRATION

/**
 When physics support is enabled this will set the physics world.
 */
-(void)setPhysicalWorld:(b2World*)world;
/**
 When physics support is enabled this will return the physics world.
 */
-(b2World*)physicalWorld;

/**
 When physics support is enabled this will set the current point to meter ratio you want to use.
 */
-(void)setPointToMeterRatio:(float)value;
/**
 When physics support is enabled this will return the current point to meter ratio in use.
 */
-(float)pointToMeterRatio;

#endif
@end
