

var Vim = require('./jsvim/vim');

var vim = module.exports = new Vim();

// expose the raw Vim Class

vim.Vim = Vim;

// might change, by default pipe the result of Vim stream to stdout

vim.pipe(process.stdout);


