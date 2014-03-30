/*
 * LastFmTrackTableCellView.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Cocoa/Cocoa.h>

@interface LastFmTrackTableCellView : NSTableCellView

@property (retain) IBOutlet NSImageView *artView;
@property (retain) IBOutlet NSTextField *titleView;
@property (retain) IBOutlet NSTextField *artistAlbumView;
@property (retain) IBOutlet NSTextField *timestampView;

@end
