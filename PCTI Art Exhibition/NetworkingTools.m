//
//  NetworkingTools.m
//  PCTI Art Exhibition
//
//  Created by Dan on 1/12/16.
//  Copyright © 2016 Passaic County Technical Institute. All rights reserved.
//

#import "NetworkingTools.h"
#import "AFNetworking.h"

@implementation NetworkingTools

+ (void)downloadImageFromURL:(NSURL *)imageURL toView:(UIImageView *)imageView withActivity:(UIActivityIndicatorView *)activityIndicator {
    // Use the default session configuration for the manager (background downloads must use the delegate APIs)
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    // Use AFNetworking's NSURLSessionManager to manage a NSURLSession.
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    // Create a request object for the given URL.
    NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
    // Create a block to handle download progress updates
    void(^_Nullable downloadProgressHandler)(NSProgress * _Nonnull) = ^(NSProgress *downloadProgress) {
        // Update UI from main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![activityIndicator isAnimating]) {
                [activityIndicator startAnimating];
            }
        });
    };
    
    // Create the callback block responsible for determining the location to save the downloaded file to.
    NSURL *(^destinationBlock)(NSURL *targetPath, NSURLResponse *response) = ^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        // Get the path of the application's documents directory.
        NSURL *documentsDirectoryURL = [self documentsDirectoryURL];
        NSURL *saveLocation = nil;
        
        // Check if the response contains a suggested file name
        if (response.suggestedFilename) {
            // Append the suggested file name to the documents directory path.
            saveLocation = [documentsDirectoryURL URLByAppendingPathComponent:response.suggestedFilename];
        } else {
            // Append the desired file name to the documents directory path.
            saveLocation = [documentsDirectoryURL URLByAppendingPathComponent:@"PCTIAE"];
        }
        
        return saveLocation;
    };
    
    // Create the completion block that will be called when the image is done downloading/saving.
    void (^completionBlock)(NSURLResponse *response, NSURL *filePath, NSError *error) = ^void (NSURLResponse *response, NSURL *filePath, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // There is no longer any reason to observe progress, the download has finished or cancelled.
            //[progress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
            
            if (error) {
                NSLog(@"%@",error.localizedDescription);
                // Something went wrong downloading or saving the file. Figure out what went wrong and handle the error.
            } else {
                // Remove activity indicator
                [activityIndicator removeFromSuperview];
                // Get the data for the image we just saved.
                NSData *imageData = [NSData dataWithContentsOfURL:filePath];
                // Get a UIImage object from the image data.
                imageView.image = [UIImage imageWithData:imageData];
            }
        });
    };
    
    // Create the download task for the image.
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request
                                                             progress:downloadProgressHandler
                                                          destination:destinationBlock
                                                    completionHandler:completionBlock];
    // Start the download task.
    [task resume];
}

+ (void)downloadImageFromURL:(NSURL *)imageURL toView:(UIImageView *)imageView withProgress:(UIProgressView *)progressView {
    // Use the default session configuration for the manager (background downloads must use the delegate APIs)
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    // Use AFNetworking's NSURLSessionManager to manage a NSURLSession.
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    // Create a request object for the given URL.
    NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
    // Create a block to handle download progress updates
    void(^_Nullable downloadProgressHandler)(NSProgress * _Nonnull) = ^(NSProgress *downloadProgress) {
        // Update UI from main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            progressView.progress = downloadProgress.fractionCompleted;
        });
    };
    
    // Create the callback block responsible for determining the location to save the downloaded file to.
    NSURL *(^destinationBlock)(NSURL *targetPath, NSURLResponse *response) = ^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        // Get the path of the application's documents directory.
        NSURL *documentsDirectoryURL = [self documentsDirectoryURL];
        NSURL *saveLocation = nil;
        
        // Check if the response contains a suggested file name
        if (response.suggestedFilename) {
            // Append the suggested file name to the documents directory path.
            saveLocation = [documentsDirectoryURL URLByAppendingPathComponent:response.suggestedFilename];
        } else {
            // Append the desired file name to the documents directory path.
            saveLocation = [documentsDirectoryURL URLByAppendingPathComponent:@"PCTIAE"];
        }
        
        return saveLocation;
    };
    
    // Create the completion block that will be called when the image is done downloading/saving.
    void (^completionBlock)(NSURLResponse *response, NSURL *filePath, NSError *error) = ^void (NSURLResponse *response, NSURL *filePath, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // There is no longer any reason to observe progress, the download has finished or cancelled.
            //[progress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
            
            if (error) {
                NSLog(@"%@",error.localizedDescription);
                // Something went wrong downloading or saving the file. Figure out what went wrong and handle the error.
            } else {
                // Remove progress indicator
                [progressView removeFromSuperview];
                // Get the data for the image we just saved.
                NSData *imageData = [NSData dataWithContentsOfURL:filePath];
                // Get a UIImage object from the image data.
                imageView.image = [UIImage imageWithData:imageData];
            }
        });
    };
    
    // Create the download task for the image.
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request
                                                             progress:downloadProgressHandler
                                                          destination:destinationBlock
                                                    completionHandler:completionBlock];
    // Start the download task.
    [task resume];
}

