//
//  TableTextViewCell.m
//  Palaver
//
//  Created by Kyle Fuller on 29/05/2012.
//  Copyright (c) 2012-2013 Cocode. All rights reserved. Vendored/Borrowed/Stealed from Palaver.
//

#import "TableTextViewCell.h"

@implementation TableTextViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
        textField.delegate = self;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.textAlignment = NSTextAlignmentRight;

        [self addSubview:textField];
        self.textField = textField;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat x = (self.textLabel.frame.origin.x * 2.0) + self.textLabel.bounds.size.width;
    self.textField.frame = CGRectMake(x, 0, self.bounds.size.width - x - self.textLabel.frame.origin.x, self.bounds.size.height);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

	if (selected && self.selectionStyle == UITableViewCellSelectionStyleNone) {
        [self.textField becomeFirstResponder];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];

    UITextField *textField = self.textField;

    [textField resignFirstResponder];
    textField.text = @"";
    textField.placeholder = @"";
    textField.keyboardType = UIKeyboardTypeDefault;
    textField.secureTextEntry = NO;

    if (textField.inputAccessoryView) {
        /* UITextField causes a crash when you set inputAccessoryView to nil.
           WTF? It's nil by default. */

        textField.inputAccessoryView = [UIView new];
    }

    self.block = nil;
}

- (void)setNumberKeyboard {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
//        DoneCancelNumberPadToolbar *toolbar = [[DoneCancelNumberPadToolbar alloc] initWithTextField:[self textField]];
//        [toolbar setBarStyle:UIBarStyleDefault];
//        [[self textField] setInputAccessoryView:toolbar];
    } else {
        [[self textField] setKeyboardType:UIKeyboardTypeNumberPad];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.block) {
        self.block();
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.block) {
        self.block();
    }
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL result = YES;

    if ([textField keyboardType] == UIKeyboardTypeNumberPad) {
        NSString *numberRegex = @"^[0-9]*$";
        NSPredicate *numberRegexPredicate =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", numberRegex];
        result = [numberRegexPredicate evaluateWithObject:string];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.block) {
            self.block();
        }
    });

    return result;
}

@end
