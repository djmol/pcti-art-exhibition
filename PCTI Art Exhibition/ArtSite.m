//
//  ArtSite.m
//  PCTI Art Exhibition
//
//  Created by Dan on 3/21/16.
//  Copyright © 2016 Passaic County Technical Institute. All rights reserved.
//

#import "ArtSite.h"

@implementation ArtSite

- (ArtSite *)initWithSiteInfo:(NSDictionary *)siteInfo {
    self = [super init];
    
    if (self) {
        self.siteInfo = [[NSDictionary alloc] initWithDictionary:siteInfo];
    }
    
    return self;
}

@end
