
#import "Skeletons_ChangeAnimationTimeTest.h"


@implementation Skeletons_ChangeAnimationTimeTest

-(void) dealloc
{
	[super dealloc];
}

-(NSString*)initTest
{
    CGSize s = [CCDirector sharedDirector].winSize;
    currentAnim = 0;
    
    GHSkeletalAnimationCache* cache = [GHSkeletalAnimationCache sharedSkeletalAnimationCache];
    [cache addSkeletalAnimationWithFile:@"RES_Skeletons_LoadTest/skeletons/animations/BallPlay.plist"];
    [cache addSkeletalAnimationWithFile:@"RES_Skeletons_LoadTest/skeletons/animations/Bow.plist"];
    [cache addSkeletalAnimationWithFile:@"RES_Skeletons_LoadTest/skeletons/animations/Death.plist"];
    [cache addSkeletalAnimationWithFile:@"RES_Skeletons_LoadTest/skeletons/animations/HatWave.plist"];
    [cache addSkeletalAnimationWithFile:@"RES_Skeletons_LoadTest/skeletons/animations/HolsterGun.plist"];
    [cache addSkeletalAnimationWithFile:@"RES_Skeletons_LoadTest/skeletons/animations/Idle.plist"];
    [cache addSkeletalAnimationWithFile:@"RES_Skeletons_LoadTest/skeletons/animations/Push.plist"];
    [cache addSkeletalAnimationWithFile:@"RES_Skeletons_LoadTest/skeletons/animations/Shoot.plist"];
    [cache addSkeletalAnimationWithFile:@"RES_Skeletons_LoadTest/skeletons/animations/SoftWalk.plist"];
    [cache addSkeletalAnimationWithFile:@"RES_Skeletons_LoadTest/skeletons/animations/StrongWalk.plist"];
    
    [self executeTestCodeAtPosition:ccp(s.width/2, s.height/2)];

    glClearColor(0.5, 0.5, 0.5, 1);//white background
    
    return @"\nDemonstrate changing skeleton animation time.\nTap on left side of the screen to animate faster.\nTap on right side of the screen to animate slower.";
}

-(void)executeTestCodeAtPosition:(CGPoint)p
{
    if(skeleton == nil){
        skeleton = [GHSkeleton skeletonWithFile:@"RES_Skeletons_LoadTest/skeletons/Officer_Officer.plist"];
        
        [skeleton setPosition:p];
        [skeleton setDelegate:self];
        
        [self addChild:skeleton];
    }
    [self changeAnimation];
}

-(void)didStartAnimation:(GHSkeletalAnimation*)animation onSkeleton:(GHSkeleton*)skelet{
//    NSLog(@"DID START ANIMATION NAMED %@ ON SKELETON %@", [animation name], skelet);
}
-(void)didStopAnimation:(GHSkeletalAnimation*)animation onSkeleton:(GHSkeleton*)skelet{
//    NSLog(@"DID STOP ANIMATION NAMED %@ ON SKELETON %@", [animation name], skelet);
}

-(void)didFinishLoopInAnimation:(GHSkeletalAnimation *)animation onSkeleton:(GHSkeleton *)skelet{

//    NSLog(@"DID FINISH LOOP %d ON ANIMATION NAMED %@ ON SKELETON %@", [animation currentLoop], [animation name], skelet);
}

-(void)changeAnimation{

    NSArray *animNames = [NSArray arrayWithObjects:
                          @"BallPlay",
                          @"Bow",
                          @"Death",
                          @"HatWave",
                          @"HolsterGun",
                          @"Idle",
                          @"Push",
                          @"Shoot",
                          @"SoftWalk",
                          @"StrongWalk",
                          nil];
    
    NSString* finalAnimName = [animNames objectAtIndex:currentAnim];
    
    ++currentAnim;
    
    if(currentAnim >= [animNames count])
        currentAnim = 0;
    
    [skeleton playAnimationWithName:finalAnimName];
}


- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    CGSize s = [CCDirector sharedDirector].winSize;
    //Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
        
		location = [[CCDirector sharedDirector] convertToGL: location];
     
        if(location.x < s.width/2)
        {
            if(skeleton){
                GHSkeletalAnimation* anim = [skeleton animation];
                [anim setTotalTime:[anim totalTime]-0.1];
                NSLog(@"NEW ANIMATION TIME %f", [anim totalTime]);
            }
        }
        else{
            if(skeleton){
                GHSkeletalAnimation* anim = [skeleton animation];
                [anim setTotalTime:[anim totalTime]+0.1];
                NSLog(@"NEW ANIMATION TIME %f", [anim totalTime]);
            }
        }
	}
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    //Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
        
		location = [[CCDirector sharedDirector] convertToGL: location];
        
	}
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
        
		location = [[CCDirector sharedDirector] convertToGL: location];
        
//		[self executeTestCodeAtPosition: location];
	}
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
