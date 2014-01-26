//
//  LineCell.h
//  EasyBus
//
//  Created by Benoit on 22/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LineCell : UITableViewCell

@property (nonatomic) IBOutlet UIImageView* _picto;
@property (weak, nonatomic) IBOutlet UILabel *libTerminus0;
@property (weak, nonatomic) IBOutlet UILabel *libTerminus1;

@end
