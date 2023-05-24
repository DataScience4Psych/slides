document.addEventListener('DOMContentLoaded', function() {
  var hiddenSlides = document.getElementsByClassName('my-hidden-slide');
  for (var i = 0; i < hiddenSlides.length; i++) {
    hiddenSlides[i].style.display = 'none';
  }
});
