const htmlmin = require("html-minifier");
const yaml = require("js-yaml");
const markdownIt = require("markdown-it");
const { markdownToTxt } = require("markdown-to-txt");
const markdownItRenderer = new markdownIt();
const { DateTime } = require("luxon");

module.exports = (config) => {
  config.addPassthroughCopy({
    "./src/images": "./images", // images
    "./src/static": "/", // static folders/files
  });

  // filters
  config.addFilter("log", (value) => {
    console.log(value);
    return value;
  });
  config.addFilter("limit", (items, limit) => items.slice(0, limit));
  config.addFilter("markdown", (data) => markdownItRenderer.render(data));
  config.addFilter("plain", (data) => markdownToTxt(data));
  config.addFilter("json", (value, spaces = 2) =>
    JSON.stringify(value, null, spaces).replace(/'/g, "\\'").replace(/"/g, "'")
  );
  config.addFilter("doubleLine", (value) => value.replace(/\n/g, "\n\n"));
  config.addFilter("inline", (value) => value.replace(/\n/g, ""));
  config.addFilter("readableDate", (dateObj) => {
    return DateTime.fromJSDate(dateObj, { zone: "utc" }).toFormat("dd LLL yyyy");
  });

  // yaml
  config.addDataExtension("yaml", (contents) => yaml.load(contents));

  // minify
  config.addTransform("htmlmin", function (content, outputPath) {
    if (outputPath.endsWith(".html")) {
      let minified = htmlmin.minify(content, {
        useShortDoctype: true,
        removeComments: true,
        collapseWhitespace: true,
      });
      return minified;
    }

    return content;
  });

  return {
    dir: {
      input: "src",
      // ⚠️ These values are both relative to your input directory.
      includes: "_includes",
      layouts: "_layouts",
    },
    htmlTemplateEngine: "njk",
  };
};
