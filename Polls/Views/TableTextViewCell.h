//
//  TableTextViewCell.h
//  Palaver
//
//  Created by Kyle Fuller on 29/05/2012.
//  Copyright (c) 2012-2013 Cocode. All rights reserved. Vendored/Borrowed/Stealed from Palaver.
//

#import <UIKit/UIKit.h>

@interface TableTextViewCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, weak) UITextField *textField;
@property (nonatomic, copy) dispatch_block_t block;

@end
