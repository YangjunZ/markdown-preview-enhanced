#
#  As the markdown-toc library is very hard to use
#  I decide to write a markdown-toc library by myself
#
uslug = require 'uslug'

nPrefix = (str, n)->
  output = ''
  for i in [0...n]
    output += str
  return output


#
# eg:
#
# Haha [A](www.a.com) xxx [B](www.b.com)
#  should become
# Haha A xxx B
#
# check issue #41
#

sanitizeContent = (content)->
  output = ''
  offset = 0

  # test ![...](...)
  # test [...](...)
  ## <a name="myAnchor"></a>Anchor Header
  r = /\!?\[([^\]]*)\]\(([^)]*)\)|<([^>]*)>([^<]*)<\/([^>]*)>/g
  match = null
  while match = r.exec(content)
    output += content.slice(offset, match.index)
    offset = match.index + match[0].length
    if match[0][0] == '<'
      output += match[4]
    else if match[0][0] != '!'
      output += match[1]
    else # image
      output += match[0]

  output += content.slice(offset, content.length)
  return output

toc = (tokens, ordered)->
  if !tokens or !tokens.length
    return []

  outputArr = []
  tocTable = {}
  smallestLevel = tokens[0].level

  # get smallestLevel
  for i in [0...tokens.length]
    if tokens[i].level < smallestLevel
      smallestLevel = tokens[i].level

  for i in [0...tokens.length]
    token = tokens[i]
    content = token.content
    level = token.level
    slug = uslug(content)

    if tocTable[slug] >= 0
      tocTable[slug] += 1
      slug += '-' + tocTable[slug]
    else
      tocTable[slug] = 0

    listItem = "#{nPrefix('\t', level-smallestLevel)}#{if ordered then '1.' else '-'} [#{sanitizeContent(content)}](##{slug})"
    outputArr.push(listItem)

  return {
    content: outputArr.join('\n'),
    array: outputArr
  }

module.exports = toc
