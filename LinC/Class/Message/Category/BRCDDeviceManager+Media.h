//
//  BRCDDeviceManager+Media.h
//  LinC
//
//  Created by Yingwei Fan on 8/11/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRCDDeviceManagerBase.h"

@interface BRCDDeviceManager (Media)

#pragma mark - AudioPlayer
// Play the audio
- (void)asyncPlayingWithPath:(NSString *)aFilePath
                  completion:(void(^)(NSError *error))completon;
// Stop playing
- (void)stopPlaying;

- (void)stopPlayingWithChangeCategory:(BOOL)isChange;

-(BOOL)isPlaying;

#pragma mark - AudioRecorder
// Start recording
- (void)asyncStartRecordingWithFileName:(NSString *)fileName
                             completion:(void(^)(NSError *error))completion;

// Stop recording
-(void)asyncStopRecordingWithCompletion:(void(^)(NSString *recordPath,
                                                 NSInteger aDuration,
                                                 NSError *error))completion;
// Cancel recording
-(void)cancelCurrentRecording;

-(BOOL)isRecording;

// Get the saved data path
+ (NSString*)dataPath;

@end
