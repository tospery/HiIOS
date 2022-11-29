# HiIOS
<p>
  <img src="https://github.com/tospery/HiIOS/blob/main/resource/logo.png" width="500" alt="Logo" />
</p>
HiIOS是一个致力于提高项目开发效率的响应式应用框架，其设计目的在于整合常用的必要三方库并搭建一个响应式应用框架，让开发者能够专注于业务需求而无需耗费精力在应用框架的设计上。

[![CI Status](https://img.shields.io/travis/yangjianxiang/HiIOS.svg?style=flat)](https://travis-ci.org/yangjianxiang/HiIOS)
[![Version](https://img.shields.io/cocoapods/v/HiIOS.svg?style=flat)](https://cocoapods.org/pods/HiIOS)
[![License](https://img.shields.io/cocoapods/l/HiIOS.svg?style=flat)](https://cocoapods.org/pods/HiIOS)
[![Platform](https://img.shields.io/cocoapods/p/HiIOS.svg?style=flat)](https://cocoapods.org/pods/HiIOS)

## 功能特性
### 应用框架

采用Reactor单向流框架，用户行为（User Action）和视图状态（View State）通过可观察的流递送到各自的层，这些流是单向的：View只能提交Action到Reactor、View的状态只能由Reactor驱动。

采用的三方库[ReactorKit](https://github.com/ReactorKit/ReactorKit)

### 主题管理

主题管理基于Rx方式。内置了backgroundColor、foregroundColor、titleColor、bodyColor和borderColor等常用的颜色属性，不够的、可以通过specialColors数组来进行扩展。

采用的三方库[RxTheme](https://github.com/RxSwiftCommunity/RxTheme)

### 路由管理

方式一：ioshub://about

方式二：https://ioshub.com/about

路由管理基于URL方式。应用会注册一个自己的URL Scheme，比如ioshub；同时也支持由https进行驱动，如果注册了about的host，则会打开原生关于页面，反之打开网页。

同时对路由进行了Reactive的扩展，支持Rx方式调用，可以方便的处理结果。

采用的三方库[URLNavigator](https://github.com/devxoul/URLNavigator)

### 网络请求

Moya

### 序列化

ObjectMapper

### 兼容性

QMUI_iOS

## 支持iOS版本

iOS 11+

## 项目模板

请查看[IOSTemplate](https://github.com/tospery/IOSTemplate)

## 示例项目

请查看[IOSHub](https://github.com/tospery/IOSHub)

## 注意事项

- 关于 ObjC：这是一个Swift库，在项目中可以通过桥接（OCHelper）使用Objective-C。

## 设计资源

可以在项目中添加同名的图标来替换内置的资源，

请查看[内置资源](https://github.com/tospery/HiIOS/tree/main/HiIOS/Resources/Images.xcassets)

## 其他

Core
Model
Router
Network
Resources
Components（Cache/Theme/JSBridge）