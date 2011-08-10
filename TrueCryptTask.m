//
//  TrueCryptTask.m
//  TrueCrypt Mounter
//
//  Created by Samuel Kadolph on 11-08-07.
//  Copyright 2011 Samuel Kadolph. All rights reserved.
//

#import "TrueCryptTask.h"
#import "RegexKitLite.h"

@implementation TrueCryptTask
+ (NSString *)getTrueCryptPath
{
  NSURL * url = [[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:@"org.TrueCryptFoundation.TrueCrypt"];
  NSBundle * bundle = [NSBundle bundleWithPath:[url path]];
  NSString * path = [bundle executablePath];
  
  return [path autorelease];
}
+ (NSTask *)runTrueCryptTask:(id)firstArgument, ...
{
  va_list vargs;
  va_start(vargs, firstArgument);
  NSMutableArray * args = [NSMutableArray array];
  
  for (id argument = firstArgument; argument != nil; argument = va_arg(vargs, id))
    [args addObject:argument];
  
  NSTask * task = [[[NSTask alloc] init] autorelease];
  
  [task setLaunchPath:[self getTrueCryptPath]];
  [task setArguments:args];
  
  NSPipe * output = [NSPipe pipe];
  NSPipe * error = [NSPipe pipe];
  
  [task setStandardOutput:output];
  [task setStandardError:error];
  
  [task launch];
  [task waitUntilExit];
  
  return task;
}

+ (BOOL)isVolumeMounted:(NSString *)path
{
  NSTask * task = [self runTrueCryptTask:@"--text", @"--list", path, nil];
  return [task terminationStatus] == 0 ? YES : NO;
}
+ (NSString *)mountVolume:(NSString *)path
{
  NSString * name = [[path lastPathComponent] stringByDeletingPathExtension];
  NSString * mountPath = [NSString stringWithFormat:@"/Volumes/%@", name];
  NSTask * task = [self runTrueCryptTask:path, mountPath, nil];
  
  if ([task terminationStatus] == 0)
  {
    return mountPath;
  }
  
  exit(1);
}
+ (NSString *)volumeMountPath:(NSString *)path
{
  NSTask * task = [self runTrueCryptTask:@"--text", @"--list", path, nil];
  
  if ([task terminationStatus] == 0)
  {
    NSFileHandle * output = [[task standardOutput] fileHandleForReading];
    NSData * data = [output readDataToEndOfFile];
    NSString * result = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];    
    
    NSArray * parts = [result componentsMatchedByRegex:@"[^\\s\"']+|\"[^\"]*\"|'[^']*'"];
    NSCharacterSet * quotes = [NSCharacterSet characterSetWithCharactersInString:@"\"'"];
    NSString * mountPath = [[parts objectAtIndex:3] stringByTrimmingCharactersInSet:quotes];
    
    return mountPath;
  }
  else
  {
    return nil;
  }
}
@end
