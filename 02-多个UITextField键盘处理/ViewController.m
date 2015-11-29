//
//  ViewController.m
//  02-多个UITextField键盘处理
//
//  Created by Rocco on 15/11/25.
//  Copyright © 2015年 Rocco. All rights reserved.
//

#import "ViewController.h"
#import "GHKeyboardToolbar.h"

@interface ViewController () <GHkeyboardToolbarDelegate,UIPickerViewDataSource, UIPickerViewDelegate>
// 注册容器UIView
@property (weak, nonatomic) IBOutlet UIView *registerContainer;
// 邮箱textField
@property (weak, nonatomic) IBOutlet UITextField *emailView;

@property (weak, nonatomic) IBOutlet UITextField *birthdayView;
@property (weak, nonatomic) IBOutlet UITextField *cityView;


// 可以多个TextField 共用同一个Toolbar实例对象
@property (nonatomic, strong) GHKeyboardToolbar *toolbar;
// 存放所有的 TextField 的数组
@property (nonatomic, strong) NSMutableArray *textfields;

// 省份
@property (nonatomic, strong) NSArray *allProvinces;
// 城市
@property (nonatomic, strong) NSDictionary *allCities;

@end

@implementation ViewController

#pragma mark - 懒加载
- (GHKeyboardToolbar *)toolbar
{
    if (!_toolbar) {
        _toolbar = [GHKeyboardToolbar toolbar];
        _toolbar.kbdelegate = self;
    }
    return _toolbar;
}

#pragma mark -
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 演示代码修改UITextFeild的属性
    self.emailView.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailView.returnKeyType = UIReturnKeyDone;
    self.emailView.placeholder = @"请输入邮箱";
    
    // 用于临时存放需用的TextField
    NSMutableArray *tmpFields = [NSMutableArray array];
#warning sizeClasses导航注册框窗口的子控件器为空，须去掉storyboard的sizeClasse
    // 遍历注册容器View的子控件，为所有的UITextField添加KeyboardToolbar
    for (UIView *subView in self.registerContainer.subviews) {
        // 只要UITextField的控件
        if ([subView isKindOfClass:[UITextField class]]) {
            // 控件类型强制转换
            UITextField *textfield = (UITextField *)subView;
            textfield.inputAccessoryView = self.toolbar;
            // 绑定tag 记录各子的队列排序索引，方便“上/下一个”等功能的快速跳转
            textfield.tag = tmpFields.count;
            
            [tmpFields addObject:textfield];
        }
    }
    self.textfields = tmpFields;
    
    // 添加监控键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    /* 生日框的键盘 */
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    // 设置区域
    datePicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
    // 设置日期显示格式
    datePicker.datePickerMode = UIDatePickerModeDate;
    // 设置监听 datePicker 日期改变事件
    [datePicker addTarget:self action:@selector(dateChange:) forControlEvents:UIControlEventValueChanged];
    // 替换生日框的键盘视图
    self.birthdayView.inputView = datePicker;
    self.birthdayView.placeholder = @"请选择日期";
    
    /* 城市框的键盘 */
    UIPickerView *cityPicker = [[UIPickerView alloc] init];
    cityPicker.dataSource = self;
    cityPicker.delegate = self;
    cityPicker.showsSelectionIndicator = NO;
    
    self.cityView.inputView = cityPicker;
    self.cityView.placeholder = @"请选择城市";
    
    // 加载plist文件
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"cities" ofType:@"plist"]];
    // 获取省份城市数据
    self.allProvinces = dict[@"provinces"];
    self.allCities = dict[@"cities"];
}


