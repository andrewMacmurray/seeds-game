module.exports = {
  plugins: [
    require("autoprefixer")(),
    require("postcss-import")(),
    require("postcss-custom-media")(),
    require("postcss-clean")(),
    require("postcss-custom-properties")({ preserve: false })
  ]
};
