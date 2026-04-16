{# Celda: video + overlay. Variables: cell_raw_url, cell_kicker, cell_title, cell_btn1, cell_btn1_url, cell_btn2, cell_btn2_url #}
{% include 'snipplets/brand/brand-video-block.tpl' with {
	block_raw_url: cell_raw_url,
	block_kicker: cell_kicker,
	block_title: cell_title,
	block_btn1: cell_btn1,
	block_btn1_url: cell_btn1_url,
	block_btn2: cell_btn2,
	block_btn2_url: cell_btn2_url,
	block_autoplay: settings.brand_split_video_autoplay,
	block_muted: settings.brand_split_video_muted,
	block_video_class: 'js-brand-split-video-file'
} %}
