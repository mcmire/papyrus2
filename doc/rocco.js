
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
        var classes
        if ('classList' in elem) {
          elem.classList.add(klass)
        } else {
          classes = elem.className.split(" ")
          hash = {}
          newClasses = []
          classes.push(klass)
          each(classes, function (cls) {
            cls = cls.trim()
            if (!(cls in hash)) {
              hash[cls] = 1
              newClasses.push(cls)
            }
          })
          elem.className = newClasses.join(" ")
        }
      }

  window.addEventListener('load', function () {
    var hrs = []
      , headerRows = []

    /*
    each(document.querySelectorAll('tr[data-parent-index] > .docs > div'), function (div) {
      var img = document.createElement('img')
        , firstChild = div.children[0]
      img.src = "../../../note.png"
      img.className = 'note'
      img.width = 16
      img.height = 16
      firstChild.insertBefore(img, firstChild.childNodes[0])
    })
    */

    each(document.querySelectorAll('tr[id]'), function (tr) {
      var docsElem = tr.querySelector('.docs')
        , pilcrowWrapper = docsElem.children[0].children[0]
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

    each(document.querySelectorAll('tbody > tr:nth-child(1)'), function (tr) {
      addClass(tr, 'description')
    })

    each(document.querySelectorAll('tbody > tr:nth-child(2)'), function (tr) {
      hrs.push(tr)
    })
    each(document.querySelectorAll('.docs h1'), function (header) {
      var tr = header.parentNode.parentNode
      hrs.push(tr)
      headerRows.push(tr)
    })
    each(document.querySelectorAll('.docs h2, .docs h3, .docs h4'), function (header) {
      var tr = header.parentNode.parentNode.parentNode
      hrs.push(tr)
      headerRows.push(tr)
    })
    each(document.querySelectorAll('.code pre'), function (code) {
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

    each(document.querySelectorAll('tr:not([data-parent-index])'), function (tr) {
      var node = tr
        , lastNode
      for (var i = 0; ; i++) {
        if (i > 0) {
          if (!node || !node.hasAttribute('data-parent-index')) {
            addClass(lastNode, 'section-group-last')
            break
          }
          addClass(lastNode, 'section-group')
        }
        lastNode = node
        node = node.nextElementSibling
      }
    })
  })
})()

