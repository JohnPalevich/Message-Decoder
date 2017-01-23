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
    NSString * _messageString;
    NSString * _letterString;
    NSString * _previousNote;
    BOOL _recordNotes;
    NSDictionary *_charMap;
    NSInteger _previousNoteCounter;
}

-(instancetype) init{
    self = [super init];
    if(self){
        _messageString = @"";
        _previousNote = @"";
        _letterString = @"";
        Float32 A4 = 440;
        _C0 = A4 * powf(2, -4.75);
        _previousNoteCounter = 0;
        _name = @[@"C", @"C#", @"D", @"D#", @"E", @"F", @"F#", @"G", @"G#", @"A", @"A#", @"B"];
        _charMap = @{
                     @"cd":@"A",
                     @"ce":@"B",
                     @"cf":@"C",
                     @"cg":@"D",
                     @"ca":@"E",
                     @"cb":@"F",
                     @"dc":@"G",
                     @"de":@"H",
                     @"df":@"I",
                     @"dg":@"J",
                     @"da":@"K",
                     @"db":@"L",
                     @"ec":@"M",
                     @"ed":@"N",
                     @"ef":@"O",
                     @"eg":@"P",
                     @"ea":@"Q",
                     @"eb":@"R",
                     @"fc":@"S",
                     @"fd":@"T",
                     @"fe":@"U",
                     @"fg":@"V",
                     @"fa":@"W",
                     @"fb":@"X",
                     @"gc":@"Y",
                     @"gd":@"Z",
                     @"ge":@" ",
                     @"gf":@".",
                     @"ga":@",",
                     @"gb":@"!",
                     @"ac":@"?",
                     @"ad":@"*",
                     };

    }
    return self;
}
- (NSString *) messageForFreq: (Float32) freq power: (Float32) power
{
    if(power < 1e-7)
    {
        return _messageString;
    }
    NSString * tempNote = [self pitch:freq];
    if(_previousNote != tempNote)
    {

        _previousNote = tempNote;
        _previousNoteCounter = 1;
        return _messageString;
    }
    if(_previousNoteCounter == 1)
    {
        _previousNoteCounter ++;
    }
    else
    {
        return _messageString;
    }
    
    if([tempNote containsString:@"#"] || [tempNote isEqualToString:@"F0"] )
    {
        return _messageString;
    }
    if(![tempNote containsString:@"6"] && ![tempNote containsString:@"7"])
    {
        return _messageString;
    }
    if([tempNote isEqualToString:@"G7"])
    {
        NSString * decodedLetter = _charMap[_letterString];
        if(decodedLetter)
        {
            _messageString = [_messageString stringByAppendingString:decodedLetter];
        }
        else{
            _messageString = [_messageString stringByAppendingString:@"_"];
        }
        _letterString = @"";
        return _messageString;
    }
    if([tempNote isEqualToString:@"A7"])
    {
        _recordNotes = YES;
        _messageString = [_messageString stringByAppendingString:@"\n"];
        return _messageString;
    }
    if([tempNote isEqualToString:@"B7"])
    {
        _recordNotes = NO;
    }
    if(!_recordNotes)
    {
        return _messageString;
    }
    
    NSString * letter = [[tempNote substringWithRange:NSMakeRange(0, 1)] lowercaseString];
    _letterString =  [_letterString stringByAppendingString:letter];
    return _messageString;
}


- (NSString *) pitch: (Float32) freq{
    if(freq < _C0)
    {
        return @"C0";
    }
    int32_t h = round(12*log2(freq/_C0));
    int32_t octave = h / 12;
    int32_t n = h % 12;
    return [NSString stringWithFormat: @"%@%d", _name[n] , octave];
}

- (void ) clear
{
    _messageString = @"";
}

@end
