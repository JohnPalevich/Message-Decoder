//
//  NoteToMessage.m
//  DetectingSoundFrequency
//
//  Created by Jack Palevich on 1/15/17.
//  Copyright © 2017 Mac. All rights reserved.
//

#import "NoteToMessage.h"

@implementation NoteToMessage{
    Float32 _C0;
    NSArray * _name;
}
-(instancetype) init{
    self = [super init];
    if(self){
        Float32 A4 = 440;
        _C0 = A4 * powf(2, -4.75);
        _name = @[@"C", @"C#", @"D", @"D#", @"E", @"F", @"F#", @"G", @"G#", @"A", @"A#", @"B"];
    }
    return self;
}
- (NSString *) messageForFreq: (Float32) freq power: (Float32) power
{
    if(power < 1e-6)
    {
        return @"silence";
    }
    return [self pitch:freq];
}


- (NSString *) pitch: (Float32) freq{
    int32_t h = round(12*log2(freq/_C0));
    int32_t octave = h / 12;
    int32_t n = h % 12;
    return [NSString stringWithFormat: @"%@%d", _name[n] , octave];
}

@end
