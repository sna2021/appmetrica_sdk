// Copyright 2019 EM ALL iT Studio. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "AppmetricaSdkPlugin.h"
#import <YandexMobileMetrica/YandexMobileMetrica.h>
#import <YandexMobileMetrica/YMMProfileAttribute.h>

@implementation AppmetricaSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"emallstudio.com/appmetrica_sdk"
            binaryMessenger:[registrar messenger]];
  AppmetricaSdkPlugin* instance = [[AppmetricaSdkPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"activate" isEqualToString:call.method]) {
      [self handleActivate:call result:result];
  } else if ([@"reportEvent" isEqualToString:call.method]) {
      [self handleReportEvent:call result:result];
  } else if ([@"reportUserProfileCustomString" isEqualToString:call.method]) {
      [self handleReportUserProfileCustomString:call result:result];
  } else if ([@"reportUserProfileCustomNumber" isEqualToString:call.method]) {
      [self handleReportUserProfileCustomNumber:call result:result];
  } else if ([@"reportUserProfileCustomBoolean" isEqualToString:call.method]) {
      [self handleReportUserProfileCustomBoolean:call result:result];
  } else if ([@"reportUserProfileCustomCounter" isEqualToString:call.method]) {
      [self handleReportUserProfileCustomCounter:call result:result];
  } else if ([@"reportUserProfileUserName" isEqualToString:call.method]) {
      [self handleReportUserProfileUserName:call result:result];
  } else if ([@"reportUserProfileNotificationsEnabled" isEqualToString:call.method]) {
      [self handleReportUserProfileNotificationsEnabled:call result:result];
  } else if ([@"setStatisticsSending" isEqualToString:call.method]) {
      [self handleSetStatisticsSending:call result:result];
  } else if ([@"getLibraryVersion" isEqualToString:call.method]) {
      [self handleGetLibraryVersion:call result:result];
  } else {
      result(FlutterMethodNotImplemented);
  }
}

- (FlutterError* _Nullable)getFlutterError:(NSError*)error {
  if (error == nil) return nil;

  return [FlutterError errorWithCode:[NSString stringWithFormat:@"Error %ld", (long)error.code]
                             message:error.domain
                             details:error.localizedDescription];
}

- (void)handleActivate:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString* apiKey = call.arguments[@"apiKey"];
    NSInteger sessionTimeout = [call.arguments[@"sessionTimeout"] integerValue];
    NSNumber *locationTracking = [NSNumber numberWithBool:call.arguments[@"locationTracking"]];
    NSNumber *statisticsSending = [NSNumber numberWithBool:call.arguments[@"statisticsSending"]];
    NSNumber *crashReporting = [NSNumber numberWithBool:call.arguments[@"crashReporting"]];
    // Creating an extended library configuration.
    YMMYandexMetricaConfiguration *configuration = [[YMMYandexMetricaConfiguration alloc] initWithApiKey:apiKey];
    // Setting up the configuration.
    configuration.logs = YES;
    configuration.sessionTimeout = sessionTimeout;
    configuration.locationTracking = [locationTracking boolValue];
    configuration.statisticsSending = [statisticsSending boolValue];
    configuration.crashReporting = [crashReporting boolValue];
    // Initializing the AppMetrica SDK.
    [YMMYandexMetrica activateWithConfiguration:configuration];
    result(nil);
}

- (void)handleReportEvent:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString* name = call.arguments[@"name"];

    if (![call.arguments[@"attributes"] isEqual:[NSNull null]]) {
        NSDictionary* attributes = call.arguments[@"attributes"];
        [YMMYandexMetrica reportEvent:name
            parameters:attributes
            onFailure:^(NSError *error) {
               result([self getFlutterError:error]);
            }
        ];
    } else {
        [YMMYandexMetrica reportEvent:name
            onFailure:^(NSError *error) {
               result([self getFlutterError:error]);
            }
        ];
    }

    result(nil);
}


- (void)handleReportUserProfileCustomString:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString* key = call.arguments[@"key"];

    YMMMutableUserProfile* userProfile =[ [YMMMutableUserProfile alloc] init];
    if (![call.arguments[@"value"] isEqual:[NSNull null]]) {
        NSString* value = call.arguments[@"value"];
        [userProfile apply:[[YMMProfileAttribute customString:key] withValue:value]];
    } else {
        [userProfile apply:[[YMMProfileAttribute customString:key] withValueReset]];
    }

    [YMMYandexMetrica reportUserProfile:userProfile
            onFailure:^(NSError *error) {
               result([self getFlutterError:error]);
            }];

    result(nil);
}

