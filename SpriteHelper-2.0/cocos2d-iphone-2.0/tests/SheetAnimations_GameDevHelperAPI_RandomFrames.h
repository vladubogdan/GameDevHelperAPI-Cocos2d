//
// cocos2d
//

#import "cocos2d.h"
#import "BaseAppController.h"

#import "GameDevHelper.h"

#import "TestLayer.h"

#define TEST_CLASS SheetAnimations_GameDevHelperAPI_RandomFrames

@interface AppController : BaseAppController
@end

@interface SheetAnimations_GameDevHelperAPI_RandomFrames : TestLayer <GHAnimationDelegate> {
    
    CCSpriteBatchNode *batchNodeParent;
}
@end
