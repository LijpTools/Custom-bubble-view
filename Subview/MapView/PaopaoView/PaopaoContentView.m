//
//  PaopaoContentView.m
//  TGProject
//
//  Created by lijunping on 15/8/17.
//  Copyright (c) 2015年 TG. All rights reserved.
//

#import "PaopaoContentView.h"

@interface PaopaoContentView ()
{
    SEL _action;
    SEL _toProject;
    
    CGFloat _width;
    CGFloat _height;
    CGFloat _currentHeight;
    
 
    NSString *_annotaiontitle;
    
    UIButton *_contentButtonView;
    UIButton *_shareBtn;
    UIImageView *_headImages;
}

@end

@implementation PaopaoContentView

@synthesize title = _title,subtitle = _subtitle;

- (id)initLayout:(CGRect)frame whitTitle:(NSString *)annotaiontitle andAction:(SEL)action ToProjectView:(SEL)toProjectView{
    self = [super initWithFrame:frame];
    if (self) {
        _action = action;
        _toProject = toProjectView;
        _annotaiontitle = annotaiontitle;
        [self setUI];
            }
    return self;
}
- (void)setUI{
    _contentButtonView = [UIButton buttonWithType:UIButtonTypeCustom];
    [_contentButtonView addTarget:self.superview action:_toProject forControlEvents:UIControlEventTouchUpInside];
    
    _titlelable = [[UILabel alloc]init];
    _titlelable.font = [UIFont systemFontOfSize:14];
    _titlelable.textColor = [UIColor blueColor];
    [self addSubview:_titlelable];
    
    _subtitlelable = [[UILabel alloc]init];
    _subtitlelable.textColor = [UIColor grayColor];
    _subtitlelable.font = [UIFont systemFontOfSize:14];
    _subtitlelable.textAlignment = NSTextAlignmentLeft;
    
    _shareBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];

    [_shareBtn setTitle:@"我要分享" forState:UIControlStateNormal];
    [_shareBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_shareBtn setBackgroundImage:[UIImage getImageWithName:kShare_normal] forState:UIControlStateNormal];
    [_shareBtn setBackgroundImage:[UIImage getImageWithName:kShare_heightlight] forState:UIControlStateHighlighted];
    _shareBtn.imageView.clipsToBounds = YES;
    _shareBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [_shareBtn addTarget:self.superview action:_action forControlEvents:UIControlEventTouchUpInside];
    [_shareBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    _shareBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    _shareBtn.layer.cornerRadius = 4;
    
    if (![_annotaiontitle isEqualToString:@"0"]) {
        _subtitlelable.frame = CGRectMake(0, 28, 100, 20);
        [self addSubview:_shareBtn];
    }else{
        NSString *imageStr = [NSString stringWithFormat:@"self.jpg"];
        _headImages = [[UIImageView alloc]initWithImage:[UIImage imageNamed:imageStr]];
        _headImages.layer.cornerRadius = 10;
        //移除多余部分
        _headImages.clipsToBounds = YES;
        _headImages.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_headImages];
        [self addSubview:_contentButtonView];
        _subtitlelable.frame = CGRectMake(33, 28, 100, 20);
    }
    
    [self addSubview:_subtitlelable];
    

}
- (void)layoutSubviews{
    [super layoutSubviews];
    _width = self.frame.size.width;
    _height = self.frame.size.height;
    
    [_contentButtonView setFrame:0 y:0 w:_width  h:_height];
    [_headImages setFrame:0 y:28 w:20 h:20];
    [_shareBtn setFrame:100 y:23 w:80 h:30];
    [_titlelable setFrame:0 y:3 w:_width h:20];
    
}
- (void)setTitle:(NSString *)title{
    _titlelable.text = title;
    
}
- (void)setSubtitle:(NSString *)subtitle{
    _subtitlelable.text = subtitle;
    
}
- (void)setHeadImage:(NSString *)headImage{
    
}


@end