- (void)handleReportUserProfileCustomNumber:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString* key = call.arguments[@"key"];

    YMMMutableUserProfile* userProfile =[ [YMMMutableUserProfile alloc] init];
    if (![call.arguments[@"value"] isEqual:[NSNull null]]) {
        double value = [call.arguments[@"value"] doubleValue];
        [userProfile apply:[[YMMProfileAttribute customNumber:key] withValue:value]];
    } else {
        [userProfile apply:[[YMMProfileAttribute customNumber:key] withValueReset]];
    }

    [YMMYandexMetrica reportUserProfile:userProfile
            onFailure:^(NSError *error) {
               result([self getFlutterError:error]);
            }];

    result(nil);
}

- (void)handleReportUserProfileCustomBoolean:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString* key = call.arguments[@"key"];

    YMMMutableUserProfile* userProfile =[ [YMMMutableUserProfile alloc] init];
    if (![call.arguments[@"value"] isEqual:[NSNull null]]) {
        NSNumber *value = [NSNumber numberWithBool:call.arguments[@"value"]];
        [userProfile apply:[[YMMProfileAttribute customBool:key] withValue:[value boolValue]]];
    } else {
        [userProfile apply:[[YMMProfileAttribute customBool:key] withValueReset]];
    }

    [YMMYandexMetrica reportUserProfile:userProfile
            onFailure:^(NSError *error) {
               result([self getFlutterError:error]);
            }];

    result(nil);
}

- (void)handleReportUserProfileCustomCounter:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString* key = call.arguments[@"key"];
    double value = [call.arguments[@"delta"] doubleValue];

    YMMMutableUserProfile* userProfile =[ [YMMMutableUserProfile alloc] init];
    [userProfile apply:[[YMMProfileAttribute customCounter:key] withDelta:value]];
    [YMMYandexMetrica reportUserProfile:userProfile
            onFailure:^(NSError *error) {
               result([self getFlutterError:error]);
            }];

    result(nil);
}

- (void)handleReportUserProfileUserName:(FlutterMethodCall*)call result:(FlutterResult)result {
    YMMMutableUserProfile* userProfile =[ [YMMMutableUserProfile alloc] init];
    if (![call.arguments[@"userName"] isEqual:[NSNull null]]) {
        NSString* userName = call.arguments[@"userName"];
        [userProfile apply:[[YMMProfileAttribute name] withValue:userName]];
    } else {
        [userProfile apply:[[YMMProfileAttribute name] withValueReset]];
    }

    [YMMYandexMetrica reportUserProfile:userProfile
            onFailure:^(NSError *error) {
               result([self getFlutterError:error]);
            }];

    result(nil);
}

- (void)handleReportUserProfileNotificationsEnabled:(FlutterMethodCall*)call result:(FlutterResult)result {
    YMMMutableUserProfile* userProfile =[ [YMMMutableUserProfile alloc] init];
    if (![call.arguments[@"notificationsEnabled"] isEqual:[NSNull null]]) {
        NSNumber *notificationsEnabled = [NSNumber numberWithBool:call.arguments[@"notificationsEnabled"]];
        [userProfile apply:[[YMMProfileAttribute notificationsEnabled] withValue:[notificationsEnabled boolValue]]];
    } else {
        [userProfile apply:[[YMMProfileAttribute notificationsEnabled] withValueReset]];
    }

    [YMMYandexMetrica reportUserProfile:userProfile
            onFailure:^(NSError *error) {
               result([self getFlutterError:error]);
            }];

    result(nil);
}

- (void)handleSetStatisticsSending:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSNumber *statisticsSending = [NSNumber numberWithBool:call.arguments[@"statisticsSending"]];

    [YMMYandexMetrica setStatisticsSending:[statisticsSending boolValue]];

    result(nil);
}

- (void)handleGetLibraryVersion:(FlutterMethodCall*)call result:(FlutterResult)result {   
    result([YMMYandexMetrica libraryVersion]);
}

@end