//
//  PixelCommands.h
//  wwRemote
//
//  Created by Matthew Regan on 4/11/12.
//  Copyright (c) 2012 LSGC. All rights reserved.
//

#ifndef wwRemote_PixelCommands_h
#define wwRemote_PixelCommands_h

#define COMMAND_ON_OFF                      0x21
#define COMMAND_WHITE_MIX                   0x2F
#define COMMAND_INTENSITY                   0x41
#define COMMAND_INTENSITY_16BIT             0x42
#define COMMAND_COLOR_MIX_FADE_FREQ         0x50
#define COMMAND_INTENSITY_FADE_FREQ         0x51
#define COMMAND_TAP_FADE_FREQ               0x52
#define COMMAND_DIRECT_FADE_FREQ            0x53
#define COMMAND_COLORS_DW                   0x55
#define COMMAND_COLOR                       0x61
#define COMMAND_COLOR_MIX_16BIT             0x62
#define COMMAND_COLORS_DIRECT               0x66

#define COMMAND_MOTOR_TAP                   0x68
#define COMMAND_MOTOR_CONTINUOUS            0x69
#define COMMAND_MOTOR_STOP                  0x6A

#define COMMAND_EVENT                       0x90
#define COMMAND_EVENT_ON_OFF                0xA0
#define COMMAND_EVENT_START_STOP            0xA1
#define COMMAND_SET_RTC                     0xA2
#define COMMAND_EVENT_CREATE                0xA3
#define COMMAND_EVENT_DELETE                0xA4

#define COMMAND_PHOTODIODE                  0xB0
#define COMMAND_MEASURE_COLOR_LUMINANCE     0xB1
#define COMMAND_ERASE_PHOTO                 0xB2
#define COMMAND_WRITE_PHOTO                 0xB3
#define COMMAND_STORE_PHOTO                 0xB4
#define COMMAND_BASELINE_PHOTO_LUMINANCE    0xB5
#define COMMAND_READ_PHOTO                  0xB6
#define COMMAND_PHOTO_FEEDBACK              0xB7
#define COMMAND_RESET_OUTPUT_FACTOR         0xB8

#define COMMAND_READ_FIRMWARE_VERSION       0xC0
#define COMMAND_FIRMWARE_UPDATE             0xC6
#define COMMAND_FIRMWARE_RECEIVE            0xC7

#endif
