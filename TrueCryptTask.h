//
//  TrueCryptTask.h
//  TrueCrypt Mounter
//
//  Created by Samuel Kadolph on 11-08-07.
//  Copyright 2011 Samuel Kadolph. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TrueCryptTask : NSObject
+ (NSString *)getTrueCryptPath;
+ (NSTask *)runTrueCryptTask:(id)firstArgument, ... NS_REQUIRES_NIL_TERMINATION;

+ (BOOL)isVolumeMounted:(NSString *)path;
+ (NSString *)mountVolume:(NSString *)path;
+ (NSString *)volumeMountPath:(NSString *)path;
@end
