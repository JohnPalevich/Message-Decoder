//
//  NoteToMessage.h
//  DetectingSoundFrequency
//
//  Created by Jack Palevich on 1/15/17.
//  Copyright © 2017 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NoteToMessage : NSObject
- (NSString *) messageForFreq: (Float32) freq power: (Float32) power;
-(void) clear;

@end
            
