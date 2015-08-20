//
//  MapPaopaoView.m
//  Map_Demo
//
//  Created by lijunping on 15/7/27.
//  Copyright (c) 2015年 lijunping. All rights reserved.
//

#import "MapPaopaoView.h"
#define kContentSizeW contentSize.width
#define kContentSizeH contentSize.height
#define kContentMarginL self.contentMargin.left
#define kContentMarginR self.contentMargin.right
#define kContentMarginT self.contentMargin.top
#define kContentMarginB self.contentMargin.bottom

@implementation MapPaopaoView
@synthesize animateds;
- (void)setupAlloc{
    _cornerRadius = 8;//圆角
    _arrowSize = CGSizeMake(10, 10);//箭头尺寸
    _arrowMargin = 0;//触碰点与箭头间的间距
    _arrowOffset = 0;//偏移量
    CGFloat size = 8;
    _contentMargin = UIEdgeInsetsMake(size, size, size, size);//contentView与背景框的间距（top,left.bottom,right)
    _supportedArrowDirection = UIPopoverArrowDirectionAny;//箭头方向
    
    //iOS7适配阴影风格
    self.layer.shadowOpacity = [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0?0.1:0.5;
    self.layer.shadowOffset = CGSizeMake(2, 2);
    self.layer.shadowRadius = 2;
    self.clipsToBounds = NO;
    self.userInteractionEnabled = YES;
}

-(id)init{
    self = [super init];
    if (self) {
        [self setupAlloc];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupAlloc];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupAlloc];
        [self setAnimated:YES];
    }
    return self;
}
- (void)setBorderColor:(UIColor *)borderColor{
    if(![_borderColor isEqual:borderColor]){
        _borderColor = borderColor;
        [self setNeedsDisplay];
    }
}
- (void)setBorderWidth:(CGFloat)borderWidth{
    if(_borderWidth!=borderWidth){
        _borderWidth = borderWidth;
        [self setNeedsDisplay];
    }
}
- (void)setTintColor:(UIColor *)tintColor{
    if(![_tintColor isEqual:tintColor]){
        _tintColor = tintColor;
        [self setNeedsDisplay];
    }
}
- (void)setTintColor2:(UIColor *)tintColor2{
    if (![_tintColor2 isEqual:tintColor2]) {
        _tintColor2 = tintColor2;
        [self setNeedsDisplay];
    }
}
- (void)setCornerRadius:(CGFloat)cornerRadius{
    if(_cornerRadius!=cornerRadius){
        _cornerRadius = cornerRadius;
        [self setNeedsDisplay];
    }
}
- (void)setBackgroundColor:(UIColor *)backgroundColor{
    self.tintColor = self.tintColor2 = backgroundColor;
    [super setBackgroundColor:[UIColor clearColor]];
}
- (UIColor *)backgroundColor{
    if([self.tintColor isEqual:self.tintColor2]){
        return self.tintColor;
    }else{
        return [super backgroundColor];
    }
}


#pragma mark - 初始化视图方法


-(id)initWithContentView:(UIView *)contentView
                anchorRect:(CGRect)anchorRect
               displayArea:(CGRect)displayArea
  supportedArrowDirections:(UIPopoverArrowDirection)supportedArrowDirections{

    if (self = [self initWithFrame:CGRectZero]) {
        _anchorRect = anchorRect;
        _displayArea = displayArea;
        _supportedArrowDirection =supportedArrowDirections;
        self.contentView = contentView;
        [self refresh];
    }
    return self;
}
#pragma mark -计算尺寸
-(void)refresh{
    [self calGeometry];
    [self setNeedsDisplay];
}
- (void)calGeometry{
    //计算出弹出框圆角矩形区域的尺寸,大小为contentSize加上self.contentMargin
    CGSize contentSize = self.contentView.bounds.size;
    CGSize correctedSize = CGSizeMake(contentSize.width+self.contentMargin.left+self.contentMargin.right, contentSize.height+self.contentMargin.top+self.contentMargin.bottom);
    [self determineGeometryForRoundedRectangleSize:correctedSize anchorRect:self.anchorRect displayArea:self.displayArea supportedArrowDirections:self.supportedArrowDirection];
}

