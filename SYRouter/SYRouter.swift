//
//  SYRouter.swift
//  SYRouter
//
//  Created by wangshiyu13 on 16/4/24.
//  Copyright © 2016年 wangshiyu13. All rights reserved.
//

import UIKit

enum SYRouterType {
    case none, viewController, closure
}

typealias SYRouterParamsClosure = ([String: Any]) -> AnyObject?

class SYRouter {
    static let shared = SYRouter()
    
    func map(_ route: String, toControllerClass controllerClass: AnyClass) {
        let subRoutes = subRoutesToRoute(route)
        subRoutes["_"] = controllerClass
    }
    
    func matchController(_ route: String) -> UIViewController {
        var params = paramsInRoute(route)
        if let controllerClass = params?["controller_class"] as? UIViewController.Type {
            let viewController = controllerClass.init()
            let SEL = #selector(setter: UIViewController.sy_routeParams)
            if viewController.responds(to: SEL) {
                viewController.perform(SEL, with: params)
            }
            return viewController
        } else {
            fatalError("控制器不存在")
        }
    }
    
    func map(_ route: String, toClosure closure: SYRouterParamsClosure) {
        let subRoutes = subRoutesToRoute(route)
        subRoutes["_"] = closure([:])
    }
    
    func matchClosure(_ route: String) -> SYRouterParamsClosure? {
        var params = paramsInRoute(route)
        if params == nil {
            return nil
        }
        
        let routerClosure = params!["closure"] as? SYRouterParamsClosure
        let returnclosure: SYRouterParamsClosure? = { (aParams: [String: Any]) in
            if routerClosure != nil {
                var dict = params!
                aParams.forEach { (key, value) in
                    dict[key] = value
                }
                return routerClosure!(dict)
            }
            return nil
        }
        
        return returnclosure
    }
    
    func callClosure(_ route: String) -> AnyObject? {
        var params = paramsInRoute(route)
        let routerBlock = params?["block"] as? SYRouterParamsClosure
        
        if routerBlock != nil {
            return routerBlock?(params!)
        }
        return nil
    }
    
    func canRoute(_ route: String) -> SYRouterType {
        var params = paramsInRoute(route)
        if params?["controller_class"] != nil {
            return .viewController
        }
        
        if params?["block"] != nil {
            return .closure
        }
        
        return .none
    }
    
    /// MARK: - extract params in a route
    fileprivate func paramsInRoute(_ route: String) -> [String: Any]? {
        var params: [String: Any] = [:]
    
        params["route"] = stringFromFilterAppUrlScheme(route) as AnyObject?
        
        var subRoutes = self.routeDict
        let pathComponents = pathComponentsFromRoute(stringFromFilterAppUrlScheme(route))
        for pathComponent in pathComponents {
            var found = false
            let subRoutesKeys = subRoutes.allKeys as NSArray
            for k in subRoutesKeys {
                let key = k as! NSString
                if subRoutesKeys.contains(pathComponent) {
                    found = true
                    subRoutes = subRoutes[pathComponent] as! NSMutableDictionary
                    break
                } else if (key.hasPrefix(":")) {
                    found = true
                    subRoutes = subRoutes[key] as! NSMutableDictionary
                    params[key.substring(from: 1)] = pathComponent as AnyObject?
                    break
                }
            }
            if (!found) {
                return nil
            }
        }
    
        /// MARK: - Extract Params From Query.
        let firstRange = (route as NSString).range(of: "?")
        if (firstRange.location != NSNotFound && route.characters.count > firstRange.location + firstRange.length) {
            let paramsString = (route as NSString).substring(from: firstRange.location + firstRange.length)
            let paramStringArr = paramsString.components(separatedBy: "&")
            for paramString in paramStringArr {
                let paramArr = paramString.components(separatedBy: "=")
                if (paramArr.count > 1) {
                    let key = paramArr[0]
                    let value = paramArr[1]
                    params[key] = value as AnyObject?
                }
            }
        }
    
        let cls: AnyClass = subRoutes["_"] as! AnyClass
        if (class_isMetaClass(object_getClass(cls))) {
            if cls.isSubclass(of: UIViewController.self) {
                params["controller_class"] = subRoutes["_"]
            } else {
                return nil
            }
        } else {
            if subRoutes["_"] != nil {
                params["block"] = subRoutes["_"]
            }
        }
        
        return params
    }
    
    /// MARK: - Private Property & Method
    fileprivate let routeDict = NSMutableDictionary()
    
    fileprivate var appUrlSchemes: [String] = {
        var schemes: [String] = []
        var infos = Bundle.main.infoDictionary
        if let types = infos?["CFBundleURLTypes"] as? [[String: Any]] {
            for dict in types {
                if let scheme = dict["CFBundleURLSchemes"] as? [String] {
                    schemes.append(scheme.first!)
                }
            }
        }
        return schemes
    }()
    
    fileprivate func pathComponentsFromRoute(_ route: String) -> [String] {
        let routePath = NSString(string: route)
        var pathComponents: [String] = []
        for str in routePath.pathComponents {
            let strx = NSString(string: str)
            if strx.isEqual(to: "/") {
                continue
            }
            if (strx.substring(to: 1) as NSString).isEqual(to: "?") {
                break
            }
            pathComponents.append(strx as String)
        }
        return pathComponents
    }
    
    fileprivate func stringFromFilterAppUrlScheme(_ string: String) -> String {
        for appUrlScheme in appUrlSchemes {
            if string.hasPrefix("\(appUrlScheme):") {
                return (string as NSString).substring(from: appUrlScheme.characters.count + 2)
            }
        }
        return string
    }
    
    fileprivate func subRoutesToRoute(_ route: String) -> NSMutableDictionary {
        let pathComponents = pathComponentsFromRoute(route)
        var index = 0
        var subRoutes = self.routeDict
        
        while index < pathComponents.count {
            let pathComponent = pathComponents[index]
            if subRoutes[pathComponent] == nil {
                subRoutes[pathComponent] = NSMutableDictionary()
            }
            subRoutes = subRoutes[pathComponent] as! NSMutableDictionary
            index += 1
        }
        return subRoutes
    }
}


extension UIViewController {
    private static var kAssociatedParamsObjectKey: Void?
    
    var sy_routeParams: [String: AnyObject]? {
        get {
            return objc_getAssociatedObject(self, &UIViewController.kAssociatedParamsObjectKey) as? [String: AnyObject]
        }
        set {
            objc_setAssociatedObject(self, &UIViewController.kAssociatedParamsObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
