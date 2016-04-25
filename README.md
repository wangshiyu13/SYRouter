# SYRouter

基于URI的视图控制器路由

-----
使用方法

```
SYRouter.shared.map("/B/:test", toControllerClass: BViewController.self)

let vc = SYRouter.shared.matchController("/B/:test/?test=1")
self.presentViewController(vc, animated:true, completion: nil)


```

接受参数

```
self.sy_routeParams
```