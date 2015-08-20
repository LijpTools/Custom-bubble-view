//
//  MapView.m
//  TGProject
//
//  Created by lijunping on 15/8/17.
//  Copyright (c) 2015年 TG. All rights reserved.
//

#import "TGMapView.h"
#import "MapBaseView.h"
#import "AnnonModel.h"
#import "PaopaoContentView.h"
#import "MapPaopaoViewBaes.h"
@interface TGMapView ()<BMKMapViewDelegate,MapBaseViewDelegate,BMKLocationServiceDelegate>
{
    SEL _shareView;
    SEL _toProject;
    CGFloat _width;
    CGFloat _height;
    CGFloat _currentHeight;
    MapBaseView *_mapBaseView;
    UITapGestureRecognizer *_mTap;
   
    BMKUserLocation *_userLocation;
    PaopaoContentView *_contentView;
    MapPaopaoViewBaes *_annotationPop;
    NSMutableArray *_modelArrays;
    id<BMKAnnotation> _annotation;
    
    NSTimer *_testTimer;
    NSInteger _testFlag;
    int lastI;
}
@property (nonatomic ,strong) BMKLocationService *locationService;
@property (nonatomic ,weak)BMKMapView *mapView;
@end

@implementation TGMapView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self OpenService];
        [self initMapUI];
    }return self;
}

- (id)initWithFrame:(CGRect)frame turnToShare:(SEL)shareView toProjectView:(SEL)toProjectView{
    self = [super initWithFrame:frame];
    if (self) {
        _toProject = toProjectView;
        _shareView = shareView;
        [self OpenService];
        [self initMapUI];
        [self setAnnotation];
    }
    return self;
}

