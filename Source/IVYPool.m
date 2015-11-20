//
// Author: Håvard Fossli <hfossli@agens.no>
//
// Copyright (c) 2013 Agens AS (http://agens.no/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "IVYPool.h"
#import <UIKit/UIKit.h>
#import <libkern/OSAtomic.h>

// Arbitrary limit
const NSUInteger kIVYPoolMaxFillLimit = 1000;

@interface IVYPool ()

@property (nonatomic, strong, readwrite) Class instanceClass;
@property (nonatomic, strong, readwrite) NSMutableArray *instances;

@end

@implementation IVYPool {
    OSSpinLock _lock;
}

- (id)init
{
    [NSException raise:NSInternalInconsistencyException format:@"Use designated initializer"];
    return nil;
}

- (instancetype)initWithClass:(Class)aClass
{
	self = [super init];
	if(self)
	{
        self.instanceClass = aClass;
        self.drainHalfOnMemoryWarning = NO;
        self.capacity = NSUIntegerMax;
        self.instances = [NSMutableArray new];
        self.createBlock = ^id { return [aClass new]; };
        self.takePrepare = ^(id instance) {};
        self.addPrepare = ^(id instance) {};

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(memoryWarningReceived:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
	}
	return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSUInteger)count
{
    OSSpinLockLock(&_lock);
    NSUInteger count = self.instances.count;
    OSSpinLockUnlock(&_lock);
    return count;
}

- (id)create
{
    id instance = self.createBlock();
    self.addPrepare(instance);
    self.takePrepare(instance);
    return instance;
}

- (id)take
{
    return [self takeFirstIn];
}

- (BOOL)add:(id)instance
{
    if([instance class] != self.instanceClass)
    {
        [NSException raise:NSInternalInconsistencyException format:@"This is a homogeneous pool of instances with same class. Expecting instance of class '%@', but received '%@'", NSStringFromClass(self.instanceClass), NSStringFromClass([instance class])];
    }

    self.addPrepare(instance);

    OSSpinLockLock(&_lock);
    BOOL canAdd = self.instances.count < self.capacity;
    if(canAdd)
    {
        [self.instances addObject:instance];
    }
    OSSpinLockUnlock(&_lock);
    return canAdd;
}

- (id)prepareOrCreateIfNil:(id)instanceOrNil
{
    if(instanceOrNil)
    {
        self.takePrepare(instanceOrNil);
    }
    else
    {
        instanceOrNil = [self create];
    }
    return instanceOrNil;
}

- (id)getFirstIn
{
    return [self getInstanceMatching:^BOOL(id instance) {
        return YES;
    } startWithLast:NO];
}

- (id)getLastIn
{
    return [self getInstanceMatching:^BOOL(id instance) {
        return YES;
    } startWithLast:YES];
}

- (id)getFirstInMatching:(BOOL(^)(id instance))filter
{
    return [self getInstanceMatching:filter startWithLast:NO];
}

- (id)getLastInMatching:(BOOL(^)(id instance))filter
{
    return [self getInstanceMatching:filter startWithLast:YES];
}

- (id)getFirstInPreferablyMatching:(BOOL(^)(id instance))filter
{
    id instance = [self getInstanceMatching:filter startWithLast:NO];
    return instance ?: [self getFirstIn];
}

- (id)getLastInPreferablyMatching:(BOOL(^)(id instance))filter
{
    id instance = [self getInstanceMatching:filter startWithLast:YES];
    return instance ?: [self getLastIn];
}

- (id)takeFirstIn
{
    id instance = [self getFirstIn];
    return [self prepareOrCreateIfNil:instance];
}

- (id)takeLastIn
{
    id instance = [self getLastIn];
    return [self prepareOrCreateIfNil:instance];
}

- (id)takeFirstInPreferablyMatching:(BOOL(^)(id instance))filter
{
    id instance = [self getInstanceMatching:filter startWithLast:NO];
    return instance ?: [self takeFirstIn];
}

- (id)takeLastInPreferablyMatching:(BOOL(^)(id instance))filter
{
    id instance = [self getInstanceMatching:filter startWithLast:YES];
    return instance ?: [self takeLastIn];
}

- (id)getInstanceMatching:(BOOL (^)(id instance))filter startWithLast:(BOOL)reversed
{
    NSEnumerationOptions options = reversed ? NSEnumerationReverse : 0;
    OSSpinLockLock(&_lock);
    NSUInteger index = [self.instances indexOfObjectWithOptions:options passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return filter(obj);
    }];
    id instance = nil;
    if(index != NSNotFound)
    {
        instance = self.instances[index];
        [self.instances removeObjectAtIndex:index];
    }
    OSSpinLockUnlock(&_lock);
    return instance;
}

- (void)fill
{
    if(self.capacity > kIVYPoolMaxFillLimit)
    {
        [NSException raise:NSInternalInconsistencyException format:@"Way too big capacity to fill."];
    }
    [self fillTo:self.capacity];
}

- (void)fillTo:(NSUInteger)mark
{
    OSSpinLockLock(&_lock);
    while (self.instances.count < mark && self.instances.count < self.capacity)
    {
        [self.instances addObject:[self create]];
    }
    OSSpinLockUnlock(&_lock);
}

- (NSArray *)drainHalf
{
    NSArray *drained = @[];
    OSSpinLockLock(&_lock);
    if(self.instances > 0)
    {
        NSUInteger half = self.instances.count / 2;
        NSRange range = NSMakeRange(0, half);
        drained = [self.instances subarrayWithRange:range];
        [self.instances removeObjectsInRange:range];
    }
    OSSpinLockUnlock(&_lock);
    return drained;
}

- (NSArray *)drainTo:(NSUInteger)mark
{
    NSArray *drained = @[];
    OSSpinLockLock(&_lock);
    if(self.instances.count > mark)
    {
        NSRange range = NSMakeRange(0, self.instances.count - mark);
        drained = [self.instances subarrayWithRange:range];
        [self.instances removeObjectsInRange:range];
    }
    OSSpinLockUnlock(&_lock);
    return drained;
}

- (NSArray *)drain
{
    OSSpinLockLock(&_lock);
    NSArray *drained = [self.instances copy];
    [self.instances removeAllObjects];
    OSSpinLockUnlock(&_lock);
    return drained;
}

- (void)memoryWarningReceived:(NSNotificationCenter *)notification
{
    if(self.drainHalfOnMemoryWarning)
    {
        [self drainHalf];
    }
}

@end
