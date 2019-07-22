(function(){
  "use strict";
  var nodes = document.getElementsByClassName('legacy-browser');
  for (var i = 0, len = nodes.length; i < len; i++) {
    nodes[i].classList.remove('d-none');
  }
})();