//初始化地图
- (void)initMapUI{
    _mapBaseView = [[MapBaseView alloc]initWithFrame:CGRectZero
                                     withShareAciton:_shareView];
    _mapBaseView.delegate = self;
    _mapView = _mapBaseView.map;
    _mapView.delegate = self;
    //时间控制器
    _testTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f
                                                  target:self
                                                selector:@selector(timerAction:)
                                                userInfo:nil
                                                 repeats:YES];
    lastI = 0;
    [self addSubview:_mapBaseView];
    
}
- (void)OpenService{
    _locationService = [[BMKLocationService alloc]init];
    [_locationService startUserLocationService];
    _locationService.delegate = self;
    [BMKLocationService setLocationDistanceFilter:100.f];
    [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    
}

#pragma mark - UITapGestureRecognize 触摸事件,让用户自选大头针时有充足时间看信息

- (void)tapPress:(UITapGestureRecognizer *)gestureRecognizer{
    _testFlag = 2;
    NSLog(@"testFlag %ld",_testFlag);
}

#pragma mark /////Test_Annotation
- (void)setModel{
    _modelArrays = [NSMutableArray array];
    AnnonModel *model = [[AnnonModel alloc]init];
    model.latitude = 23.123 + 0.01;
    model.longitude = 113.316;
    [_modelArrays addObject:model];
    
    AnnonModel *model1 = [[AnnonModel alloc]init];
    model1.latitude = 23.123;
    model1.longitude = 113.316 +0.01;
    [_modelArrays addObject:model1];
    
    AnnonModel *model2 = [[AnnonModel alloc]init];
    model2.latitude = 23.123 + 0.01;
    model2.longitude = 113.316 +0.01;
    [_modelArrays addObject:model2];
    
    AnnonModel *model3 = [[AnnonModel alloc]init];
    model3.latitude = 23.123;
    model3.longitude = 113.316;
    [_modelArrays addObject:model3];
    
    AnnonModel *model4 = [[AnnonModel alloc]init];
    model4.latitude = 23.123 + 0.005;
    model4.longitude = 113.316;
    [_modelArrays addObject:model4];
    
    AnnonModel *model5 = [[AnnonModel alloc]init];
    model5.latitude = 23.123 ;
    model5.longitude = 113.316 + 0.005;
    [_modelArrays addObject:model5];

    
}
- (void)setAnnotation{
    [self setModel];
    NSMutableArray * arr = [NSMutableArray array];
    for (int i = 0; i <_modelArrays.count; i++) {
        AnnonModel * model = _modelArrays[i];
        BMKPointAnnotation *annotationPoin = [[BMKPointAnnotation alloc]init];
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = model.latitude;
        coordinate.longitude = model.longitude;
        annotationPoin.coordinate = coordinate;
        annotationPoin.title = [NSString stringWithFormat:@"%d",i];
        annotationPoin.subtitle = [NSString stringWithFormat:@"%d",i];
        
        [arr addObject:annotationPoin];
    }
    [_mapView addAnnotations:arr];
    
    

}
-(void)layoutSubviews{
    [super layoutSubviews];
    _width = self.frame.size.width;
    _height = self.frame.size.height;
    [_mapBaseView setFrame:0 y:0 w:_width h:_height];
    
#warning mark - Test
    
    [_contentView setFrame:0 y:0 w:180 h:40];
}
#pragma mark - MapBaseVipDelegate
- (void)showUserLocations{
    [_mapView setCenterCoordinate:_userLocation.location.coordinate animated:YES];
}

#pragma mark - BMKLocationServiceDelegate
-(void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
    _userLocation = userLocation;
    [_mapView updateLocationData:userLocation];
    [_locationService stopUserLocationService];
}
-(void)didUpdateUserHeading:(BMKUserLocation *)userLocation{
    [_mapView updateLocationData:userLocation];
}
#pragma mark - BMKMapViewDelegate

-(BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation{
    _annotation = annotation;
    //内容view
    _contentView = [[PaopaoContentView alloc]initLayout:CGRectZero
                                              whitTitle:annotation.title
                                              andAction:_shareView
                                          ToProjectView:_toProject];
    if([annotation.title isEqualToString:@"0"]){
        [_contentView setTitle:@"asadadadad"];
        [_contentView setSubtitle:@"刘女士xxxxxxxx"];
        
    }else{
        [_contentView setTitle:@"qwqqqeeqweqw"];
        [_contentView setSubtitle:@"暂无人分享"];
        
    }

    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        NSString *AnnotationViewID = @"myAnnotation";
        _annotationPop = (MapPaopaoViewBaes *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
        
        if (!_annotationPop) {
            
            [_annotationPop setContentViews:_contentView];
            _annotationPop = [[MapPaopaoViewBaes alloc]initWithAnnotation:annotation
                                                reuseIdentifier:AnnotationViewID
                                                withContentView:_contentView];

            _mTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapPress:)];
            _mTap.cancelsTouchesInView = NO;

            [_annotationPop addGestureRecognizer:_mTap];
        }else{
            _annotationPop.annotation = annotation;
        }
        _annotationPop.animatesDrop = NO;
        


        return _annotationPop;
    }

    return nil;
}
#pragma mark - 选择大头针
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view{
    __weak MapPaopaoViewBaes *popView = (MapPaopaoViewBaes*)view;
    if ([view isKindOfClass:[BMKPinAnnotationView class]]){
        ((BMKPinAnnotationView*)view).pinColor = BMKPinAnnotationColorRed;
        [popView showContentView];
    }
}
#pragma mark - 取消选择大头针
- (void)mapView:(BMKMapView *)mapView didDeselectAnnotationView:(BMKAnnotationView *)view{
    __weak MapPaopaoViewBaes *popView = (MapPaopaoViewBaes*)view;
    if ([view isKindOfClass:[BMKPinAnnotationView class]]){
        [popView dismissContentView];
        ((BMKPinAnnotationView*)view).pinColor = BMKPinAnnotationColorPurple;
    }
}

#pragma mark - 倒计时，每次移动地图几秒后开始弹出
-(void)mapView:(BMKMapView *)mapView onDrawMapFrame:(BMKMapStatus *)status{
    
    _testFlag = 2;
}
#pragma mark - testTimer
- (void)timerAction:(id)sender{
    
    if (self.window) {
        _testFlag--;
        if (1 > _testFlag) {
            [self selectAllAnnotationView];
        }

    }
}

- (void)selectAllAnnotationView{
    int i;
    do {
        i = arc4random() % _mapView.annotations.count;
    } while (i == lastI);
    NSLog(@"%d",lastI);
    [_mapView deselectAnnotation:[_mapView.annotations objectAtIndex:lastI] animated:NO];
    [_mapView selectAnnotation:[_mapView.annotations objectAtIndex:i]  animated:NO];
    lastI = i;
}


-(void)dealloc{
    [_mapBaseView setMapDelegateForDelloc];
    _locationService.delegate = nil;
}
@end
