//
//  GHDirector.mm
//  cocos2d-ios
//
//  Created by Bogdan Vladu on 4/29/13.
//
//

#import "GHDirector.h"

@implementation GHDirector

+ (GHDirector*)sharedDirector{
	static id sharedInstance = nil;
	if (sharedInstance == nil){
		sharedInstance = [[GHDirector alloc] init];
	}
    return sharedInstance;
}

////////////////////////////////////////////////////////////////////////////////
- (id)init
{
	self = [super init];
	if (self != nil) {

#if GH_ENABLE_PHYSICS_INTEGRATION
        physicalWorld = NULL;
        ptm = 32.0f;
#endif
        
	}
	return self;
}

-(void)dealloc{
    

    
#if GH_ENABLE_PHYSICS_INTEGRATION
    physicalWorld = NULL;
#endif
    
    [super dealloc];
}


#if GH_ENABLE_PHYSICS_INTEGRATION

-(void)setPhysicalWorld:(b2World*)world{
    physicalWorld = world;
}
-(b2World*)physicalWorld{
    return physicalWorld;
}

-(void)setPointToMeterRatio:(float)value{
    ptm = value;
}
-(float)pointToMeterRatio{
    return ptm;
}

#endif

@end
