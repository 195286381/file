const path = require('path')
const htmlWebpackPlugin = require('html-webpack-plugin')

module.exports = {
	entry: path.resolve(__dirname, 'app/index.js'),
	output: {
		path: path.resolve(__dirname, 'dist'),
		filename: 'bundle.js'
	},
	module: {
		rules: [
			{test: /\.js$/, use: 'babel-loader'},
			{test: /\.css$/, use: ['style-loader', 'css-loader']}
		]
	},
	plugins: [new htmlWebpackPlugin({
		template: 'app/index.html'
	})]
}
