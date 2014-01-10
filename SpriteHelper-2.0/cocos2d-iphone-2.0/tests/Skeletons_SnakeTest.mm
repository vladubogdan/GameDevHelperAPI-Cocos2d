
#import "Skeletons_SnakeTest.h"


@implementation Skeletons_SnakeTest

-(void) dealloc
{
	[super dealloc];
}

-(NSString*)initTest
{
    CGSize s = [CCDirector sharedDirector].winSize;
    
    [self executeTestCodeAtPosition:ccp(s.width/2, s.height/2)];
    
    glClearColor(0.5, 0.5, 0.5, 1.0f);
    
    return @"\nDemonstrate using bones for other intereting effects.\nTouch and drag to move snake...";
}

-(void)executeTestCodeAtPosition:(CGPoint)p
{
    if(skeleton == nil){
        skeleton = [GHSkeleton skeletonWithFile:@"RES_Skeletons_SnakeTest/skeletons/Snake_SnakeSkeleton.plist"];
        
        [skeleton setPosition:p];
        [self addChild:skeleton];
    }
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    //Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
        
		location = [[CCDirector sharedDirector] convertToGL: location];
        
	}
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    //Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
        
		location = [[CCDirector sharedDirector] convertToGL: location];
     
        if(skeleton){
            
            location.x -= 60;//i substract this so the snake head will not be hidden by the finger when testing on device
            
            [skeleton setPosition:location forBoneNamed:@"RootBone"];
            NSLog(@"SKELETON BOUNDING BOX IS : %@", NSStringFromCGRect([skeleton boundingBox]));
        }
	}
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
        
		location = [[CCDirector sharedDirector] convertToGL: location];
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
