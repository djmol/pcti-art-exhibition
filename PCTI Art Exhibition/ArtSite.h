//
//  ArtSite.h
//  PCTI Art Exhibition
//
//  Created by Dan on 3/21/16.
//  Copyright © 2016 Passaic County Technical Institute. All rights reserved.
//

#import <Foundation/Foundation.h>

// Artwork site info is stored in a dictionary (using an enum as keys) because it's easier
// to load the plist containing all the data into a dictionary than a bunch of separate properties, ya kno?

typedef enum {
    ArtSiteMajorMinor = 0,
    ArtSiteTitle,
    ArtSiteMedium,
    ArtSiteDescription,
    ArtSiteArtist,
    ArtSiteBio,
    ArtSiteArtworkImage,
    ArtSiteArtworkViewMode,
    ArtSiteHeadshotImage,
    ArtSiteBannerImage
} ArtSiteKey;

@interface ArtSite : NSObject

- (ArtSite *)initWithSiteInfo:(NSDictionary *)siteInfo;

@property (nonatomic, strong) NSDictionary *siteInfo;

@end
