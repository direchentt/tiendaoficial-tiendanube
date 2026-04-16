{# Toggle claro/oscuro + View Transitions (ver style-async: brand-theme-view-transition) #}
<span class="utilities-container d-inline-block">
  <button
    type="button"
    class="js-color-scheme-toggle btn btn-utility utilities-item brand-theme-toggle"
    aria-label="{{ 'Cambiar tema claro u oscuro' | translate }}"
    title="{{ 'Cambiar tema' | translate }}"
  >
    <span class="brand-theme-toggle__icon brand-theme-toggle__icon--moon" aria-hidden="true">
      <svg class="icon-inline header-utility-svg" width="20" height="20"><use xlink:href="#brand-theme-moon"/></svg>
    </span>
    <span class="brand-theme-toggle__icon brand-theme-toggle__icon--sun" aria-hidden="true">
      <svg class="icon-inline header-utility-svg" width="20" height="20"><use xlink:href="#brand-theme-sun"/></svg>
    </span>
  </button>
</span>
