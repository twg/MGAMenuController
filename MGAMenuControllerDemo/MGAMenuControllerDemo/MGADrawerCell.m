//
//  MGADrawerCell.m
//  MGAMenuControllerDemo
//
//  Created by Dane Carr on 12-03-14.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MGADrawerCell.h"

@implementation MGADrawerCell

@synthesize accessoryPosition = _accessoryPosition;
@synthesize accessoryTag = _accessoryTag;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.accessoryTag = -1;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.indentationLevel == 0) {
        CGRect r;
        if (self.accessoryView) {
            // If a custom accessory view is set
            r = self.accessoryView.frame;
            r.origin.x = self.accessoryPosition;
            self.accessoryView.frame = r;
        }
        else {
            // Find accessory view in array of cell's subviews
            UIView* defaultAccessoryView = nil;
            for (UIView* subview in self.subviews) {
                if (subview.tag == self.accessoryTag || (subview != self.textLabel && 
                    subview != self.detailTextLabel && 
                    subview != self.backgroundView && 
                    subview != self.contentView &&
                    subview != self.selectedBackgroundView &&
                    subview != self.imageView &&
                    subview.frame.origin.x == 290 &&
                    subview.frame.origin.y == 0)) {
                    defaultAccessoryView = subview;
                    self.accessoryTag = 1;
                    subview.tag = self.accessoryTag;
                    NSLog(@"%@", NSStringFromCGRect(subview.frame));
                    break;
                }
            }
            r = defaultAccessoryView.frame;
            r.origin.x = self.accessoryPosition;
            defaultAccessoryView.frame = r;
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self setNeedsLayout];
}

@end
