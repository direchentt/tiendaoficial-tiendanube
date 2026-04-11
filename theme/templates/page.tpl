{% embed "snipplets/page-header.tpl" %}
	{% block page_header_text %}{{ page.name }}{% endblock page_header_text %}
{% endembed %}

{# Institutional page  #}

<section class="user-content brand-page-user-content pb-5 pt-md-1">
	<div class="container-fluid">
		<div class="row justify-content-center">
			<div class="col-12 col-lg-10 col-xl-8 brand-page-rail">
				<div class="user-content-body">
					{{ page.content }}
				</div>
			</div>
		</div>
	</div>
</section>
