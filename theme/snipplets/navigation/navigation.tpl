<div class="nav-desktop">
    <ul class="js-nav-desktop-list nav-desktop-list" data-store="navigation" data-component="menu">
        <span class="js-nav-desktop-list-arrow js-nav-desktop-list-arrow-left nav-desktop-list-arrow nav-desktop-list-arrow-left disable" style="display: none">
            <svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#chevron"/></svg>
        </span>
        {% include 'snipplets/navigation/navigation-nav-list.tpl' with {'megamenu' : true } %}
        <span class="js-nav-desktop-list-arrow js-nav-desktop-list-arrow-right nav-desktop-list-arrow nav-desktop-list-arrow-right" style="display: none">
            <svg class="icon-inline icon-lg"><use xlink:href="#chevron"/></svg>
        </span>
    </ul>
</div>