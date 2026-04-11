{% set form_class = search_modal ? 'w-100' %}
{% set search_suggestions_container_class = search_modal ? 'position-relative mt-5 w-100' %}

{{ component('search/search-form', {
    use_submit_text: true,
    use_delete_btn: false,
    form_classes: { 
        form: form_class,
        input_group: 'm-0', 
        input: input_class, 
        submit: submit_class,
        search_suggestions_container: search_suggestions_container_class 
    }
    }) 
}}