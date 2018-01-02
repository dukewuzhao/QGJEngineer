

#import <UIKit/UIKit.h>

@interface UIImage (HC)

/** 转换iOS6/7所用图片 */
+ (UIImage *)imageWithName:(NSString *)imageName;

/** 拉伸不变形图片 */
+ (UIImage *)resizableImageWithName:(NSString *)imageName;

/** 圆形头像 */
+ (UIImage *)circleImageWithName:(NSString *)name borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;


@end
