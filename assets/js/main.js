(function () {
  var toggle = document.querySelector(".nav-toggle");
  var nav = document.querySelector(".site-nav");
  if (toggle && nav) {
    toggle.addEventListener("click", function () {
      var open = nav.classList.toggle("is-open");
      toggle.setAttribute("aria-expanded", open ? "true" : "false");
    });
  }
  var year = document.getElementById("footer-year");
  if (year) year.textContent = String(new Date().getFullYear());

  var video = document.querySelector(".hero-video");
  var fallback = document.querySelector(".hero-fallback");
  if (video) {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      video.pause();
      video.removeAttribute("autoplay");
    }
    video.addEventListener("error", function () {
      video.style.display = "none";
      if (fallback) fallback.style.display = "block";
    });
  }
})();
