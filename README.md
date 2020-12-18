# ldcvmgr

ldcover manager.

## Installation


## Usage

include required js file, and create a ldcvmgr instance:

    ldcvmgr = new ldcvmgr({ ... });


## Options

 - path: where to find cache-missed ldcover html files. default `/modules/cover`
   - use function ( `path(name)` ) for a more customizable behavior of name-cover pair lookups.
 - loader: ldLoader compatible object for loading indicator when ldcvmgr is fetching remote ldcover html files.
   - default to a fullscreen ldLoader spinner, with class `ldld full`.


## API

 - get(name, param): popup a ldcover `name`, and expect return value from it.
   - when `param` is provided, it will be sent to `on` event as params.
 - set(name, param): resolve popped ldcover `name` with `param`
 - on(name, callback({...})): listen to `name` event
   - on: fired when some ldcover is toggled on. callback params:
     - node: ldcover dom root.
     - params: additional parameters provided when `get` is called.
     - name: toggled ldcover name
   - off: fired when some ldcover is toggled off. similar params with `on`.
 - lock(name): popup a ldcover `name`, and user can't dismiss it.
 - purge(name): clear cache for ldcover `name`.
 - toggle(name,value,param): toggle ldcover `name` with state based on the value (true or false)
   - optional `param` passed to `on` event, just like `get`.
 - getcover(name): return `ldcover` instance of ldcover `name`.
 - getdom(name): return DOM root of ldcover `name`.
 - is-on(name): return true if ldcover `name` is on.


## Note about `path` option

you can set `path` as function to make a more customizable behavior of ldcvmgr. For example, you can define name as:

    locale@variant@name

and invoke `ldcvmgr.get` like this:

    zh-tw@depart-1024@logout


this is an abstract name and there is nothing to do with server file structure, however you can convert it with `path` function into something like this:

    /ldcv/zh-tw/depart-1024/logout.html

furthermore, you can also config your reverse proxy to lookup files ( nginx config for example ):

    location /ldcv/(?<lc>.+)/(?<dep>.+)/(?<name>.+) {
      try_files /intl/$lc/ldcv/$dep/$name.html /intl/$lc/ldcv/generic/$name.html /ldcv/generic/$name.html =404;
    }


## LICENSE

MIT
