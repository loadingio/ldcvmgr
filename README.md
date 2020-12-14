# ldcvmgr

ldcover manager.

## Installation


## Usage

include required js file, and create a ldcvmgr instance:

    ldcvmgr = new ldcvmgr({ ... });


## Options

 - path: where to find cache-missed ldcover html files. default `/modules/cover`
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


## LICENSE

MIT
