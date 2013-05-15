//
// cocos2d
//

#import "cocos2d.h"
#import "BaseAppController.h"

#import "TestLayer.h"

#define TEST_CLASS Physics_LoadSpritesWithPhysicalBody

@interface AppController : BaseAppController
@end

#include "Box2d.h"
#import "GLES-Render.h"

#import "GameDevHelper.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

@interface Physics_LoadSpritesWithPhysicalBody : TestLayer {
    
    CCSpriteBatchNode *batchNodeParent;
    
	b2World* world;					// strong ref

}
@end
