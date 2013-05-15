//
// cocos2d
//

#import "cocos2d.h"
#import "BaseAppController.h"

#import "GameDevHelper.h"

#import "TestLayer.h"

#define TEST_CLASS Skeletons_CombineAnimationsTest

@interface AppController : BaseAppController
@end

@interface Skeletons_CombineAnimationsTest : TestLayer <GHSkeletonDelegate> {
    
    GHSkeleton* skeleton;
    int currentAnim;
    bool walk;
}
@end
