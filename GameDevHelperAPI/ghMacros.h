//
//  ghMacros.h
//  cocos2d-ios
//
//  Created by Bogdan Vladu on 4/29/13.
//
//

#ifndef GAME_DEV_HELPER_ios_ghMacros_h
#define GAME_DEV_HELPER_ios_ghMacros_h

#import "ghConfig.h"


#if GH_ENABLE_PHYSICS_INTEGRATION

/** @def GH_METER_RATIO
 Returns currently used points to meter ratio
 */
#define GH_METER_RATIO() [[GHDirector sharedDirector] pointToMeterRatio]


#define GH_POINT_TO_METERS(__point__) \
b2Vec2((__point__).x / GH_METER_RATIO(), (__point__).y / GH_METER_RATIO())

#define GH_VALUE_TO_METERS(__value__) \
(__value__) / GH_METER_RATIO()


#define GH_METERS_TO_POINT(__box2d_point__) \
CGPointMake((__box2d_point__).x * GH_METER_RATIO(), (__box2d_point__).y * GH_METER_RATIO())


#endif






#endif