- (void)dealloc {
#warning 记得移除通知监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - 键盘监控事件
/**
 *  键盘将弹出显示时被调用
 *
 *  @param notification 系统通知
 */
- (void)keyboardWillShow:(NSNotification *)notification
{
//    NSLog(@"%@", notification.userInfo);
    // 1.获取当前选中的UITextField
    UITextField *currenttf = [self getFirstResponder];
    
    // 2.获取当前textfield在视窗中的 y坐标最大
    // 相对父容器(注册容器UIView)的Max Y + 父容器相对视察的Y位置
    CGFloat maxY = CGRectGetMaxY(currenttf.frame) + self.registerContainer.frame.origin.y;
    // 3.获取键盘弹出后的y值
    CGRect kbEndFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    CGFloat kbEndY = kbEndFrame.origin.y;
    
    // 4.比较Y值 判断TextField是否会被遮挡
    CGFloat distance = kbEndY - maxY;
    if (distance < 0) {   //被遮挡了 需上移
        // 动画式上移
        [UIView animateWithDuration:(0.3) animations:^{
            self.registerContainer.transform = CGAffineTransformMakeTranslation(0, distance);
        }];
    }
    
    // 5.判断上/下一个按钮是否可用
    self.toolbar.previousItem.enabled = currenttf.tag != 0 ? true : false;
    self.toolbar.nextItem.enabled = currenttf.tag != self.textfields.count - 1 ? true : false;
}

/**
 *  键盘将隐藏时 被调用
 *
 *  @param notification 系统通知
 */
- (void)keyboardWillHide:(NSNotification *)notification
{
    // 若有偏移 就动画式恢复原状
    if (self.registerContainer.frame.origin.y) {
        [UIView animateWithDuration:0.3 animations:^{
            self.registerContainer.transform = CGAffineTransformIdentity;
        }];
    }
    
    /* 不适用 直接点击其它TextField时，键盘不会隐藏*/
    // 还原 上/下一个的使能状态
//    self.toolbar.previousItem.enabled = YES;
//    self.toolbar.nextItem.enabled = YES;
}

/**
 *  获得当前相应的UITextField
 *
 */
- (UITextField *)getFirstResponder {
    for (UITextField *tf in self.textfields) {
        if ([tf isFirstResponder]) {
            return tf;
        }
    }
    return nil;
}


#pragma mark - 点击无关地方退出键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


#pragma mark - Toolbar代理方法
- (void)keyboardToolbar:(GHKeyboardToolbar *)toolbar btndidSelected:(UIBarButtonItem *)item
{
    switch (item.tag) {
        case 1:  // 上一个
//            NSLog(@"previous");
            [self kbTboolbarPrevious];
            break;
        case 2:  // 下一个
            [self kbToolbarNext];
            break;
        case 3:  // 完成
            [self kbToolbarDone];
            break;
            
        default:
            break;
    }
}

/**
 *  切换上一个  切换时键盘也会经历 隐藏->显示
 */
- (void)kbTboolbarPrevious {
    // 1.获取当前选中的UITextField
    UITextField *currenttf = [self getFirstResponder];
    // 2.获取上一个索引
    NSInteger previousIndex = currenttf.tag - 1;
    // 3.切换上一个UITextField 为响应者
    if (previousIndex >= 0) {
        // 3.1 取消当前UITextField的响应编辑状态
        [currenttf resignFirstResponder];
        // 3.2 上一个为响应者
        [self.textfields[previousIndex] becomeFirstResponder];
    }
}

/**
 *  切换下一个
 */
- (void)kbToolbarNext {
    // 1.获取当前选中的UITextField
    UITextField *currenttf = [self getFirstResponder];
    // 2.获取下一个索引
    NSInteger nextIndex = currenttf.tag + 1;
    // 3.切换下一个UITextField 为响应者
    if (nextIndex <= self.textfields.count - 1) {
        // 3.1 取消当前UITextField的响应编辑状态
        [currenttf resignFirstResponder];
        // 3.2 下一个为响应者
        [self.textfields[nextIndex] becomeFirstResponder];
    }
}

/**
 *  点击键盘工具条完成
 */
- (void)kbToolbarDone {
    [self.view endEditing:YES];
}


#pragma mark - 生日框的日期键盘值改变
- (void)dateChange:(UIDatePicker *)datePicker
{
    // 指定日期字符串的格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy年 M月 d日";
    
    self.birthdayView.text = [formatter stringFromDate:datePicker.date];
}


#pragma mark - 城市UIPickerView 数据源方法
#pragma mark 总列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

#pragma mark 各列的行数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    // 第一列 省份数
    if (component == 0) {
        return self.allProvinces.count;
    } else {  // 某省份下的城市
        // 获取是哪个省份
        NSUInteger pIndex = [pickerView selectedRowInComponent:0];
        NSString *pName = self.allProvinces[pIndex];
        // 该省份的城市数
        NSArray *cities = self.allCities[pName];
        
        return cities.count;
    }
}


#pragma mark - 城市UIPickerView 代理方法
#pragma mark 各行显示的数据内容
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return self.allProvinces[row];
    } else {
        // 获取是哪个省份
        NSUInteger pIndex = [pickerView selectedRowInComponent:0];
        NSString *pName = self.allProvinces[pIndex];
        // 该省份的城市数
        NSArray *cities = self.allCities[pName];
        
        return cities[row];
    }
}

#pragma mark UIPickerView 选中了某一行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // 刷新第1列的数据
    [pickerView reloadComponent:1];
    // 获取所选省名
    NSUInteger pIndex = [pickerView selectedRowInComponent:0];
    NSString *pName = self.allProvinces[pIndex];
    // 获取所选市名
    NSUInteger cIndex = [pickerView selectedRowInComponent:1];
    NSArray *cities = self.allCities[pName];
    NSString *cName = cities[cIndex];
    // 城市文本框显示 位置
    self.cityView.text = [NSString stringWithFormat:@"%@ %@", pName, cName];
}


@end
