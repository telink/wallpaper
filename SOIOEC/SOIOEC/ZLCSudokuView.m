//
//  WTSudokuView.m
//  DirectBank
//
//  Created by sulier_J on 2014/4/18.
//  Copyright © 2014年 sulier_J. All rights reserved.
//

#import "ZLCSudokuView.h"

#define kGesturePasswordBackground @"GesturePasswordBackground.png"

#define kSpace 20.0f
#define kCenterWidth 300.0f
#define kCircleRadius ((kCenterWidth - kSpace * 6) / 6)

@interface ZLCSudokuView ()

@property(nonatomic,strong)UILabel *titleLab;

@property (nonatomic, strong) UIImageView *avatarView;

@property (nonatomic, strong) UIImageView *imageView;

@property(nonatomic,strong)NSMutableArray *secretArr;

@end

@implementation ZLCSudokuView

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super initWithCoder:aDecoder]){
        [self setup];
    }
    return self;
}

- (void)setup{
    _secretArr = [NSMutableArray array];
    CGSize size = self.frame.size;
    
    [self addSubview:self.imageView];
    [self addSubview:self.titleLab];
    self.titleLab.hidden = YES;
    
    UIView *centerView = [[UIView alloc]initWithFrame:CGRectMake((size.width - kCenterWidth) / 2, size.height / 2 - 150, kCenterWidth, kCenterWidth)];
    [self addSubview:centerView];
    NSMutableArray *btnArray = [NSMutableArray array];
    for(int i = 0; i < 9; i++){
        ZLCSudokuButton *btn = [[ZLCSudokuButton alloc]initWithFrame:CGRectMake(i % 3 * (kCenterWidth / 3) + kSpace,floorl(i / 3) * (kCenterWidth / 3) + kSpace, kCircleRadius * 2, kCircleRadius * 2)];
        btn.tag = i;
        [centerView addSubview:btn];
        [btnArray addObject:btn];
    }
    
    _touchView = [[WTTouchView alloc]initWithFrame:centerView.frame];
    _touchView.btnArray = btnArray;
    [self addSubview:_touchView];
}

- (void)showTitle:(NSString *)title{
    self.titleLab.hidden = NO;
    _titleLab.text = title;
}

- (void)showAvatar:(UIImage *)image{
    
}

- (UILabel *)titleLab{
    if(!_titleLab){
        _titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 120, self.frame.size.width, 30)];
        _titleLab.textColor = [UIColor whiteColor];
        _titleLab.font = [UIFont boldSystemFontOfSize:18];
        _titleLab.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLab;
}

- (UIImageView *)imageView{
    if(!_imageView){
        _imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kGesturePasswordBackground]];
        _imageView.frame = self.frame;
    }
    return _imageView;
}

- (UIImageView *)avatarView{
    if(!_avatarView){
        _avatarView = [[UIImageView alloc]init];
    }
    return _avatarView;
}


@end

@implementation ZLCSudokuButton

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor clearColor];
        _type = WTSudokuButtonTypeNormal;
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect frame = rect;
    switch (self.type) {
        case WTSudokuButtonTypeNormal:
        {
            CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1);
            CGContextSetLineWidth(ctx,2);
            frame = CGRectMake(2, 2, rect.size.width-3, rect.size.height-3);
            CGContextAddEllipseInRect(ctx,frame);
            CGContextStrokePath(ctx);
            
            CGContextSetRGBFillColor(ctx,30/255.f, 175/255.f, 235/255.f,0.3);
            CGContextAddEllipseInRect(ctx,frame);
        }
            break;
        case WTSudokuButtonTypeSelected:
        {
            CGContextSetRGBStrokeColor(ctx, 2/255.f, 174/255.f, 240/255.f,1);
            CGContextSetLineWidth(ctx,2);
            frame = CGRectMake(2, 2, rect.size.width-3, rect.size.height-3);
            CGContextAddEllipseInRect(ctx,frame);
            CGContextStrokePath(ctx);
            
            CGContextSetRGBFillColor(ctx,2/255.f, 174/255.f, 240/255.f,1);
            frame = CGRectMake(rect.size.width / 2 - rect.size.width / 8 + 1, rect.size.height / 2 - rect.size.height / 8, rect.size.width / 4, rect.size.height / 4);
            CGContextAddEllipseInRect(ctx, frame);
            CGContextFillPath(ctx);
            
            CGContextSetRGBFillColor(ctx,30/255.f, 175/255.f, 235/255.f,0.3);
            CGContextAddEllipseInRect(ctx,frame);
            CGContextFillPath(ctx);
            
        }
            break;
        case WTSudokuButtonTypeError:
        {
            CGContextSetRGBStrokeColor(ctx, 208/255.f, 36/255.f, 36/255.f,1);
            CGContextSetLineWidth(ctx,2);
            frame = CGRectMake(2, 2, rect.size.width-3, rect.size.height-3);
            CGContextAddEllipseInRect(ctx,frame);
            CGContextStrokePath(ctx);
            
            CGContextSetRGBFillColor(ctx,208/255.f, 36/255.f, 36/255.f,1);
            frame = CGRectMake(rect.size.width / 2 - rect.size.width / 8 + 1, rect.size.height / 2 - rect.size.height / 8, rect.size.width / 4, rect.size.height / 4);
            CGContextAddEllipseInRect(ctx, frame);
            CGContextFillPath(ctx);
            
            CGContextSetRGBFillColor(ctx,208/255.f, 36/255.f, 36/255.f,0.3);
            CGContextAddEllipseInRect(ctx,frame);
            CGContextFillPath(ctx);
        }
            break;
    }
}

@end

