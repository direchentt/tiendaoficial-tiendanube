{% embed "snipplets/page-header.tpl" with { breadcrumbs: true } %}
    {% block page_header_text %}{{ "Blog" | translate }}{% endblock page_header_text %}
{% endembed %}
<div class="container mb-5">
    <section class="blog-page">
        <div class="row">
            {% for post in blog.posts %}
                <div class="col-md-4 mb-2">
                    {{ component(
                        'blog/blog-post-item', {
                            image_lazy: true,
                            image_lazy_js: true,
                            post_item_classes: {
                                item: 'item',
                                image: 'img-absolute img-absolute-centered fade-in pb-3',
                                information: 'item-description',
                                title: 'item-name mb-2 font-weight-bold',
                                summary: 'mb-3',
                                read_more: 'btn-link btn-link-primary',
                            },
                        })
                    }}
                </div>
            {% endfor %}
        </div>
    </section>
    {% include 'snipplets/grid/pagination.tpl' with {'pages': blog.pages} %}
</div>
