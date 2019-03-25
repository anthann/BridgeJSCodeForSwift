# README  

这是一个示例项目，演示如何把一些常见的JS库放在iOS的JavaScriptCore中运行。  
最近几年，大前端领域蓬勃发展，JS相关的开原生态枝繁叶茂，各种便利的第三方库层出不穷。  
借助JavaScriptCore，我们有可能把一些JS库直接运行在iOS上，极大的扩展了iOS开发者的工具箱。  
相比于浏览器或node.js环境，JavaScriptCore提供了一个纯粹的JS运行环境，在这个环境中没有window、console、setTimeOut等对象和接口，然而大量JS库都依赖于这些东西。  
本工程项目代码中见招拆招的逐步解决了以上的一部分问题，借此希望开拓思路、解决问题，让更多优秀的JS库可以运行在iOS上。

目前支持：  

1. Prism.js
2. Highlight.js
3. Tern.js
4. Acorn.js

