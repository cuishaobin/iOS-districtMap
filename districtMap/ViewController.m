//
//  ViewController.m
//  runAndDraw
//
//  Created by shaobin on 2018/5/8.
//  Copyright © 2018年 autonavi. All rights reserved.
//

#import "ViewController.h"
#import <MAMapKit/MAMapKit.h>

@interface ViewController ()<MAMapViewDelegate> {
    CLLocationCoordinate2D *_points;
    NSInteger _pointCount;
}

@property (nonatomic, strong) MAMapView *mapView;


@property (nonatomic, strong) MAPolygon *districtPolygon;
@property (nonatomic, strong) MAPolygon *worldPolygon;

@end

@implementation ViewController

#pragma mark - Map Delegate
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay {
    if(overlay == self.worldPolygon) {
        MAPolygonRenderer *renderer = [[MAPolygonRenderer alloc] initWithPolygon:overlay];
        
        renderer.fillColor  = [UIColor blackColor];
        
        return renderer;
    }
    
    return nil;
}

#pragma mark life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initPoints];
    
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    
    [self.view addSubview:self.mapView];
    
    self.districtPolygon = [MAPolygon polygonWithCoordinates:_points count:_pointCount];
    
    MAMapPoint worldPoints[4] = {
        MAMapRectWorld.origin,
        MAMapPointMake(MAMapRectWorld.origin.x + MAMapRectWorld.size.width, MAMapRectWorld.origin.y),
        MAMapPointMake(MAMapRectWorld.origin.x + MAMapRectWorld.size.width, MAMapRectWorld.origin.y + MAMapRectWorld.size.height),
        MAMapPointMake(MAMapRectWorld.origin.x, MAMapRectWorld.origin.y + MAMapRectWorld.size.height)
    };
    self.worldPolygon = [MAPolygon polygonWithPoints:worldPoints count:4];
    self.worldPolygon.hollowShapes = @[self.districtPolygon];
    
    [self.mapView addOverlay:self.worldPolygon];
    [self.mapView setVisibleMapRect:self.districtPolygon.boundingMapRect];
}

- (void)dealloc {
    if(_points != NULL) {
        free(_points);
        _points = NULL;
    }
}

- (void)initPoints {
    NSString *mainBunldePath = [[NSBundle mainBundle] bundlePath];
    NSString *fileFullPath = [NSString stringWithFormat:@"%@/%@",mainBunldePath,@"points.txt"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:fileFullPath]) {
        return;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:fileFullPath];
    NSError *err = nil;
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *arr = [str componentsSeparatedByString:@";"];
    if(!arr) {
        NSLog(@"[AMap]: %@", err);
        return;
    }
    
    _pointCount = arr.count;
    _points = malloc(sizeof(CLLocationCoordinate2D) * _pointCount);
    for(int i = 0; i < _pointCount; ++i) {
        NSArray *tempArr = [arr[i] componentsSeparatedByString:@","];
        NSString *lon = tempArr.firstObject;
        NSString *lat = tempArr.lastObject;
        _points[i] = CLLocationCoordinate2DMake([lat doubleValue], [lon doubleValue]);
    }
}

@end

