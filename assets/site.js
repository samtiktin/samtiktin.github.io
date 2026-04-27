(function () {
  var navGroups = document.querySelectorAll(".nav-group");
  navGroups.forEach(function (group) {
    var trigger = group.querySelector(".nav-group-trigger");
    if (!trigger) {
      return;
    }

    trigger.addEventListener("click", function (event) {
      if (window.matchMedia("(max-width: 720px)").matches) {
        event.preventDefault();
        group.classList.toggle("open");
      }
    });
  });
})();
