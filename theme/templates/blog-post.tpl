<div class="container container-narrow">
    {% embed "snipplets/page-header.tpl" with { container: false, breadcrumbs: true, page_header_title_class: 'mb-0', page_header_title_class: 'h1 h4-huge-md'} %}
        {% block page_header_text %}{{ post.title }}{% endblock page_header_text %}
    {% endembed %}
    <div class="blog-post-page">
        {{ component(
            'blog/blog-post-content', {
                image_lazy: true,
                image_lazy_js: true,
                post_content_classes: {
                    date: 'mb-4 font-small',
                    image: 'img-fluid fade-in mb-3',
                    content: 'mb-2',
                },
            }) }}
    </div>
</div>
