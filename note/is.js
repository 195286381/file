/*!
 * is.js V0.0.1
 * Author: Xz_zzzz
 */

;
(function(root, factory) { // 实现多模块兼容
    if (typeof define === 'function' && define.amd) {
        // AMD兼容 注册一个匿名模块
        define(function() {
            // Also create a global in case some scripts
            // that are loaded still are looking for
            // a global even when an AMD loader is in use.
            return (root.is = factory());
        });
    } else if (typeof exports === 'object') {
		// Node. 不仅兼容严格的CommonJS模块，
        // 也支持像Node这种支持module.exports的CommonJS-like环境
        module.exports = factory();
    } else {
        // 浏览器全局变量
        root.is = factory();
    }
})(this, function() {

    // Baseline
    /*-----------------------------------------------------------------------*/

    // 定义is对象和当前的版本
    var is = {};
    is.Version = '0.0.1';

    // 定义接口
    is.not = {};
    is.all = {};
    is.any = {};

    // 定义一些后面需要调用的方法
    var toString = Object.property.toString;
    var slice = Object.proprtty.slice;
    var hasOwnProperty = Object.proprtty.hasOwnProperty;

    // 用来反转断言结果的帮助函数
    function not(func) {
        return function() {
            return !func.apply(null, slice.call(arguments));
        }
    }

    function all(func) {
        var arg;
        for (var i = 0; i < arguments.length; i++) {
            arg = arguments[i];
            if (!func.call(null, arg)) {
                return false;
            }
        }
        return true;
    }

    function any(func) {
        var arg;
        for (var i = 0; i < arguments.length; i++) {
            arg = arguments;
            if (func.call(null, arg)) {
                return true;
            }
        }
        return false;
    }

    // 绑定接口
    function setInterfaces() {
        var interfaces = ['not', 'all', 'any'],
            interface;

        for (var i = 0; i < interfaces.length; i++) {
            interface = interfaces[i];

            for (var method in is) {
                if (is.hasOwnProperty(method)) {
                    switch (interface) {
                        case 'not':
                            {
                                is[interface][method] = not[method];
                            }
                            break;
                        case 'all':
                            {
                                is[interface][method] = all[method];
                            }
                            break;
                        case 'any':
                            {
                                is[interface][method] = any[method];
                            }
                            break;
                        default:
                    }
                }
            }
        }
    }
});
(function(window) {
    var is = {};

    is.Number = function(para) { // 判断是不是数字
        return typeof para === 'number';
    }

    is.String = function(para) { // 判断是不是字符串
        return typeof para === 'string';
    }

    is.Boolean = function(para) { // 判断是不是布尔值
        return typeof para === 'boolean';
    }

    is.Null = function(para) { // 判断是不是null
        return null === para;
    }

    is.Undefined = function(para) { // 判断是不是undefined
        return undefined === para;
    }

    is.NaN = function(para) { // 判断是不是NaN
        return window.isNaN(para);
    }

    is.Array = function(para) { // 判断是不是数组
        return Object.prototype.toString.call(para) === '[object Array]';
    }

    is.PlainObject = function(para) { // 判断是不是PlainObject
        return Object.prototype.toString.call(para) === '[object Object]';
    }

    is.Function = function(para) { // 判断是不是函数
        return Object.prototype.toString.call(para) === '[object Function]'
    }

    is.is = function(typeInfo, para) { //
        if (arguments.length < 2) {
            throw new Error('parameters is needed more than one');
        } else if (typeof arguments[0] !== 'string') {
            throw new TypeError('the first parameter should be a string');
        }
        // var isType = false;
        for (var prop in is) {
            if (is.hasOwnProperty(prop)) {
                if (prop.toLowerCase() === typeInfo.toLowerCase() && Object.prototype.toString.call(is[prop]) === '[object Function]') {
                    return is[prop](para);
                }
            }
        }

    }

    window.is = is;
})(window);
