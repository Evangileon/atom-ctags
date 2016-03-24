leveldb = require "leveldb"

module.exports =
class CacheProvider
  db = null
  initialize: (file) ->
    db = leveldb(file, {'valueEncoding': 'json'})

  finalize: ->
    db?.close

  # Get a JSON array, if get nothing, resolve an empty object
  get: (key) ->
    if db?
      return new Promise (resolve) =>
        callback = (err, value) =>
          if err?.notFound?
            resolve([])
          else
            resolve(value)
        db.get(key, callback)

  # value is a JSON array
  put: (key, value) ->
    return unless db
    err_handler = (err) ->
      return console.log('Fail to put value!', err) if err
    db.put(key, value, err_handler)

  # append list to end of array value mapped by key
  append: (key, list) ->
    @get(key)?.then (oldList) =>
      newList = oldList.concat list
      @put(key, newList)


  del: (key) ->
    return unless db
    err_handler = (err) ->
      return console.log('Fail to delete value!', err)  if err
    db.del(key, err_handler)
