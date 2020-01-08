#import <UIKit/UIKit.h>

typedef enum
{
    VerticalAlignmentTop = 0, // default
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} VerticalAlignment;

@interface SOLabel : UILabel

@property (nonatomic, readwrite) VerticalAlignment verticalAlignment;

@end