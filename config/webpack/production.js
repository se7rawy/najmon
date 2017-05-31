// Note: You must restart bin/webpack-dev-server for changes to take effect

const webpack = require('webpack');
const merge = require('webpack-merge');
const CompressionPlugin = require('compression-webpack-plugin');
const sharedConfig = require('./shared.js');
const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin;
const OfflinePlugin = require('offline-plugin');
const { publicPath } = require('./configuration.js');
const fs = require('fs');
const path = require('path');

module.exports = merge(sharedConfig, {
  output: { filename: '[name]-[chunkhash].js' },
  devtool: 'source-map', // separate sourcemap file, suitable for production
  stats: 'normal',

  plugins: [
    new webpack.optimize.UglifyJsPlugin({
      sourceMap: true,
      mangle: true,

      compress: {
        warnings: false,
      },

      output: {
        comments: false,
      },
    }),
    new CompressionPlugin({
      asset: '[path].gz[query]',
      algorithm: 'gzip',
      test: /\.(js|css|html|json|ico|svg|eot|otf|ttf)$/,
    }),
    new BundleAnalyzerPlugin({ // generates report.html and stats.json
      analyzerMode: 'static',
      generateStatsFile: true,
      statsOptions: {
        // allows usage with http://chrisbateman.github.io/webpack-visualizer/
        chunkModules: true,
      },
      openAnalyzer: false,
      logLevel: 'silent', // do not bother Webpacker, who runs with --json and parses stdout
    }),
    new OfflinePlugin({
      publicPath: publicPath, // sw.js must be served from the root to avoid scope issues
      excludes: [
        '**/.*',
        '**/*.map',
        '**/*.gz',
        '**/*.eot',
        '**/*.ttf',
        '**/*.woff', // only cache woff2 fonts; browsers that support SW support this
      ],
      autoUpdate: 1000 * 60 * 60 * 6, // update every 6 hours
      ServiceWorker: {
        entry: path.join(__dirname, '../../app/javascript/mastodon/service_worker/entry.js'),
        cacheName: 'mastodon',
        output: '../sw.js',
        publicPath: '/sw.js',
        // credentials (cookies) are required to access HTML files
        prefetchRequest: {
          credentials: 'include',
        },
        minify: false,
      },
    }),
  ],
});
