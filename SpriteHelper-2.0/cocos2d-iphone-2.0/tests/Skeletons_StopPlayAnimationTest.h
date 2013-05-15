//
// cocos2d
//

#import "cocos2d.h"
#import "BaseAppController.h"

#import "GameDevHelper.h"

#import "TestLayer.h"

#define TEST_CLASS Skeletons_StopPlayAnimationTest

@interface AppController : BaseAppController
@end

@interface Skeletons_StopPlayAnimationTest : TestLayer <GHSkeletonDelegate> {
    
    GHSkeleton* skeleton;
    int currentAnim;
}
@end
