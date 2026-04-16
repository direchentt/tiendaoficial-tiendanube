{% set depth = depth | default(0) %}
{% set branch_uid = branch_uid | default(0) %}
{% if items and items is not empty %}
	<ul class="brand-hamburger-drawer__sublist brand-hamburger-drawer__sublist--depth-{{ depth }} list-unstyled mb-0">
		{% for sub in items %}
			<li class="brand-hamburger-drawer__subitem{% if sub.subitems %} brand-hamburger-drawer__branch{% endif %}">
				{% if sub.subitems %}
					{% set acc_id = 'brand-h-acc-' ~ branch_uid ~ '-' ~ depth ~ '-' ~ loop.index0 %}
					<div class="brand-hamburger-drawer__branch-head">
						{% if sub.url %}
							<a class="brand-hamburger-drawer__branch-title" href="{{ sub.url | setting_url }}">{{ sub.name }}</a>
						{% else %}
							<span class="brand-hamburger-drawer__branch-title">{{ sub.name }}</span>
						{% endif %}
						<button type="button" class="brand-hamburger-drawer__branch-toggle js-brand-hamburger-accordion-toggle" aria-expanded="false" aria-controls="{{ acc_id }}" aria-label="{{ 'Alternar subcategorías' | translate }}">
							<span class="brand-hamburger-drawer__branch-icon" aria-hidden="true">+</span>
						</button>
					</div>
					<div class="brand-hamburger-drawer__accordion-panel js-brand-hamburger-accordion-panel" id="{{ acc_id }}" role="region" hidden>
						<div class="brand-hamburger-drawer__accordion-panel-inner">
							{% include 'snipplets/navigation/navigation-brand-hamburger-subitems.tpl' with { items: sub.subitems, depth: depth + 1, branch_uid: branch_uid } %}
						</div>
					</div>
				{% else %}
					<a class="brand-hamburger-drawer__sublink {% if depth == 0 %}brand-hamburger-drawer__sublink--root-leaf{% else %}font-small{% endif %}" href="{% if sub.url %}{{ sub.url | setting_url }}{% else %}#{% endif %}">{{ sub.name }}</a>
				{% endif %}
			</li>
		{% endfor %}
	</ul>
{% endif %}
