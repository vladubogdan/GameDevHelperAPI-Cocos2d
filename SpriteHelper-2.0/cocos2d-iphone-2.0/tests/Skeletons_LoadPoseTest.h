//
// cocos2d
//

#import "cocos2d.h"
#import "BaseAppController.h"

#import "GameDevHelper.h"

#import "TestLayer.h"

#define TEST_CLASS Skeletons_LoadPoseTest

@interface AppController : BaseAppController
@end

@interface Skeletons_LoadPoseTest : TestLayer {
    
    GHSkeleton* skeleton;
    int currentPose;
}
@end