- (void)drawRect:(CGRect)rect{
    [self calGeometry];
    [self drawArrowAndRoundedRectangle:_roundedRectangleRect inContext:UIGraphicsGetCurrentContext()];
}
#pragma 计算出圆角矩形区域的frame,箭头的方向,箭头的frame,self.frame
- (void)determineGeometryForRoundedRectangleSize:(CGSize)roundedRectangleSize
                                      anchorRect:(CGRect)anchorRect
                                     displayArea:(CGRect)displayArea
                        supportedArrowDirections:(UIPopoverArrowDirection)supportedArrowDirections
{
    UIPopoverArrowDirection theArrowDirection = UIPopoverArrowDirectionUp;
    //初始化箭头frme和矩形框frame,箭头方向
    _roundedRectangleRect = CGRectNull;
    _arrowRect = CGRectZero;
    _arrowDirection = UIPopoverArrowDirectionUnknown;
    
    CGFloat biggestSurface = 0.0f;
    
    CGSize arrowSize = self.arrowSize;
    //箭头在displayArea坐标系中的frame
    CGRect finalArrowFrame = CGRectZero;
    //圆角矩形背景在displayArea坐标系中的frame
    CGRect finalRoundedRectangleFrame = CGRectZero;
    //self.frame值
    CGRect finalFrame = CGRectZero;
    //值=arrowRect的中中点与_roundedRectangleRect的中心点之间的距离/_roundedRectangleRect的边长,用于当两个方向计算出来的_roundedRectangleRect面积一样时,取该值更小者为更优方向
    CGFloat distanceFactorOfCenterPoint = CGFLOAT_MAX;
    
    NSInteger directions[4] = {UIPopoverArrowDirectionUp,UIPopoverArrowDirectionDown,UIPopoverArrowDirectionLeft
        ,UIPopoverArrowDirectionRight};
    
    for (int i =0; i < 4; i ++) {
        theArrowDirection = directions[i];
        if (supportedArrowDirections & theArrowDirection) {//判断是否在可选方向中
            //箭头在displayArea中的frame
            CGRect arrowFrame = CGRectZero;
            //圆角矩形背景在displayArea坐标系中的frame
            CGRect roundBgFrame = CGRectZero;
            //箭头中间点的坐标值
            CGPoint anchorPoint = CGPointZero;
            //中点与中心点之间的距离
            CGFloat fator = CGFLOAT_MAX;
            switch (theArrowDirection) {
                 
                case UIPopoverArrowDirectionUp:
                    /*
                      ______
                     |______|
                      __/\____
                     |  pop   |
                     |content |
                     |        |
                     |________|
                     */
                    anchorPoint = CGPointMake(CGRectGetMaxX(anchorRect), CGRectGetMaxY(anchorRect));
                    if (anchorPoint.y > CGRectGetMaxY(displayArea)) {
                NSAssert(supportedArrowDirections & UIPopoverArrowDirectionDown,@"ArrowDirectionDown is needed but wasn't allowed");
                        break;
                    }
                    arrowSize = self.arrowSize;
                    arrowFrame = CGRectMake(anchorPoint.x - arrowSize.width*0.5, anchorPoint.y,
                                            arrowSize.width, arrowSize.height);
                    arrowFrame.origin.y +=self.arrowMargin;//加上偏移量
                    roundBgFrame = CGRectMake(anchorPoint.x - (roundedRectangleSize.width*0.5),
                                              CGRectGetMaxY(arrowFrame),
                                              roundedRectangleSize.width,
                                              roundedRectangleSize.height);
                    roundBgFrame.origin.y -=self.arrowOffset;
                    //如果宽度超过显示宽度,縮小
                    if(CGRectGetWidth(roundBgFrame)>CGRectGetWidth(displayArea)){
                        roundBgFrame.size.width -= CGRectGetWidth(roundBgFrame)-CGRectGetWidth(displayArea);
                    }
                    //如果背景超过右边框,背景左移
                    if(CGRectGetMaxX(roundBgFrame)>CGRectGetMaxX(displayArea)){
                        roundBgFrame.origin.x -= CGRectGetMaxX(roundBgFrame)-CGRectGetMaxX(displayArea);
                    }
                    //如果背景超过左边框,背景右移
                    if(CGRectGetMinX(roundBgFrame)<CGRectGetMinX(displayArea)){
                        roundBgFrame.origin.x += CGRectGetMinX(displayArea)-CGRectGetMinX(roundBgFrame);
                    }
                    //如果背景底部超过边框,背景減小高度
                    if(CGRectGetMaxY(roundBgFrame)>CGRectGetMaxY(displayArea)){
                        roundBgFrame.size.height -= CGRectGetMaxY(roundBgFrame)-CGRectGetMaxY(displayArea);
                        if(roundBgFrame.size.height<0){
                            roundBgFrame.size.height = 0;
                        }
                    }
                    fator = ABS(anchorPoint.x-CGRectGetMidX(roundBgFrame))/CGRectGetWidth(roundBgFrame);
                    break;
                 case UIPopoverArrowDirectionDown:
                 
                    /*
                      ________
                     |  pop   |
                     |content |
                     |        |
                     |__ _____|
                      __V__
                     |_____|
                     
                     */
                   
                    anchorPoint = CGPointMake(CGRectGetMidX(anchorRect), CGRectGetMinY(anchorRect));
                    

                    if (anchorPoint.y > CGRectGetMaxY(displayArea)) {
                        // Shift the point to the visible area
                        anchorPoint.y = CGRectGetMaxY(displayArea);
                        break;
                    }
                    arrowSize = self.arrowSize;
                    
                    arrowFrame = CGRectMake(anchorPoint.x-arrowSize.width*0.5, anchorPoint.y-arrowSize.height, arrowSize.width, arrowSize.height);
                    arrowFrame.origin.y -= self.arrowMargin;	//加上偏移量
                    roundBgFrame = CGRectMake(anchorPoint.x-(roundedRectangleSize.width*0.5), CGRectGetMinY(arrowFrame)-roundedRectangleSize.height, roundedRectangleSize.width, roundedRectangleSize.height);
                    roundBgFrame.origin.y += self.arrowOffset;
                    
                    //如果宽度超过显示宽度,缩小
                    if(CGRectGetWidth(roundBgFrame)>CGRectGetWidth(displayArea)){
                        roundBgFrame.size.width -= CGRectGetWidth(roundBgFrame)-CGRectGetWidth(displayArea);
                    }
                    //如果背景超過右边框,背景左移
                    if(CGRectGetMaxX(roundBgFrame)>CGRectGetMaxX(displayArea)){
                        roundBgFrame.origin.x -= CGRectGetMaxX(roundBgFrame)-CGRectGetMaxX(displayArea);
                    }
                    //如果背景超过左边框,背景右移
                    if(CGRectGetMinX(roundBgFrame)<CGRectGetMinX(displayArea)){
                        roundBgFrame.origin.x += CGRectGetMinX(displayArea)-CGRectGetMinX(roundBgFrame);
                    }
                    //如果背景顶部超过边框,背景減小高度
                    if(CGRectGetMinY(roundBgFrame)<CGRectGetMinY(displayArea)){
                        CGFloat diff = CGRectGetMinY(displayArea)-CGRectGetMinY(roundBgFrame);
                        roundBgFrame.origin.y += diff;
                        roundBgFrame.size.height -= diff;;
                        if(roundBgFrame.size.height<0){
                            roundBgFrame.origin.y += roundBgFrame.size.height;
                            roundBgFrame.size.height = 0;
                        }
                    }
                    fator = ABS(anchorPoint.x-CGRectGetMidX(roundBgFrame))/CGRectGetWidth(roundBgFrame);
                    break;

                    break;
                 case UIPopoverArrowDirectionLeft:
                    /*
                            ________
                      ___  |  pop   |
                     |___|< content |
                           |        |
                           |________|

                     */
                    anchorPoint = CGPointMake(CGRectGetMaxX(anchorRect), CGRectGetMidY(anchorRect));
                    
                    // Check if anchorPoint is under the displayArea (due to keyboard showing)
                    if (anchorPoint.y > CGRectGetMaxY(displayArea)) {
                        // Skip this test since we need ArrowDirectionDown in this case.
                        NSAssert(supportedArrowDirections & UIPopoverArrowDirectionDown, @"ArrowDirectionDown is needed but wasn't allowed");
                        break;
                    }
                    arrowSize = self.arrowSize;
                    
                    arrowFrame = CGRectMake(anchorPoint.x, anchorPoint.y-arrowSize.height*0.5, arrowSize.width, arrowSize.height);
                    arrowFrame.origin.x += self.arrowMargin;	//加上偏移量
                    roundBgFrame = CGRectMake(CGRectGetMaxX(arrowFrame),anchorPoint.y-roundedRectangleSize.height*0.5,roundedRectangleSize.width,roundedRectangleSize.height);
                    roundBgFrame.origin.x -= self.arrowOffset;
                    
                    //如果宽度超过显示宽度,縮小
                    if(CGRectGetHeight(roundBgFrame)>CGRectGetHeight(displayArea)){
                        roundBgFrame.size.width -= CGRectGetHeight(roundBgFrame)-CGRectGetHeight(displayArea);
                    }
                    //如果背景超过上边框,背景下移
                    if(CGRectGetMinY(roundBgFrame)<CGRectGetMinY(displayArea)){
                        roundBgFrame.origin.y += CGRectGetMinY(displayArea)-CGRectGetMinY(roundBgFrame);
                    }
                    //如果背景超过下边框,背景上移
                    if(CGRectGetMaxY(roundBgFrame)>CGRectGetMaxY(displayArea)){
                        roundBgFrame.origin.y -= CGRectGetMaxY(roundBgFrame)-CGRectGetMaxY(displayArea);
                    }
                    //如果背景右边超过边框,背景減小寬度
                    if(CGRectGetMaxX(roundBgFrame)>CGRectGetMaxX(displayArea)){
                        roundBgFrame.size.width -= CGRectGetMaxX(roundBgFrame)-CGRectGetMaxX(displayArea);
                        if(roundBgFrame.size.width<0){
                            roundBgFrame.size.width = 0;
                        }
                    }
                    fator = ABS(anchorPoint.y-CGRectGetMidY(roundBgFrame))/CGRectGetHeight(roundBgFrame);
                    break;
                 case UIPopoverArrowDirectionRight:
                    //>
                    /*
                      ________
                     |   pop  |  ____
                     | content >|____|
                     |        |
                     |________|
                     */
                    
                    anchorPoint = CGPointMake(CGRectGetMinX(anchorRect), CGRectGetMidY(anchorRect));
                    
                    if (anchorPoint.y > CGRectGetMaxY(displayArea)) {
                       
                        NSAssert((supportedArrowDirections & UIPopoverArrowDirectionDown), @"ArrowDirectionDown is needed but wasn't allowed");
                        break;
                    }
                    
                    arrowSize = self.arrowSize;
                    
                    arrowFrame = CGRectMake(anchorPoint.x-arrowSize.width, anchorPoint.y-arrowSize.height*0.5, arrowSize.width, arrowSize.height);
                    arrowFrame.origin.x -= self.arrowMargin;	//加上偏移量
                    roundBgFrame = CGRectMake(CGRectGetMinX(arrowFrame)-roundedRectangleSize.width,anchorPoint.y-roundedRectangleSize.height*0.5,roundedRectangleSize.width,roundedRectangleSize.height);
                    roundBgFrame.origin.x += self.arrowOffset;
                    
                    //如果高度超过显示宽度,縮小
                    if(CGRectGetHeight(roundBgFrame)>CGRectGetHeight(displayArea)){
                        roundBgFrame.size.width -= CGRectGetHeight(roundBgFrame)-CGRectGetHeight(displayArea);
                    }
                    //如果背景超过上边框,背景下移
                    if(CGRectGetMinY(roundBgFrame)<CGRectGetMinY(displayArea)){
                        roundBgFrame.origin.y += CGRectGetMinY(displayArea)-CGRectGetMinY(roundBgFrame);
                    }
                    //如果背景超过下边框,背景上移
                    if(CGRectGetMaxY(roundBgFrame)>CGRectGetMaxY(displayArea)){
                        roundBgFrame.origin.y -= CGRectGetMaxY(roundBgFrame)-CGRectGetMaxY(displayArea);
                    }
                    //如果背景左部超过边框,背景減小宽度
                    if(CGRectGetMinX(roundBgFrame)<CGRectGetMinX(displayArea)){
                        CGFloat diff = CGRectGetMinX(displayArea)-CGRectGetMinX(roundBgFrame);
                        roundBgFrame.origin.x += diff;
                        roundBgFrame.size.width -= diff;
                        if(roundBgFrame.size.width<0){
                            roundBgFrame.origin.x += roundBgFrame.size.width;
                            roundBgFrame.size.width = 0;
                        }
                    }
                    fator = ABS(anchorPoint.y-CGRectGetMidY(roundBgFrame))/CGRectGetHeight(roundBgFrame);
                    break;
                default:
                    break;
            }
            //计算面积最大者，弹出矩形框
            CGFloat surface = fabsf(roundBgFrame.size.width) * fabsf(roundBgFrame.size.height);
            BOOL change = NO;
            if (surface > biggestSurface) {
                change =YES;
            }else if(surface == biggestSurface){
                if (distanceFactorOfCenterPoint >fator) {
                    change =YES;
                }
            }
            if (change) {
                distanceFactorOfCenterPoint = fator;
                biggestSurface = surface;
                finalArrowFrame = arrowFrame;
                finalRoundedRectangleFrame = roundBgFrame;
                finalFrame = CGRectUnion(arrowFrame, roundBgFrame);
                _arrowDirection = theArrowDirection;
            }
        }
    }
    self.frame = finalFrame;
    CGPoint offset = self.frame.origin;
    _arrowRect = CGRectOffset(finalArrowFrame, -offset.x, -offset.y);
    _roundedRectangleRect = CGRectOffset(finalRoundedRectangleFrame, -offset.x, -offset.y);
    self.contentView.frame = self.contentRect;
    NSAssert(!CGRectEqualToRect(_roundedRectangleRect, CGRectNull), @"bgRect is null");
}
#pragma mark - 计算视图的实际显示区域
- (CGRect)contentRect {
    UIEdgeInsets contentMargin = self.contentMargin;
    CGRect rect = CGRectMake(_roundedRectangleRect.origin.x+contentMargin.left,
                             _roundedRectangleRect.origin.y+contentMargin.top,
                             _roundedRectangleRect.size.width-contentMargin.left-contentMargin.right,
                             _roundedRectangleRect.size.height-contentMargin.top-contentMargin.bottom);

    return rect;
}

