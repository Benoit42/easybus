//
//  DepartureCell.h
//  EasyBus
//
//  Created by Benoit on 23/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DepartureCell : UITableViewCell

@property (nonatomic) IBOutlet UIImageView* _picto;
@property (nonatomic) IBOutlet UILabel* _delai;
@property (weak, nonatomic) IBOutlet UILabel *_heure;
@property (weak, nonatomic) IBOutlet UILabel *_min;
@property (weak, nonatomic) IBOutlet UILabel *direction;

@end
