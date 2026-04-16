{% set megamenu = megamenu | default(false) %}
{% set hamburger = hamburger | default(false) %}
{% set subitem = subitem | default(false) %}

{% set hamburger_desktop_subpanels_position = settings.logo_position_desktop == 'center' ? 'nav-list-panel-left-md' : 'nav-list-panel-right-md' %}

{% for item in navigation %}
	
	{% if item.subitems %}
		<li class="{% if megamenu %}js-desktop-nav-item js-item-subitems-desktop nav-item-desktop {% if not subitem %}js-nav-main-item nav-dropdown nav-main-item {% endif %}{% endif %} nav-item item-with-subitems" data-component="menu.item">
			{% if megamenu %}
			<div class="nav-item-container">
			{% endif %}
				<a class="{% if hamburger %}js-toggle-menu-panel align-items-center{% endif %} nav-list-link position-relative {{ item.current ? 'selected' : '' }}" href="{% if megamenu and item.url %}{{ item.url }}{% else %}#{% endif %}">{{ item.name }}
					{% if hamburger %}
						<span class="nav-list-arrow ml-1">
							<svg class="icon-inline icon-md svg-icon-text"><use xlink:href="#chevron"/></svg>
						</span>
					{% endif %}
				</a>
			{% if megamenu %}
			</div>
			{% endif %}
			{% if megamenu and not subitem %}
				<div class="js-desktop-dropdown nav-dropdown-content desktop-dropdown">
					<div class="container-fluid desktop-dropdown-container brand-nav-mega">
			{% endif %}
						<ul class="{% if megamenu %}{% if not subitem %}desktop-list-subitems{% endif %} {% else %}js-menu-panel nav-list-panel nav-list-panel-right {{ hamburger_desktop_subpanels_position }} {% endif %} list-subitems" {% if hamburger %}style="display:none;"{% endif %}>
							{% if hamburger %}
								<div class="modal-header">
									<div class="row no-gutters">
										<div class="col">
											<a class="js-toggle-menu-back" href="#">
												<div class="row no-gutters align-items-center">
													<div class="col-auto">
														<span class="modal-back pr-2 mr-1">
															<svg class="icon-inline icon-flip-horizontal svg-icon-text"><use xlink:href="#chevron"/></svg>
														</span>
													</div>
													<div class="col my-3 text-center">
														{{ item.name }}
													</div>
												</div>
											</a>
										</div>
										<div class="col-auto">
											<a class="js-toggle-menu-close js-modal-close modal-close">
												<svg class="icon-inline icon-lg modal-close-icon"><use xlink:href="#times"/></svg>
											</a>
										</div>
									</div>
								</div>
								<div class="modal-body p-0">
									{% if item.isCategory %}
										<li class="nav-item py-1">
											<a class="nav-list-link position-relative font-body py-3 {{ item.current ? 'selected' : '' }}" href="{{ item.url }}">
												{% if item.isRootCategory %}
													{{ 'Ver todos los productos' | translate }}
												{% else %}
													{{ 'Ver todo en' | translate }} {{ item.name }}
												{% endif %}
											</a>
										</li>
									{% endif %}
							{% endif %}

							{% set hamburger_val = false %}
							{% if hamburger %}
								{% set hamburger_val = true %}
							{% endif %}
							{% include 'snipplets/navigation/navigation-nav-list.tpl' with { 'navigation' : item.subitems, 'subitem' : true, 'hamburger' : hamburger_val  } %}
							
							{% if hamburger %}
								</div>
							{% endif %}
						</ul>
			{% if megamenu and not subitem %}
					</div>
				</div>
			{% endif %}
		</li>
	{% else %}
		<li class="js-desktop-nav-item {% if megamenu %}{% if not subitem %}js-nav-main-item nav-main-item{% endif %} nav-item-desktop{% endif %} nav-item" data-component="menu.item">
			<a class="nav-list-link {{ item.current ? 'selected' : '' }}" href="{% if item.url %}{{ item.url | setting_url }}{% else %}#{% endif %}">{{ item.name }}</a>
		</li>
	{% endif %}
{% endfor %}