//
//  AnnonModel.h
//  Map_Demo
//
//  Created by lijunping on 15/7/21.
//  Copyright (c) 2015年 lijunping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface AnnonModel : NSObject

@property (nonatomic ,assign)double latitude;
@property (nonatomic ,assign)double longitude;
@property (nonatomic ,copy)NSString *rootTitle;
@end
