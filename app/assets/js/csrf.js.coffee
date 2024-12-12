getMetaContent = (name) ->
  for metaEl in document.getElementsByTagName('meta')
    if metaEl.name == name
      return metaEl.content

export csrfParam = -> getMetaContent('csrf-param')
export csrfToken = -> getMetaContent('csrf-token')
export default csrf = -> {[csrfParam()]: csrfToken()}
