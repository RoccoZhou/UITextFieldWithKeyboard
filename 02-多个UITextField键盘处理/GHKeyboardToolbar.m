//
//  GHKeyboardToolbar.m
//  02-多个UITextField键盘处理
//
//  Created by Rocco on 15/11/25.
//  Copyright © 2015年 Rocco. All rights reserved.
//

#import "GHKeyboardToolbar.h"

@implementation GHKeyboardToolbar

+ (instancetype)toolbar
{
    // 直接返回xlb 的UIToolbar
    return [[[NSBundle mainBundle] loadNibNamed:@"GHKeyboardToolbar" owner:nil options:nil] lastObject];
}


// 多个ItemButton 都指向这方法
- (IBAction)itemBtnClick:(UIBarButtonItem *)sender {
    // 判断代理方法有实现方法
    if ([self.kbdelegate respondsToSelector:@selector(keyboardToolbar:btndidSelected:)]) {
        [self.kbdelegate keyboardToolbar:self btndidSelected:sender];
    }
}

@end
