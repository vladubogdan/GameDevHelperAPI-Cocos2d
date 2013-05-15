//
// cocos2d
//

#import "cocos2d.h"
#import "BaseAppController.h"

#import "GameDevHelper.h"

#import "TestLayer.h"

#define TEST_CLASS Skeletons_SnakeTest

@interface AppController : BaseAppController
@end

@interface Skeletons_SnakeTest : TestLayer {
    
    GHSkeleton* skeleton;
}
@end
