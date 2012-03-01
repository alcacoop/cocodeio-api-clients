cocode.io API clients
=====================

cocode.io is a real-time web collaborative code editor. Our service is currently in beta (http://cocode.io/beta) 
but any invited user could use our HTTP API to create new "cocoding sessions" populated  with local data.

This is our first step on the road to a better integration between cocode.io and your development environment.

If you want to try it out, you can request an invite visiting the link below:

* http://cocode.io/beta

For further info, feel free to contact us on:

* [@cocodeio (twitter)](https://twitter.com/#!/cocodeio)
* [+cocodeio (google+)](https://plus.google.com/110953439702828767840/posts)
* [cocode.io@alcacoop.it](mailto:cocode.io@alcacoop.it)

If you are one of our **beta heroes** and you'd like to integrate your favourite
IDE or code editor, please fork this project, develop your own plugin and send us a pull request :-D

HTTP API
--------

Currently there's only one possible API call for creating new sessions.

### Authentication

At this time only beta users could use this API and user credentials are needed using HTTP Basic Authentication 
method. E.g.:

```
$ curl -u "username:PASSWORD" ... OTHER_ARGS
```

### Create a new session 

    POST /api/session

#### Input

Description
: _Optional_ **string** - Cocode Session/Github Gist Description

Files
: _Required_ **array** - Cocode Session/Github Gist Files, an array of hash with content:

  Filename
  : _Required_ **string** - File name

  Content
  : _Required_ **string** - File contents
  
```
{
  "Description": "My Example Session",
  "Files": [{
    "Filename": "example.js",
    "Content": "alert("Hello World!!!");"
  },...]
}
```

#### Response

##### Success

HTTP Status Code
: 200

HTTP Body
: new session url (e.g. "https://cocode.io/session/XYZ")

##### Invalid Request

HTTP Status Code
: 400 (Bad Request)

HTTP Body
: error message (e.g. "Invalid Request")

Returned in case of invalid data sent in the request.

##### Unauthorized

HTTP Status Code
: 401 (Unauthorized)

HTTP Body
: error message (e.g. "Unhauthorized")

Returned in case of invalid or missing beta user authentication.

Emacs: cocodeio.el
------------------

We use emacs as our development environment and we've already written some simple emacs integrations.

### Installation

Copy **cocodeio.el** into your emacs load path and add to your dotemacs something
like:

```
;;;;;;; COCODEIO
(require 'cocodeio)

;; add a "cocodeio session from buffer" shortcut `C-c c b'
(global-set-key [(control ?c) (?c) (?b)]
'cocodeio-create-session-from-buffer)

;; add a "cocodeio session from region" shortcut `C-c c r'
(global-set-key [(control ?c) (?c) (?r)]
'cocodeio-create-session-from-region)
```

**cocodeio.el** depends on **json.el** (tested using v. 1.2) and should work correctly
using the version bundled into emacs-23

### Configuration

You needs to configure and save your credentials using customize-group:

```
(customize-group cocodeio)
```
