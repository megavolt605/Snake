//
//  MVSnakeView.h
//  Snake
//
//  Created by Igor Smirnov
//  Copyright (c) 2012 megavolt605@gmail.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// начальные константы (надо будет вынести в настройки)

// время до начала игры с момента нажатия на старт
const int startTimer = 5;

// начальная скорость игры
const float startingSpeed = 0.2f;

// уменьшение времени таймера после каждого съедания
const float incTimeCounter = -0.01f;

// размеры поля
const int fieldWidth = 50;
const int fieldHeight = 50;

// начальная длина змейки
const int initialLength = 10;

// определение типов для читаемости кода
typedef enum direction {dLeft, dUp, dRight, dDown} direction;
typedef enum hitTestResult {htrEmpty, htrFood, htrWall, htrSnake} hitTestResult;

// делаем объект а-ля NSPoint (хз, может я просто не нашел информацию про уже существующий)
// просто хочется использовать NSMutableArray для хранения координат элементов змейки
@interface MVSnakeViewPoint : NSObject
{
    int x, y;
}
- (MVSnakeViewPoint*) initWithPoint:(NSPoint)point;
@property (assign, readwrite) int x;
@property (assign, readwrite) int y;
@end

// основной класс
@interface MVSnakeView : NSView
{
    // связь с окном
    IBOutlet NSToolbarItem * newGameMenuItem;
    IBOutlet NSTextField * scoreLabel;
}

- (IBAction)newGame:(id)sender;         // новая игра

@end
