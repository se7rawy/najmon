// Note: You must restart bin/webpack-dev-server for changes to take effect

/* eslint global-require: 0 */
/* eslint import/no-dynamic-require: 0 */

const webpack = require('webpack');
const { basename, dirname, join, relative, resolve } = require('path');
const { sync } = require('glob');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const ManifestPlugin = require('webpack-manifest-plugin');
const extname = require('path-complete-extname');
const { env, paths, publicPath, loadersDir } = require('./configuration.js');
const localePackPaths = require('./generateLocalePacks');

const extensionGlob = `**/*{${paths.extensions.join(',')}}*`;
const packPaths = sync(join(paths.source, paths.entry, extensionGlob));
const entryPacks = [].concat(packPaths).concat(localePackPaths);

module.exports = {
  entry: entryPacks.reduce(
    (map, entry) => {
      const localMap = map;
      let namespace = relative(join(paths.source, paths.entry), dirname(entry));
      if (namespace === '../../../tmp/packs') {
        namespace = ''; // generated by generateLocalePacks.js
      }
      localMap[join(namespace, basename(entry, extname(entry)))] = resolve(entry);
      return localMap;
    }, {}
  ),

  output: {
    filename: '[name].js',
    chunkFilename: '[name]-[chunkhash].js',
    path: resolve(paths.output, paths.entry),
    publicPath,
  },

  module: {
    rules: sync(join(loadersDir, '*.js')).map(loader => require(loader)),
  },

  plugins: [
    new webpack.EnvironmentPlugin(JSON.parse(JSON.stringify(env))),
    new ExtractTextPlugin(env.NODE_ENV === 'production' ? '[name]-[hash].css' : '[name].css'),
    new ManifestPlugin({ fileName: paths.manifest, publicPath, writeToFileEmit: true }),
    new webpack.optimize.CommonsChunkPlugin({
      name: 'common',
      minChunks: (module, count) => {
        if (module.resource && /node_modules\/react-intl/.test(module.resource)) {
          // skip react-intl because it's useless to put in the common chunk,
          // e.g. because "shared" modules between zh-TW and zh-CN will never
          // be loaded together
          return false;
        }

        if (module.resource && /node_modules\/font-awesome/.test(module.resource)) {
          // extract vendor css into common module
          return true;
        }

        return count >= 2;
      },
    }),
  ],

  resolve: {
    extensions: paths.extensions,
    modules: [
      resolve(paths.source),
      resolve(paths.node_modules),
    ],
  },

  resolveLoader: {
    modules: [paths.node_modules],
  },

  node: {
    // Called by http-link-header in an API we never use, increases
    // bundle size unnecessarily
    Buffer: false,
  },
};
