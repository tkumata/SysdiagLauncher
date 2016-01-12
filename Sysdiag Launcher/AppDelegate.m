//
//  AppDelegate.m
//  Sysdiag Launcher
//
//  Created by KUMATA Tomokatsu on 7/25/15.
//  Copyright © 2015 KUMATA Tomokatsu. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreServices/CoreServices.h>

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
- (IBAction)saveAction:(id)sender;

@end

@implementation AppDelegate {
    NSStatusItem *_statusItem;
    NSImage *menubarIcon;
    NSString *msgLevelValue;
    int tcpdumpFlag;
}

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    NSLog(@"Launch App.");
    
    // Get Datetime at start.
//    NSDate *startDatetime = [NSDate date];

    // Check system version.
    NSOperatingSystemVersion os = [[NSProcessInfo processInfo] operatingSystemVersion];
    if (os.minorVersion < 11) {
        [self alertFunc:@"It is not EL Capitan."];
        NSLog(@"It is not EL Capitan.");
        exit(0);
    }
    else if (os.minorVersion > 12) {
        [self alertFunc:@"It is not released yet."];
        NSLog(@"It is not released yet.");
        exit(0);
    }

    //
    tcpdumpFlag = 0;
    
    // Check default msglevel value.
    NSString *ret = execShell(@"/usr/libexec/airportd msglevel | awk '{print $3}'");
    msgLevelValue = ret;
 
    // Set menubar icon image.
    menubarIcon = [NSImage imageNamed:@"tri-mark"];
    [menubarIcon setTemplate:YES];

    // Set Menu
    [self setupStatusBarItems];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    NSLog(@"Quit App");
}