#pragma mark - 箭头的路径,用于绘制箭头
- (UIBezierPath*)arrowBorderPath{
    CGRect frame = _roundedRectangleRect;
    CGFloat cornerRadius = self.cornerRadius;
    UIPopoverArrowDirection arrowDirection = _arrowDirection;
    CGRect arrowRect = _arrowRect;
    
    // render arrow
    UIBezierPath *borderPath = [UIBezierPath bezierPath];
    
    CGRect bodyFrame = frame;
    CGPoint arrowStartPoint,arrowCenterPoint,arrowEndPoint;	//剪頭起始,中間,結束點
    CGPoint centerOfRightTop = CGPointMake(CGRectGetMaxX(bodyFrame)-cornerRadius, CGRectGetMinY(bodyFrame)+cornerRadius);	//右上角圓心
    CGPoint centerOfRightBottom = CGPointMake(CGRectGetMaxX(bodyFrame)-cornerRadius, CGRectGetMaxY(bodyFrame)-cornerRadius);//右下角圓心
    CGPoint centerOfLeftBottom = CGPointMake(CGRectGetMinX(bodyFrame)+cornerRadius, CGRectGetMaxY(bodyFrame)-cornerRadius);	//左下角圓心
    CGPoint centerOfLeftTop = CGPointMake(CGRectGetMinX(bodyFrame)+cornerRadius, CGRectGetMinY(bodyFrame)+cornerRadius);	//左上角圓心
    CGPoint gradientStartPoint,gradientEndPoint;	//漸變的起始與終止點
    
    //繪製邊框時,是按順時針方向繪製的,因此arrowStartPoint與arrowEndPoint也是按順時針方向計算的
    if(arrowDirection == UIPopoverArrowDirectionUp){	//^
        /*
          ______
         |______|
          __/\____
         |  pop   |
         |content |
         |        |
         |________|
         */
        arrowCenterPoint = CGPointMake(CGRectGetMidX(arrowRect), CGRectGetMinY(arrowRect));
        
        gradientStartPoint = arrowCenterPoint;
        gradientEndPoint = CGPointMake(gradientStartPoint.x, CGRectGetMaxY(bodyFrame));
        
        CGFloat sp = (arrowRect.size.width*0.5/arrowRect.size.height)*(CGRectGetMinY(bodyFrame) - arrowCenterPoint.y);
        arrowStartPoint = CGPointMake(arrowCenterPoint.x-sp, CGRectGetMinY(bodyFrame));
        arrowEndPoint = CGPointMake(arrowCenterPoint.x+sp, CGRectGetMinY(bodyFrame));
        //進行邊境判斷
        if(arrowStartPoint.x<centerOfLeftTop.x){
            arrowStartPoint.x = centerOfLeftTop.x;
            arrowEndPoint.x = arrowStartPoint.x+2*sp;
        }
        if(arrowEndPoint.x>centerOfRightTop.x){
            arrowEndPoint.x = centerOfRightTop.x;
            arrowStartPoint.x = arrowEndPoint.x-2*sp;
        }
    }else if(arrowDirection == UIPopoverArrowDirectionDown){	//v
        /*
          ________
         |  pop   |
         |content |
         |        |
         |__ _____|
          __V__
         |_____|
         
         */
        arrowCenterPoint = CGPointMake(CGRectGetMidX(arrowRect), CGRectGetMaxY(arrowRect));
        
        gradientStartPoint = CGPointMake(arrowCenterPoint.x, CGRectGetMinY(bodyFrame));
        gradientEndPoint = arrowCenterPoint;
        
        CGFloat sp = (arrowRect.size.width*0.5/arrowRect.size.height)*(arrowCenterPoint.y-CGRectGetMaxY(bodyFrame));
        arrowStartPoint = CGPointMake(arrowCenterPoint.x+sp, CGRectGetMaxY(bodyFrame));
        arrowEndPoint = CGPointMake(arrowCenterPoint.x-sp, CGRectGetMaxY(bodyFrame));
        if(arrowStartPoint.x>centerOfRightBottom.x){
            arrowStartPoint.x = centerOfRightBottom.x;
            arrowEndPoint.x = arrowStartPoint.x-2*sp;
        }
        if(arrowEndPoint.x<centerOfLeftBottom.x){
            arrowEndPoint.x = centerOfLeftBottom.x;
            arrowStartPoint.x = arrowEndPoint.x+2*sp;
        }
        
    }else if(arrowDirection == UIPopoverArrowDirectionLeft){	//<
        /*
                ________
          ___  |  pop   |
         |___|< content |
               |        |
		       |________|
         */
        arrowCenterPoint = CGPointMake(CGRectGetMinX(arrowRect), CGRectGetMidY(arrowRect));
        
        gradientStartPoint = CGPointMake(CGRectGetMidX(bodyFrame), CGRectGetMinY(bodyFrame));
        gradientEndPoint = CGPointMake(gradientStartPoint.x, CGRectGetMaxY(bodyFrame));
        
        CGFloat sp = (arrowRect.size.height*0.5/arrowRect.size.width)*(CGRectGetMinX(bodyFrame)-arrowCenterPoint.x);
        arrowStartPoint = CGPointMake(CGRectGetMinX(bodyFrame), arrowCenterPoint.y+sp);
        arrowEndPoint = CGPointMake(CGRectGetMinX(bodyFrame), arrowCenterPoint.y-sp);
        if(arrowStartPoint.y>centerOfLeftBottom.y){
            arrowStartPoint.y = centerOfLeftBottom.y;
            arrowEndPoint.y = arrowStartPoint.y-2*sp;
        }
        if(arrowEndPoint.y<centerOfLeftTop.y){
            arrowEndPoint.y = centerOfLeftTop.y;
            arrowStartPoint.y = arrowEndPoint.y+2*sp;
        }
    }else if(arrowDirection == UIPopoverArrowDirectionRight){	//>
        /*
          ________
         |   pop  |  ____
         | content >|____|
         |        |
         |________|
         */
        arrowCenterPoint = CGPointMake(CGRectGetMaxX(arrowRect), CGRectGetMinY(arrowRect));
        
        gradientStartPoint = CGPointMake(CGRectGetMidX(bodyFrame), CGRectGetMinY(bodyFrame));
        gradientEndPoint = CGPointMake(gradientStartPoint.x, CGRectGetMaxY(bodyFrame));
        
        CGFloat sp = (arrowRect.size.height*0.5/arrowRect.size.width)*(arrowCenterPoint.x-CGRectGetMaxX(bodyFrame));
        arrowStartPoint = CGPointMake(CGRectGetMaxX(bodyFrame), arrowCenterPoint.y-sp);
        arrowEndPoint = CGPointMake(CGRectGetMaxX(bodyFrame), arrowCenterPoint.y+sp);
        if(arrowStartPoint.y<centerOfRightTop.y){
            arrowStartPoint.y = centerOfRightTop.y;
            arrowEndPoint.y = arrowStartPoint.y+2*sp;
        }
        if(arrowEndPoint.y>centerOfRightBottom.y){
            arrowEndPoint.y = centerOfRightBottom.y;
            arrowStartPoint.y = arrowEndPoint.y-2*sp;
        }
    }else{
    }
    
    //繪製外框路徑
    CGFloat angle = 0;
    
    [borderPath moveToPoint:CGPointMake(CGRectGetMaxX(bodyFrame), centerOfRightTop.y)];
    if(arrowDirection==UIPopoverArrowDirectionRight){	//>
        [borderPath addLineToPoint:arrowStartPoint];
        [borderPath addLineToPoint:arrowCenterPoint];
        [borderPath addLineToPoint:arrowEndPoint];
    }
    [borderPath addLineToPoint:CGPointMake(CGRectGetMaxX(bodyFrame), centerOfRightBottom.y)];
    [borderPath addArcWithCenter:centerOfRightBottom radius:cornerRadius startAngle:angle endAngle:(angle+M_PI_2) clockwise:YES];
    angle+=M_PI_2;
    if(arrowDirection==UIPopoverArrowDirectionDown){	//v
        [borderPath addLineToPoint:arrowStartPoint];
        [borderPath addLineToPoint:arrowCenterPoint];
        [borderPath addLineToPoint:arrowEndPoint];
    }
    [borderPath addLineToPoint:CGPointMake(centerOfLeftBottom.x, CGRectGetMaxY(bodyFrame))];
    [borderPath addArcWithCenter:centerOfLeftBottom radius:cornerRadius startAngle:angle endAngle:(angle+M_PI_2) clockwise:YES];
    angle+=M_PI_2;
    if(arrowDirection==UIPopoverArrowDirectionLeft){	//<
        [borderPath addLineToPoint:arrowStartPoint];
        [borderPath addLineToPoint:arrowCenterPoint];
        [borderPath addLineToPoint:arrowEndPoint];
    }
    [borderPath addLineToPoint:CGPointMake(CGRectGetMinX(bodyFrame), centerOfLeftTop.y)];
    [borderPath addArcWithCenter:centerOfLeftTop radius:cornerRadius startAngle:angle endAngle:(angle+M_PI_2) clockwise:YES];
    angle+=M_PI_2;
    if(arrowDirection==UIPopoverArrowDirectionUp){	//^
        [borderPath addLineToPoint:arrowStartPoint];
        [borderPath addLineToPoint:arrowCenterPoint];
        [borderPath addLineToPoint:arrowEndPoint];
    }
    [borderPath addLineToPoint:CGPointMake(centerOfRightTop.x, CGRectGetMinY(bodyFrame))];
    [borderPath addArcWithCenter:centerOfRightTop radius:cornerRadius startAngle:angle endAngle:(angle+M_PI_2) clockwise:YES];
    angle+=M_PI_2;
    [borderPath closePath];
    
    [self.borderColor set];
    borderPath.lineWidth = self.borderWidth;
    borderPath.lineJoinStyle = kCGLineJoinRound;
    borderPath.lineCapStyle = kCGLineCapRound;
    return borderPath;
}
- (void)layoutSubviews{
    self.contentView.frame = self.contentRect;
}

