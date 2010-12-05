//
//  WMAccelerometer.mm
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 12/4/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "WMAccelerometer.h"

@implementation WMAccelerometer

+ (WMAccelerometer *)sharedAccelerometer;
{
	static WMAccelerometer *sharedAccelerometer;
	if (!sharedAccelerometer) {
		sharedAccelerometer = [[WMAccelerometer alloc] init];
	}
	return sharedAccelerometer;
}

- (id) init {
	[super init];
	if (self == nil) return self; 
	
	lowPassFactor = 0.95f;
	
	motionManager = [[CMMotionManager alloc] init];
	
	//TODO: handle non-iPhone 4 case
	[motionManager startDeviceMotionUpdates];
	
	//Device is being held straight up-down unless we hear otherwise
	acceleration = Vec3(0.0f, 10.0f, 0.0f);
	
	return self;
}

- (Vec3)gravity;
{
	CMDeviceMotion *motion = [motionManager deviceMotion];
	if (motion) {
		CMAcceleration grav = [motion gravity];
		return Vec3(grav.x, grav.y, grav.z);
	} else {
		return Vec3(0.0f, 0.0f, 0.0f);
	}

}

- (Vec3)rotationRate;
{
	CMDeviceMotion *motion = [motionManager deviceMotion];
	if (motion) {
		CMRotationRate rotationRate = [motion rotationRate];
		return Vec3(rotationRate.x, rotationRate.y, rotationRate.z);
	} else {
		return Vec3(0.0f, 0.0f, 0.0f);
	}

}


- (void) dealloc;
{
	[motionManager release];
	[super dealloc];
}



@end
