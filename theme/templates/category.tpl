{% set has_filters_available = products and has_filters_enabled and (filter_categories is not empty or product_filters is not empty) %}

{# Only remove this if you want to take away the theme onboarding advices #}
{% set show_help = not has_products %}

{% if settings.pagination == 'infinite' %}
	{% paginate by 12 %}
{% else %}
	{% paginate by 48 %}
{% endif %}

{# Lógica del Candado VIP #}
{% set is_vip_locked = false %}
{% if settings.vip_category_enabled and settings.vip_category_handle %}
    {% set handle_lower = settings.vip_category_handle | lower | trim %}
    {% set cat_name_lower = category.name | lower | trim %}
    {% if handle_lower == cat_name_lower or handle_lower in category.url %}
        {% set is_vip_locked = true %}
    {% endif %}
{% endif %}

{% if not show_help %}

    {% if is_vip_locked %}
        <div id="vip-lock-screen" style="display:flex; flex-direction:column; align-items:center; justify-content:center; min-height: 80vh; background:#111; color:#fff; text-align:center; padding: 20px;">
            <svg style="width: 40px; fill:#fff; margin-bottom:20px; opacity:0.8;" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M12 17a2 2 0 100-4 2 2 0 000 4zm6-9v-2c0-3.31-2.69-6-6-6S6 4.69 6 8v2H4v12h16V8h-2zM8 8c0-2.21 1.79-4 4-4s4 1.79 4 4v2H8V8z"/></svg>
            <h1 style="font-family: var(--font-headings); font-size: 2.5rem; letter-spacing:-0.02em; margin-bottom:10px;">{{ category.name }}</h1>
            <p style="font-size: 1.1rem; color: #aaa; margin-bottom: 30px; max-width: 400px; line-height:1.5;">
                {% if settings.vip_category_message %}
                    {{ settings.vip_category_message }}
                {% else %}
                    Área VIP protegida. Ingresá la contraseña exclusiva para acceder.
                {% endif %}
            </p>
            <form id="vip-form" style="display:flex; max-width: 400px; width:100%; gap: 10px;">
                <input type="password" id="vip-pwd" placeholder="Contraseña secreta" style="flex:1; padding: 15px; border:1px solid #333; background:#000; color:#fff; border-radius:0; outline:none;" required />
                <button type="submit" style="background:#fff; color:#000; border:none; padding: 0 25px; font-weight:bold; letter-spacing:0.05em; text-transform:uppercase; cursor:pointer;">Entrar</button>
            </form>
            <div id="vip-error" style="display:none; color: #ff5555; margin-top:15px; font-size: 0.9rem;">Contraseña incorrecta. Intentalo de nuevo.</div>
        </div>
    {% endif %}

    <div id="vip-content" style="{% if is_vip_locked %}display:none; opacity:0; transition: opacity 0.5s ease;{% endif %}">
        {% include 'snipplets/brand/brand-promo-split.tpl' %}
        {% include 'snipplets/brand/brand-split-video-hero.tpl' %}

        {% set category_banner = (category.images is not empty) or ("banner-products.jpg" | has_custom_image) %}
        {% set has_category_description_without_banner = not category_banner and category.description %}

        {% if category_banner %}
            {% include 'snipplets/category-banner.tpl' %}
        {% endif %}

        {% if not category_banner or category.description or products %}
            <div class="container-fluid">
                {% if products %}
                    {% if category_banner %}
                        {% include 'snipplets/grid/catalog-nav-strip.tpl' with { nav_breadcrumbs_class: 'mt-2 mb-0' } %}
                    {% else %}
                        {% set _nav_pad = category.description ? 'pt-3 pb-1' : 'py-2' %}
                        <div class="{{ _nav_pad }}">
                            {% include 'snipplets/grid/catalog-nav-strip.tpl' with { nav_category_title: category.name, nav_breadcrumbs_class: 'mb-0' } %}
                        </div>
                    {% endif %}
                {% elseif category_banner %}
                    {% include 'snipplets/breadcrumbs.tpl' with {breadcrumbs_custom_class: 'mt-2 mb-0'} %}
                {% else %}
                    {% set page_header_padding = category.description ? false : true %}
                    {% set page_header_classes = category.description ? 'pt-4 pb-2 pt-md-4 pb-md-2' %}
                    {% embed "snipplets/page-header.tpl" with {container: false, padding: page_header_padding, page_header_class: page_header_classes} %}
                        {% block page_header_text %}{{ category.name }}{% endblock page_header_text %}
                    {% endembed %}
                {% endif %}
                {% set category_desc_trim = category.description | trim %}
                {% if category_desc_trim != '' %}
                    <p class="{% if category_banner %}mt-2 py-md-2 mb-0{% else %}mb-4 pb-1{% endif %}">{{ category.description }}</p>
                {% endif %}
            </div>
        {% elseif category_banner %}
            <div class="container-fluid">
                {% include 'snipplets/breadcrumbs.tpl' with {breadcrumbs_custom_class: 'mt-2 mb-0'} %}
            </div>
        {% endif %}

        {% include 'snipplets/grid/filters-modals.tpl' %}

        <section class="category-body {% if settings.filters_desktop_modal %}pt-md-2{% endif %}" data-store="category-grid-{{ category.id }}" aria-label="{{ category.name }}: {{ 'Listado de productos' | translate }}">
            <div class="container-fluid mt-2 mb-5">
                <div class="row">
                    {% include 'snipplets/grid/filters-sidebar.tpl' %}
                    {% include 'snipplets/grid/products-list.tpl' %}
                </div>
            </div>
        </section>

        {% include 'snipplets/home/home-brand-routine-showcase.tpl' %}
        {% include 'snipplets/home/home-brand-shoppable-stories.tpl' %}
    </div>

    {% if is_vip_locked %}
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            var lockScreen = document.getElementById('vip-lock-screen');
            var vipContent = document.getElementById('vip-content');
            var form = document.getElementById('vip-form');
            var pwdInput = document.getElementById('vip-pwd');
            var errorMsg = document.getElementById('vip-error');
            
            var realPwd = "{{ settings.vip_category_password | trim | escape('js') }}";
            var savedPwd = localStorage.getItem('vip_pwd_{{ category.id }}');
            
            if (savedPwd === realPwd && realPwd !== '') {
                lockScreen.style.display = 'none';
                vipContent.style.display = 'block';
                setTimeout(function(){ vipContent.style.opacity = '1'; }, 50);
            }
            
            form.addEventListener('submit', function(e) {
                e.preventDefault();
                if (pwdInput.value === realPwd) {
                    localStorage.setItem('vip_pwd_{{ category.id }}', realPwd);
                    lockScreen.style.display = 'none';
                    vipContent.style.display = 'block';
                    setTimeout(function(){ vipContent.style.opacity = '1'; }, 50);
                    errorMsg.style.display = 'none';
                } else {
                    errorMsg.style.display = 'block';
                    pwdInput.value = '';
                }
            });
        });
    </script>
    {% endif %}

{% elseif show_help %}
	{# Category Placeholder #}
	{% include 'snipplets/defaults/show_help_category.tpl' %}
{% endif %}