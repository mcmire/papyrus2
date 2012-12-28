
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
    , addClass = function (elem, klass) {
        var classes = elem.className.split(" ")
        classes.push(klass)
        elem.className = classes.join(" ")
      }

  window.addEventListener('load', function () {
    var trs
      , headers
      , hrs = []
      , headerRows = []

    trs = document.querySelectorAll('tr[id]')
    each(trs, function (tr) {
      var docsElem = tr.querySelector('.docs')
        , pilcrowWrapper = docsElem.children[0]
        , pilcrow, link
      if (pilcrowWrapper && pilcrowWrapper.childNodes.length) {
        link = document.createElement('a')
        link.href = '#' + tr.getAttribute('id')
        link.innerHTML = "&#182;"
        pilcrow = document.createElement('div')
        addClass(pilcrow, 'pilcrow')
        pilcrow.appendChild(link)
        // insert as the first node
        pilcrowWrapper.insertBefore(pilcrow, pilcrowWrapper.childNodes[0])
      }
    })

    addClass(document.querySelector('tbody > tr:nth-child(1)'), 'description')

    hrs.push(document.querySelector('tbody > tr:nth-child(2)'))

    headers = document.querySelectorAll('.docs h2, .docs h3, .docs h4')
    each(headers, function (header) {
      var tr = header.parentNode.parentNode
      hrs.push(tr)
      headerRows.push(tr)
    })
    codes = document.querySelectorAll('.code pre')
    each(codes, function (code) {
      if (/\s*(?:def \w+|attr_reader|attr_writer|attr_accessor)/.test(code.innerText)) {
        hrs.push(code.parentNode.parentNode.parentNode)
      }
    })

    each(hrs, function (hr) {
      addClass(hr, 'hr')
      if (hr.previousElementSibling) {
        addClass(hr.previousElementSibling, 'pre-hr')
      }
    })
    each(headerRows, function(tr) {
      addClass(tr, 'header')
      if (tr.previousElementSibling) {
        addClass(tr.previousElementSibling, 'pre-header')
      }
    })
  })
})()

