1、打开Podfile，重命名Target，删除Pods、Podfile.lock和IOSTemplate.xcworkspace
2、打开IOSTemplate.xcodeproj，依次重命名工程名、主文件夹和IOSTemplate.entitlements
3、关闭工程，执行pod install
4、搜索替换IOSTemplate和iostemplate，Build Settings中筛选iostemplate进行修改，修改R.swift的Build Phases
5、关闭工程，删除Pods、Podfile.lock和*.xcworkspace后重新pod install
6、再次执行第4步，看看有没遗漏
7、编译运行（检测scheme，如有必要删除IOSTemplate的scheme）

