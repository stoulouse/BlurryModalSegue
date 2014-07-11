//
//  BlurryModalSegue.m
//  BlurryModal
//
//  Created by Matthew Hupman on 11/21/13.
//  Copyright (c) 2013 Citrrus. All rights reserved.
//

#import "BlurryModalSegue.h"
#import <QuartzCore/QuartzCore.h>
#import "../../UIImage-BlurredFrame/UIImage+ImageEffects.h"

static UIImageOrientation ImageOrientationFromInterfaceOrientation(UIInterfaceOrientation orientation) {
    switch (orientation)
    {
        case UIInterfaceOrientationPortraitUpsideDown:
            return UIImageOrientationDown;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            return UIImageOrientationRight;
            break;
        case UIInterfaceOrientationLandscapeRight:
            return UIImageOrientationLeft;
            break;
        default:
            return UIImageOrientationUp;
    }
}

@implementation BlurryModalSegue

- (id)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    self = [super initWithIdentifier:identifier source:source destination:destination];
    
    if (self)
    {
        // Some sane defaults
        self.backingImageBlurRadius = @(20);
        self.backingImageSaturationDeltaFactor = @(.45f);
		self.backingImageTintColor = destination.view.backgroundColor;
    }
    
    return self;
}

- (void)perform
{
    UIViewController* source = (UIViewController*)self.sourceViewController;
    UIViewController* destination = (UIViewController*)self.destinationViewController;

    CGRect windowBounds = source.view.window.bounds;
    
    // Normalize based on the orientation
    CGRect nomalizedWindowBounds = [source.view convertRect:windowBounds fromView:nil];
    
    UIGraphicsBeginImageContextWithOptions(windowBounds.size, YES, 0.0);

    [source.view.window drawViewHierarchyInRect:windowBounds afterScreenUpdates:NO];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();

    if (self.processBackgroundImage)
    {
        snapshot = self.processBackgroundImage(self, snapshot);
    }
    else
    {
        snapshot = [snapshot applyBlurWithRadius:self.backingImageBlurRadius.doubleValue
                                       tintColor:self.backingImageTintColor
                           saturationDeltaFactor:self.backingImageSaturationDeltaFactor.doubleValue
                                       maskImage:nil];
    }
    
    snapshot = [UIImage imageWithCGImage:snapshot.CGImage scale:1.0 orientation:ImageOrientationFromInterfaceOrientation([UIApplication sharedApplication].statusBarOrientation)];
    
    destination.view.clipsToBounds = YES;
    
    UIImageView* backgroundImageView = [[UIImageView alloc] initWithImage:snapshot];

    CGRect frame;
    switch (destination.modalTransitionStyle) {
        case UIModalTransitionStyleCoverVertical:
            // Only the CoverVertical transition make sense to have an
            // animation on the background to make it look still while
            // destination view controllers animates from the bottom to top
            frame = CGRectMake(0, -nomalizedWindowBounds.size.height, nomalizedWindowBounds.size.width, nomalizedWindowBounds.size.height);
            break;
        default:
            frame = CGRectMake(0, 0, nomalizedWindowBounds.size.width, nomalizedWindowBounds.size.height);
            break;
    }
    backgroundImageView.frame = frame;
    
    [destination.view addSubview:backgroundImageView];
    [destination.view sendSubviewToBack:backgroundImageView];
    
//    [self.sourceViewController presentModalViewController:self.destinationViewController animated:YES];
	[source.view.superview addSubview: destination.view];
	CGRect f = source.view.frame;
	f.origin.y += f.size.height;
	destination.view.frame = f;
	[UIView animateWithDuration:0.3f animations:^{
		destination.view.frame = source.view.frame;
	}];
	source.blurryViewController = destination;
	destination.blurryViewController = source;
    
    [destination.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [UIView animateWithDuration:[context transitionDuration] animations:^{
            backgroundImageView.frame = CGRectMake(0, 0, nomalizedWindowBounds.size.width, nomalizedWindowBounds.size.height);
        }];
    } completion:nil];
}

@end



@implementation BlurryModalUnwindSegue

- (void)perform
{
    UIViewController* source = (UIViewController*)self.sourceViewController;
    UIViewController* destination = (UIViewController*)self.destinationViewController;
	
	//    [self.sourceViewController presentModalViewController:self.destinationViewController animated:YES];
	CGRect f = source.view.frame;
	f.origin.y += f.size.height;
	[UIView animateWithDuration:0.3f animations:^{
		source.view.frame = f;
	} completion:^(BOOL finished) {
		[source.view removeFromSuperview];
		source.blurryViewController = nil;
		destination.blurryViewController = nil;
	}];
}

@end


@implementation UIViewController (BlurryModal)
static NSMutableDictionary* sBlurryModalControllers = nil;
-(void)initBlurryModal {
	if (sBlurryModalControllers == nil) {
		sBlurryModalControllers = [[NSMutableDictionary alloc] init];
	}
}
-(void)setBlurryViewController:(UIViewController *)blurryViewController {
	[self initBlurryModal];
	if (blurryViewController == nil) {
		[sBlurryModalControllers removeObjectForKey:[NSNumber numberWithUnsignedInteger:(uintptr_t) self]];
	 } else {
		[sBlurryModalControllers setObject:blurryViewController forKey:[NSNumber numberWithUnsignedInteger:(uintptr_t) self]];
	}
}
-(UIViewController*)blurryViewController {
	[self initBlurryModal];
	return [sBlurryModalControllers objectForKey:[NSNumber numberWithUnsignedInteger:(uintptr_t) self]];
}
- (IBAction)dismissBlurryModal:(id)sender {
	UIViewController* parent = self.blurryViewController;
	if (parent) {
		BlurryModalUnwindSegue* segue = [[BlurryModalUnwindSegue alloc] initWithIdentifier:@"" source:self destination:parent];
		[self prepareForSegue:segue sender:sender];
		[segue perform];
		NSLog(@"");
	}
}
@end