//
//  GHKeyboardToolbar.h
//  02-多个UITextField键盘处理
//
//  Created by Rocco on 15/11/25.
//  Copyright © 2015年 Rocco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GHKeyboardToolbar;

// 自定义代理方法
@protocol GHkeyboardToolbarDelegate <NSObject>

@optional  // 可选写代理方法
/**
 *  item.tag 0表示上一个；1表示下一个；2表示Done完成.
 */
- (void)keyboardToolbar:(GHKeyboardToolbar *)toolbar btndidSelected:(UIBarButtonItem *)item;

@end

@interface GHKeyboardToolbar : UIToolbar

/* 把按钮都定义在这里 为了能被外部的更改使能状态*/
// 上一个
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousItem;
// 下一个
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextItem;
// 完成
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneItem;

// 类方法 快速初始化
+ (instancetype)toolbar;

// 定义代理属性
@property (nonatomic, weak) id<GHkeyboardToolbarDelegate> kbdelegate;

@end
