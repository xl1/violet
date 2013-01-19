$ = (id) -> document.getElementById id

main = ->
  movie = bonsai.setup(
    runnerContext: bonsai.IframeRunnerContext
  ).run document.body, {
    width: innerWidth, height: innerHeight
    url: 'script/code.js'
  }

document.addEventListener 'DOMContentLoaded', main, false