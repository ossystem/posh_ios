#import "UIImage+animatedGIF.h"
#import <ImageIO/ImageIO.h>
#import <WatchKit/WatchKit.h>

#if __has_feature(objc_arc)
#define toCF (__bridge CFTypeRef)
#define fromCF (__bridge id)
#else
#define toCF (CFTypeRef)
#define fromCF (id)
#endif

@implementation UIImage (animatedGIF)
    
    static int delayCentisecondsForImageAtIndex(CGImageSourceRef const source, size_t const i) {
        int delayCentiseconds = 1;
        CFDictionaryRef const properties = CGImageSourceCopyPropertiesAtIndex(source, i, NULL);
        if (properties) {
            CFDictionaryRef const gifProperties = CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
            if (gifProperties) {
                NSNumber *number = fromCF CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFUnclampedDelayTime);
                if (number == NULL || [number doubleValue] == 0) {
                    number = fromCF CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFDelayTime);
                }
                if ([number doubleValue] > 0) {
                    // Even though the GIF stores the delay as an integer number of centiseconds, ImageIO “helpfully” converts that to seconds for us.
                    delayCentiseconds = (int)lrint([number doubleValue] * 100);
                }
            }
            CFRelease(properties);
        }
        return delayCentiseconds;
    }
    
    static void createImagesAndDelays(CGImageSourceRef source, size_t count, CGImageRef imagesOut[count], int delayCentisecondsOut[count]) {
        for (size_t i = 0; i < count; ++i) {
            imagesOut[i] = CGImageSourceCreateImageAtIndex(source, i, NULL);
            delayCentisecondsOut[i] = delayCentisecondsForImageAtIndex(source, i);
        }
    }
    
    static int sum(size_t const count, int const *const values) {
        int theSum = 0;
        for (size_t i = 0; i < count; ++i) {
            theSum += values[i];
        }
        return theSum;
    }
    
    static int pairGCD(int a, int b) {
        if (a < b)
        return pairGCD(b, a);
        while (true) {
            int const r = a % b;
            if (r == 0)
            return b;
            a = b;
            b = r;
        }
    }
    
    static int vectorGCD(size_t const count, int const *const values) {
        int gcd = values[0];
        for (size_t i = 1; i < count; ++i) {
            // Note that after I process the first few elements of the vector, `gcd` will probably be smaller than any remaining element.  By passing the smaller value as the second argument to `pairGCD`, I avoid making it swap the arguments.
            gcd = pairGCD(values[i], gcd);
        }
        return gcd;
    }
    
    static NSArray *frameArray(size_t const count, CGImageRef const images[count], int const delayCentiseconds[count], int const totalDurationCentiseconds) {
        int const gcd = vectorGCD(count, delayCentiseconds);
        size_t const frameCount = totalDurationCentiseconds / gcd;
        UIImage *frames[frameCount];
        for (size_t i = 0, f = 0; i < count; ++i) {
            UIImage *const frame = [UIImage imageWithCGImage:images[i]];
            for (size_t j = delayCentiseconds[i] / gcd; j > 0; --j) {
                frames[f++] = frame;
            }
        }
        return [NSArray arrayWithObjects:frames count:frameCount];
    }
    
    static void releaseImages(size_t const count, CGImageRef const images[count]) {
        for (size_t i = 0; i < count; ++i) {
            CGImageRelease(images[i]);
        }
    }
    
    static UIImage *animatedImageWithAnimatedGIFImageSource(CGImageSourceRef const source) {
        size_t const count = CGImageSourceGetCount(source);
        CGImageRef images[count];
        int delayCentiseconds[count]; // in centiseconds
        createImagesAndDelays(source, count, images, delayCentiseconds);
        int const totalDurationCentiseconds = sum(count, delayCentiseconds);
        NSArray *const frames = frameArray(count, images, delayCentiseconds, totalDurationCentiseconds);
        UIImage *const animation = [UIImage animatedImageWithImages:frames duration:(NSTimeInterval)totalDurationCentiseconds / 100.0];
        releaseImages(count, images);
        return animation;
    }
    
    static UIImage *animatedImageWithAnimatedGIFReleasingImageSource(CGImageSourceRef CF_RELEASES_ARGUMENT source) {
        if (source) {
            UIImage *const image = animatedImageWithAnimatedGIFImageSource(source);
            CFRelease(source);
            return image;
        } else {
            return nil;
        }
    }
    
+ (UIImage *)animatedImageWithAnimatedGIFData:(NSData *)data {
    return animatedImageWithAnimatedGIFReleasingImageSource(CGImageSourceCreateWithData(toCF data, NULL));
}
    
+ (UIImage *)animatedImageWithAnimatedGIFURL:(NSURL *)url {
    return animatedImageWithAnimatedGIFReleasingImageSource(CGImageSourceCreateWithURL(toCF url, NULL));
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage*) fixedAnimatedImage {
    NSUInteger maxFramesCnt = 201;
    CGSize screenSize = [WKInterfaceDevice currentDevice].screenBounds.size;
    screenSize.width *= [WKInterfaceDevice currentDevice].screenScale;
    screenSize.height *= [WKInterfaceDevice currentDevice].screenScale;
    CGSize maxSize = screenSize;
    
    NSUInteger framesCnt = self.images.count;
    UIImage* firstFrame = [self.images firstObject];
    CGSize size = firstFrame.size;
    BOOL isFramesCntOk = framesCnt <= maxFramesCnt;
    BOOL isSizeOk = size.width <= maxSize.width && size.height <= maxSize.height;
    if (isFramesCntOk && isSizeOk)
        return self;
    
    NSTimeInterval duration = self.duration;
    NSArray<UIImage*>* frames = self.images;
    NSUInteger newFramesCnt = isFramesCntOk ? framesCnt : maxFramesCnt;
    CGFloat sizeRatio = isSizeOk ? 1.0 : MAX(size.width / maxSize.width, size.height / maxSize.height);
    CGSize newSize = isSizeOk ? size : CGSizeMake(MIN(maxSize.width, size.width / sizeRatio), MIN(maxSize.height, size.height / sizeRatio));
    NSMutableArray<UIImage*>* fixedFrames = [NSMutableArray arrayWithCapacity:newFramesCnt];
    NSUInteger ff = 0;
    CGFloat fratio = 1.0 * framesCnt / newFramesCnt;
    for (NSUInteger f = 0 ; f < framesCnt ; f++) {
        CGFloat factor = 1.0 * (f + 1) / fratio;
        bool take = isFramesCntOk || f == 0 || ((int)factor >= ff && (int)factor < newFramesCnt);
        if (take) {
            UIImage* frame = [frames objectAtIndex:f];
            UIImage* fixedFrame = isSizeOk ? frame : [UIImage imageWithImage:frame scaledToSize:newSize];
            [fixedFrames addObject:fixedFrame];
            ff++;
        }
    }
    UIImage* newImage = [UIImage animatedImageWithImages:fixedFrames duration:duration];
    return newImage;
}


    
    @end
