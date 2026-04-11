{% set has_footer_menu = settings.footer_menu and settings.footer_menu_show %}
{% set show_footer_logo = "footer_logo.jpg" | has_custom_image and template != 'password' %}
{% set show_right_md_col_logo = show_footer_logo and not settings.news_show %}
<nav class="footer-nav-secondary" aria-label="{{ 'Menú secundario' | translate }}">
	<ul class="list d-flex flex-wrap mb-0 {% if (has_footer_menu and not show_right_md_col_logo) or show_right_md_col_logo %}justify-content-md-between{% endif %}">
		{% for item in menus[settings.footer_menu_secondary] %}
			<li class="mr-2 mr-md-3 mb-2 mb-md-3">
				<a class="btn-link text-transform font-small font-md-body" href="{{ item.url }}" {% if item.url | is_external %}target="_blank" rel="noopener noreferrer"{% endif %}>{{ item.name }}</a>
			</li>
		{% endfor %}
	</ul>
</nav>