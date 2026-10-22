if (array_length(global.templates) == 0) exit;
tpl_index = (tpl_index - 1 + array_length(global.templates)) % array_length(global.templates);
scr_tpl_viewer_show();