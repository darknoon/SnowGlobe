//
//  WMViewController.m
//  NewTemplateTest
//
//  Created by Andrew Pouliot on 10/12/10.
//  Copyright 2010 Darknoon. All rights reserved.
//


#import "WMViewController.h"
#import "EAGLView.h"

#import <QuartzCore/QuartzCore.h>

#import "WMEngine.h"
#import "WMRenderEngine.h"
#import "WMDebugViewController.h"

@interface WMViewController ()
@end

@implementation WMViewController

@synthesize engine;
@synthesize animating;
@synthesize debugViewController;

- (void)reloadGame;
{
	if (engine) {
		[engine release];
		engine = nil;
	}
	
	engine = [[WMEngine alloc] init];
	engine.renderEngine = [[WMRenderEngine alloc] initWithEngine:engine];
	//TODO: start lazily
	[engine start];
	
	[(EAGLView *)self.view setContext:engine.renderEngine.context];
    [(EAGLView *)self.view setFramebuffer];
	
}

- (void)awakeFromNib
{
	[self reloadGame];
    animationFrameInterval = 1;
    
    // Use of CADisplayLink requires iOS version 3.1 or greater.
	// The NSTimer object is used as fallback when it isn't available.
    NSString *reqSysVer = @"3.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
        displayLinkSupported = TRUE;

	NSLog(@"foo: %d", __IPHONE_OS_VERSION_MAX_ALLOWED);

	// TODO: grr, Xcode bug won't let this compile. WTF??
	// UISwipeGestureRecognizer *recog = [[UISwipeGestureRecognizer alloc] init];
	// recog.target = self;
	// recog.selector = @selector(debugSwipeAction:);
	// recog.direction = (UISwipeGestureRecognizerDirection) (UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown);
	// [self.view addGestureRecognizer:recog];
}

- (void)viewDidLoad;
{
	[super viewDidLoad];
	fpsLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 10, 200, 22)];
	fpsLabel.backgroundColor = [UIColor clearColor];
	fpsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.f];
	fpsLabel.textColor = [UIColor whiteColor];
	fpsLabel.shadowColor = [UIColor blackColor];
	fpsLabel.shadowOffset = CGSizeMake(0, 1);
	fpsLabel.alpha = 0.8f;
	fpsLabel.text = @"fps";
	[self.view addSubview:fpsLabel];
				
}

- (void)dealloc
{    
    [engine release];
	[debugViewController release];

    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self startAnimation];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopAnimation];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	[fpsLabel release];
	fpsLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation; // Override to allow rotation. Default returns YES only for UIDeviceOrientationPortrait
{
	return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (NSInteger)animationFrameInterval
{
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
    /*
	 Frame interval defines how many display frames must pass between each time the display link fires.
	 The display link will only fire 30 times a second when the frame internal is two on a display that refreshes 60 times a second. The default frame interval setting of one will fire 60 times a second when the display refreshes at 60 times a second. A frame interval setting of less than one results in undefined behavior.
	 */
    if (frameInterval >= 1)
    {
        animationFrameInterval = frameInterval;
        
        if (animating)
        {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation
{
    if (!animating)
    {
        if (displayLinkSupported)
        {
            /*
			 CADisplayLink is API new in iOS 3.1. Compiling against earlier versions will result in a warning, but can be dismissed if the system version runtime check for CADisplayLink exists in -awakeFromNib. The runtime check ensures this code will not be called in system versions earlier than 3.1.
            */
            displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawFrame)];
            [displayLink setFrameInterval:animationFrameInterval];
            
            // The run loop will retain the display link on add.
            [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        }
        else
            animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval) target:self selector:@selector(drawFrame) userInfo:nil repeats:TRUE];
        
        animating = TRUE;
		lastFrameEndTime = CFAbsoluteTimeGetCurrent();
    }
}

- (void)stopAnimation
{
    if (animating)
    {
        if (displayLinkSupported)
        {
            [displayLink invalidate];
            displayLink = nil;
        }
        else
        {
            [animationTimer invalidate];
            animationTimer = nil;
        }
        
        animating = FALSE;
    }
}

- (void)drawFrame
{
    [(EAGLView *)self.view setFramebuffer];
 
	
	NSTimeInterval frameStartTime = CFAbsoluteTimeGetCurrent();
	
	[engine.renderEngine drawFrameInRect:self.view.bounds];
	
	[engine update];

	NSTimeInterval frameEndTime = CFAbsoluteTimeGetCurrent();
	
	NSTimeInterval timeToDrawFrame = frameEndTime - frameStartTime;
	
	double fps = 1.0 / (frameEndTime - lastFrameEndTime);
	
	fpsLabel.text = [NSString stringWithFormat:@"%.0lf fps (%.0lf ms)", fps, timeToDrawFrame * 1000.0];
	
	lastFrameEndTime = frameEndTime;

    [(EAGLView *)self.view presentFramebuffer];
}

#pragma mark -
#pragma mark Actions

- (IBAction)showDebug:(id)sender;
{
	[self.view addSubview:debugViewController.view];
	debugViewController.view.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

@end