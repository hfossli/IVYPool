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

#import <XCTest/XCTest.h>
#import <IVYPool/IVYPool.h>
#import <UIKit/UIKit.h>

@interface IVYPoolTest : XCTestCase

@property (nonatomic, strong) IVYPool *pool;

@end

@implementation IVYPoolTest

#pragma mark - Construct and destruct

- (void)setUp
{
	[super setUp];
    self.pool = [[IVYPool alloc] initWithClass:[NSIndexPath class]];
}

- (void)tearDown
{
    self.pool = nil;
    [super tearDown];
}

#pragma mark - Tests

- (void)testCreate
{   
    NSIndexPath *instance = [self.pool create];
    XCTAssertNotNil(instance);
}

- (void)testCustomCreate
{    
    self.pool.createBlock = (id)^(void){
        return [NSIndexPath indexPathForRow:5 inSection:10];
    };
    
    NSIndexPath *instance = [self.pool create];
    
    XCTAssertNotNil(instance);
    XCTAssertEqual(instance.row, 5, @"we initialized an indexpath with row 5");
    XCTAssertEqual(instance.section, 10, @"we initialized an indexpath with section 10");
}

- (void)testAdd
{
    NSIndexPath *instance = [self.pool create];
    XCTAssertEqual(self.pool.count, (NSUInteger)0, @"no instances have been added");
    [self.pool add:instance];
    XCTAssertEqual(self.pool.count, (NSUInteger)1, @"we just added one instance to empty list");
}

- (void)testTakeFirstIn
{
    NSIndexPath *firstInstance = [self.pool create];
    [self.pool add:firstInstance];

    [self.pool fillTo:5];

    NSIndexPath *lastInstance = [self.pool create];
    [self.pool add:lastInstance];

    XCTAssertEqual(self.pool.count, (NSUInteger)6);
    NSIndexPath *returnedInstance = [self.pool takeFirstIn];
    XCTAssertTrue(returnedInstance != lastInstance);
    XCTAssertTrue(returnedInstance == firstInstance);
    XCTAssertNotNil(returnedInstance, @"we are supposed to find one instance");
    XCTAssertEqual(self.pool.count, (NSUInteger)5);
}

- (void)testTakeLastIn
{
    NSIndexPath *firstInstance = [self.pool create];
    [self.pool add:firstInstance];

    [self.pool fillTo:5];

    NSIndexPath *lastInstance = [self.pool create];
    [self.pool add:lastInstance];

    XCTAssertEqual(self.pool.count, (NSUInteger)6);
    NSIndexPath *returnedInstance = [self.pool takeLastIn];
    XCTAssertTrue(returnedInstance != firstInstance);
    XCTAssertTrue(returnedInstance == lastInstance);
    XCTAssertNotNil(returnedInstance, @"we are supposed to find one instance");
    XCTAssertEqual(self.pool.count, (NSUInteger)5);
}

- (void)testTakeMatching
{
    self.pool.createBlock = (id)^(void){
        return [NSIndexPath indexPathForRow:5 inSection:10];
    };
    
    [self.pool fillTo:2];
    
    NSIndexPath *instance = [self.pool takeFirstInPreferablyMatching:^BOOL(NSIndexPath *indexPath) {
        return indexPath.row == 200;
    }];
    XCTAssertEqual(instance.row, 5, @"Found nothing and created using default initialization");

    instance = [NSIndexPath indexPathForItem:77 inSection:88];
    [self.pool add:instance];

    instance = [NSIndexPath indexPathForItem:22 inSection:33];
    [self.pool add:instance];

    instance = [self.pool takeFirstInPreferablyMatching:^BOOL(NSIndexPath *indexPath) {
        return indexPath.row == 77;
    }];

    XCTAssertEqual(instance.row, 77);
    XCTAssertEqual(instance.section, 88);
}

- (void)testCapacity
{
    self.pool.capacity = 8;
    [self.pool fillTo:9];
    XCTAssertEqual(self.pool.count, 8);

    [self.pool add:[NSIndexPath indexPathForRow:5 inSection:10]];
    XCTAssertEqual(self.pool.count, 8);

    self.pool.capacity = 9;

    [self.pool add:[NSIndexPath indexPathForRow:5 inSection:10]];
    XCTAssertEqual(self.pool.count, 9);
}

