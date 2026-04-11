{% if infinite_scroll %}
	{% if pages.current == 1 and not pages.is_last %}
		<div class="js-load-more text-center my-4">
			<a class="btn btn-default d-inline-block">
				{{ 'Mostrar más productos' | t }}
				<span class="js-load-more-spinner ml-2" style="display:none;">
					<svg class="icon-inline icon-spin"><use xlink:href="#spinner-third"/></svg>
				</span>
			</a>
		</div>
		<div id="js-infinite-scroll-spinner" class="my-4 text-center w-100" style="display:none">
			<svg class="icon-inline icon-30px svg-icon-text icon-spin"><use xlink:href="#spinner-third"/></svg>
		</div>
	{% endif %}
{% else %}
	<div class="row justify-content-center align-items-center mt-5">
		{% if pages.numbers %}
			<div class="col-auto">
				<a {% if pages.previous %}href="{{ pages.previous }}"{% endif %} class="swiper-button-prev {% if not pages.previous %}opacity-30 disabled{% endif %}">
					<svg class="icon-inline icon-xs icon-flip-horizontal"><use xlink:href="#chevron"/></svg>
				</a>
			</div>
			<div class="col-auto">
				<div class="mx-2 text-center">
					{% for page in pages.numbers %}
						{% if page.selected %}
							<span>{{ page.number }}</span>
						{% endif %}
					{% endfor %}
					<span>{{'de' | translate }}</span>
					<span>{{ pages.amount }}</span>
				</div>
			</div>
			<div class="col-auto">
				<a {% if pages.next %}href="{{ pages.next }}"{% endif %} class="swiper-button-next {% if not pages.next %}opacity-30 disabled{% endif %}">
					<svg class="icon-inline icon-xs"><use xlink:href="#chevron"/></svg>
				</a>
			</div>
		{% endif %}
	</div>
{% endif %}