
var util = require('util'),
  stream = require('stream');

module.exports = Vim;

function Vim(opts) {
  this.readable = true;
  this.writable = true;

  this.commands = [];

  stream.Stream.call(this);
}

util.inherits(Vim, stream.Stream);

Vim.prototype.set = function(name, value) {
  var data = {};
  // no value given, assume a single object
  if(!value) data = name;

  data.name = data.name || name;
  // parse the given name, for vim scoping default to global
  var parts = data.name.split(':'),
    scope = parts.length > 1 ? parts[0] : 'g';

  data.scope = (data.scope || scope).charAt(0);
  data.value = data.value || 0;
  data.name = parts.length > 1 ? parts[1] : (data.name || name);

  // XXX Better and mode type coercion
  data.value = typeof data.value === 'string' ? '"' + data.value + '"' : data.value;

  this.add('set', data);
  return this;
};

Vim.prototype.echo = function(str) {
  return this.add('echo', {
    message: str
  });
};

// :h command
Vim.prototype.command = function(cmd, value) {
  // XXX find a way to deal with callback value, dnode?
  if(typeof value !== 'string') return;
  return this.add('command', {
    name: cmd,
    bang: true,
    nargs: '*',
    trigger: value
  });
};

Vim.prototype.nmap = function(key, o, value) {
  if(!value) value = o, o = {};
  // XXX find a way to deal with callback value, dnode?
  if(typeof value !== 'string') return;
  return this.add('nmap', {
    key: key,
    buffer: typeof o.buffer != null ? o.buffer : true,
    trigger: value
  });
  return this;
};

Vim.prototype.imap = function(key, o, value) {
  if(!value) value = o, o = {};
  // XXX find a way to deal with callback value, dnode?
  if(typeof value !== 'string') return;
  return this.add('imap', {
    key: key,
    buffer: typeof o.buffer != null ? o.buffer : true,
    trigger: value
  });
  return this;
};

// Stream API

Vim.prototype.write = function(chunk) {
  this.emit('data', chunk);
};

Vim.prototype.end = function() {
  var json = JSON.stringify(this.commands, null, 2);
  this.emit('data', json);
  this.emit('end');
};

// Utilities

Vim.prototype.error = function(err) {
  if(!(err instanceof Error)) err = new Error(err);
  this.emit('error', err);
};

Vim.prototype.add = function(cmd, data) {
  this.commands = this.commands.concat({
    cmd: cmd,
    data: data
  });
  return this;
};
