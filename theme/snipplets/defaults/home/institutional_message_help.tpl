{# Welcome and institutional messages that work as examples #}

<section class="section-home {% if not welcome_message %}my-2{% endif %}" data-store="{{ data_store }}">
	<div class="container-fluid">
		{% set title_classes = institutional_message ? 'h2-extra-huge-md h3-huge mb-3' : 'h1-huge mb-3' %}
		<h2 class="{{ title_classes }}">{{ title }}</h2>
		{% if institutional_message %}
			<p class="mb-3">{{ "Usá este texto para compartir información de tu negocio, dar la bienvenida a tus clientes o para contar lo increíble que son tus productos." | translate }}</p>
		{% endif %}
	</div>
</section>


