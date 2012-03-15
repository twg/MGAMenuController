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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews {
    //if (self.accessoryView) {
    //self.accessoryView.frame = CGRectMake(self.accessoryView.frame.origin.x - 100, self.accessoryView.frame.origin.y, self.accessoryView.frame.size.width, self.accessoryView.frame.size.height);
    //}
    [super layoutSubviews];
    
    if (self.indentationLevel == 0) {
        CGRect r;
        if (self.accessoryView) {
            r = self.accessoryView.frame;
            r.origin.x = self.accessoryPosition;
            self.accessoryView.frame = r;
        }
        else {
            UIView* defaultAccessoryView = nil;
            for (UIView* subview in self.subviews) {
                if (subview != self.textLabel && 
                    subview != self.detailTextLabel && 
                    subview != self.backgroundView && 
                    subview != self.contentView &&
                    subview != self.selectedBackgroundView &&
                    subview != self.imageView &&
                    subview.frame.size.width == 30 &&
                    subview.frame.size.height == 43) {
                    defaultAccessoryView = subview;
                    //NSLog(@"%@", NSStringFromCGRect(subview.frame));
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
