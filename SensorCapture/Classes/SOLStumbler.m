//
//  SOLStumbler.m
//  Stumbler
//
//  Created by Bryan Bernhart on 1/6/10.
//  Copyright 2010 Bryan Bernhart. All rights reserved.
//	License: GNU General Public License
//

#import "SOLStumbler.h"

@implementation SOLStumbler
@synthesize parameters;

- (id)init
{
	self = [super init];
	
	// scanned networks
	networks = [[NSMutableDictionary alloc] init];

	// scanning parameters
	NSDictionary *theParameters = [[NSDictionary alloc] initWithObjectsAndKeys:
								   [NSNumber numberWithBool:NO], @"SCAN_MERGE", // don't discard multiple MACs for each network
								   nil];
	self.parameters = theParameters;
	[parameters release];


	libHandle = dlopen("/System/Library/SystemConfiguration/WiFiManager.bundle/WiFiManager", RTLD_LAZY);
	
	char *error;
	if (libHandle == NULL && (error = dlerror()) != NULL)  {
		NSLog(@"%c",error);
		exit(1);
	}
	
	apple80211Open = dlsym(libHandle, "Apple80211Open");
	apple80211Bind = dlsym(libHandle, "Apple80211BindToInterface");
	apple80211Close = dlsym(libHandle, "Apple80211Close");
	apple80211Scan = dlsym(libHandle, "Apple80211Scan");
	
	apple80211Open(&airportHandle);
	apple80211Bind(airportHandle, @"en0");	
	
	return self;
}

- (NSDictionary *)network:(NSString *) BSSID
{
	return [networks objectForKey:@"BSSID"];
}

- (NSDictionary *)networks
{
	return networks;
}

- (void)scanNetworks
{
	NSArray *scan_networks; //is a CFArrayRef of CFDictionaryRef(s) containing key/value data on each discovered network
	
	apple80211Scan(airportHandle, &scan_networks, self.parameters);
	
	[networks removeAllObjects];
	for (int i = 0; i < [scan_networks count]; i++) {
		[networks setObject:[scan_networks objectAtIndex: i] forKey:[[scan_networks objectAtIndex: i] objectForKey:@"BSSID"]];
	}
}

- (int)numberOfNetworks
{
	return [networks count];
}

- ( NSString * ) description {
	
	NSMutableString *result = [[NSMutableString alloc] initWithString:@"Networks State: \n"];
	
	for (id key in networks){
		
		[result appendString:[NSString stringWithFormat:@"%@ (MAC: %@), RSSI: %@, Channel: %@ \n", 
								[[networks objectForKey: key] objectForKey:@"SSID_STR"], //Station Name
																					key, //Station BBSID (MAC Address)
									[[networks objectForKey: key] objectForKey:@"RSSI"], //Signal Strength
								 [[networks objectForKey: key] objectForKey:@"CHANNEL"]  //Operating Channel
							  ]];
	}
	
	return [NSString stringWithString:result];
}

- (void) dealloc {
	apple80211Close(airportHandle);
	[super dealloc];
}


@end
