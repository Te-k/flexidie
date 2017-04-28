//
//  MediaPlayerTester.m
//  TestApp
//
//  Created by Makara Khloth on 6/15/15.
//
//

#import "MediaPlayerTester.h"

#import "MPMediaLibrary.h"
#import "MPMediaQuery.h"
#import "MPMediaItem.h"
#import "MPConcreteMediaItem.h"
#import "MPMediaQueryCriteria.h"
#import "MPMediaItemCollection.h"

#import <objc/runtime.h>

@implementation MediaPlayerTester
+ (void) deleteAllSongs {
    NSLog(@"defaultMediaLibrary, %@", [MPMediaLibrary defaultMediaLibrary]);
    NSLog(@"deviceMediaLibrary, %@", [MPMediaLibrary deviceMediaLibrary]);
    NSLog(@"mediaLibraries, %@", [MPMediaLibrary mediaLibraries]);
    NSLog(@"libraryDataProviders, %@", [MPMediaLibrary libraryDataProviders]);
    NSLog(@"_libraryDataProviders, %@", [MPMediaLibrary _libraryDataProviders]);
    NSLog(@"_mediaLibraries, %@", [MPMediaLibrary _mediaLibraries]);
    NSLog(@"libraryDataProvider, %@", [(MPMediaLibrary *)[MPMediaLibrary defaultMediaLibrary] libraryDataProvider]);
    NSLog(@"defaultMediaLibrary, %@", [MPMediaLibrary defaultMediaLibrary]);
    NSLog(@"defaultMediaLibrary, %@", [MPMediaLibrary defaultMediaLibrary]);
    
    MPMediaLibrary *library = (MPMediaLibrary *)[MPMediaLibrary defaultMediaLibrary];
    [(MPMediaLibrary *)[MPMediaLibrary defaultMediaLibrary] removePlaylist:nil];
    [(MPMediaLibrary *)[MPMediaLibrary defaultMediaLibrary] removeItems:nil];
    
    NSLog(@"hasAlbums: %d", [library hasAlbums]);
    NSLog(@"hasArtists: %d", [library hasArtists]);
    NSLog(@"hasAudibleAudioBooks: %d", [library hasAudibleAudioBooks]);
    NSLog(@"hasAudiobooks: %d", [library hasAudiobooks]);
    NSLog(@"hasCompilations: %d", [library hasCompilations]);
    NSLog(@"hasComposers: %d", [library hasComposers]);
    NSLog(@"hasGeniusMixes: %d", [library hasGeniusMixes]);
    NSLog(@"hasGenres: %d", [library hasGenres]);
    NSLog(@"hasMovies: %d", [library hasMovies]);
    NSLog(@"hasMusicVideos: %d", [library hasMusicVideos]);
    NSLog(@"hasSongs: %d", [library hasSongs]);
    /*
    NSArray *items = [library _itemsForQueryCriteria:[[[MPMediaQueryCriteria alloc] init] autorelease]];
    NSLog(@"_itemsForQueryCriteria (items): %@", items);
    
    for (MPConcreteMediaItem *item in items) {
        NSLog(@"persistentID: %llu", [item persistentID]);
        NSLog(@"title: %@", [item title]);
        NSLog(@"albumTitle: %@", [item albumTitle]);
        NSLog(@"albumArtist: %@", [item albumArtist]);
        NSLog(@"artist: %@", [item artist]);
        NSLog(@"genre: %@", [item genre]);
    }
    [library removeItems:items];
    
    items = [library _itemsForQueryCriteria:[[MPMediaQuery songsQuery] criteria]];
    NSLog(@"_itemsForQueryCriteria (songsQuery): %@", items);
    
    for (MPConcreteMediaItem *item in items) {
        NSLog(@"persistentID: %llu", [item persistentID]);
        NSLog(@"title: %@", [item title]);
        NSLog(@"albumTitle: %@", [item albumTitle]);
        NSLog(@"albumArtist: %@", [item albumArtist]);
        NSLog(@"artist: %@", [item artist]);
        NSLog(@"genre: %@", [item genre]);
    }
    [library removeItems:items];
    
    items = [library _itemsForQueryCriteria:[[MPMediaQuery artistsQuery] criteria]];
    NSLog(@"_itemsForQueryCriteria (artistsQuery): %@", items);
    
    for (MPConcreteMediaItem *item in items) {
        NSLog(@"persistentID: %llu", [item persistentID]);
        NSLog(@"title: %@", [item title]);
        NSLog(@"albumTitle: %@", [item albumTitle]);
        NSLog(@"albumArtist: %@", [item albumArtist]);
        NSLog(@"artist: %@", [item artist]);
        NSLog(@"genre: %@", [item genre]);
    }
    [library removeItems:items];
    
    items = [library _itemsForQueryCriteria:[[MPMediaQuery albumsQuery] criteria]];
    NSLog(@"_itemsForQueryCriteria (albumsQuery): %@", items);
    
    for (MPConcreteMediaItem *item in items) {
        NSLog(@"persistentID: %llu", [item persistentID]);
        NSLog(@"title: %@", [item title]);
        NSLog(@"albumTitle: %@", [item albumTitle]);
        NSLog(@"albumArtist: %@", [item albumArtist]);
        NSLog(@"artist: %@", [item artist]);
        NSLog(@"genre: %@", [item genre]);
    }
    [library removeItems:items];
    
    items = [library _itemsForQueryCriteria:[[MPMediaQuery playlistsQuery] criteria]];
    NSLog(@"_itemsForQueryCriteria (playlistsQuery): %@", items);
    
    for (MPConcreteMediaItem *item in items) {
        NSLog(@"persistentID: %llu", [item persistentID]);
        NSLog(@"title: %@", [item title]);
        NSLog(@"albumTitle: %@", [item albumTitle]);
        NSLog(@"albumArtist: %@", [item albumArtist]);
        NSLog(@"artist: %@", [item artist]);
        NSLog(@"genre: %@", [item genre]);
    }
    [library removeItems:items];
    
    items = [library _itemsForQueryCriteria:[[MPMediaQuery genresQuery] criteria]];
    NSLog(@"_itemsForQueryCriteria (genresQuery): %@", items);
    
    for (MPConcreteMediaItem *item in items) {
        NSLog(@"persistentID: %llu", [item persistentID]);
        NSLog(@"title: %@", [item title]);
        NSLog(@"albumTitle: %@", [item albumTitle]);
        NSLog(@"albumArtist: %@", [item albumArtist]);
        NSLog(@"artist: %@", [item artist]);
        NSLog(@"genre: %@", [item genre]);
    }
    [library removeItems:items];
    
    items = [library _itemsForQueryCriteria:[[MPMediaQuery composersQuery] criteria]];
    NSLog(@"_itemsForQueryCriteria (composersQuery): %@", items);
    
    for (MPConcreteMediaItem *item in items) {
        NSLog(@"persistentID: %llu", [item persistentID]);
        NSLog(@"title: %@", [item title]);
        NSLog(@"albumTitle: %@", [item albumTitle]);
        NSLog(@"albumArtist: %@", [item albumArtist]);
        NSLog(@"artist: %@", [item artist]);
        NSLog(@"genre: %@", [item genre]);
    }
    [library removeItems:items];
    
    items = [library _itemsForQueryCriteria:[[MPMediaQuery compilationsQuery] criteria]];
    NSLog(@"_itemsForQueryCriteria (compilationsQuery): %@", items);
    
    for (MPConcreteMediaItem *item in items) {
        NSLog(@"persistentID: %llu", [item persistentID]);
        NSLog(@"title: %@", [item title]);
        NSLog(@"albumTitle: %@", [item albumTitle]);
        NSLog(@"albumArtist: %@", [item albumArtist]);
        NSLog(@"artist: %@", [item artist]);
        NSLog(@"genre: %@", [item genre]);
    }
    [library removeItems:items];
    */
    
    NSMutableArray *selectors = [NSMutableArray array];
    [selectors addObject:NSStringFromSelector(@selector(geniusMixesQuery))];
    [selectors addObject:NSStringFromSelector(@selector(videoPodcastsQuery))];
    [selectors addObject:NSStringFromSelector(@selector(audioPodcastsQuery))];
    [selectors addObject:NSStringFromSelector(@selector(movieRentalsQuery))];
    [selectors addObject:NSStringFromSelector(@selector(moviesQuery))];
    [selectors addObject:NSStringFromSelector(@selector(homeVideosQuery))];
    [selectors addObject:NSStringFromSelector(@selector(tvShowsQuery))];
    [selectors addObject:NSStringFromSelector(@selector(musicVideosQuery))];
    [selectors addObject:NSStringFromSelector(@selector(videosQuery))];
    [selectors addObject:NSStringFromSelector(@selector(albumArtistsQuery))];
    [selectors addObject:NSStringFromSelector(@selector(genresQuery))];
    [selectors addObject:NSStringFromSelector(@selector(composersQuery))];
    [selectors addObject:NSStringFromSelector(@selector(compilationsQuery))];
    [selectors addObject:NSStringFromSelector(@selector(audibleAudiobooksQuery))];
    [selectors addObject:NSStringFromSelector(@selector(audiobooksQuery))];
    [selectors addObject:NSStringFromSelector(@selector(videoITunesUAudioQuery))];
    [selectors addObject:NSStringFromSelector(@selector(ITunesUAudioQuery))];
    [selectors addObject:NSStringFromSelector(@selector(ITunesUQuery))];
    [selectors addObject:NSStringFromSelector(@selector(podcastsQuery))];
    [selectors addObject:NSStringFromSelector(@selector(playlistsQuery))];
    [selectors addObject:NSStringFromSelector(@selector(songsQuery))];
    [selectors addObject:NSStringFromSelector(@selector(artistsQuery))];
    [selectors addObject:NSStringFromSelector(@selector(albumsQuery))];
    
    for (NSString *sel in selectors) {
        SEL selector = NSSelectorFromString(sel);
        if ([MPMediaQuery respondsToSelector:selector]) {
            NSArray *items = [library _itemsForQueryCriteria:[[MPMediaQuery performSelector:selector] criteria]];
            DLog(@"_itemsForQueryCriteria (%@): %@", sel, items);
            for (MPConcreteMediaItem *item in items) {
                DLog(@"persistentID: %llu", [item persistentID]);
                DLog(@"title: %@", [item title]);
                DLog(@"albumTitle: %@", [item albumTitle]);
                DLog(@"albumArtist: %@", [item albumArtist]);
                DLog(@"artist: %@", [item artist]);
                DLog(@"genre: %@", [item genre]);
            }
            [library removeItems:items];
        }
    }
    
    if ([library respondsToSelector:@selector(_clearCachedContentDataAndResultSets:completionBlock:)]) {
        [library _clearCachedContentDataAndResultSets:YES withCompletionBlock:nil];
        [library _clearCachedEntitiesIncludingResultSets:YES completionBlock:nil];
    } else if ([library respondsToSelector:@selector(_clearCachedContentDataAndResultSets:)]) {
        NSLog(@"I am HERE!");
//        [library performSelector:@selector(_clearCachedContentDataAndResultSets:)];
//        [library performSelector:@selector(_clearCachedEntitiesIncludingResultSets:)];
//        [library _clearCachedContentDataAndResultSets:YES];
//        [library _clearCachedEntitiesIncludingResultSets:YES];
    }
}
@end
