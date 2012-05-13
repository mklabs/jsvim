
jsvim
=====

Might be silly but.. What if we could configure and write Vim plugins
with nothing but JavaScript?

Vim has built-in support and interface to Python, Lua, Ruby and probably
others I don't know. Sadly, there is not (yet, but pretty sure it'll
come) such interface to JavaScript. See `:h ruby` or `:h python`.

This is just an experiment at using node scripts and a basic API to
bridge some common functions and utilities from JavaScript / node land
to Vim's land.

This is pretty much a first implementation, exploring the idea.

Requirements
------------

vim < 7.0 || node < 0.6.x

Intro
-----

`jsvim` can be seen as a framework to extend the Vim text-editor with a
JavaScript Api. This works by relying on a simple "protocol" between
node's land and Vim's land.

Node scripts simply stream to stdout valid JSON stream, whose output
match the requirements of the given "protocol". Vim's plugin simply
spawn at specific lifecyle time given scripts, which output is then
parsed through the minimalist and most excellent JSON to Vim dictionnary
parser by Tim Pope, borrowed from
[vim-rhubarb](https://github.com/tpope/vim-rhubarb).

Scripts should output JSON with the following form, an array of Hash
objects:

```json
[{
  "cmd": "set",
  "data": ["String', "or", { "hash": "object" }]
}, ...]
```

This is then parsed and converted into dictionnaries back into Vim,
which then iterates through each command item, and trigger the matching
code and according logic from Vim's land.

Register a bundle
-----------------

The plugin will try to load and handle "js bundles" that were registered
during Vim bootstraping. This can be seen as very simplified version of
how pathogen includes plugin in the vim runtimepath.

```vim
" runtime can be user instead of source, if the plugin is stored within
" one of the vim runtime paths (like ~/.vim/bundle)
source ~/src/vim/bundle/vim-pathogen/autoload/pathogen.vim
call jsvim#register('~/path/to/my/js/bundles')
```

The directory that is registered should contain various `.js` file (like
`init.js`)

Events
------

Specific scripts are executed at specific time, here's a non exhaustive
list of these (right now, only VimEnter event is handled):

* VimEnter: trigger the init.js script
* BufRead, BufNewFile: triggers the newfile.js script
* Filetype: triggers the filetype.js script
* ...

Each script is given command lines arguments and / or input stream (to
read from stdin) that are specific to each events. For instance, the
filetype script is given information about the vim filetype (js, python,
etc) and file's name and path(`<afile>`).


Api
---

Scripts may require the `jsvim` to access the following API. Most of the
commands are EventEmitters.

Basically, every part of the API is building a model that is converted
back to JSON that conforms to the appropriate interface. Can be sync
or async.

Every scripts must call the `.end()` method or trigger the `end` event
once they're ready to stream back the resulting JSON.


**Example**

```js

var vim = require('jsvim');

// the API is chainable, every method returns the vim instance

vim.set('g:foobar', 'Hello');

vim.set({
  scope: 'global', // script, buffer, etc.
  name: 'barrrr',
  value: 'Hello'
});

// a simple echo
vim.echo('Hello from node land');

// - some user-defined commands
// makes the :HelloFromNode command available
// defaults to <bar> <buffer> -nargs=*
vim.command('HelloFromNode', 'echo "foo"');

// this would kind of super nice to be able to register callback...
//
// noop for now
vim.command('HelloCallback', function(err) {
  console.log('that would be awesome.');
  vim.echo('echo from node');
});


//
// - some keymapping examples
//
// for now, all the mapping is done using the noremap forms of map commands
//

// Setup Ctrl+K to map the `dd` operation (delete current line)
vim.nmap('<C-K>', { buffer: true }, 'dd"');

// Setup Ctrl+K and Ctrl-Space in insert mode to trigger omnicompletion active
// for the given filetype
vim.imap('<C-K>', '<C-X><C-O>');
vim.imap('<C-Space>', '<C-X><C-O>');

// noop for now
vim.nmap('<C-K>', { buffer: true }, function() {
  console.log('same for mapping');
});

// emit the end event, this results in the JSON stream piped to stdout
vim.end();

```

