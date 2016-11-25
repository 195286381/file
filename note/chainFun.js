// 链式函数对象
function  ChainFunc() {
}

ChainFunc.prototype.after = function (func) {
	if(Object.prototype.toString.call(func) === '[object Function]') {
		this.funcs = this.funcs || [];
		this.funcs.push(func);
	}
	return this;
}

ChainFunc.prototype.before = function (func) {
	if(Object.prototype.toString.call(func) === '[object Function]') {
		this.funcs = this.funcs || [];
		this.funcs.unshift(func);
	}
	return this;
}

ChainFunc.prototype.play = function (func) {
	if (this.funcs) {
		for (var i = 0; i < this.funcs.length; i++){
			if (this.funcs[i]() === false) {
				return false;
			}
			this.funcs
		}
	}
}

var arrayFunc = new ChainFunc();
arrayFunc
	.after(function () {
	console.log(1);
	})
	.after(function () {
	console.log(2);
	})
	.before(function() {
	console.log(333);
	})
	.play();
