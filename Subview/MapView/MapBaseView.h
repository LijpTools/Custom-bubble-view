//
//  MapBaseView.h
//  Map_Demo
//
//  Created by lijunping on 15/7/24.
//  Copyright (c) 2015年 lijunping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI/BMapKit.h>
#define kNearProject_normal @"near_project_normal"
#define kNearProject_press @"near_project_press"
#define kCompass_normal @"compass_normal"
#define kCompass_heightlight @"compass_heighlight"
@protocol MapBaseViewDelegate <NSObject>

#pragma mark - 当前位置定位
-(void)showUserLocations;

#pragma 搜索周边活动事件
-(void)shouRoundProject;

@end

@interface MapBaseView : UIView
@property (weak, nonatomic)BMKMapView *map;

@property (weak ,nonatomic)id<MapBaseViewDelegate>delegate;
@property (nonatomic, weak)UITextField *textFiled;
#pragma mark - 是否显示周边活动的按钮
- (void)shouRoundButton;

#pragma mark - 是否显示定位的按钮
- (void)showUserLocationBtn;

#pragma mark - 搜索周边活动事件
- (void)searchRoundProject;

#pragma mark - 当前位置定位
- (void)moveToUserLocation;

#pragma mark - mapView的delegate
- (void)setMApDelegate;

#pragma mark - 释放mapView的delegate
- (void)setMapDelegateForDelloc;

-(id)initWithFrame:(CGRect)frame withShareAciton:(SEL)shareAction;
@end
