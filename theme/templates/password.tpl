<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:fb="http://www.facebook.com/2008/fbml" xmlns:og="http://opengraphprotocol.org/schema/">
    <head>
        {% include 'snipplets/theme-color-scheme-head.tpl' %}
        <link rel="preconnect" href="{{ store_resource_hints }}" />
        <link rel="dns-prefetch" href="{{ store_resource_hints }}" />
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>{{ page_title }}</title>
        <meta name="description" content="{{ page_description }}" />
        <link rel="preload" as="style" href="{{ [settings.font_headings, settings.font_rest] | google_fonts_url('400,500,600,700') }}" />
        <link rel="preload" href="{{ 'css/style-critical.scss' | static_url }}" as="style" />
        <link rel="preload" href="{{ 'css/style-async.scss' | static_url }}" as="style" />
        <link rel="preload" href="{{ 'js/external-no-dependencies.js.tpl' | static_url }}" as="script" />
        
        {{ component('social-meta') }}

        {#/*============================================================================
            #CSS and fonts
        ==============================================================================*/#}

        {# Critical CSS needed to show first elements of store while CSS async is loading #}

        <style>
            {# Font families #}

            {{ component(
                'fonts',{
                    font_weights: '400,500,600,700',
                    font_settings: 'settings.font_headings, settings.font_rest'
                })
            }}

            {# General CSS Tokens #}

            {% include "static/css/style-tokens.tpl" %}
        </style>

        {# Critical CSS #}

        {{ 'css/style-critical.scss' | static_url | static_inline }}

        {# Estilos principales: bloqueante para evitar saltos de layout al cargar. #}

        <link rel="stylesheet" href="{{ 'css/style-async.scss' | static_url }}" />

        {# Loads custom CSS added from Advanced Settings on the admin´s theme customization screen #}

        <style>
            {{ settings.css_code | raw }}
        </style>

        {#/*============================================================================
            #Javascript: Needed before HTML loads
        ==============================================================================*/#}

        {# Defines if async JS will be used by using script_tag(true) #}

        {% set async_js = true %}

        {# Defines the usage of jquery loaded below, if nojquery = true is deleted it will fallback to jquery 1.5 #}

        {% set nojquery = true %}

        {# Jquery async by adding script_tag(true) #}

        {{ '//ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js' | script_tag(true) }}

        {# Loads private Tienda Nube JS #}

        {% head_content %}

        {# Structured data to provide information for Google about the page content #}

        {{ component('structured-data') }}

    </head>
    {# Misma clase de marca que layout.tpl (snipplets/theme-brand-body-class.tpl) #}
    <body class="{% include 'snipplets/theme-brand-body-class.tpl' %} body-password">

        {# Theme icons #}

        {% include "snipplets/svg/icons.tpl" %}

        {# Back to admin bar #}

        {{back_to_admin}}

        {# Page content #}

        <header class="head-main">
            <div class="container">
                <div class="row justify-content-md-center align-items-center">
                    <div class="col text-right py-2">
                        {% include 'snipplets/header/header-theme-toggle.tpl' %}
                    </div>
                </div>
                <div class="row justify-content-md-center">
                    <div class="col-md-8 text-center">
                        <div class="my-3">
                            {{ component('logos/logo', {
                                logo_size: 'large',
                                logo_img_classes: 'transition-soft', 
                                logo_text_classes: 'h3 m-0'}) 
                            }}
                        </div>
                    </div>
                </div>
            </div>
        </header>
        <div class="flex-grow-1 h-100 d-flex align-items-center">
            <div class="container py-4">
                <div class="row justify-content-center mb-2 mb-md-4">
                    <div class="col-md-4">
                        <h2 class="h3-huge mb-4">{{ message }}</h2>
                        {% embed "snipplets/forms/form.tpl" with{form_id: 'password-form', submit_text: 'Desbloquear' | translate, submit_custom_class: 'btn-block btn-big', form_custom_class: 'w-100' } %}
                            {% block form_body %}

                                {% embed "snipplets/forms/form-input.tpl" with{input_for: 'password', type_password: true, input_name: 'password', input_label_text: 'Contraseña de acceso' | translate, input_placeholder: 'ej.: tucontraseña' | translate } %}
                                    {% block input_form_alert %}
                                        {% if invalid_password == true %}
                                            <div class="alert alert-danger mt-3">{{ 'La contraseña es incorrecta.' | translate }}</div>
                                        {% endif %}
                                    {% endblock input_form_alert %}
                                {% endembed %}

                            {% endblock %}
                        {% endembed %}
                    </div>
                </div>
            </div>
        </div>


        {# Footer #}

        {% snipplet "footer/footer.tpl" %}

        {# Javascript needed to footer logos lazyload #}

        {{ 'js/external-no-dependencies.js.tpl' | static_url | script_tag }}

        {# Google survey JS for Tienda Nube Survey #}

        {{ component('google-survey') }}

    </body>
</html>
