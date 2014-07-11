//
//  BlurryModalSegue.h
//  BlurryModal
//
//  Created by Matthew Hupman on 11/21/13.
//  Copyright (c) 2013 Citrrus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BlurryModalSegue;

typedef UIImage*(^ProcessBackgroundImage)(BlurryModalSegue* blurryModalSegue, UIImage* rawImage);

@interface BlurryModalSegue : UIStoryboardSegue

@property (nonatomic, copy) ProcessBackgroundImage processBackgroundImage;

@property (nonatomic) NSNumber* backingImageBlurRadius UI_APPEARANCE_SELECTOR;
@property (nonatomic) NSNumber* backingImageSaturationDeltaFactor UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor* backingImageTintColor UI_APPEARANCE_SELECTOR;

@end


@interface BlurryModalUnwindSegue : UIStoryboardSegue
@end



@interface UIViewController (BlurryModal)
@property (nonatomic, strong) UIViewController* blurryViewController;
- (IBAction)dismissBlurryModal: (UIStoryboardSegue*) segue;
@end
