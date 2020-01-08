//
//  VAProgressCircle.h
//  VAProgressCircleExample
//
//  Created by Malleo, Mitch on 4/22/15.
//  Copyright (c) 2015 Mitchell Malleo. All rights reserved.
//

#import <UIKit/UIKit.h>

#define VADefaultGreen [UIColor colorWithRed:35.0/255.0 green:177.0/255.0 blue:70.0/255.0 alpha:1.0f]
#define VADefaultBlue [UIColor colorWithRed:32.0/255.0 green:149.0/255.0 blue:242.0/255.0 alpha:1.0f]

@class VAProgressCircle;

@protocol VAProgressCircleDelegate <NSObject>

- (void)progressCircle:(VAProgressCircle *)circle willAnimateToProgress:(int)progress;
- (void)progressCircle:(VAProgressCircle *)circle didAnimateToProgress:(int)progress;

@end

typedef void (^VAProgressCircleProgressCompletionBlock)(int progress, BOOL isAnimationCompleteForProgress);

typedef NS_ENUM(NSInteger, VAProgressCircleColorTransitionType){
    VAProgressCircleColorTransitionTypeGradual,
    VAProgressCircleColorTransitionTypeNone
};

typedef NS_ENUM(NSInteger, VAProgressCircleRotationDirection){
    VAProgressCircleRotationDirectionClockwise,
    VAProgressCircleRotationDirectionCounterClockwise
};

@interface VAProgressCircle : UIView <UIApplicationDelegate>

- (instancetype)initWithFrame:(CGRect)frame;
- (void)setProgress:(int)progress;

- (void)setColor:(UIColor *)color;
- (void)setTransitionColor:(UIColor *)transitionColor;
- (void)setColor:(UIColor *)color withHighlightColor:(UIColor *)highlightColor;
- (void)setTransitionColor:(UIColor *)color withHighlightTransitionColor:(UIColor *)highlightColor;

@property float animationSpeed;

@property (strong, nonatomic) UIColor *circleColor;
@property (strong, nonatomic) UIColor *accentLineColor;
@property (strong, nonatomic) UIColor *numberLabelColor;
@property (strong, nonatomic) UIColor *circleHighlightColor;
                        
@property (strong, nonatomic) UIColor *circleTransitionColor;
@property (strong, nonatomic) UIColor *accentLineTransitionColor;
@property (strong, nonatomic) UIColor *numberLabelTransitionColor;
@property (strong, nonatomic) UIColor *circleHighlightTransitionColor;

@property BOOL shouldShowAccentLine;
@property BOOL shouldShowFinishedAccentCircle;
@property BOOL shouldHighlightProgress;
@property BOOL shouldNumberLabelTransition;

@property (nonatomic) VAProgressCircleColorTransitionType transitionType;
@property (nonatomic) VAProgressCircleRotationDirection rotationDirection;

@property (copy, nonatomic) VAProgressCircleProgressCompletionBlock progressBlock;

@property (weak, nonatomic) id<VAProgressCircleDelegate> delegate;

@end
