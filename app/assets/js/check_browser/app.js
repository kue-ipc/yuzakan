if (!Array.prototype.with) {
  document.getElementById("obsolete-browser").classList.remove("d-none");
} else if (!Object.groupBy) {
  document.getElementById("deprecated-browser").classList.remove("d-none");
}
