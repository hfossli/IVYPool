IVYPool
=======

A thread safe pool factory for iOS. Store, get and create objects on demand.


### Installation

```objc
pod 'IVYPool'
```

##### Import in swift

```objc
import IVYPool
```

##### Import in Objective-C

```objc
#import <IVYPool/IVYPool.h>
```

## API

```objc
...
@property (nonatomic, copy, readwrite) id (^createBlock)(void);
@property (nonatomic, assign, readwrite) NSUInteger capacity;
...

/*
 The instances you add, get and create should all be of this class or subclass
 */
- (instancetype)initWithClass:(Class)aClass;

/*
 Create an instance using `createBlock`
 */
- (id)create;

/*
 Add instance to the pool.
 It will immediately be accsible with `getLast` or `takeLast`
 */
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

/*
 Creates object using `createBlock`
 */
- (void)fill;
- (void)fillTo:(NSUInteger)mark;

/*
 Removes objects from the pool
 */
- (NSArray *)drain;
- (NSArray *)drainHalf;
- (NSArray *)drainTo:(NSUInteger)mark;
```

## Terminology

If `a` and `b` were added to the pool. `firstIn` refers `a` while `lastIn` refers to `b`.


## Example

In most cases I recommend creating a simple facade. In this case IVYPagerReusePool owns an IVYPool and creates a clear and concise API.

```objc
@interface IVYPagerReusePool : NSObject

- (void)registerPageClass:(Class)pageClass forReuseIdentifier:(NSString *)reuseIdentifier;
- (Class)pageClassForReuseIdentifier:(NSString *)reuseIdentifier;

- (IVYArticlePage *)getAnyPageWithPath:(IVYPagerPath *)path;
- (IVYArticlePage *)getAnyPageWithIdentifier:(NSString *)identifier;
- (IVYArticlePage *)getAnyPageWithReuseIdentifier:(NSString *)reuseIdentifier;

- (NSArray <IVYArticlePage *> *)drainTo:(NSUInteger)mark;

- (BOOL)add:(IVYArticlePage *)page;

@end
```


[![Agens | Digital craftsmanship](http://static.agens.no/images/agens_logo_w_slogan_avenir_small.png)](http://agens.no/)
