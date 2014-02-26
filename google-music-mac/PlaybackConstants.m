/*
 * PlaybackConstants.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#include "PlaybackConstants.h"

// Repeat modes.
NSString *const MUSIC_LIST_REPEAT = @"LIST_REPEAT";
NSString *const MUSIC_SINGLE_REPEAT = @"SINGLE_REPEAT";
NSString *const MUSIC_NO_REPEAT = @"NO_REPEAT";

// Shuffle modes.
NSString *const MUSIC_ALL_SHUFFLE = @"ALL_SHUFFLE";
NSString *const MUSIC_NO_SHUFFLE = @"NO_SHUFFLE";

// Playback modes.
NSInteger const MUSIC_PAUSED = 0;
NSInteger const MUSIC_PLAYING = 1;

// Rating modes.
NSInteger const MUSIC_RATING_THUMBSUP = 5;
NSInteger const MUSIC_RATING_THUMBSDOWN = 1;
NSInteger const MUSIC_RATING_NONE = 1;