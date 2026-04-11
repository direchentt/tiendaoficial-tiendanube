{# Mobile Sharing #}

<div class="social-share {% if product.description is empty %}mt-3{% endif %}">
	{# Whatsapp button #}

	{% set social_share_class = 'btn-link font-small text-transform' %}

	<a class="social-share-button d-inline-block d-md-none {{ social_share_class }}" data-network="whatsapp" target="_blank" rel="noopener noreferrer" href="whatsapp://send?text={{ product.social_url }}" title="{{ 'Compartir en WhatsApp' | translate }}" aria-label="{{ 'Compartir en WhatsApp' | translate }}">{{ 'WhatsApp' | translate }}</a>

	{# Facebook button #}
	<a class="social-share-button {{ social_share_class }}" data-network="facebook" target="_blank" rel="noopener noreferrer" href="https://www.facebook.com/sharer/sharer.php?u={{ product.social_url }}" title="{{ 'Compartir en Facebook' | translate }}" aria-label="{{ 'Compartir en Facebook' | translate }}">{{ 'Facebook' | translate }}</a>

	{# Twitter button #}
	<a class="social-share-button {{ social_share_class }}" data-network="twitter" target="_blank" rel="noopener noreferrer" href="https://twitter.com/share?url={{ product.social_url }}" title="{{ 'Compartir en Twitter' | translate }}" aria-label="{{ 'Compartir en Twitter' | translate }}">{{ 'Twitter' | translate }}</a>

	{# Pinterest button #}
	<a class="js-pinterest-share social-share-button {{ social_share_class }}" data-network="pinterest" target="_blank" rel="noopener noreferrer" href="#" title="{{ 'Compartir en Pinterest' | translate }}" aria-label="{{ 'Compartir en Pinterest' | translate }}">{{ 'Pinterest' | translate }}</a>

	<div class="pinterest-hidden social-share-button" style="display: none;" data-network="pinterest">
		{{product.social_url | pin_it('https:' ~ product.featured_image | product_image_url('large'))}}
	</div>
</div>