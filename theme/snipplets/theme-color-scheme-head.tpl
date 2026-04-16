{# Aplica preferencia antes del paint (evita flash). Clave: store-color-scheme #}
<script>
(function () {
  try {
    var t = localStorage.getItem('store-color-scheme');
    if (t === 'dark' || t === 'light') {
      document.documentElement.setAttribute('data-color-scheme', t);
    } else {
      document.documentElement.setAttribute('data-color-scheme', 'light');
    }
  } catch (e) {
    document.documentElement.setAttribute('data-color-scheme', 'light');
  }
})();
</script>
