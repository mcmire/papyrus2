
(function () {
  var isArray = function (obj) {
        return Array.isArray(obj) || (typeof obj === 'object' && 'length' in obj);
      }
    , each = function (obj, fn) {
        if (isArray(obj)) {
          for (var i = 0, len = obj.length; i < len; i++) {
            fn(obj[i], i)
          }
        } else {
          for (var k in obj) {
            fn(k, obj[k])
          }
        }
      }

  window.addEventListener('load', function () {
    var trs = document.querySelectorAll('tr[id]')
      , firstTr = document.querySelector('tbody > tr:first-child')

    each(trs, function (tr) {
      var docsElem = tr.querySelector('.docs')
        , pilcrowWrapper = docsElem.children[0]
        , pilcrow, link
      if (pilcrowWrapper && pilcrowWrapper.childNodes.length) {
        link = document.createElement('a')
        link.href = '#' + tr.getAttribute('id')
        link.innerHTML = "&#182;"
        pilcrow = document.createElement('div')
        pilcrow.className += " pilcrow"
        pilcrow.appendChild(link)
        // insert as the first node
        pilcrowWrapper.insertBefore(pilcrow, pilcrowWrapper.childNodes[0])
      }
    })

    firstTr.className += " description"
  })
})()

