
#import "UIImage+HC.h"

@implementation UIImage (HC)

+ (UIImage *)imageWithName:(NSString *)imageName
{
    UIImage *myImage = nil;
    
    if (iOS7) {
        NSString *newStr = [imageName stringByAppendingString:@"_os7"];
        myImage = [UIImage imageNamed:newStr];
    }
    if (myImage == nil) {
        myImage = [UIImage imageNamed:imageName];
    }
    
    return myImage;
}

+ (UIImage *)resizableImageWithName:(NSString *)imageName
{
    UIImage *newImage = [self imageWithName:imageName];
    
    // 设置拉伸尺寸
    CGFloat left = newImage.size.width * 0.5;
    CGFloat right = newImage.size.height * 0.5;
    return [newImage stretchableImageWithLeftCapWidth:left topCapHeight:right];
}

+ (UIImage *)circleImageWithName:(NSString *)name borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor
{
    // 加载原图
    UIImage *oldImage = [UIImage imageNamed:name];
    
    // 开启上下文
    CGFloat imageW = oldImage.size.width + 2 * borderWidth;
    CGFloat imageH = oldImage.size.height + 2 * borderWidth;
    CGSize imageSize = CGSizeMake(imageW, imageH);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    
    // 取得当前的上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 画边框(大圆)
    [borderColor set];
    CGFloat bigRadius = imageW * 0.5; // 大圆半径
    CGFloat centerX = bigRadius; // 圆心
    CGFloat centerY = bigRadius;
    CGContextAddArc(ctx, centerX, centerY, bigRadius, 0, M_PI * 2, 0);
    CGContextFillPath(ctx); // 画圆
    
    // 小圆
    CGFloat smallRadius = bigRadius - borderWidth;
    CGContextAddArc(ctx, centerX, centerY, smallRadius, 0, M_PI * 2, 0);
    // 裁剪
    CGContextClip(ctx);
    
    // 画图
    [oldImage drawInRect:CGRectMake(borderWidth, borderWidth, oldImage.size.width, oldImage.size.height)];
    
    // 取图
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 结束上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
