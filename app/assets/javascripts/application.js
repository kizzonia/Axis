//= require jquery-3.6.0
//= require jquery-migrate-3.0.0.min
//= require popper.min
//= require bootstrap
//= require bootstrap-select.min
//= require jquery.mmenu.all
//= require ace-responsive-menu
//= require isotop
//= require snackbar.min
//= require simplebar
//= require parallax

//= require jquery.counterup
//= require wow.min
//= require progressbar
//= require slider
//= require timepicker
//= require toastr

document.addEventListener("DOMContentLoaded", function() {
  tinymce.init({
    selector: 'textarea.tinymce', // Selector for textarea elements
    height: 500,
    menubar: false,
    plugins: [
      'advlist autolink lists link image charmap print preview anchor',
      'searchreplace visualblocks code fullscreen',
      'insertdatetime media table paste code help wordcount'
    ],
    toolbar: 'undo redo | formatselect | bold italic backcolor | \
              alignleft aligncenter alignright alignjustify | \
              bullist numlist outdent indent | removeformat | help'
  });
});
