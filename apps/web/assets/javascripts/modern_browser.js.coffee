# check modern browser

# If yore browser has `globalThis`, it is a modern browser. 
# https://developer.mozilla.org/docs/Web/JavaScript/Reference/Global_Objects/globalThis
# https://github.com/mdn/browser-compat-data/blob/master/javascript/builtins/globals.json

unless globalThis?
  document.getElementById('legacy-browser').classList.remove('d-none')
