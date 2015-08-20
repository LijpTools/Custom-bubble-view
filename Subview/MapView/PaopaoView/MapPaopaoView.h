//
//  MapPaopaoView.h
//  Map_Demo
//
//  Created by lijunping on 15/7/27.
//  Copyright (c) 2015年 lijunping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI/BMapKit.h>
@interface MapPaopaoView : UIView
{
@protected
    CGRect _arrowRect;//箭头在本view中的frame
    CGRect _roundedRectangleRect;//圆角矩形边框在本view中得frame
    
    //自定义动作相关参数
    BOOL _animated;
    NSTimeInterval _startTime;
    NSTimeInterval _animateDuration;
    CGSize _startContentSize;//(**)
    CGSize _endContentSize;//(**)
    CADisplayLink *_displayLink;
}
#pragma mark -箭头支持的朝向，默认为any
@property (nonatomic ,assign)UIPopoverArrowDirection supportedArrowDirection;//

#pragma mark -箭头的方向
@property (nonatomic ,assign)UIPopoverArrowDirection arrowDirection; //

#pragma mark -内容视图
@property (nonatomic ,assign)UIView *contentView; //

#pragma mark -箭头指向的区域的frame
@property (nonatomic ,assign)CGRect anchorRect;//

#pragma mark -容器彈出框的區域的frame
@property(nonatomic,assign) CGRect displayArea;//

/*
  ______________
 |  ________    |
 | |  pop   |   |->displayArea
 | |content |   |
 | |        |   |
 | |__ _____|   |
 |  __V______   |
 | | touched |----->anchorRect
 | |_________|  |
 |______________|
 
 这里anchorRect的displayArea的作用是用于计算弹出框的方向以及弹出框适合的大小及方向,anchorRect的displayArea要在同
 一个坐标系中
 */
#pragma mark -contentView与背景边框的间距
@property (nonatomic ,assign)UIEdgeInsets contentMargin;//

#pragma mark -触碰点与箭头之间的间距，默认为0
@property (nonatomic ,assign)CGFloat arrowMargin; //；

#pragma mark -箭头与圆角矩形之间的偏移量，当为正值时，箭头与矩形背景框部分重叠;负值则与背景框分离，默认为0
@property (nonatomic ,assign)CGFloat arrowOffset; /**/

#pragma mark -箭头的尺寸
@property (nonatomic ,assign)CGSize arrowSize; //

#pragma mark -圆角矩形的边角圆形半径，默认为8
@property (nonatomic , assign)CGFloat cornerRadius; //；

#pragma mark -返回箭头尖尖的点在本坐标系中的坐标值
@property (nonatomic ,readonly)CGPoint arrowPoint; //

#pragma mark - 边框颜色
@property(nonatomic,strong) UIColor *borderColor;	//

#pragma mark - 边框宽度
@property(nonatomic,assign) CGFloat borderWidth;	//

#pragma mark - 渐变起始颜色，默认为nil
@property(nonatomic,strong) UIColor *tintColor;

#pragma mark - 渐变结束颜色，默认为nil,用于tintColor渐变
@property(nonatomic,strong) UIColor *tintColor2;	
@property(nonatomic)BOOL animateds;
#pragma mark - 初始化视图方法
/**
 *  初始化
 *
 *  @param contentView              内容视图
 *  @param anchorRect               箭头指向的区域的frame
 *  @param displayArea              弹出框显示的frame
 *  @param supportedArrowDirections 支持的箭头朝向
 */
-(id)initWithContentView:(UIView *)contentView
                anchorRect:(CGRect)anchorRect
               displayArea:(CGRect)displayArea
  supportedArrowDirections:(UIPopoverArrowDirection)supportedArrowDirections;

#pragma mark - 重新计算箭头朝向
-(void)refresh;

#pragma mark - 动画改变内容尺寸**
-(void)setContentSize:(CGSize)contentSize withAnimated:(BOOL)animated;

#pragma mark - 箭头的路径,用于绘制箭头
- (UIBezierPath*)arrowBorderPath;

#pragma mark - 绘制渐变
- (void)drawGradientWithContext:(CGContextRef)context gradientStartPoint:(CGPoint)gradientStartPoint gradientEndPoint:(CGPoint)gradientEndPoint;
- (void)animatedStart:(BOOL)animated;
@end
