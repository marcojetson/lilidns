require 'sinatra/assetpack'

assets {
  serve '/static/js', from: 'public/static/js'
  serve '/static/css', from: 'public/static/css'
  serve '/static/img', from: 'public/static/img'

  js :main, '/static/js/build.js', [
    '/static/js/bootstrap.js',
    '/static/js/ZeroClipboard.min.js',
    '/static/js/jquery.notification.js',
    '/static/js/app.js'
  ]

  css :main, '/static/css/build.css', [
    '/static/css/bootstrap.min.css',
    '/static/css/theme.css',
    '/static/css/notification.css'
  ]

  js_compression  :jsmin
  css_compression :simple
}