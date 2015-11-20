IVYPool
=======

A pool factory for iOS. Store, get and create objects on demand.


### Installation

```objective-c
pod 'IVYPool'
```

##### Import in swift

```objective-c
import IVYPool
```

##### Import in Objective-C

```objective-c
#import <IVYPool/IVYPool.h>
```

## API

```objective-c
...
@property (nonatomic, copy, readwrite) id (^createBlock)(void);
@property (nonatomic, assign, readwrite) NSUInteger capacity;
...

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

/*
 Creates object using
*/
- (void)fill;
- (void)fillTo:(NSUInteger)mark;

- (NSArray *)drain;
- (NSArray *)drainHalf;
- (NSArray *)drainTo:(NSUInteger)mark;
```


## Example

In most cases I recommend creating a simple facade. In this case IVYPagerReusePool owns an IVYPool and creates a clear and concise API.

```objective-c
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
