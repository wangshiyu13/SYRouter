Pod::Spec.new do |spec|
spec.name             = 'SYRouter'
spec.version          = '1.0.0'
spec.license          = { :type => "MIT", :file => 'LICENSE' }
spec.homepage         = 'http://192.168.4.250:3000/wangshiyu13/SYRouter'
spec.authors          = {"wangshiyu13" => "wangshiyu13@163.com"}
spec.summary          = '基于URI的视图控制器路由'
spec.source           =  {:git => 'http://192.168.4.250:3000/wangshiyu13/SYRouter.git', :tag => '1.0.0' }
spec.source_files     = 'SYRouter/SYRouter.swift'
spec.requires_arc     = true
spec.ios.deployment_target = '8.0'
end