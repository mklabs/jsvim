
// var vim = require('jsvim');

var vim = require('../');

// XXX conversion from Ctrl+K like mapping to <C-K>, same Cmd, etc.
// XXX find a way to deal with callback value, dnode?

// the API is chainable, every method returns the vim instance

vim.set('g:foobar', 'Hello');

vim.set({
  scope: 'global', // script, buffer, etc.
  name: 'barrrr',
  value: 'Hello'
});

// a simple echo
vim.echo('Hello from node land');

//
// - some user-defined commands
//

// makes te :HelloFromNode command available, defaults to <bar> <buffer> -nargs=*
vim.command('HelloFromNode', 'echo "foo"');


// this would kind of super nice to be able to register callback...
// noop for now
//
//      vim.command('HelloCallback', function(err) {
//        console.log('that would be awesome.');
//        vim.echo('echo from node');
//      });


//
// - some keymapping examples
//
// for now, all the mapping is done using the noremap forms of map commands
//

// Setup Ctrl+K to map the `dd` operation (delete current line)
vim.nmap('<C-K>', { buffer: true }, 'dd"');

// Setup Ctrl+K in insert mode to trigger omnicompletion active for the
// given filetype, let's setup this to <Tab> too.
vim.imap('<C-K>', '<C-X><C-O>');
vim.imap('<Tab>', '<C-X><C-O>');

// noop for now
// vim.nmap('<C-K>', { buffer: true }, function() {
//   console.log('same for mapping');
// });

// emit the end event, this results in the JSON stream piped to stdout
vim.end();


//
// vim.nmap()
// vim.nnoremap()
// vim.imap()
// vim.inoremap()
// ...
