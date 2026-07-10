/* *********************************************************************
 *                  _____         _               _
 *                 |_   _|____  _| |_ _   _  __ _| |
 *                   | |/ _ \ \/ / __| | | |/ _` | |
 *                   | |  __/>  <| |_| |_| | (_| | |
 *                   |_|\___/_/\_\\__|\__,_|\__,_|_|
 *
 * Copyright (c) 2010 - 2018 Codeux Software, LLC & respective contributors.
 *       Please see Acknowledgements.pdf for additional information.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 *  * Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *  * Neither the name of Textual, "Codeux Software, LLC", nor the
 *    names of its contributors may be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 *********************************************************************** */

#import "NSObjectHelperPrivate.h"
#import "TPCPreferencesLocal.h"
#import "TLOInternetAddressLookup.h"

NS_ASSUME_NONNULL_BEGIN

#define _requestTimeoutInterval			30.0

@interface TLOInternetAddressLookup ()
@property (nonatomic, weak) id requestDelegate;
@property (nonatomic, strong, nullable) NSURLSessionDataTask *dataTask;
@property (nonatomic, copy, nullable) NSString *address;
@end

@implementation TLOInternetAddressLookup

#pragma mark -
#pragma mark Public API

- (instancetype)init
{
	[self doesNotRecognizeSelector:_cmd];

	return nil;
}

- (instancetype)initWithDelegate:(id <TLOInternetAddressLookupDelegate>)delegate
{
	NSParameterAssert(delegate != nil);

	if ((self = [super init])) {
		self.IPv4AddressIsValid = YES;
		self.IPv6AddressIsValid = YES;

		self.requestDelegate = delegate;

		return self;
	}

	return nil;
}

- (void)performLookup
{
	[self setupConnectionRequest];
}

- (void)cancelLookup
{
	NSURLSessionDataTask *task = self.dataTask;
	self.dataTask = nil;

	[task cancel];
}

- (void)setupConnectionRequest
{
	NSAssert((self.dataTask == nil), @"A lookup is already in progress");

	NSURL *requestURL = [NSURL URLWithString:[self addressSourceURL]];

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL
														   cachePolicy:NSURLRequestReloadIgnoringCacheData
													   timeoutInterval:_requestTimeoutInterval];

	request.HTTPMethod = @"GET";

	NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];

	NSURLSession *session = [NSURLSession sessionWithConfiguration:config
														  delegate:nil
													 delegateQueue:[NSOperationQueue mainQueue]];

	self.dataTask = [session dataTaskWithRequest:request
							  completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		[self _processResponse:response data:data error:error];
	}];

	[self.dataTask resume];
}

- (void)_processResponse:(nullable NSURLResponse *)response data:(nullable NSData *)data error:(nullable NSError *)error
{
	if (self.dataTask == nil) {
		return; // Cancelled before this callback arrived
	}

	if (error != nil) {
		LogToConsole("Lookup failed with error: %{public}@", error.localizedDescription);
	} else if (data.length > 1024) {
		LogToConsoleError("Too much data has been received for this to be a valid request");
	} else if ([response isKindOfClass:[NSHTTPURLResponse class]] &&
			   [(NSHTTPURLResponse *)response statusCode] == 200)
	{
		NSString *address = [NSString stringWithData:data encoding:NSUTF8StringEncoding];

		address = [address stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

		if ((address.isIPv4Address && self.IPv4AddressIsValid) ||
			(address.isIPv6Address && self.IPv6AddressIsValid))
		{
			self.address = address;
		}
	}

	[self teardownConnectionRequest];
}

- (void)teardownConnectionRequest
{
	self.dataTask = nil;

	[self informDelegate];

	self.address = nil;
}

- (NSString *)addressSourceURL
{
	if ([TPCPreferences fileTransferIPAddressDetectionMethod] == TXFileTransferIPAddressMethodRouterAndThirdParty) {
		return [self thirdPartySourceURL];
	}

	return @"https://api.ipify.org/";
}

- (NSString *)thirdPartySourceURL
{
	NSArray *services = @[
	  @"https://wtfismyip.com/text",
	  @"https://canhazip.com/",
	  @"http://ifconfig.me/ip",
	  @"http://v4.ipv6-test.com/api/myip.php",
	];

	NSUInteger randomIndex = (arc4random() % services.count);

	return services[randomIndex];
}

#pragma mark -
#pragma mark Delegate

- (void)informDelegate
{
	NSString *address = self.address;

	if (address) {
		[self informDelegateLookupReturnedAddress:address];
	} else {
		[self informDelegateLookupFailed];
	}
}

- (void)informDelegateLookupReturnedAddress:(NSString *)address
{
	if ([self.requestDelegate respondsToSelector:@selector(internetAddressLookupReturnedAddress:)]) {
		[self.requestDelegate internetAddressLookupReturnedAddress:address];
	}
}

- (void)informDelegateLookupFailed
{
	if ([self.requestDelegate respondsToSelector:@selector(internetAddressLookupFailed)]) {
		[self.requestDelegate internetAddressLookupFailed];
	}
}

@end

NS_ASSUME_NONNULL_END
