//
//  MVSnakeView.m
//  Snake
//
//  Created by Igor Smirnov
//  Copyright (c) 2012 megavolt605@gmail.com. All rights reserved.
//

#import "MVSnakeView.h"

@implementation MVSnakeView
{
    NSTimer * timerRedraw;          // таймер на перерорисовку
    NSTimer * timerGame;            // таймер на шаг игры
    
    float gameSpeed;                // текущая скорость игры
    
    Boolean inGame;                 // признак активной игры
    direction dir;                  // текущее напревление змейки
    int score;                      // очки
    
    MVSnakeViewPoint * snakePos;    // координаты головы
    MVSnakeViewPoint * foodPos;     // координаты еды
    
    NSMutableArray * snake;         // массив с объектами координат змейки
}

// инициализация
- (id)initWithFrame:(NSRect)frame
{
    // инициализация родителя
    self = [super initWithFrame:frame];
    if (self) {
        // создаем змейку 
        snake = [[NSMutableArray alloc] init];
        
        gameSpeed = startingSpeed;
        
        // и два таймера для прорисовки и игры
        timerRedraw = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(tickRedraw:) userInfo:nil repeats:YES];
        
        // начальных очков нет
        [self setScore:0 andGameOver:true];
    }
    
    return self;
}

// установка новой координаты еды
// важно, чтобы она не оказалась на змейке
- (void) setFood;
{
    MVSnakeViewPoint * sp;
    sp = [[MVSnakeViewPoint alloc] initWithPoint:NSMakePoint(0, 0)];
    foodPos.x = 0;
    foodPos.y = 0;
    
    // уменьшенная область из-за границ поля
    do {
        sp.x = arc4random_uniform(fieldWidth - 2) + 1;
        sp.y = arc4random_uniform(fieldHeight - 2) + 1;
    } while ([self hitTestSnake:sp] != htrEmpty);
    
    foodPos = sp;
}

// проверка принадлежность ячейки поля
- (hitTestResult) hitTestSnake:(MVSnakeViewPoint *)p
{
    MVSnakeViewPoint * sp;
    
    // границы поля
    if ((p.x == 0) | (p.y == 0) | (p.x == (fieldWidth - 1)) | (p.y == (fieldHeight - 1)))
    {
        return htrWall;
    }
    
    // змейка
    for (int i = 0; i < [snake count]; i++) 
    {
        sp = [snake objectAtIndex:i];
        if ((sp.x == p.x) & (sp.y == p.y))
        {
            return htrSnake;
        }
    }

    // еда
    if ((foodPos.x == p.x) & (foodPos.y == p.y))
    {
        return htrFood;
    }
    
    // иначе - пустота
    return htrEmpty;
}

