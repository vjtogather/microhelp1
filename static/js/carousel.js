(function () {
  var root = document.querySelector("[data-carousel]");
  if (!root) return;
  var slides = Array.prototype.slice.call(root.querySelectorAll(".feature-slide"));
  var dots = Array.prototype.slice.call(document.querySelectorAll(".carousel-dots button"));
  var current = 0;
  function show(index) {
    current = (index + slides.length) % slides.length;
    slides.forEach(function (slide, i) { slide.classList.toggle("is-active", i === current); });
    dots.forEach(function (dot, i) { dot.classList.toggle("is-active", i === current); });
  }
  var prev = document.querySelector(".carousel-prev");
  var next = document.querySelector(".carousel-next");
  if (prev) prev.addEventListener("click", function () { show(current - 1); });
  if (next) next.addEventListener("click", function () { show(current + 1); });
  dots.forEach(function (dot, i) { dot.addEventListener("click", function () { show(i); }); });
  var timer = window.setInterval(function () { show(current + 1); }, 6500);
  root.addEventListener("mouseenter", function () { window.clearInterval(timer); });
})();