- (void)setupStatusBarItems {
    // Get version
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [info objectForKey:@"CFBundleShortVersionString"];
    
    // Submenu for airportd
    NSMenu *submenu = [[NSMenu alloc] init];
    [submenu addItemWithTitle:@"0x0000000000000000"
                       action:@selector(exec_airportd_msglevel:)
                keyEquivalent:@""];
    [submenu addItemWithTitle:@"0x0000000200000101"
                       action:@selector(exec_airportd_msglevel:)
                keyEquivalent:@""];
    [submenu addItemWithTitle:@"Exec get-mobility-info"
                    action:@selector(exec_getMobilityInfo)
             keyEquivalent:@"m"];

    // Submenu for sysdiagnose
    NSMenu *submenu2 = [[NSMenu alloc] init];
    [submenu2 addItemWithTitle:@"sysdiagnose"
                        action:@selector(exec_sysdiagnose)
                 keyEquivalent:@"s"];
    [submenu2 addItemWithTitle:@"sysdiagnose Safari"
                        action:@selector(exec_sysdiagnose_safari)
                 keyEquivalent:@""];
    [submenu2 addItemWithTitle:@"sysdiagnose Mail"
                        action:@selector(exec_sysdiagnose_mail)
                 keyEquivalent:@""];
    [submenu2 addItemWithTitle:@"sysdiagnose Photos"
                        action:@selector(exec_sysdiagnose_photos)
                 keyEquivalent:@""];
    [submenu2 addItemWithTitle:@"sysdiagnose iTunes"
                        action:@selector(exec_sysdiagnose_itunes)
                 keyEquivalent:@""];
    [submenu2 addItemWithTitle:@"sysdiagnose Notes"
                        action:@selector(exec_sysdiagnose_notes)
                 keyEquivalent:@""];

    // Submenu for build-in apps
//    NSMenu *submenu3 = [[NSMenu alloc] init];
//    [submenu3 addItemWithTitle:@"Activity Monitor"
//                        action:@selector(exec_activitymonitor)
//                 keyEquivalent:@""];
//    [submenu3 addItemWithTitle:@"Console"
//                        action:@selector(exec_console)
//                 keyEquivalent:@""];
//    [submenu3 addItemWithTitle:@"Terminal"
//                        action:@selector(exec_terminal)
//                 keyEquivalent:@""];

    // Submenu for iBeacon recieve
    NSMenu *submenu4 = [[NSMenu alloc] init];
    [submenu4 addItemWithTitle:@"iBeacon central On"
                        action:@selector(exec_ibc_on)
                 keyEquivalent:@""];
    [submenu4 addItemWithTitle:@"iBeacon central Off"
                        action:@selector(exec_ibc_off)
                 keyEquivalent:@""];

    // Submenu for iBeacon recieve
    NSMenu *submenu5 = [[NSMenu alloc] init];
    [submenu5 addItemWithTitle:@"Gathering"
                        action:@selector(exec_tcpdump_start)
                 keyEquivalent:@""];
    [submenu5 addItemWithTitle:@"Stopping"
                        action:@selector(exec_tcpdump_stop)
                 keyEquivalent:@""];

    // Main Menu
    NSMenu *menu = [[NSMenu alloc] init];
    // Show App version
    [menu addItemWithTitle:[NSString stringWithFormat:@"Version.%@", version]
                    action:nil
             keyEquivalent:@""];

    // Separator
    [menu addItem:[NSMenuItem separatorItem]];

    // Execute sysdiagnose
    [menu setSubmenu:submenu2 forItem:[menu addItemWithTitle:@"sysdiagnose"
                                                     action:nil
                                              keyEquivalent:@""]];
    
    // Option airportd msglevel
    [menu setSubmenu:submenu forItem:[menu addItemWithTitle:@"get-mobility-info"
                                                     action:nil
                                              keyEquivalent:@""]];

    // tcpdump
    [menu setSubmenu:submenu5 forItem:[menu addItemWithTitle:@"tcpdump"
                                                     action:nil
                                              keyEquivalent:@""]];

    // Execute Bluetooth Reporter
    // Debug level is here /Library/Preferences/com.apple.Bluetooth.plist
    [menu addItemWithTitle:@"Bluetooth Reporter"
                    action:@selector(exec_bluetoothreporter)
             keyEquivalent:@"b"];

    // Execute Screen Capture
    [menu addItemWithTitle:@"Screen Capture"
                    action:@selector(exec_screencapture)
             keyEquivalent:@"c"];
    
    // Execute Screen Capture
    [menu addItemWithTitle:@"Screen Record"
                    action:@selector(exec_screenrecording)
             keyEquivalent:@"r"];
    
    // Separator
    [menu addItem:[NSMenuItem separatorItem]];
    
    // Open built-in app
    [menu addItemWithTitle:@"Activity Monitor" action:@selector(exec_activitymonitor) keyEquivalent:@""];
    [menu addItemWithTitle:@"Console" action:@selector(exec_console) keyEquivalent:@""];
    [menu addItemWithTitle:@"Disk Utility" action:@selector(exec_diskutil) keyEquivalent:@""];
    [menu addItemWithTitle:@"Terminal" action:@selector(exec_terminal) keyEquivalent:@""];
//    [menu setSubmenu:submenu3 forItem:[menu addItemWithTitle:@"Open built-in Apps"
//                                                      action:nil
//                                               keyEquivalent:@""]];

    // iBeacon Reciever
//    [menu setSubmenu:submenu4 forItem:[menu addItemWithTitle:@"iBeacon Reciever"
//                                                      action:nil
//                                               keyEquivalent:@""]];

    // Separator
    [menu addItem:[NSMenuItem separatorItem]];

    // Quit App
    [menu addItemWithTitle:@"Quit"
                    action:@selector(terminate:)
             keyEquivalent:@"q"];

    // Make menu in statusbar
    NSStatusBar *systemStatusBar = [NSStatusBar systemStatusBar];
    _statusItem = [systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
    [_statusItem setImage:menubarIcon];
//    [_statusItem setAttributedTitle:attrString(@"Extra Logs   ")];
    [_statusItem setEnabled:YES];
    [_statusItem setHighlightMode:YES];
    [_statusItem setMenu:menu];
}

// Exec sysdiagnose
- (void)exec_sysdiagnose {
    NSLog(@"START sysdiagnose.");
    
    NSString*ret = execShell(@"(time osascript -e \"do shell script \\\"\
                             /usr/bin/sysdiagnose -f ~/Desktop/ &>/dev/null &\
                             \\\" with administrator privileges\"\
                             ) 2>&1|grep \"real\"");
    NSString *timeStr = getTimeStr(ret);
    
    NSLog(@"END sysdiagnose %@", timeStr);
}

// Exec sysdiagnose Safari
- (void)exec_sysdiagnose_safari {
    NSString*ret = execShell(@"(time osascript -e \"do shell script \\\"\
                             /usr/bin/sysdiagnose -f ~/Desktop/ Safari &>/dev/null &\
                             \\\" with administrator privileges\"\
                             ) 2>&1|grep \"real\"");
    NSString *timeStr = getTimeStr(ret);
    NSLog(@"END sysdiagnose %@", timeStr);
}

// Exec sysdiagnose Mail
- (void)exec_sysdiagnose_mail {
    NSString*ret = execShell(@"(time osascript -e \"do shell script \\\"\
                             /usr/bin/sysdiagnose -f ~/Desktop/ Mail &>/dev/null &\
                             \\\" with administrator privileges\"\
                             ) 2>&1|grep \"real\"");
    NSString *timeStr = getTimeStr(ret);
    NSLog(@"END sysdiagnose %@", timeStr);
}

// Exec sysdiagnose Photos
- (void)exec_sysdiagnose_photos {
    NSString*ret = execShell(@"(time osascript -e \"do shell script \\\"\
                             /usr/bin/sysdiagnose -f ~/Desktop/ Photos &>/dev/null &\
                             \\\" with administrator privileges\"\
                             ) 2>&1|grep \"real\"");
    NSString *timeStr = getTimeStr(ret);
    NSLog(@"END sysdiagnose %@", timeStr);
}

// Exec sysdiagnose iTunes
- (void)exec_sysdiagnose_itunes {
    NSString*ret = execShell(@"(time osascript -e \"do shell script \\\"\
                             /usr/bin/sysdiagnose -f ~/Desktop/ iTunes &>/dev/null &\
                             \\\" with administrator privileges\"\
                             ) 2>&1|grep \"real\"");
    NSString *timeStr = getTimeStr(ret);
    NSLog(@"END sysdiagnose %@", timeStr);
}

// Exec sysdiagnose Notes
- (void)exec_sysdiagnose_notes {
    NSString*ret = execShell(@"(time osascript -e \"do shell script \\\"\
                             /usr/bin/sysdiagnose -f ~/Desktop/ Notes &>/dev/null &\
                             \\\" with administrator privileges\"\
                             ) 2>&1|grep \"real\"");
    NSString *timeStr = getTimeStr(ret);
    NSLog(@"END sysdiagnose %@", timeStr);
}

// Exec get-mobility-info
- (void)exec_getMobilityInfo {
    NSLog(@"START get-mobility-info.");
    
    NSString *ret = execShell(@"(time osascript -e \"do shell script \\\"\
                              /System/Library/Frameworks/SystemConfiguration.framework/Resources/get-mobility-info &>/dev/null &\
                              \\\" with administrator privileges\"\
                              ) 2>&1 | grep \"real\"");
    NSString *timeStr = getTimeStr(ret);
    
    NSLog(@"END get-mobility-info %@", timeStr);
}

// airdportd msg level
- (void)exec_airportd_msglevel:(id)sender {
    NSLog(@"START airportd msglevel.");
    
    NSString *timeStr;
    NSString *ret;
    NSMenuItem *mi = (NSMenuItem *)sender;
    NSString *optValue = (NSString *)mi.title;
    
    NSString *cmd = [NSString stringWithFormat:@"(time osascript -e \"do shell script \\\"\
                     /usr/libexec/airportd msglevel %@\
                     \\\" with administrator privileges\"\
                     ) 2>&1 | grep \"real\"", optValue];
    ret = execShell(cmd);
    timeStr = getTimeStr(ret);
    
    // Check default msglevel value.
    NSString *ret2 = execShell(@"/usr/libexec/airportd msglevel | awk '{print $3}'");
    msgLevelValue = ret2;
    
    NSLog(@"END airportd msglevel. %@", timeStr);
}

// Exec Bluetooth Reporter
- (void)exec_bluetoothreporter {
    NSLog(@"START Bluetooth Reporter.");
    
    [self alertFunc:@"\
     1) Hold shift + option key.\n\
     2) Click Bluetooth icon.\n\
     3) Select \"Debug > Enable Bluetooth logging\".\n\
     Are you Ready?"];
    
    NSString *ret = execShell(@"(time osascript -e \"do shell script \\\"\
                              /System/Library/Frameworks/IOBluetooth.framework/Resources/BluetoothReporter &>/dev/null &\
                              \\\" with administrator privileges\"\
                              ) 2>&1 | grep \"real\"");
    NSString *timeStr = getTimeStr(ret);

    NSLog(@"END Bluetooth Reporter. %@", timeStr);
}

// Exec Screen Capture
- (void)exec_screencapture {
    NSLog(@"START Screen Capture.");
    
    NSString *timeStr;
    NSString *ret;
    
    NSDate *tmpDatetime = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMdd-hhmmss"];
    NSString *strDatetime = [formatter stringFromDate:tmpDatetime];
    
    NSString *cmd = [NSString stringWithFormat:@"(time osascript -e \"do shell script \\\"\
                     /usr/sbin/screencapture ~/Desktop/Screencapture_%@.png\
                     \\\" \") 2>&1 | grep \"real\"", strDatetime];
    ret = execShell(cmd);
    timeStr = getTimeStr(ret);
    
    NSLog(@"END Screen Capture. %@", timeStr);
}

// Exec Screen Recodring
- (void)exec_screenrecording {
    NSLog(@"START Screen Recording.");
    
    [self alertFunc:@"If you allow this app to Privacy in System Preferences, recording start automatically.\nOtherwise you click red record button."];

    NSDictionary* errorDict;
    NSAppleEventDescriptor* returnDescriptor = NULL;
    
    // Need to allow Privacy tab in Security in System Preferences
    NSAppleScript *scriptObject = [[NSAppleScript alloc] initWithSource:@"\
                                   tell application \"Quicktime Player\"\n\
                                   activate\n\
                                   (New Screen Recording)\n\
                                   tell application \"System Events\" to tell application process \"QuickTime Player\" to tell window \"Screen Recording\"\n\
                                   click button 1\n\
                                   end tell\n\
                                   end tell"];
    // Click red record button your self.
//    NSAppleScript *scriptObject = [[NSAppleScript alloc] initWithSource:@"\
//                                   tell application \"Quicktime Player\"\n\
//                                   activate\n\
//                                   (New Screen Recording)\n\
//                                   end tell"];

    returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
    NSLog(@"%@", errorDict);

    NSLog(@"END Screen Recording.");
}

// Exec tcpdump start
- (void)exec_tcpdump_start {
    NSLog(@"START tcpdump.");
    tcpdumpFlag = 1;
//    NSString *dumpcmd = @"tcpdump -i en0 -s 0 -B 524288 -w ~/Desktop/DumpFile.pcap > /tmp/tcpdump.pid && sudo kill $(cat /tmp/tcpdump.pid)";
    NSString *s = [NSString stringWithFormat:@"do shell script \"tcpdump -i en0 -s 0 -B 524288 -w ~/Desktop/DumpFile.pcap &>/dev/null & echo $! > /tmp/tcpdump.pid\" with administrator privileges"];
    NSAppleScript *as = [[NSAppleScript alloc] initWithSource:s];
    [as executeAndReturnError:nil];
}

// Exec tcpdump stop
- (void)exec_tcpdump_stop {
    tcpdumpFlag = 0;
    NSString *s = [NSString stringWithFormat:@"do shell script \"\
                   sudo kill $(cat /tmp/tcpdump.pid) && sudo rm /tmp/tcpdump.pid\
                   \" with administrator privileges"];
    NSAppleScript *as = [[NSAppleScript alloc] initWithSource:s];
    [as executeAndReturnError:nil];
    
    NSLog(@"END tcpdump.");
}

// Exec Activity Monitor
- (void)exec_activitymonitor {
    NSDictionary *errorDict;
    NSAppleEventDescriptor *returnDescriptor = NULL;
    
    // Need to allow Privacy tab in Security in System Preferences
    NSAppleScript *scriptObject = [[NSAppleScript alloc] initWithSource:@"tell application \"Activity Monitor\"\n\
                                   activate\n\
                                   end tell"];
    returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
}

// Exec Console
- (void)exec_console {
    NSDictionary *errorDict;
    NSAppleEventDescriptor *returnDescriptor = NULL;
    
    // Need to allow Privacy tab in Security in System Preferences
    NSAppleScript *scriptObject = [[NSAppleScript alloc] initWithSource:@"tell application \"Console\"\n\
                                   activate\n\
                                   end tell"];
    returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
}

// Exec Disk Utility
- (void)exec_diskutil {
    NSDictionary *errorDict;
    NSAppleEventDescriptor *returnDescriptor = NULL;
    
    // Need to allow Privacy tab in Security in System Preferences
    NSAppleScript *scriptObject = [[NSAppleScript alloc] initWithSource:@"tell application \"Disk Utility\"\n\
                                   activate\n\
                                   end tell"];
    returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
}

// Exec Terminal
- (void)exec_terminal {
    NSDictionary *errorDict;
    NSAppleEventDescriptor *returnDescriptor = NULL;
    
    // Need to allow Privacy tab in Security in System Preferences
    NSAppleScript *scriptObject = [[NSAppleScript alloc] initWithSource:@"tell application \"Terminal\"\n\
                                   activate\n\
                                   end tell"];
    returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
}

// Exec iBeacon Reciever On
- (void)exec_ibc_on {
    
}
// Exec iBeacon Reciever Off
- (void)exec_ibc_off {
    
}

// Validate Menu Item
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    if ([[menuItem title] isEqual:@"0x0000000000000000"] && [menuItem action] == @selector(exec_airportd_msglevel:)) {
        if ([msgLevelValue isEqual:@"0x0000000000000000"]) {
            [menuItem setState:NSOnState];
        } else {
            [menuItem setState:NSOffState];
        }
    }

    if ([[menuItem title] isEqual:@"0x0000000200000101"] && [menuItem action] == @selector(exec_airportd_msglevel:)) {
        if ([msgLevelValue isEqual:@"0x0000000200000101"]) {
            [menuItem setState:NSOnState];
        } else {
            [menuItem setState:NSOffState];
        }
    }

    if ([[menuItem title] isEqual:@"Gathering"] && [menuItem action] == @selector(exec_tcpdump_start)) {
        if (tcpdumpFlag == 1) {
            [menuItem setState:NSOnState];
        } else {
            [menuItem setState:NSOffState];
        }
    }

    if ([[menuItem title] isEqual:@"Stopping"] && [menuItem action] == @selector(exec_tcpdump_stop)) {
        if (tcpdumpFlag == 0) {
            [menuItem setState:NSOnState];
        } else {
            [menuItem setState:NSOffState];
        }
    }

    return YES;
}