@interface WTTouchView (){
    CGPoint lineEndPoint;
}

@property (nonatomic, strong) NSMutableArray *touchesArray;

@property (nonatomic, strong) NSArray *pointsArray;

@end

@implementation WTTouchView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        _touchesArray = [NSMutableArray array];
        _pointsArray = @[@"20,0|15,5|15,-5",
                         @"14,14|14,7|7,14",
                         @"0,20|5,15|-5,15",
                         @"-14,14|-14,7|-7,14",
                         @"-20,0|-15,5|-15,-5",
                         @"-14,-14|-14,-7|-7,-14",
                         @"0,-20|5,-15|-5,-15",
                         @"14,-14|14,-7|7,-14"];
        
        _type = WTTouchViewTypeSetting;
        _success = YES;
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [_touchesArray removeAllObjects];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    for(ZLCSudokuButton *btn in self.btnArray){
        if(CGRectContainsPoint(btn.frame, point)){
            btn.type = WTSudokuButtonTypeSelected;
            [_touchesArray addObject:btn];
            [btn setNeedsDisplay];
        }
    }
    lineEndPoint = point;
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    for(ZLCSudokuButton *btn in self.btnArray){
        if(CGRectContainsPoint(btn.frame, point)){
            if([_touchesArray containsObject:btn]){
                
            }else{
                btn.type = WTSudokuButtonTypeSelected;
                [_touchesArray addObject:btn];
                [btn setNeedsDisplay];
            }
        }
    }
    lineEndPoint = point;
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSMutableString *result = [NSMutableString string];
    for(ZLCSudokuButton *btn in _touchesArray){
        [result appendFormat:@"%ld",btn.tag];
    }
    switch (_type) {
        case WTTouchViewTypeSetting:
        {
            if(_settingDelegate && [_settingDelegate respondsToSelector:@selector(settingPassword:)]){
                _success = [_settingDelegate settingPassword:result];
            }
        }
            break;
        case WTTouchViewTypeVerify:
        {
            if(_verifyDelegate && [_verifyDelegate respondsToSelector:@selector(verifyPassword:)]){
                _success = [_verifyDelegate verifyPassword:result];
            }
        }
            break;
    }

    if(_success){
        
    }else{
        for(ZLCSudokuButton *btn in _touchesArray){
            [btn setType:WTSudokuButtonTypeError];
            [btn setNeedsDisplay];
        }
        [self setNeedsDisplay];
    }
    
    [self clearTouch];
}

- (void)drawRect:(CGRect)rect{
    for(int i = 0; i < _touchesArray.count; i++){
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        if(_success){
            CGContextSetRGBStrokeColor(ctx, 2/255.f, 174/255.f, 240/255.f, 0.7);//线条颜色
        }else{
            CGContextSetRGBStrokeColor(ctx, 208/255.f, 36/255.f, 36/255.f, 0.7);
        }
        
        CGContextSetLineWidth(ctx, 2);
        
        ZLCSudokuButton *btn = _touchesArray[i];
        CGPoint point = btn.center;
        CGContextMoveToPoint(ctx, point.x, point.y);//定点
        
        if(_touchesArray.count - 1 > i){
            btn = _touchesArray[i + 1];
            point = btn.center;
            CGContextAddLineToPoint(ctx, point.x, point.y);//移点
        }else{
            if(_success){
                CGContextAddLineToPoint(ctx, lineEndPoint.x, lineEndPoint.y);
            }
        }
        CGContextStrokePath(ctx);
        
        if(_touchesArray.count - 1 > i){
            btn = _touchesArray[i + 1];
            CGPoint pointNext = btn.center;
            
            btn = _touchesArray[i];
            point = btn.center;
            NSInteger index = [self calculateIndexWithX:pointNext.x - point.x Y:pointNext.y - point.y];
            NSString *pointsList = _pointsArray[index];
            
            NSArray *points = [pointsList componentsSeparatedByString:@"|"];
            NSString * pointString = @"";
            NSArray *pointList = [NSArray array];
            CGFloat x,y;
            
            //绘制三角形
            if(_success){
                CGContextSetRGBFillColor(ctx, 2/255.f, 174/255.f, 240/255.f, 0.7);//线条颜色
            }else{
                CGContextSetRGBFillColor(ctx, 208/255.f, 36/255.f, 36/255.f, 0.7);
            }
            
            for(int i = 0; i < points.count; i++){
                pointString = points[i];
                pointList = [pointString componentsSeparatedByString:@","];
                x = [pointList[0] floatValue];
                y = [pointList[1] floatValue];
                if(i == 0){
                    CGContextMoveToPoint(ctx, point.x + x, point.y + y);
                }else{
                    CGContextAddLineToPoint(ctx, point.x + x, point.y + y);
                }
            }
            
            CGContextFillPath(ctx);
        }
        
    }
}

- (NSInteger)calculateIndexWithX:(CGFloat)x Y:(CGFloat)y{
    if(x > 0)//1,4象限
    {
        if(y > 0) return 1;
        else if (y == 0) return 0;
        else return 7;
    }
    else if(x == 0)//y轴
    {
        if(y > 0) return 2;
        else return 6;
    }
    else//2,3象限
    {
        if(y > 0) return 3;
        else if (y == 0) return 4;
        else return 5;
    }
}

- (void)clearTouch {
    self.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_touchesArray removeAllObjects];
        _success = YES;
        for(ZLCSudokuButton *btn in self.btnArray){
            btn.type = WTSudokuButtonTypeNormal;
            [btn setNeedsDisplay];
        }
        [self setNeedsDisplay];
        self.userInteractionEnabled = YES;
    });
    
}

@end
