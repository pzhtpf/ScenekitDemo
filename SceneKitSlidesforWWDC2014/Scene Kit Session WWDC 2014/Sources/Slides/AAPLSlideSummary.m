#import "AAPLPresentationViewController.h"
#import "AAPLSlideTextManager.h"
#import "AAPLSlide.h"
#import "Utils.h"

@interface AAPLSlideSummary : AAPLSlide
@end

@implementation AAPLSlideSummary

- (void)setupSlideWithPresentationViewController:(AAPLPresentationViewController *)presentationViewController
{
    self.textManager.title = @"Summary";
    [self.textManager addBullet:@"SceneKit available on iOS" atLevel:0];
    [self.textManager addBullet:@"Casual game ready" atLevel:0];
    [self.textManager addBullet:@"Full featured rendering" atLevel:0];
    [self.textManager addBullet:@"Extendable" atLevel:0];
}

@end