// обработка нажатий клавиш клавиатуры -- отпраляем обработчикам
- (void)keyDown:(NSEvent *)theEvent
{
    [self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
}
     
// вверх
- (IBAction)moveUp:(id)sender {
    dir = dUp;
}

// вниз
- (IBAction)moveDown:(id)sender {
    dir = dDown;
}

// влево
- (IBAction)moveLeft:(id)sender {
    dir = dLeft;
}

// вправо
- (IBAction)moveRight:(id)sender {
    dir = dRight;
}

// отрисовка нашего вида
- (void)drawRect:(NSRect)dirtyRect
{
    NSBezierPath * p;
    MVSnakeViewPoint * sp;
    
    // рассчитывам размеры отдельной ячейки
    float cellWidth = [self bounds].size.width / fieldWidth;
    float cellHeight = [self bounds].size.height / fieldHeight;
    
    // прорисовка поля с его границами
    for (int y = 0; y < fieldHeight; y++) {
        for (int x  = 0; x < fieldWidth; x++) {
            
            if ( (y == 0) | (x == 0) | (y == (fieldHeight - 1)) | (x == (fieldWidth - 1))) {
                // граница
                [[NSColor colorWithSRGBRed:0.5f green:0.5f blue:0.5f alpha:1] set];
            } else {
                // поле
                [[NSColor colorWithSRGBRed:1 green:1 blue:1 alpha:1] set];
            }
            
            p = [NSBezierPath bezierPathWithRect:NSMakeRect(x * cellWidth, y * cellHeight, cellWidth - 1, cellHeight - 1)];
            [p fill];
            [p stroke];
        }
    }
    
    // прорисовка змейки
    for (int i = 0; i < [snake count]; i++) 
    {
        sp = [snake objectAtIndex:i];
        [[NSColor colorWithSRGBRed:(([snake count] - i)*1.0f/[snake count]) green:0 blue:0 alpha:1] set];
        p = [NSBezierPath bezierPathWithRect:NSMakeRect(sp.x * cellWidth, sp.y * cellHeight, cellWidth - 1, cellHeight - 1)];
        [p fill];
        [p stroke];
    }
    
    // прорисовка еды
    [[NSColor colorWithSRGBRed:0 green:1 blue:0 alpha:1] set];
    p = [NSBezierPath bezierPathWithRect:NSMakeRect(foodPos.x * cellWidth, foodPos.y * cellHeight, cellWidth - 1, cellHeight - 1)];
    [p fill];
    [p stroke];
}

-(BOOL) acceptsFirstResponder
{
    return true;
}

- (void) tickRedraw:(id)sender;
{
//    NSLog(@"рисуем... %@", sender);
    [self setNeedsDisplay:true];
}

- (void) gameFailed
{
    inGame = false;
}

- (void) tickGame:(id)sender;
{
//    NSLog(@"играем... %@", sender);
    hitTestResult ht;
    
    // если игра начата
    if (inGame) 
    {
        // смещение позиции головы змейки в зависимости от текущего направления
        switch (dir) {
            case dLeft: snakePos.x--; break;
            case dRight: snakePos.x++; break;
            case dUp: snakePos.y++; break;
            case dDown: snakePos.y--; break;
            default: break;
        }
        
        // проверка, куда попала наша голова
        ht = [self hitTestSnake:snakePos];
        switch (ht) {
                
            // пусто - смело двигаемся вперед
            case htrEmpty: 
                [snake insertObject:[snakePos copy] atIndex:0];
                [snake removeObjectAtIndex:[snake count] - 1]; // подбираем хвост
                timerGame = [NSTimer scheduledTimerWithTimeInterval:gameSpeed target:self selector:@selector(tickGame:) userInfo:nil repeats:NO];
                break;
            
            // еда - двигаемся, да еще и удлиняемся, убыстряемся и + к очкам
            case htrFood:
                [snake insertObject:[snakePos copy] atIndex:0];
                
                gameSpeed += incTimeCounter;
                timerGame = [NSTimer scheduledTimerWithTimeInterval:gameSpeed target:self selector:@selector(tickGame:) userInfo:nil repeats:NO];
                [self setFood]; // не забываем про новую еду
                [self setScore:score + 1 andGameOver:false];
                break;
            
            // столкнулись со своим хвостом, стеной - конец игры
            case htrSnake:
            case htrWall:
                [self setScore:score + 1 andGameOver:true];
                [self gameFailed];
                break;
            
            // ...
            default:
                break;
        }
    }
}

// установка надписи с количеством очков
-(void)setScore:(int)value andGameOver:(Boolean) b
{
    NSString * s;
    score = value;
    if (!b) {
        s = [NSString stringWithFormat:@"Score: %d", score];
    } else {
        s = [NSString stringWithFormat:@"Game Over, score: %d", score];
    }
    [scoreLabel setStringValue:s];
}

// нажатие на кнопку "начало игры"
-(IBAction)newGame:(id)sender
{
    if (inGame) {
        [sender setLabel:@"New game"];
    } else {
        gameSpeed = startingSpeed;
        timerGame = [NSTimer scheduledTimerWithTimeInterval:gameSpeed target:self selector:@selector(tickGame:) userInfo:nil repeats:NO];

        [sender setLabel:@"Stop game"];
        
        // очищаем змейку
        [snake removeAllObjects];
        
        // начальная позиция - середина поля
        snakePos = [[MVSnakeViewPoint alloc] initWithPoint:NSMakePoint(fieldWidth / 2, fieldHeight / 2 - initialLength)];
        
        // продливаем вниз
        for (int i = 0; i < initialLength; i++) {
            [snake insertObject:[snakePos copy] atIndex:0];
            if (i < (initialLength - 2)) { snakePos.y++; }
        }
        
        // начальное направление
        dir = dLeft;
        
        // еда и очки
        [self setFood];
        [self setScore:0 andGameOver:false];
    }
    inGame = !inGame;
}
@end
         
// надстройка над NSPoint, для возможности хранения в массиве
@implementation MVSnakeViewPoint

- (MVSnakeViewPoint * ) initWithPoint:(NSPoint)point
{
    self = [super init];
    if (self) {
        x = point.x;
        y = point.y;
    }
    return self;
}

- (MVSnakeViewPoint * ) copy
{
    MVSnakeViewPoint * c;
    c = [[MVSnakeViewPoint alloc] initWithPoint:NSMakePoint(x, y)];
    return c;
}

@synthesize x;
@synthesize y;

@end
         
