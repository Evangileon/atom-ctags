leveldb = require "leveldb"

module.exports =
class CacheProvider
  db = null
  initialize: (file)->
    db = leveldb(file)

  get: (key, callback)->
    unless db
      callback([])
      return
    db.get key, (err, value)=>
      if (err) return console.log('Ooops!', err)
      callback(value)

  put: (key, value)->
    unless db return
    err_handler = (err)->
      if (err) return console.log('Ooops!', err)
    db.put(key, value, err_handler)

  del: (key)->
    unless db return
    err_handler = (err)->
      if (err) return console.log('Ooops!', err)
    db.del(key, err_handler)
