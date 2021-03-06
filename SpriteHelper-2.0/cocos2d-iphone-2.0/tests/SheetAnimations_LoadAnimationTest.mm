
#import "SheetAnimations_LoadAnimationTest.h"


@implementation SheetAnimations_LoadAnimationTest

-(void) dealloc
{
	[super dealloc];
}

-(NSString*)initTest
{
     CGSize s = [CCDirector sharedDirector].winSize;
    
    NSLog(@"THIS TEST");
    
#if 1
		// Use batch node. Faster
        //when using batches - load a batch node using the generated image
		batchNodeParent = [CCSpriteBatchNode batchNodeWithFile:@"RES_SheetAnimations_LoadAnimationTest/spriteSheetAnimationsTest_Numbers.png" capacity:100];
		[self addChild:batchNodeParent z:0];
#endif
        
    //load into the sprite frame cache the plist generated by SH
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"RES_SheetAnimations_LoadAnimationTest/spriteSheetAnimationsTest_Numbers.plist"];
    
    //multiple animations in this document so lets cache all the sheets
    //not necessary - but if we dont do this we will have a warning in the console
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"RES_SheetAnimations_LoadAnimationTest/spriteSheetAnimationsTest_robotBlinking.plist"];
    

    CCAnimationCache *cache = [CCAnimationCache sharedAnimationCache];
    [cache addAnimationsWithFile:@"RES_SheetAnimations_LoadAnimationTest/spriteSheetAnimationsTest_SheetAnimations.plist"];//the animation exported plist file

    
    [self executeTestCodeAtPosition:ccp(s.width/2, s.height/2)];

    return @"\n\n\n\n\nDemonstrate the use of sprite sheets animations.\nFirst frames will run faster,\nwhile last frames will run slower\ndemonstrating variable frame time.\nWhen animation finishes, the initial sprites is restored (Number 0).\nFrame 5 contains user info - check out the console.";
}

-(void)executeTestCodeAtPosition:(CGPoint)p
{
    GHSprite * sprite = [GHSprite spriteWithSpriteFrameName:@"number_0.png"];//the name of one of the sprite in the sheet plist
    
    if(batchNodeParent != nil){//if we use batch nodes we must add the sprite to its batch parent
        [batchNodeParent addChild:sprite];
    }
    else{//if we dont use batch nodes then we must add the sprite to a normal node - e.g the layer or another node
        [self addChild:sprite];
    }
    [sprite setPosition:p];


    CCAnimationCache *cache = [CCAnimationCache sharedAnimationCache];
    CCAnimation *animation = [cache animationByName:@"NumbersAnim"];//the name of the animation
        
    id action = [CCAnimate actionWithAnimation:animation];
    [sprite runAction:action];
//    [sprite runAction: [CCSequence actions: action, [action reverse], nil]];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:CCAnimationFrameDisplayedNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification* notification) {
        
                                                      NSDictionary *userInfo = [notification userInfo];
                            
                                                      if([[userInfo allKeys] count] > 0){
                                                          NSLog(@"object %@ with data %@", [notification object], userInfo );
                                                      }
                                                      
                                                  }];
    
}

@end









////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


#pragma mark - AppDelegate

#ifdef __CC_PLATFORM_IOS

@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];

	// Turn on display FPS
	[director_ setDisplayStats:YES];

	// Turn on multiple touches
	[director_.view setMultipleTouchEnabled:YES];

	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
//	[director_ setProjection:kCCDirectorProjection3D];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");

    
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	// Assume that PVR images have the alpha channel premultiplied
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

	// If the 1st suffix is not found, then the fallback suffixes are going to used. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:YES];			// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"

	// add layer
	CCScene *scene = [CCScene node];
	id layer = [TEST_CLASS node];
	[scene addChild:layer z:0];

	[director_ pushScene: scene];

	return YES;
}
     
@end

#elif defined(__CC_PLATFORM_MAC)

#pragma mark AppController - Mac

@implementation AppController

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[super applicationDidFinishLaunching:aNotification];

	// add layer
	CCScene *scene = [CCScene node];
	[scene addChild: [TEST_CLASS node] ];

	[director_ runWithScene:scene];
}
@end
#endif
