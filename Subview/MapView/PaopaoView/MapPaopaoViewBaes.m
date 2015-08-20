//
//  MapPaopaoViewBaes.m
//  Map_Demo
//
//  Created by lijunping on 15/7/27.
//  Copyright (c) 2015年 lijunping. All rights reserved.
//

#import "MapPaopaoViewBaes.h"
//test
#import "AppDelegate.h"

@interface MapPaopaoViewBaes ()

@end


@implementation MapPaopaoViewBaes

-(id)initWithAnnotation:(id<BMKAnnotation>)annotation
        reuseIdentifier:(NSString *)reuseIdentifier
        withContentView:(PaopaoContentView *)contentView
{
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        self.canShowCallout = NO;
        self.backgroundColor = [UIColor whiteColor];
        _calloutView = [[MapPaopaoView alloc]initWithFrame:CGRectZero];
        _calloutView.borderWidth =1;
        _calloutView.borderColor = [UIColor grayColor];
        _calloutView.backgroundColor = [UIColor whiteColor];
        _calloutView.supportedArrowDirection = UIPopoverArrowDirectionDown;
        _contentViews = contentView;
        _calloutView.contentView = _contentViews;
        
        self.pinColor = BMKPinAnnotationColorPurple;
        self.backgroundColor = [UIColor clearColor];
        self.contentViews.bounds = CGRectMake(0, 0, 200, 60);
           }
    return self;
}
-(id)init{
    self = [super self];
    if (self) {
        
    }
    return self;
}
-(void)setContentViews:(UIView *)contentViews{
    _contentViews = contentViews;
}

- (BMKMapView *)mapView{
    UIView *outerView = self.superview;
    while (outerView!=nil) {
        if([outerView isKindOfClass:[BMKMapView class]]){
            return (BMKMapView *)outerView;
        }else{
            outerView = outerView.superview;
        }
    }
    return nil;
}
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    BOOL inside = [super pointInside:point withEvent:event];
    if(!inside){
        //判断是否点击弹出框
        if(self.calloutView.superview){
            CGPoint pointInCalloutView = [self convertPoint:point toView:self.calloutView];
            inside = [self.calloutView pointInside:pointInCalloutView withEvent:event];
        }
    }
    return inside;
}


/**
 *  以下均为弹出收回泡泡框
 */
/**
 *	获取弹出框的截图,用于动画
 */
- (UIImage *)imageSpotWithCalloutView{
    UIGraphicsBeginImageContext(self.calloutView.bounds.size);
    [self.calloutView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}

/**
 *	刷新弹出框
 */
- (void)refreshCalloutView{
    BMKMapView *mapView = self.mapView;
    CGRect anchorRect = self.bounds;
    //self.calloutOffset默认值为(-8,0),即使设置了self.image值,因此如果出現箭头
    anchorRect.origin.x += self.calloutOffset.x;
    anchorRect.origin.y += self.calloutOffset.y;
    
    //进行显示区域的微调
    CGRect displayArea = [mapView convertRect:mapView.bounds toView:self];
    CGFloat space = 10;	//边距
    displayArea = CGRectInset(displayArea, space, space);
    displayArea.origin.y = -NSIntegerMax/2;
    displayArea.size.height = NSIntegerMax;
    
    CGRect frameInMap = self.frame;
    CGRect mapViewBounds = mapView.bounds;
    if(CGRectGetMinX(frameInMap)-space<CGRectGetMinX(mapViewBounds)){
        displayArea.origin.x -= CGRectGetMinX(mapViewBounds)-CGRectGetMinX(frameInMap)+space;
    }else if(CGRectGetMaxX(frameInMap)+space>CGRectGetMaxX(mapViewBounds)){
        displayArea.origin.x += CGRectGetMaxX(frameInMap)+space-CGRectGetMaxX(mapViewBounds);
    }
    
    self.calloutView.anchorRect = anchorRect;
    self.calloutView.displayArea = displayArea;
    [self.calloutView refresh];
}
/**
 *	调整外层mapview的显示region,使得弹出框全部显示
 */
- (BMKCoordinateRegion)adjustMapViewRegion{
    BMKMapView *mapView = [self mapView];
    CGRect calloutViewFrameInMap = [mapView convertRect:self.calloutView.frame fromView:self];
    CGRect mapViewBounds = mapView.bounds;
    BMKCoordinateRegion region = mapView.region;
    BMKCoordinateRegion deta;
    CGFloat space = 10;	//边距
    if(CGRectGetMinX(calloutViewFrameInMap)<CGRectGetMinX(mapViewBounds)){
        deta = [mapView convertRect:CGRectMake(0, 0, space+CGRectGetMinX(mapViewBounds)-CGRectGetMinX(calloutViewFrameInMap), 1) toRegionFromView:self];
        region.center.longitude -= deta.span.longitudeDelta;
    }else if(CGRectGetMaxX(calloutViewFrameInMap)>CGRectGetMaxX(mapViewBounds)){
        deta = [mapView convertRect:CGRectMake(0, 0, space+CGRectGetMaxX(calloutViewFrameInMap)-CGRectGetMaxX(mapViewBounds), 1) toRegionFromView:self];
        region.center.longitude += deta.span.longitudeDelta;
    }
    if(CGRectGetMinY(calloutViewFrameInMap)<CGRectGetMinY(mapViewBounds)){
        deta = [mapView convertRect:CGRectMake(0, 0, 1,space+CGRectGetMinY(mapViewBounds)-CGRectGetMinY(calloutViewFrameInMap)) toRegionFromView:self];
        region.center.latitude += deta.span.latitudeDelta;
    }else if(CGRectGetMaxY(calloutViewFrameInMap)>CGRectGetMaxY(mapViewBounds)){
        deta = [mapView convertRect:CGRectMake(0, 0, 1,space+CGRectGetMaxY(calloutViewFrameInMap)-CGRectGetMaxY(mapViewBounds)) toRegionFromView:self];
        region.center.latitude -= deta.span.latitudeDelta;
    }
    return region;
}
#pragma mark - 取消显示弹出框
-(void)dismissContentView{
    if(self.calloutView.superview){
        CGPoint point = self.calloutView.arrowPoint;
        CGRect endFrame = (CGRect){[self convertPoint:point fromView:self.calloutView],CGSizeZero};
        UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:self.calloutView.frame];
        tmpImageView.image = [self imageSpotWithCalloutView];
        [self.calloutView removeFromSuperview];
        [self addSubview:tmpImageView];
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            tmpImageView.frame = endFrame;
        } completion:^(BOOL finished) {
            [tmpImageView removeFromSuperview];
        }];
    }
}
#pragma mark - 显示弹出框
-(void)showContentView{
    NSTimeInterval duration = 0.3;
    if(!self.calloutView.superview){
        [self refreshCalloutView];
        [self addSubview:self.calloutView];
        
        CGPoint point = self.calloutView.arrowPoint;
        CGRect startFrame = (CGRect){[self convertPoint:point fromView:self.calloutView],CGSizeZero};
        UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:startFrame];
        tmpImageView.image = [self imageSpotWithCalloutView];
        [self addSubview:tmpImageView];
        self.calloutView.hidden = YES;
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            tmpImageView.frame = self.calloutView.frame;
        } completion:^(BOOL finished) {
            [tmpImageView removeFromSuperview];
            self.calloutView.hidden = NO;
        }];
    }
}



@end
