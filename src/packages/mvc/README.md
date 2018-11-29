# MVS - The MVC framework for cocos2d-lua

Model View Scene is like the cocos2d lua default mvc framework, but:

1. convention over configuration
2. scene act as separated controller

```Lua
-- main.lua
local function main()
    local App = require('app.App')
    App:switch('MainController')
end
```



## View

### Files


* /res/views/Name.csb cocos studio 输出的UI的Layer。
* /res/views/Name.plist 合图
* /res/views/Name.png

* /app/views/Name.lua 扩展脚本。用于动态初始化控件和UI内部回调处理。
