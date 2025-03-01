# Pin npm packages by running ./bin/importmap

pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
# pin_all_from "app/javascript/front", under: "front"
pin "jquery-3.6.0", preload: true
pin "application", preload: true

pin "popper", to: 'popper.js', preload: true
pin "bootstrap", to: 'bootstrap.min.js', preload: true
# pin "front/bootstrap-select.min"
# pin "front/jquery.mmenu.all"
# pin "front/ace-responsive-menu"
# pin "front/isotop"
# pin "front/snackbar.min"
# pin "front/simplebar"
# pin "front/parallax"
# pin "front/scrollto"
# pin "front/jquery-scrolltofixed-min"
# pin "front/jquery.counterup"
# pin "front/wow.min"
# pin "front/progressbar"
# pin "front/slider"
# pin "front/scrollbalance"
# pin "front/script"
pin "trix"
pin "@rails/actiontext", to: "actiontext.esm.js"
