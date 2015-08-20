//
//  MapView.h
//  TGProject
//
//  Created by lijunping on 15/8/17.
//  Copyright (c) 2015年 TG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI/BMapKit.h>
@interface TGMapView : UIView

- (id)initWithFrame:(CGRect)frame turnToShare:(SEL)shareView toProjectView:(SEL)toProjectView;
@end
