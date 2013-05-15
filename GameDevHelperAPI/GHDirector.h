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

@class LHLayer;
@class LHSprite;
@class LHJoint;
@class LHBezier;


@interface GHDirector : NSObject
{

#if GH_ENABLE_PHYSICS_INTEGRATION
    b2World* physicalWorld;
    float ptm;
#endif
}


+ (GHDirector*)sharedDirector;

#if GH_ENABLE_PHYSICS_INTEGRATION
-(void)setPhysicalWorld:(b2World*)world;
-(b2World*)physicalWorld;

-(void)setPointToMeterRatio:(float)value;
-(float)pointToMeterRatio;

#endif
@end
