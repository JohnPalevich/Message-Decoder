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
    NSString * _noteString;
    NSString * _previousNote;
    BOOL _recordNotes;
}
-(instancetype) init{
    self = [super init];
    if(self){
        _noteString = @"";
        _previousNote = @"";
        Float32 A4 = 440;
        _C0 = A4 * powf(2, -4.75);
        _name = @[@"C", @"C#", @"D", @"D#", @"E", @"F", @"F#", @"G", @"G#", @"A", @"A#", @"B"];
    }
    return self;
}
- (NSString *) messageForFreq: (Float32) freq power: (Float32) power
{
    
    if(power < 1e-7)
    {
        return _noteString;
    }
    NSString * tempNote = [self pitch:freq];
    if(_previousNote == tempNote)
    {
        return _noteString;
    }
    if([tempNote containsString:@"#"] || [tempNote isEqualToString:@"F0"] )
    {
        return _noteString;
    }
    if(![tempNote containsString:@"4"] && ![tempNote containsString:@"5"])
    {
        return _noteString;
    }
    if([tempNote isEqualToString:@"A5"])
    {
        _recordNotes = YES;
        _noteString = @"";
        return _noteString;
    }
    if([tempNote isEqualToString:@"B5"])
    {
        _recordNotes = NO;
    }
    if(!_recordNotes)
    {
        return _noteString;
    }
    _previousNote = [self pitch:freq];
    _noteString =  [_noteString stringByAppendingString:[self pitch: freq]];
    return _noteString;
}


- (NSString *) pitch: (Float32) freq{
    int32_t h = round(12*log2(freq/_C0));
    int32_t octave = h / 12;
    int32_t n = h % 12;
    return [NSString stringWithFormat: @"%@%d", _name[n] , octave];
}

@end
