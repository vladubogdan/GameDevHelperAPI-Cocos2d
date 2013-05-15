//
// cocos2d
//

#import "cocos2d.h"
#import "BaseAppController.h"

#import "GameDevHelper.h"

#import "TestLayer.h"

#define TEST_CLASS Skeletons_ChangeAnimationTimeTest

@interface AppController : BaseAppController
@end

@interface Skeletons_ChangeAnimationTimeTest : TestLayer <GHSkeletonDelegate> {
    
    GHSkeleton* skeleton;
    int currentAnim;
}
@end
