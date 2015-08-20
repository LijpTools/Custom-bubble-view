//
//  MapPaopaoViewBaes.h
//  Map_Demo
//
//  Created by lijunping on 15/7/27.
//  Copyright (c) 2015年 lijunping. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <BaiduMapAPI/BMapKit.h>
#import "MapPaopaoView.h"
#import "PaopaoContentView.h"

@interface MapPaopaoViewBaes : BMKPinAnnotationView

@property(nonatomic ,readonly)MapPaopaoView *calloutView;
@property(nonatomic ,assign)UIView *contentViews;
@property(nonatomic ,retain)BMKMapView *mapView;
@property(nonatomic ,readwrite)NSTimeInterval duration;

-(id)initWithAnnotation:(id<BMKAnnotation>)annotation
        reuseIdentifier:(NSString *)reuseIdentifier
        withContentView:(PaopaoContentView *)contentView;
#pragma mark - 显示弹框
- (void)showContentView;
#pragma mark - 隐藏弹框
- (void)dismissContentView;
@end
