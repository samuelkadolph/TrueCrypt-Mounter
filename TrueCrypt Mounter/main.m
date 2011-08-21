//
//  main.m
//  TrueCrypt Mounter
//
//  Created by Samuel Kadolph on 11-08-06.
//  Copyright 2011 Samuel Kadolph. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

int main(int argc, char *argv[])
{
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  NSApplication * application = [NSApplication sharedApplication];
  
  [application setDelegate:[[AppDelegate alloc] init]];
  [application run];
  [application setDelegate:nil];
  
  [pool drain];
  return 0;
}
