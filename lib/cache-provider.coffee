leveldb = require "leveldb"

module.exports =
class CacheProvider
  db = null
  initialize: (file)->
    db = leveldb(file)

  finalize: ()->
    db?.close

  get: (key)->
    if db?
      return new Promise (resolve) => db.get(key, resolve)

  put: (key, value)->
    return unless db
    err_handler = (err)->
      return console.log('Fail to put value!', err) if err
    db.put(key, value, err_handler)

  del: (key)->
    return unless db
    err_handler = (err)->
      return console.log('Fail to delete value!', err)  if err
    db.del(key, err_handler)