#pragma mark - 绘制箭头与圆角矩形边框
- (void)drawArrowAndRoundedRectangle:(CGRect)frame inContext:(CGContextRef)context{
    UIPopoverArrowDirection arrowDirection = _arrowDirection;
    CGRect arrowRect = _arrowRect;
    
    // render arrow
    UIBezierPath *borderPath = [self arrowBorderPath];
    
    // render body
    [borderPath addClip];
    
    CGRect bodyFrame = frame;
    CGPoint arrowCenterPoint;	//剪頭起始,中間,结束点
    CGPoint gradientStartPoint,gradientEndPoint;	//渐变的起始与终止点
    
    //繪製邊框時,是按順時針方向繪製的,因此arrowStartPoint與arrowEndPoint也是按順時針方向計算的
    if(arrowDirection == UIPopoverArrowDirectionUp){	//^
        
        arrowCenterPoint = CGPointMake(CGRectGetMidX(arrowRect), CGRectGetMinY(arrowRect));
        
        gradientStartPoint = arrowCenterPoint;
        gradientEndPoint = CGPointMake(gradientStartPoint.x, CGRectGetMaxY(bodyFrame));
    }else if(arrowDirection == UIPopoverArrowDirectionDown){	//v
        
        arrowCenterPoint = CGPointMake(CGRectGetMidX(arrowRect), CGRectGetMaxY(arrowRect));
        
        gradientStartPoint = CGPointMake(arrowCenterPoint.x, CGRectGetMinY(bodyFrame));
        gradientEndPoint = arrowCenterPoint;
    }else if(arrowDirection == UIPopoverArrowDirectionLeft){	//<
        
        arrowCenterPoint = CGPointMake(CGRectGetMinX(arrowRect), CGRectGetMidY(arrowRect));
        
        gradientStartPoint = CGPointMake(CGRectGetMidX(bodyFrame), CGRectGetMinY(bodyFrame));
        gradientEndPoint = CGPointMake(gradientStartPoint.x, CGRectGetMaxY(bodyFrame));
    }else if(arrowDirection == UIPopoverArrowDirectionRight){	//>
        
        arrowCenterPoint = CGPointMake(CGRectGetMaxX(arrowRect), CGRectGetMinY(arrowRect));
        
        gradientStartPoint = CGPointMake(CGRectGetMidX(bodyFrame), CGRectGetMinY(bodyFrame));
        gradientEndPoint = CGPointMake(gradientStartPoint.x, CGRectGetMaxY(bodyFrame));
    }else{
    }
    
    //绘制渐变
    [self drawGradientWithContext:context gradientStartPoint:gradientStartPoint gradientEndPoint:gradientEndPoint];
    
    //绘制边框
    [borderPath stroke];
}
#pragma mark - 绘制渐变色
- (void)drawGradientWithContext:(CGContextRef)context gradientStartPoint:(CGPoint)gradientStartPoint gradientEndPoint:(CGPoint)gradientEndPoint{
    //h绘制渐变色
    UIColor *tintColor = self.tintColor;
    UIColor *tintColor2 = self.tintColor2;
    if(tintColor||tintColor2){
        CGFloat R0 = 0, G0 = 0, B0 = 0, A0 = 1;
        CGFloat R1 = 0, G1 = 0, B1 = 0, A1 = 1;
        
        if(tintColor){
            [tintColor getRed:&R0 green:&G0 blue:&B0 alpha:&A0];
        }
        if(tintColor2){
            [tintColor2 getRed:&R1 green:&G1 blue:&B1 alpha:&A1];
        }
        
        const CGFloat locations[] = {0,1};
        const CGFloat components[] = {
            R0,G0,B0,A0,
            R1,G1,B1,A1
        };
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, sizeof(locations)/sizeof(locations[0]));
        
        CGContextDrawLinearGradient(context, gradient, gradientStartPoint, gradientEndPoint, 0);
        
        CGColorSpaceRelease(colorSpace);
        CGGradientRelease(gradient);
    }
}
- (void)setContentView:(UIView *)contentView{
    if (contentView != _contentView) {
        _contentView =contentView;
        _contentView.frame = self.contentRect;
        [self addSubview:_contentView];
    }
}
- (CGSize)contentSize{

    return self.contentRect.size;
}
- (CGPoint)arrowPoint{
    CGPoint point = CGPointZero;
    switch (_arrowDirection) {
        case UIPopoverArrowDirectionDown:	//v
            point = CGPointMake(CGRectGetMidX(_arrowRect), CGRectGetMaxY(_arrowRect));
            break;
        case UIPopoverArrowDirectionUp:		//^
            point = CGPointMake(CGRectGetMidX(_arrowRect), CGRectGetMinY(_arrowRect));
            break;
        case UIPopoverArrowDirectionLeft:	//<
            point = CGPointMake(CGRectGetMinX(_arrowRect), CGRectGetMidY(_arrowRect));
            break;
        case UIPopoverArrowDirectionRight:	//>
            point = CGPointMake(CGRectGetMaxX(_arrowRect), CGRectGetMidY(_arrowRect));
            break;
        default:
            break;
    }
    return point;
}
#pragma mark -动画
- (void)setContentSize:(CGSize)contentSize withAnimated:(BOOL)animated{
    CGRect contentViewBounds = self.contentView.bounds;
    if(CGSizeEqualToSize(contentSize, contentViewBounds.size)){	//尺寸沒有變化
        return;
    }
    contentViewBounds.size = contentSize;
    if(animated){
        CGRect oldContentViewBounds = self.contentView.bounds;
        //計算出動畫後的frame
        self.contentView.bounds = contentViewBounds;
        [self refresh];
        CGRect newContentViewBounds = self.contentView.bounds;
        
        //還原回去
        self.contentView.bounds = oldContentViewBounds;
        [self refresh];
        
        if(!_animated){
            _animated = YES;
            if(_animateDuration==0) _animateDuration = 0.2;	//總時間是0.2秒
            _startContentSize = self.contentView.bounds.size;
            _endContentSize = newContentViewBounds.size;
            _startTime = [[NSDate date] timeIntervalSince1970];
            _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawView:)];
            [_displayLink setFrameInterval:1];
            [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        }
    }else{
        self.contentView.bounds = contentViewBounds;
        [self refresh];
    }
    
}
/**
 *	使用动画时，进行绘图操作
 */
- (void)drawView:(CADisplayLink *)displayLink{
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval duration = timestamp-_startTime;
    NSTimeInterval total = _animateDuration;
    CGFloat perent = duration/total;
    CGRect bounds = self.contentView.bounds;
    bounds.size = perent>=1?_endContentSize:CGSizeMake(_startContentSize.width+(_endContentSize.width-_startContentSize.width)*perent, _startContentSize.height+(_endContentSize.height-_startContentSize.height)*perent);
    self.contentView.bounds = bounds;
    [self refresh];
    if(perent>1){
        [self stopAnimate];
    }
}
- (void)setAnimated:(BOOL)animateds{
    
    if (animateds) {
        
        [UIView beginAnimations:@"animated" context:nil];
        [UIView setAnimationDuration:2.0f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDelegate:self];
        
        [UIView commitAnimations];

    }
       NSLog(@"success");
}
/**
 *	停止动画
 */
- (void)stopAnimate{
    [_displayLink invalidate];
    _animated = NO;
}
- (void)dealloc{
    //	NSLog(@"dealloc:%@",self);
}

@end
