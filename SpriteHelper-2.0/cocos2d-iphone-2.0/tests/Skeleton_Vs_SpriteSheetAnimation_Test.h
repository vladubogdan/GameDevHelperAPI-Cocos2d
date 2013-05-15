//
// cocos2d
//

#import "cocos2d.h"
#import "BaseAppController.h"

#import "GameDevHelper.h"

#import "TestLayer.h"

#define TEST_CLASS Skeleton_Vs_SpriteSheetAnimation_Test

@interface AppController : BaseAppController
@end

@interface Skeleton_Vs_SpriteSheetAnimation_Test : TestLayer <GHSkeletonDelegate> {
 
    CCSpriteBatchNode *batchNodeParent;
}
@end
