
TagGenerator = require './tag-generator'
CacheProvider = require './cache-provider'
ctags = require 'ctags'
fs = require "fs"
path = require "path"

getTagsFile = (directoryPath) ->
  tagsFile = path.join(directoryPath, ".tags")
  return tagsFile if fs.existsSync(tagsFile)

matchOpt = {matchBase: true}
module.exports =
  activate: () ->
    @cacheProvider = new CacheProvider()
    @cacheProvider.initialize

  deactivate: ->
    @cacheProvider.finalize

  initTags: (paths, auto)->
    return if paths.length == 0
    for p in paths
      tagsFile = getTagsFile(p)
      if tagsFile
        @readTags(tagsFile, @cacheProvider)
      else
        @generateTags(p) if auto

  initExtraTags: (paths) ->
    for p in paths
      p = p.trim()
      continue unless p
      @readTags(p, @cacheProvider)

  readTags: (p, container, callback) ->
    console.log "[atom-ctags:readTags] #{p} start..."
    startTime = Date.now()

    stream = ctags.createReadStream(p)

    stream.on 'error', (error)->
      console.error 'atom-ctags: ', error

    stream.on 'data', (tags)->
      # sorted tag make tags with same name are adjacent,
      # for unsorted tags file, fetch array, then append and put into cache
      sameTagName = []
      tagName = ''
      for tag in tags
        continue unless tag.pattern
        if sameTagName.length is 0
          tagName = tag.name
          sameTagName.push(tag)
        else if tag.name == tagName
          sameTagName.push(tag)
        else
          container.append(tagName, sameTagName)
          tagName = tag.name
          sameTagName = [tag]

    stream.on 'end', ()->
      console.log "[atom-ctags:readTags] #{p} cost: #{Date.now() - startTime}ms"
      callback?()

  #options = { partialMatch: true, maxItems }
  findTags: (prefix, options) ->
    @searchCache(prefix, options)

    #TODO: prompt in editor
    #console.warn("[atom-ctags:findTags] tags empty, did you RebuildTags or set extraTagFiles?") if tags.length == 0
    #return tags

  searchCache: (tag, options)->
      @cacheProvider.get(tag)

  findOf: (source, tags, prefix, options)->
    for key, value of source
      for tag in value
        if options?.partialMatch and tag.name.indexOf(prefix) == 0
          tags.push tag
        else if tag.name == prefix
          tags.push tag
        return true if options?.maxItems and tags.length == options.maxItems
    return false

  generateTags:(p, isAppend, callback) ->
    startTime = Date.now()
    console.log "[atom-ctags:rebuild] start @#{p}@ tags..."

    cmdArgs = atom.config.get("atom-ctags.cmdArgs")
    cmdArgs = cmdArgs.split(" ") if cmdArgs

    TagGenerator p, isAppend, @cmdArgs || cmdArgs, (tagpath) =>
      console.log "[atom-ctags:rebuild] command done @#{p}@ tags. cost: #{Date.now() - startTime}ms"

      startTime = Date.now()
      @readTags(tagpath, @cachedTags, callback)

  getOrCreateTags: (filePath, callback) ->
    tags = @cachedTags[filePath]
    return callback?(tags) if tags

    @generateTags filePath, true, =>
      tags = @cachedTags[filePath]
      callback?(tags)
