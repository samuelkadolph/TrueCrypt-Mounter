//
//  main.c
//  unmounter
//
//  Created by Samuel Kadolph on 11-08-06.
//  Copyright 2011 Samuel Kadolph. All rights reserved.
//

#include <Cocoa/Cocoa.h>
#include <launch.h>

#include "TrueCryptTask.h"

int main (int argc, const char * argv[])
{
  if (argc != 3)
    exit(1);
  
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  
  const char * cLabel = argv[1];
  const char * cPath = argv[2];
  
  NSString * path = [NSString stringWithUTF8String:cPath];
  
  NSTask * task = [TrueCryptTask runTrueCryptTask:@"--text", @"-d", path, nil];
  
  if ([task terminationStatus] != 0)
    NSLog(@"Unable to dismount TrueCrypt disk");
  else
    NSLog(@"Dismounted %s", cPath);
  
  launch_data_t message = launch_data_alloc(LAUNCH_DATA_DICTIONARY);
  launch_data_dict_insert(message, launch_data_new_string(cLabel), LAUNCH_KEY_REMOVEJOB);
  launch_data_t response = launch_msg(message);
  
  if (!response || launch_data_get_errno(response) != ERR_SUCCESS)
    NSLog(@"Unable to remove service");
  
  launch_data_free(message);
  launch_data_free(response);
  
  [pool drain];
  return 0;
}

