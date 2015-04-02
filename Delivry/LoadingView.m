//
//  LoadingView.m
//  Delivry
//
//  Created by Bo Wen Hou on 2015-01-20.
//  Copyright (c) 2015 Eddie Hou. All rights reserved.
//

#import "LoadingView.h"

@implementation LoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.center.x-25,self.center.y-25 , 50, 50)];
        [spinner setColor:[UIColor blueColor]];
        [spinner startAnimating];
        [self addSubview:spinner];
    }
    return self;
}


@end