// Alert window function
- (void)alertFunc:(NSString *)string {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:string];
    [alert addButtonWithTitle:@"Ok"];
    [alert runModal];
}

// Get time of time command
NSString *getTimeStr(NSString *timeres) {
    NSRegularExpression *regex1 = [NSRegularExpression regularExpressionWithPattern:@"real\\s+"
                                                                            options:0
                                                                              error:nil];
    NSRegularExpression *regex2 = [NSRegularExpression regularExpressionWithPattern:@"m"
                                                                            options:0
                                                                              error:nil];
    NSString *tmp = [regex1 stringByReplacingMatchesInString:timeres
                                                     options:0
                                                       range:NSMakeRange(0, [timeres length])
                                                withTemplate:@""];
    NSString *regexedStr = [regex2 stringByReplacingMatchesInString:tmp
                                                            options:0
                                                              range:NSMakeRange(0, [tmp length])
                                                       withTemplate:@"m "];
    return regexedStr;
}

// Set attribute
NSMutableAttributedString *attrString(NSString *str) {
    NSMutableAttributedString *initAttrStr;
    initAttrStr = [[NSMutableAttributedString alloc] initWithString:str];
    [initAttrStr addAttribute:NSFontAttributeName
                        value:[NSFont systemFontOfSize:9.0f]
                        range:NSMakeRange(0, [initAttrStr length])];
    return initAttrStr;
}

