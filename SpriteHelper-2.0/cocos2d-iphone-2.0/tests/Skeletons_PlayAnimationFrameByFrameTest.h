//
// cocos2d
//

#import "cocos2d.h"
#import "BaseAppController.h"

#import "GameDevHelper.h"

#import "TestLayer.h"

#define TEST_CLASS Skeletons_PlayAnimationFrameByFrameTest

@interface AppController : BaseAppController
@end

@interface Skeletons_PlayAnimationFrameByFrameTest : TestLayer <GHSkeletonDelegate> {
    
    GHSkeleton* skeleton;
    int currentAnim;
}
@end
