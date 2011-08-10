//
//  AppDelegate.m
//  TrueCrypt Mounter
//
//  Created by Samuel Kadolph on 11-08-06.
//  Copyright 2011 Samuel Kadolph. All rights reserved.
//

#import "AppDelegate.h"

#import <launch.h>

#import "TrueCryptTask.h"

static void submitUnmounterService(NSString * path, NSString * mountPath)
{
  launch_data_t job = launch_data_alloc(LAUNCH_DATA_DICTIONARY);
  
  int pid = [[NSProcessInfo processInfo] processIdentifier];
  NSString * label = [NSString stringWithFormat:@"org.samuelkadolph.TrueCrypt-Mounter.%d", pid];
  const char * cLabel = [label cStringUsingEncoding:NSUTF8StringEncoding];
  launch_data_dict_insert(job, launch_data_new_string(cLabel), LAUNCH_JOBKEY_LABEL);
  
  launch_data_t args = launch_data_alloc(LAUNCH_DATA_ARRAY);
  const char * unmounter = [[[NSBundle mainBundle] pathForResource:@"unmounter" ofType:@""] UTF8String];
  const char * cPath = [path UTF8String];
  const char * cMountPath = [mountPath UTF8String];
  launch_data_array_set_index(args, launch_data_new_string(unmounter), 0);
  launch_data_array_set_index(args, launch_data_new_string(cLabel), 1);
  launch_data_array_set_index(args, launch_data_new_string(cPath), 2);
  launch_data_dict_insert(job, args, LAUNCH_JOBKEY_PROGRAMARGUMENTS);
  
  launch_data_t pathstate = launch_data_alloc(LAUNCH_DATA_DICTIONARY);
  launch_data_dict_insert(pathstate, launch_data_new_bool(FALSE), cMountPath);
  
  launch_data_t keepalive = launch_data_alloc(LAUNCH_DATA_DICTIONARY);
  launch_data_dict_insert(keepalive, pathstate, LAUNCH_JOBKEY_KEEPALIVE_PATHSTATE);
  launch_data_dict_insert(job, keepalive, LAUNCH_JOBKEY_KEEPALIVE);
  
  launch_data_t message = launch_data_alloc(LAUNCH_DATA_DICTIONARY);
  launch_data_dict_insert(message, job, LAUNCH_KEY_SUBMITJOB);
  launch_data_t response = launch_msg(message);
  
  if (!response || launch_data_get_errno(response) != ERR_SUCCESS)
  {
    NSAlert * alert = [[[NSAlert alloc] init] autorelease];
    
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert setMessageText:@"Will not dismount automatically"];
    [alert setInformativeText:@"There was an error submitting the automatic dismount service. "
                               "The disk will not be dismounted when you eject the volume."];
    
    [alert runModal];
  }
  
  launch_data_free(message);
  launch_data_free(response);
}

@implementation AppDelegate
- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename
{
  volumeFilename = [filename retain];
  return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  if (![[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:@"org.TrueCryptFoundation.TrueCrypt"])
  {
    NSAlert * alert = [[[NSAlert alloc] init] autorelease];
    
    [alert setAlertStyle:NSCriticalAlertStyle];
    [alert setMessageText:@"Cannot find TrueCrypt"];
    [alert setInformativeText:@"TrueCrypt could not be found.\nMake sure it is installed."];
    
    [alert runModal];
    exit(2);
  }
  
  if (!volumeFilename)
  {
    NSOpenPanel * dialog = [NSOpenPanel openPanel];
    
    [dialog setCanChooseFiles:YES];
    [dialog setCanChooseDirectories:NO];
    [dialog setTitle:@"Open TrueCrypt Volume"];
    
    if ([dialog runModal] == NSOKButton)
    {
      volumeFilename = [[[dialog URLs] objectAtIndex:0] path];
    }
  }
  
  NSString * mountPath;
  if (![TrueCryptTask isVolumeMounted:volumeFilename])
  {
    mountPath = [TrueCryptTask mountVolume:volumeFilename];
    submitUnmounterService(volumeFilename, mountPath);
  }
  else
  {
    mountPath = [TrueCryptTask volumeMountPath:volumeFilename];
  }
  
  [[NSWorkspace sharedWorkspace] openFile:mountPath];
  exit(0);
}
@end