// Execute shell command
NSString *execShell(NSString *command) {
    NSTask *task = [[NSTask alloc] init];
    NSPipe *pipe = [[NSPipe alloc] init];
    
    [task setLaunchPath:@"/bin/sh"];
    [task setArguments:[NSArray arrayWithObjects:@"-c", command, nil]];
    
    [task setStandardOutput:pipe];
    [task launch];
    
    NSFileHandle *handle = [pipe fileHandleForReading];
    NSData *data = [handle readDataToEndOfFile];
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    result = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return result;
}






#pragma mark - Core Data stack

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.example.kmt.Sysdiag_Launcher" in the user's Application Support directory.
    NSURL *appSupportURL = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"com.example.kmt.Sysdiag_Launcher"];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Sysdiag_Launcher" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationDocumentsDirectory = [self applicationDocumentsDirectory];
    BOOL shouldFail = NO;
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    
    // Make sure the application files directory is there
    NSDictionary *properties = [applicationDocumentsDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    if (properties) {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            failureReason = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationDocumentsDirectory path]];
            shouldFail = YES;
        }
    } else if ([error code] == NSFileReadNoSuchFileError) {
        error = nil;
        [fileManager createDirectoryAtPath:[applicationDocumentsDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    if (!shouldFail && !error) {
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        NSURL *url = [applicationDocumentsDirectory URLByAppendingPathComponent:@"OSXCoreDataObjC.storedata"];
        if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
            coordinator = nil;
        }
        _persistentStoreCoordinator = coordinator;
    }
    
    if (shouldFail || error) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        if (error) {
            dict[NSUnderlyingErrorKey] = error;
        }
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

#pragma mark - Core Data Saving and Undo support

- (IBAction)saveAction:(id)sender {
    // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    NSError *error = nil;
    if ([[self managedObjectContext] hasChanges] && ![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
    return [[self managedObjectContext] undoManager];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertFirstButtonReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

@end