- (void)testTakeAndGetCount
{
    BOOL (^NONE)(id instance) = ^BOOL (id instance) { return NO; };
    BOOL (^ANY)(id instance) = ^BOOL (id instance) { return YES; };
    
    [self.pool fillTo:10];
    XCTAssertEqual(self.pool.count, 10);
    
    XCTAssertNotNil([self.pool getFirstIn]);
    XCTAssertEqual(self.pool.count, 9);
    
    XCTAssertNotNil([self.pool getLastIn]);
    XCTAssertEqual(self.pool.count, 8);
    
    XCTAssertNotNil([self.pool getFirstInMatching:ANY]);
    XCTAssertEqual(self.pool.count, 7);
    
    XCTAssertNotNil([self.pool getLastInMatching:ANY]);
    XCTAssertEqual(self.pool.count, 6);
    
    XCTAssertNil([self.pool getFirstInMatching:NONE]);
    XCTAssertEqual(self.pool.count, 6);
    
    XCTAssertNil([self.pool getLastInMatching:NONE]);
    XCTAssertEqual(self.pool.count, 6);
    
    XCTAssertNotNil([self.pool getFirstInPreferablyMatching:ANY]);
    XCTAssertEqual(self.pool.count, 5);
    
    XCTAssertNotNil([self.pool getLastInPreferablyMatching:ANY]);
    XCTAssertEqual(self.pool.count, 4);
    
    XCTAssertNotNil([self.pool getFirstInPreferablyMatching:NONE]);
    XCTAssertEqual(self.pool.count, 3);
    
    XCTAssertNotNil([self.pool getLastInPreferablyMatching:NONE]);
    XCTAssertEqual(self.pool.count, 2);
    
    
    [self.pool drain];
    XCTAssertEqual(self.pool.count, 0);
    
    
    XCTAssertNil([self.pool getFirstIn]);
    XCTAssertEqual(self.pool.count, 0);
    
    XCTAssertNil([self.pool getLastIn]);
    XCTAssertEqual(self.pool.count, 0);
    
    XCTAssertNil([self.pool getFirstInMatching:ANY]);
    XCTAssertEqual(self.pool.count, 0);
    
    XCTAssertNil([self.pool getLastInMatching:ANY]);
    XCTAssertEqual(self.pool.count, 0);
    
    XCTAssertNil([self.pool getFirstInMatching:NONE]);
    XCTAssertEqual(self.pool.count, 0);
    
    XCTAssertNil([self.pool getLastInMatching:NONE]);
    XCTAssertEqual(self.pool.count, 0);
    
    XCTAssertNil([self.pool getFirstInPreferablyMatching:ANY]);
    XCTAssertEqual(self.pool.count, 0);
    
    XCTAssertNil([self.pool getLastInPreferablyMatching:ANY]);
    XCTAssertEqual(self.pool.count, 0);
    
    XCTAssertNil([self.pool getFirstInPreferablyMatching:NONE]);
    XCTAssertEqual(self.pool.count, 0);
    
    XCTAssertNil([self.pool getLastInPreferablyMatching:NONE]);
    XCTAssertEqual(self.pool.count, 0);
    
    
    [self.pool fillTo:10];
    XCTAssertEqual(self.pool.count, 10);
    
    
    XCTAssertNotNil([self.pool takeFirstIn]);
    XCTAssertEqual(self.pool.count, 9);
    
    XCTAssertNotNil([self.pool takeLastIn]);
    XCTAssertEqual(self.pool.count, 8);
    
    XCTAssertNotNil([self.pool takeFirstInPreferablyMatching:ANY]);
    XCTAssertEqual(self.pool.count, 7);
    
    XCTAssertNotNil([self.pool takeLastInPreferablyMatching:ANY]);
    XCTAssertEqual(self.pool.count, 6);
    
    XCTAssertNotNil([self.pool takeFirstInPreferablyMatching:NONE]);
    XCTAssertEqual(self.pool.count, 5);
    
    XCTAssertNotNil([self.pool takeLastInPreferablyMatching:NONE]);
    XCTAssertEqual(self.pool.count, 4);
    
    
    [self.pool drain];
    XCTAssertEqual(self.pool.count, 0);
    
    
    XCTAssertNotNil([self.pool takeFirstIn]);
    XCTAssertEqual(self.pool.count, 0);
    
    XCTAssertNotNil([self.pool takeLastIn]);
    XCTAssertEqual(self.pool.count, 0);
    
    XCTAssertNotNil([self.pool takeFirstInPreferablyMatching:ANY]);
    XCTAssertEqual(self.pool.count, 0);
    
    XCTAssertNotNil([self.pool takeLastInPreferablyMatching:ANY]);
    XCTAssertEqual(self.pool.count, 0);
    
    XCTAssertNotNil([self.pool takeFirstInPreferablyMatching:NONE]);
    XCTAssertEqual(self.pool.count, 0);
    
    XCTAssertNotNil([self.pool takeLastInPreferablyMatching:NONE]);
    XCTAssertEqual(self.pool.count, 0);
}

- (void)simulateMemoryWarningNotification
{
    // Post 'low memory' notification that will propagate out to controllers
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidReceiveMemoryWarningNotification object: [UIApplication sharedApplication]];

    // Manually call applicationDidReceiveMemoryWarning
    if([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(applicationDidReceiveMemoryWarning:)])
    {
        [[[UIApplication sharedApplication] delegate] applicationDidReceiveMemoryWarning:[UIApplication sharedApplication]];
    }
}

- (void)testMemoryWarning
{
    [self.pool fillTo:9];

    [self simulateMemoryWarningNotification];

    XCTAssertEqual(self.pool.count, (NSUInteger)9);

    self.pool.drainHalfOnMemoryWarning = YES;

    XCTAssertEqual(self.pool.count, (NSUInteger)9);

    [self simulateMemoryWarningNotification];

    XCTAssertEqual(self.pool.count, (NSUInteger)5);
}

@end