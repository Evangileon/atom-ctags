leveldb = require "leveldb"

module.exports =
class CacheProvider
  db = null
  initialize: (file)->
    db = leveldb(file)

  get: (key)->
    if db?
      return new Promise (resolve) => db.get(key, resolve)

  put: (key, value)->
    unless db return
    err_handler = (err)->
      if (err) return console.log('Fail to put value!', err)
    db.put(key, value, err_handler)

  del: (key)->
    unless db return
    err_handler = (err)->
      if (err) return console.log('Fail to delete value!', err)
    db.del(key, err_handler)
