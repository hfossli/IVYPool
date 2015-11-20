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

#import <Foundation/Foundation.h>

/*
 A homogeneous pool of instances with same class.
 Thread safe.
 */
@interface IVYPool : NSObject

@property (nonatomic, strong, readonly) Class instanceClass;
@property (nonatomic, assign, readonly) NSUInteger count;

@property (nonatomic, copy, readwrite) id (^createBlock)(void);
@property (nonatomic, copy, readwrite) void (^addPrepare)(id instance);
@property (nonatomic, copy, readwrite) void (^takePrepare)(id instance);
@property (nonatomic, assign, readwrite) BOOL drainHalfOnMemoryWarning;
@property (nonatomic, assign, readwrite) NSUInteger capacity;

- (instancetype)initWithClass:(Class)aClass;

- (id)create;

- (BOOL)add:(id)instance;

/*
 Auto creates if none found - never returns nil
 */
- (id)takeFirstIn;
- (id)takeLastIn;
- (id)takeFirstInPreferablyMatching:(BOOL(^)(id instance))filter;
- (id)takeLastInPreferablyMatching:(BOOL(^)(id instance))filter;

/*
 Does not auto create and may return nil
 */
- (id)getFirstIn;
- (id)getLastIn;
- (id)getFirstInMatching:(BOOL(^)(id instance))filter;
- (id)getLastInMatching:(BOOL(^)(id instance))filter;
- (id)getFirstInPreferablyMatching:(BOOL(^)(id instance))filter;
- (id)getLastInPreferablyMatching:(BOOL(^)(id instance))filter;

- (void)fill;
- (void)fillTo:(NSUInteger)mark;

- (NSArray *)drain;
- (NSArray *)drainHalf;
- (NSArray *)drainTo:(NSUInteger)mark;

@end
