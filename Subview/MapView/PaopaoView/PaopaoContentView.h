//
//  PaopaoContentView.h
//  TGProject
//
//  Created by lijunping on 15/8/17.
//  Copyright (c) 2015年 TG. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kShare_normal @"share_normal"
#define kShare_heightlight @"share_heighlight"

@interface PaopaoContentView : UIView
@property (nonatomic ,weak)NSString *title;
@property (nonatomic ,weak)NSString *subtitle;
@property (nonatomic ,strong)UILabel *titlelable;
@property (nonatomic ,strong)UILabel *subtitlelable;

- (id)initLayout:(CGRect)frame
       whitTitle:(NSString *)annotaiontitle
       andAction:(SEL)action
   ToProjectView:(SEL)toProjectView;
@end
