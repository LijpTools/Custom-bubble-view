//
//  MapBaseView.m
//  Map_Demo
//
//  Created by lijunping on 15/7/24.
//  Copyright (c) 2015年 lijunping. All rights reserved.
//

#import "MapBaseView.h"
#import "LYXTools.h"
#define kMapViewSpaceTop 12
#define KMapViewSpaceLeft 10
#define KMapViewsearchRoundBtnWidth 90
#define KMapViewsearchRoundBtnHeight 35
#define KMapViewUserLocationBtnHeight 33
#define KMapViewUserLocationBtnwidth 33
#define KMapUserLocationBtnSpaceBottom 25

@interface MapBaseView ()<BMKMapViewDelegate>
{
    SEL _shareAction;
    CGFloat _width;
    CGFloat _height;
    CGFloat _currentHeight;
    UIButton * _peripheralProject;
    UIButton *_userLocationBtn;
    BMKMapView *_mapView;
}


@end

@implementation MapBaseView

-(id)initWithFrame:(CGRect)frame withShareAciton:(SEL)shareAction{
    self = [super initWithFrame:frame];
    if (self) {
        _shareAction = shareAction;
        [self initUI];
          }
    return self;
}

- (void)initUI{
    _mapView = [[BMKMapView alloc]init];
    //设置地图级别
    _mapView.zoomLevel =17;
    //定位
    //开启定位视图
    _mapView.userTrackingMode = BMKUserTrackingModeFollow;
    _mapView.showsUserLocation = YES;
    [self addSubview:_mapView];
    self.map = _mapView;
    
    //定位按钮
    _userLocationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_userLocationBtn setBackgroundImage:[UIImage getImageWithName:kCompass_normal]
                                forState:UIControlStateNormal];
    [_userLocationBtn setBackgroundImage:[UIImage getImageWithName:kCompass_heightlight]
                                forState:UIControlStateHighlighted];

    [_userLocationBtn addTarget:self action:@selector(moveToUserLocation)
               forControlEvents:UIControlEventTouchUpInside];
     [self addSubview:_userLocationBtn];
    
    //周边工程按钮
    _peripheralProject = [UIButton buttonWithType:UIButtonTypeCustom];
    [_peripheralProject setBackgroundImage:[UIImage getImageWithName:kNearProject_normal]
                                  forState:UIControlStateNormal];
    [_peripheralProject setBackgroundImage:[UIImage getImageWithName:kNearProject_press]
                                  forState:UIControlStateHighlighted];
    [_peripheralProject addTarget:self.superview action:_shareAction
                 forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_peripheralProject];

   


    
  }
- (void)layoutSubviews{
    [super layoutSubviews];
    _width = self.frame.size.width;
    _height = self.frame.size.height;
    _currentHeight = 0;
    [_mapView setFrame:0 y:0 w:_width h:_height];
    _currentHeight +=_height - KMapViewUserLocationBtnHeight - KMapUserLocationBtnSpaceBottom;
    [_userLocationBtn setFrame:KMapViewSpaceLeft
                             y:_currentHeight
                             w:KMapViewUserLocationBtnwidth
                             h:KMapViewUserLocationBtnHeight];
   [ _peripheralProject setFrame:_width-KMapViewsearchRoundBtnWidth
                               y:_currentHeight
                               w:KMapViewsearchRoundBtnWidth
                               h:KMapViewsearchRoundBtnHeight];
}
#pragma mark - 当前位置定位
- (void)moveToUserLocation
{
    if([self.delegate respondsToSelector:@selector(showUserLocations)])
    {
        [self.delegate showUserLocations];
    }
}


#pragma mark - mapView的delegate
- (void)setMApDelegate{
    [self.map viewWillAppear];
    self.map.delegate = self;
    
}
#pragma mark - 释放mapView的delegate
- (void)setMapDelegateForDelloc{
    [self.map viewWillDisappear];
    self.map.delegate = nil;
}
@end
