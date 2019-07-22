# no modern browser

unless window.MODERN_BROWESER
  nodes = document.getElementsByClassName('legacy-browser')
  for node in nodes
    node.classList.remove('d-none')
