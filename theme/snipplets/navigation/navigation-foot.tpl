<nav class="footer-nav-primary" aria-label="{{ 'Menú del final de la página. (footer)' | translate }}">
	<ul class="list pr-md-5 mb-0">
		{% for item in menus[settings.footer_menu] %}
			<li class="footer-menu-item">
				<a class="h4-huge h2-huge-md footer-menu-link" href="{{ item.url }}" {% if item.url | is_external %}target="_blank" rel="noopener noreferrer"{% endif %}>{{ item.name }}</a>
			</li>
		{% endfor %}
	</ul>
</nav>