+ (void)downloadPlistFromURL:(NSURL *)fileURL notifyAt:(NSString *)notificationName {
    // Use ephemeral session configuration so the response is not cached (we'll only be downloading when we want a new one)
    // Well, it's cached in RAM apparently...?
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    configuration.URLCache = nil;
    // Use AFNetworking's NSURLSessionManager to manage a NSURLSession.
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    
    // Create a request object for the given URL.
    NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
    // Create a block to handle download progress updates
    void(^_Nullable downloadProgressHandler)(NSProgress * _Nonnull) = ^(NSProgress *downloadProgress) {
        // Update UI from main queue
        // TODO: Showing progress for plist...?
        /*dispatch_async(dispatch_get_main_queue(), ^{
         self.progressView.progress = downloadProgress.fractionCompleted;
         // If download is complete, remove progressView
         if (downloadProgress.fractionCompleted == 1.0) {
         [self.progressView removeFromSuperview];
         }
         });*/
    };
    
    // Create the callback block responsible for determining the location to save the downloaded file to.
    NSURL *(^destinationBlock)(NSURL *targetPath, NSURLResponse *response) = ^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        // Get the path of the application's documents directory.
        NSURL *documentsDirectoryURL = [self documentsDirectoryURL];
        NSURL *saveLocation = nil;
        
        // Check if the response contains a suggested file name
        if (response.suggestedFilename) {
            // Append the suggested file name to the documents directory path.
            saveLocation = [documentsDirectoryURL URLByAppendingPathComponent:response.suggestedFilename];
        } else {
            // Append the desired file name to the documents directory path.
            saveLocation = [documentsDirectoryURL URLByAppendingPathComponent:@"PCTIAE"];
        }
        
        return saveLocation;
    };
    
    // Create the completion block that will be called when the file is done downloading/saving.
    void (^completionBlock)(NSURLResponse *response, NSURL *filePath, NSError *error) = ^void (NSURLResponse *response, NSURL *filePath, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                NSLog(@"%@",error.localizedDescription);
                // Something went wrong downloading or saving the file. Figure out what went wrong and handle the error.
            } else {
                // Get the data for the file we just saved.
                NSData *fileData = [NSData dataWithContentsOfURL:filePath];
                // Get a NSDictionary from the data.
                NSError *error;
                NSPropertyListFormat plFormat;
                NSDictionary *fileDict = [NSPropertyListSerialization propertyListWithData:fileData options:NSPropertyListImmutable format:&plFormat error:&error];
                // Post notification containing file
                [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:fileDict];
                if (error) {
                    //TODO: Handle error.
                }
            }
        });
    };
    
    // Create the download task for the file.
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request
                                                             progress:downloadProgressHandler
                                                          destination:destinationBlock
                                                    completionHandler:completionBlock];
    // Start the download task.
    [task resume];
}

+ (NSURL *)documentsDirectoryURL {
    NSError *error = nil;
    NSURL *url = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                        inDomain:NSUserDomainMask
                                               appropriateForURL:nil
                                                          create:NO
                                                           error:&error];
    if (error) {
        // TODO: Figure out what went wrong and handle the error.
    }
    
    return url;
}


@end
