{% if primary_links %}
    <div class="nav-primary">
        <ul class="nav-list" data-store="navigation" data-component="menu">
            {% include 'snipplets/navigation/navigation-nav-list.tpl' with { 'hamburger' : true  } %}
        </ul>
    </div>
{% else %}
	<div class="nav-secondary text-left brand-mobile-account-wrap" data-store="account-links">
		{% include 'snipplets/navigation/navigation-mobile-account-cta.tpl' %}
	</div>
{% endif %}